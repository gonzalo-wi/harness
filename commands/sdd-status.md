---
description: SDD · Active changes, their phase and the next step
argument-hint: "[NNN-name]"
arguments: [change]
---
Path rule: `$change` names a folder inside `changes/` (e.g. `004-cash-closing`). If it already starts with `changes/` (or is an absolute path), use it as is; never write `changes/changes/`. If it does not exist there but `specs/$change/spec.md` does, it is a legacy spec: follow the sdd skill's Legacy layout section.

Without a folder: list the active changes in `changes/` (not `archive/`) with their Status, tasks
done (x of y) and next step; then the capabilities in `specs/` with their number of FRs and the last
change in their History. If there are legacy `specs/NNN-*` folders, list them apart.

With a folder: read `changes/$change/` (proposal, deltas, plan.md, tasks.md, whichever exist) and
`MEMORY.md`, and tell me in a few lines:
1. Which SDD phase it's in and its status.
2. Tasks done and pending (x of y).
3. The exact next step, with the /sdd-* command to run.

Don't modify any file.
