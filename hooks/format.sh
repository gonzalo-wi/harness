#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit): formats the edited file by extension.
# Only uses tools that are installed and never blocks: if something fails, it moves on.

HOOK_INPUT="$(cat)"
. "$(dirname "$0")/_json.sh"

file="$(json_get tool_input.file_path)" || exit 0
[ -n "$file" ] && [ -f "$file" ] || exit 0

has() { command -v "$1" >/dev/null 2>&1; }

# find_up <name> <start-dir>: nearest ancestor path that contains <name> (monorepo-friendly).
find_up() {
  local dir="$2"
  while :; do
    [ -e "$dir/$1" ] && { printf '%s\n' "$dir/$1"; return 0; }
    [ "$dir" = "/" ] || [ "$dir" = "." ] || [ "$(dirname "$dir")" = "$dir" ] && return 1
    dir="$(dirname "$dir")"
  done
}

dir="$(cd "$(dirname "$file")" && pwd)"

case "$file" in
  *.go)
    if has goimports; then goimports -w "$file"; elif has gofmt; then gofmt -w "$file"; fi
    ;;
  *.rs)
    if has rustfmt; then
      # Use the crate's edition; a hardcoded one misformats crates on other editions.
      edition=2021
      if cargo_toml="$(find_up Cargo.toml "$dir")"; then
        found="$(sed -n 's/^edition[[:space:]]*=[[:space:]]*"\([0-9]*\)".*/\1/p' "$cargo_toml" | head -n1)"
        [ -n "$found" ] && edition="$found"
      fi
      rustfmt --edition "$edition" "$file" 2>/dev/null
    fi
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.vue|*.json|*.css|*.scss|*.html|*.yml|*.yaml|*.md)
    # Only if the project has prettier installed locally (respects its config).
    if prettier="$(find_up node_modules/.bin/prettier "$dir")"; then
      "$prettier" --write --log-level silent "$file" 2>/dev/null
    fi
    ;;
  *.java)
    # Java is formatted by the build plugin (Spotless); running it per file is too slow.
    ;;
esac

exit 0
