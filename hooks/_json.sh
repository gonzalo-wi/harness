#!/usr/bin/env bash
# Shared helper for hooks: json_get <path>... reads fields from $HOOK_INPUT (dotted paths)
# and prints them one per line, in order. Only the LAST field may contain newlines.
# Tries jq, then node, then python, so hooks work without jq (e.g. Windows) in one process.
# Returns 1 if no JSON parser is available, so callers can decide how to fail.

json_get() {
  if command -v jq >/dev/null 2>&1; then
    local filter="" p
    for p in "$@"; do filter="${filter:+$filter, }(.$p // \"\")"; done
    printf '%s' "$HOOK_INPUT" | jq -r "$filter"
  elif command -v node >/dev/null 2>&1; then
    printf '%s' "$HOOK_INPUT" | node -e '
      let s = "";
      process.stdin.on("data", d => (s += d)).on("end", () => {
        const root = JSON.parse(s);
        const out = process.argv.slice(1).map(p => {
          let v = root;
          for (const k of p.split(".")) v = v == null ? v : v[k];
          return v == null ? "" : String(v);
        });
        process.stdout.write(out.join("\n"));
      });' "$@"
  elif command -v python3 >/dev/null 2>&1 || command -v python >/dev/null 2>&1; then
    local py; py="$(command -v python3 || command -v python)"
    printf '%s' "$HOOK_INPUT" | "$py" -c '
import json, sys
root = json.load(sys.stdin)
out = []
for p in sys.argv[1:]:
    v = root
    for k in p.split("."):
        v = v.get(k) if isinstance(v, dict) else None
    out.append("" if v is None else str(v))
sys.stdout.write("\n".join(out))' "$@"
  else
    return 1
  fi
}
