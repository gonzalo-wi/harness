#!/usr/bin/env bash
# Regression tests for check-on-stop.sh. Run: bash hooks/test-check-on-stop.sh
# Not a hook: install.sh skips files that start with "test-".

here="$(cd "$(dirname "$0")" && pwd)"
hook="$here/check-on-stop.sh"
fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

run() { # run <cwd> <stop_hook_active> -> exit code of the hook
  printf '{"hook_event_name":"Stop","cwd":"%s","stop_hook_active":%s}' "$1" "$2" | bash "$hook" 2>/dev/null
}

expect() { # expect <code> <description> <cwd> [active]
  local want="$1" desc="$2" dir="$3" active="${4:-false}" got
  run "$dir" "$active"; got=$?
  if [ "$got" != "$want" ]; then
    echo "FAIL want exit $want, got $got: $desc"
    fail=1
  fi
}

new_repo() { # new_repo <name> -> path of a git repo with one commit
  local d="$tmp/$1"
  mkdir -p "$d" && git -C "$d" init -q && git -C "$d" config user.email t@t && git -C "$d" config user.name t
  echo base > "$d/README.md" && git -C "$d" add . && git -C "$d" commit -qm init
  printf '%s' "$d"
}

# No repo: nothing to do.
mkdir -p "$tmp/plain"
expect 0 "not a git repo" "$tmp/plain"

# Repo without a check-fast definition: nothing to do, even with changes.
r="$(new_repo nocheck)"; echo x >> "$r/README.md"
expect 0 "no check-fast defined" "$r"

# Makefile target passing / failing, only when there are changes.
r="$(new_repo make-ok)"; printf 'check-fast:\n\t@true\n' > "$r/Makefile"; git -C "$r" add . && git -C "$r" commit -qm mk
expect 0 "clean tree: check not run" "$r"
echo x >> "$r/README.md"
expect 0 "make check-fast passes" "$r"

r="$(new_repo make-fail)"; printf 'check-fast:\n\t@echo boom; exit 1\n' > "$r/Makefile"; git -C "$r" add . && git -C "$r" commit -qm mk
expect 0 "clean tree with failing check: not run" "$r"
echo x >> "$r/README.md"
expect 2 "make check-fast fails with changes" "$r"
expect 0 "already continuing because of the hook: no loop" "$r" true
HARNESS_STOP_CHECK=0 expect 0 "opt-out env var" "$r"

# Runs from a subfolder, using the repo root.
mkdir -p "$r/apps/api"
expect 2 "cwd in a subfolder uses the repo root" "$r/apps/api"

# Script takes precedence over the Makefile.
r="$(new_repo script)"; mkdir -p "$r/.claude"
printf 'check-fast:\n\t@exit 1\n' > "$r/Makefile"
printf '#!/usr/bin/env bash\nexit 0\n' > "$r/.claude/check-fast.sh"; chmod +x "$r/.claude/check-fast.sh"
expect 0 ".claude/check-fast.sh wins over the Makefile" "$r"

# Timeout counts as a failure.
r="$(new_repo slow)"; printf 'check-fast:\n\t@sleep 5\n' > "$r/Makefile"
HARNESS_STOP_CHECK_TIMEOUT=1 expect 2 "timeout is reported as a failure" "$r"

[ $fail -eq 0 ] && echo "check-on-stop.sh: all tests passed"
exit $fail
