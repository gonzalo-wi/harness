---
description: SDD · Requirement change - deltas first, code later
argument-hint: <NNN-name> <requirement>
arguments: [change]
---
Path rule: `$change` names a folder inside `changes/` (e.g. `004-cash-closing`). If it already starts with `changes/` (or is an absolute path), use it as is; never write `changes/changes/`. If it does not exist there but `specs/$change/spec.md` does, it is a legacy spec: follow the sdd skill's Legacy layout section.

Requirement change: $ARGUMENTS (the first word is the change folder, the rest is the requirement).

DON'T touch code. Use the sdd skill.
- If `changes/$change/` is in progress (not archived): use the `planner` subagent to update its
  deltas (and the proposal if the scope moves): new or changed FRs in EARS, their edge cases and
  what stays out of scope. Then say which parts of `plan.md` and `tasks.md` would need to change.
- If that change is already archived, or I name a capability instead of a change: behavior that is
  live changes through a NEW change. Propose its name and continue as `/sdd-spec` would.

Show me the diff and wait for my approval.
