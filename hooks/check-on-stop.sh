#!/usr/bin/env bash
# Stop hook: before Claude ends its turn, runs the project's fast check if the project defines one
# and there are uncommitted changes. If the check fails, exit 2 sends the output back to Claude so it
# fixes the problem instead of reporting the task as done.
#
# The project opts in by defining ONE of these (nothing defined = the hook does nothing):
#   - an executable `.claude/check-fast.sh` at the repo root
#   - a `check-fast` target in the root `Makefile`
# It must be fast (lint + typecheck + unit tests of what changed): it runs at the end of every turn
# that touched files.
#
# Opt out for a session: HARNESS_STOP_CHECK=0. Time limit: HARNESS_STOP_CHECK_TIMEOUT (seconds, default 300).

HOOK_INPUT="$(cat)"
. "$(dirname "$0")/_json.sh"

[ "${HARNESS_STOP_CHECK:-1}" = 0 ] && exit 0

fields="$(json_get cwd stop_hook_active)" || exit 0
nl=$'\n'
cwd="${fields%%"$nl"*}"
active="$(printf '%s' "${fields#*"$nl"}" | tr '[:upper:]' '[:lower:]')"

# Claude is already continuing because of this hook: don't loop. It gets one chance to fix it per turn.
[ "$active" = true ] && exit 0

[ -n "$cwd" ] && cd "$cwd" 2>/dev/null || exit 0
root="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
cd "$root" || exit 0

# Nothing changed in this repo: nothing to check (questions, plans, read-only work).
[ -z "$(git status --porcelain 2>/dev/null)" ] && exit 0

if [ -x .claude/check-fast.sh ]; then
  check=(./.claude/check-fast.sh)
elif [ -f Makefile ] && grep -Eq '^check-fast[[:space:]]*:' Makefile && command -v make >/dev/null 2>&1; then
  check=(make -s check-fast)
else
  exit 0
fi

limit="${HARNESS_STOP_CHECK_TIMEOUT:-300}"
if timeout --version >/dev/null 2>&1; then
  out="$(timeout "$limit" "${check[@]}" 2>&1)"; code=$?
else
  out="$("${check[@]}" 2>&1)"; code=$?
fi

[ $code -eq 0 ] && exit 0

if [ $code -eq 124 ]; then
  reason="it took longer than ${limit}s (make it faster or raise HARNESS_STOP_CHECK_TIMEOUT)"
else
  reason="it failed with exit code $code"
fi
{
  echo "The project's fast check (${check[*]}) ran because there are uncommitted changes, and $reason."
  echo "Fix the problem before reporting the task as done. If the failure is unrelated to your change, say so explicitly."
  echo "--- last lines of the output ---"
  printf '%s\n' "$out" | tail -n 60
} >&2
exit 2
