#!/usr/bin/env bash
# Installs the harness into ~/.claude.
#
#   ./install.sh              install (symlinks; copies if the OS does not allow symlinks)
#   ./install.sh --copy       force copies instead of symlinks
#   ./install.sh --codex      also install the standard as ~/.codex/AGENTS.md
#   ./install.sh --uninstall  remove everything this script installed and its settings entries
#
# With symlinks, editing the repo applies instantly. With copies, re-run ./install.sh after editing.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
MANIFEST="$CLAUDE_DIR/.my-harness-manifest"
STAMP="$(date +%Y%m%d%H%M%S)"
WITH_CODEX=0
UNINSTALL=0
MODE=link

for arg in "$@"; do
  case "$arg" in
    --codex) WITH_CODEX=1 ;;
    --copy) MODE=copy ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

merge_settings() { # merge_settings [--remove]
  local settings="$CLAUDE_DIR/settings.json"
  if ! command -v node >/dev/null 2>&1; then
    echo "  ! node is not installed: merge settings.harness.json into $settings by hand"
    return
  fi
  mkdir -p "$CLAUDE_DIR"
  [ -f "$settings" ] && cp "$settings" "$settings.bak-$STAMP"
  node "$REPO/scripts/merge-settings.js" "$settings" "$REPO/settings.harness.json" "$@"
  echo "  ~ $settings updated${1:+ ($1)} (backup: $settings.bak-$STAMP)"
}

remove_installed() { # removes every path listed in the manifest (only things we installed)
  [ -f "$MANIFEST" ] || return 0
  while IFS= read -r p; do
    [ -n "$p" ] && { [ -L "$p" ] || [ -e "$p" ]; } && rm -rf "$p" && echo "  - $p"
  done < "$MANIFEST"
}

if [ "$UNINSTALL" -eq 1 ]; then
  echo "Uninstalling harness from $CLAUDE_DIR"
  remove_installed
  # Legacy installs without a manifest: symlinks that point into this repo.
  # `|| true`: find exits 1 when ~/.codex doesn't exist, which under pipefail aborted the uninstall
  # before the settings cleanup.
  { find "$CLAUDE_DIR" "$HOME/.codex" -maxdepth 2 -type l 2>/dev/null || true; } | while read -r l; do
    case "$(readlink "$l")" in "$REPO"/*) rm "$l"; echo "  - $l" ;; esac
  done
  rm -f "$MANIFEST"
  merge_settings --remove
  echo "Done."
  exit 0
fi

# Git Bash on Windows silently copies on `ln -s` unless told to create native symlinks,
# which need Developer Mode (or admin). Probe once and fall back to copies if not allowed.
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) export MSYS=winsymlinks:nativestrict ;;
esac
if [ "$MODE" = link ]; then
  probe="$(mktemp -d)"
  if ! ln -s "$REPO/README.md" "$probe/link" 2>/dev/null || [ ! -L "$probe/link" ]; then
    MODE=copy
    echo "! This system does not allow symlinks (on Windows: enable Developer Mode)."
    echo "  Installing COPIES: re-run ./install.sh after editing the repo."
  fi
  rm -rf "$probe"
fi

echo "Installing harness from $REPO into $CLAUDE_DIR ($MODE mode)"

# Remove what a previous install put there (also cleans files renamed or deleted in the repo).
OLD_MANIFEST="$(mktemp)"
[ -f "$MANIFEST" ] && cp "$MANIFEST" "$OLD_MANIFEST"
NEW_MANIFEST="$(mktemp)"

install_one() { # install_one <src> <dst>
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if grep -Fxq "$dst" "$OLD_MANIFEST" || { [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; }; then
    rm -rf "$dst"
  elif [ -L "$dst" ] || [ -e "$dst" ]; then
    mv "$dst" "$dst.bak-$STAMP"
    echo "  ! backup: $dst.bak-$STAMP"
  fi
  if [ "$MODE" = link ]; then ln -s "$src" "$dst"; else cp -R "$src" "$dst"; fi
  echo "$dst" >> "$NEW_MANIFEST"
  echo "  + $dst"
}

echo "Global standard:"
install_one "$REPO/global/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

echo "Commands:"
for f in "$REPO"/commands/*.md; do install_one "$f" "$CLAUDE_DIR/commands/$(basename "$f")"; done

echo "Agents:"
for f in "$REPO"/agents/*.md; do install_one "$f" "$CLAUDE_DIR/agents/$(basename "$f")"; done

echo "Skills:"
for d in "$REPO"/skills/*/; do d="${d%/}"; install_one "$d" "$CLAUDE_DIR/skills/$(basename "$d")"; done

echo "Hooks:"
for f in "$REPO"/hooks/*.sh; do
  case "$(basename "$f")" in test-*) continue ;; esac
  install_one "$f" "$CLAUDE_DIR/hooks/$(basename "$f")"
done

if [ "$WITH_CODEX" -eq 1 ]; then
  echo "Codex:"
  install_one "$REPO/global/CLAUDE.md" "$HOME/.codex/AGENTS.md"
fi

# Anything installed last time that no longer exists in the repo.
while IFS= read -r p; do
  if [ -n "$p" ] && ! grep -Fxq "$p" "$NEW_MANIFEST" && { [ -L "$p" ] || [ -e "$p" ]; }; then
    rm -rf "$p"
    echo "  - stale: $p"
  fi
done < "$OLD_MANIFEST"
mv "$NEW_MANIFEST" "$MANIFEST"
rm -f "$OLD_MANIFEST"

echo "Settings:"
merge_settings

echo
echo "Done. Open Claude Code and try: /sdd-status  (or /agents to see planner, implementer and reviewer)"
