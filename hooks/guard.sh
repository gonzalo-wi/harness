#!/usr/bin/env bash
# PreToolUse hook (Bash|PowerShell|Read): blocks what the global standard forbids.
# Exit 2 = block; the reason goes back to Claude on stderr.
#
# Shell commands are split into segments (;, &&, ||, |, newlines) and each segment is checked
# by its actual program and subcommand, so `grep "git push" notes.md` is not a false positive.

HOOK_INPUT="$(cat)"
. "$(dirname "$0")/_json.sh"

block() {
  echo "Blocked by the global standard: $1. If it is really needed, ask the user to do it by hand." >&2
  exit 2
}

# .env files and keys. Example/template files are allowed so setup docs stay readable.
is_secret_path() {
  local p="${1//\\//}" base
  base="$(printf '%s' "${p##*/}" | tr '[:upper:]' '[:lower:]')"
  case "$base" in
    .env.example|.env.sample|.env.template|.env.dist|.env.defaults) return 1 ;;
    .env|.env.*|*.pem|*.key|*.p12|*.pfx) return 0 ;;
    id_rsa|id_ecdsa|id_ed25519) return 0 ;;
  esac
  case "$p" in */secrets/*|secrets/*) return 0 ;; esac
  return 1
}

# Targets that make a recursive delete catastrophic (root, drive, home, cwd, glob-all).
is_wide_delete_target() {
  local t; t="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  printf '%s' "$t" | grep -Eq '^(/|/\*|~|~/|~/\*|\$home|\$home/|\$home/\*|\$\{home\}/?|\$env:userprofile[/\\]?\*?|/[a-z]/?|/[a-z]/users/?|[a-z]:[/\\]?\*?|\.|\./|\.\.|\.\./|\*)$'
}

check_git() { # $@ = words after "git"
  local i=0 sub args=() w
  local words=("$@")
  # Skip global options; some of them take a separate value.
  while [ $i -lt ${#words[@]} ] && [[ "${words[$i]}" == -* ]]; do
    case "${words[$i]}" in -C|-c|--git-dir|--work-tree|--namespace) i=$((i + 1)) ;; esac
    i=$((i + 1))
  done
  sub="${words[$i]}"
  args=("${words[@]:$((i + 1))}")

  local has_force=0 has_short_f=0 has_short_n=0 has_dry=0 wide=0 staged=0 worktree=0
  for w in "${args[@]}"; do
    case "$w" in
      --no-verify) block "skipping hooks (--no-verify)" ;;
      --force|--force-*) has_force=1 ;;
      --dry-run) has_dry=1 ;;
      --staged|-S) staged=1 ;;
      --worktree|-W) worktree=1 ;;
      .|./|:/|'*') wide=1 ;;
    esac
    if [[ "$w" =~ ^-[a-zA-Z]+$ ]]; then
      [[ "$w" == *f* ]] && has_short_f=1
      [[ "$w" == *n* ]] && has_short_n=1
    fi
  done

  case "$sub" in
    push) block "git push is done by the user" ;;
    commit | merge | rebase | cherry-pick | am)
      [ "$sub" = commit ] && [ $has_short_n -eq 1 ] && block "skipping hooks (git commit -n)" ;;
    reset)
      for w in "${args[@]}"; do [ "$w" = --hard ] && block "git reset --hard can lose work"; done ;;
    clean)
      if [ $has_dry -eq 0 ] && [ $has_short_n -eq 0 ] && { [ $has_force -eq 1 ] || [ $has_short_f -eq 1 ]; }; then
        block "git clean -f deletes untracked files"
      fi ;;
    checkout)
      { [ $has_force -eq 1 ] || [ $has_short_f -eq 1 ] || [ $wide -eq 1 ]; } &&
        block "git checkout that discards working-tree changes" ;;
    restore)
      if [ $wide -eq 1 ] && { [ $staged -eq 0 ] || [ $worktree -eq 1 ]; }; then
        block "git restore over the whole tree discards changes"
      fi ;;
    switch)
      for w in "${args[@]}"; do
        case "$w" in --discard-changes) block "git switch --discard-changes" ;; esac
      done
      { [ $has_force -eq 1 ] || [ $has_short_f -eq 1 ]; } && block "forced git switch" ;;
    branch)
      for w in "${args[@]}"; do [ "$w" = -D ] && block "git branch -D deletes unmerged work"; done
      { [ $has_force -eq 1 ] || [ $has_short_f -eq 1 ]; } && block "forced git branch" ;;
    stash)
      [ "${args[0]}" = clear ] && block "git stash clear loses every stash" ;;
    add)
      for w in "${args[@]}"; do is_secret_path "$w" && block "staging a secrets file ($w)"; done ;;
    rm | mv | fetch) ;; # -f here does not rewrite history or drop work
    *)
      [ $has_force -eq 1 ] && block "forced git operation" ;;
  esac
}

check_segment() {
  local seg="$1" words=() prog w
  read -r -a words <<< "$seg"
  [ ${#words[@]} -eq 0 ] && return
  # Strip quotes so '"--force"' and '".env"' are seen as what they are.
  for i in "${!words[@]}"; do w="${words[$i]//\"/}"; words[$i]="${w//\'/}"; done

  # Skip wrappers: env assignments, sudo, PowerShell call operator, subshell parens.
  while [ ${#words[@]} -gt 0 ]; do
    case "${words[0]}" in
      sudo|command|exec|'&'|'('|'{'|*=*) words=("${words[@]:1}") ;;
      '('*) words[0]="${words[0]#(}" ;;
      *) break ;;
    esac
  done
  [ ${#words[@]} -eq 0 ] && return
  prog="$(printf '%s' "${words[0]##*/}" | tr '[:upper:]' '[:lower:]')"
  prog="${prog%.exe}"

  case "$prog" in
    git) check_git "${words[@]:1}" ;;
    rm|remove-item|ri|del|erase|rd|rmdir)
      local recursive=0
      for w in "${words[@]:1}"; do
        if [[ "$w" =~ ^-[a-zA-Z]{1,3}$ && "$w" == *[rR]* ]] || [[ "${w,,}" == --recursive || "${w,,}" == -recurse ]]; then
          recursive=1
        fi
      done
      if [ $recursive -eq 1 ]; then
        for w in "${words[@]:1}"; do
          [[ "$w" == -* ]] && continue
          is_wide_delete_target "$w" && block "recursive delete of '$w'"
        done
      fi ;;
  esac

  # Reading or staging secrets through the shell (the Read tool is covered separately).
  case "$prog" in
    cat|type|gc|get-content|less|more|head|tail|bat|grep|rg|sed|awk|base64|xxd|strings|sls|select-string)
      for w in "${words[@]:1}"; do
        is_secret_path "$w" && block "reading or staging a secrets file ($w)"
      done ;;
  esac
}

fields="$(json_get tool_name tool_input.file_path tool_input.command)" || {
  # No JSON parser at all: fall back to a coarse scan of the raw input.
  case "$HOOK_INPUT" in
    *"git push"*) block "git push is done by the user" ;;
    *"--no-verify"*) block "skipping hooks (--no-verify)" ;;
    *"reset --hard"*) block "git reset --hard can lose work" ;;
  esac
  exit 0
}
nl=$'\n'
tool="${fields%%"$nl"*}"; rest="${fields#*"$nl"}"
file="${rest%%"$nl"*}"; cmd="${rest#*"$nl"}"

case "$tool" in
  Read)
    [ -n "$file" ] && is_secret_path "$file" && block "reading a secrets file ($file)"
    ;;
  Bash|PowerShell)
    while IFS= read -r seg; do
      check_segment "$seg"
    done < <(printf '%s\n' "$cmd" | sed -E 's/(\&\&|\|\||;|\|)/\n/g')
    ;;
esac

exit 0
