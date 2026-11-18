---
description: SDD · Validates a change FR by FR (plus audit lenses), then offers to archive it
argument-hint: "<NNN-name> [lens,lens...]"
arguments: [change, lenses]
---
Path rule: `$change` names a folder inside `changes/` (e.g. `004-cash-closing`). If it already starts with `changes/` (or is an absolute path), use it as is; never write `changes/changes/`. If it does not exist there but `specs/$change/spec.md` does, it is a legacy spec: follow the sdd skill's Legacy layout section.

Use the `reviewer` subagent in validation mode on `changes/$change/`.

Pass it the paths of the proposal, deltas, plan, tasks, the current specs of the affected
capabilities, `docs/constitution.md` and `CLAUDE.md`. It must: go through the ADDED and MODIFIED FRs
saying which test covers each one and its result, check the REMOVED ones are gone, check the diff
doesn't break the current specs it doesn't modify, run the project's test and lint commands,
review the diff, check the completion criteria and return a verdict. It DOESN'T fix anything.

Audit lenses: the ones I passed (`$lenses`, comma-separated) plus the ones
`docs/constitution.md` lists as required. For each lens, also run the `reviewer` in audit mode
with the lens file (project `.claude/audit-lenses/<lens>.md` first, else
`~/.claude/skills/audit/lenses/<lens>.md`), in parallel with the validation.

Show me one verdict per review (validation + each lens) and the combined verdict: CHANGES
REQUIRED if any of them requires changes, with the exact list.
If the combined verdict is APPROVED, ask me whether to archive it now (`/sdd-archive $change`).
