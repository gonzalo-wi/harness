---
description: SDD · Validates the spec FR by FR (plus audit lenses)
argument-hint: "<NNN-name> [lens,lens...]"
arguments: [spec, lenses]
---
Path rule: `$spec` names a folder inside `specs/`. If it already starts with `specs/` (or is an absolute path), use it as is; never write `specs/specs/`.

Use the `reviewer` subagent in validation mode on `specs/$spec/`.

Pass it the paths of spec, plan, tasks, `docs/constitution.md` and `CLAUDE.md`. It must:
go through the spec FR by FR saying which test covers it and its result, run the project's
test and lint commands, review the diff, check the completion criteria and return a
verdict. It DOESN'T fix anything.

Audit lenses: the ones I passed (`$lenses`, comma-separated) plus the ones
`docs/constitution.md` lists as required. For each lens, also run the `reviewer` in audit mode
with `~/.claude/skills/audit/lenses/<lens>.md`, in parallel with the validation.

Show me one verdict per review (validation + each lens) and the combined verdict: CHANGES
REQUIRED if any of them requires changes, with the exact list.
