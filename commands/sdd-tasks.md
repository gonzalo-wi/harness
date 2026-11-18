---
description: SDD · Splits the plan into small, verifiable tasks
argument-hint: <NNN-name>
arguments: [change]
---
Path rule: `$change` names a folder inside `changes/` (e.g. `004-cash-closing`). If it already starts with `changes/` (or is an absolute path), use it as is; never write `changes/changes/`. If it does not exist there but `specs/$change/spec.md` does, it is a legacy spec: follow the sdd skill's Legacy layout section.

From `changes/$change/` (proposal, deltas and plan.md), generate `changes/$change/tasks.md` with the
sdd skill's format:
- Small tasks (max 20-30 min), in dependency order.
- Each with the FRs it covers (`capability/FR-x`) and a verifiable "Done when:" line.
- Checkboxes.
- If there are more than 10, propose splitting the change.
