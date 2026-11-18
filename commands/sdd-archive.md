---
description: SDD · Applies a validated change's deltas to the living specs and archives it
argument-hint: <NNN-name>
arguments: [change]
---
Path rule: `$change` names a folder inside `changes/` (e.g. `004-cash-closing`). If it already starts with `changes/` (or is an absolute path), use it as is; never write `changes/changes/`. If it does not exist there but `specs/$change/spec.md` does, it is a legacy spec: follow the sdd skill's Legacy layout section.

Archive `changes/$change/` following the sdd skill's Archive section.

1. Check it can be archived: the proposal is "Status: approved", every task in `tasks.md` is done,
   and the last `/sdd-validate` in this conversation (or the one I tell you) was APPROVED. If not,
   stop and say what's missing.
2. Use the `planner` subagent to apply each delta to `specs/<capability>/spec.md`, add the History
   entries, set "Status: implemented" and `git mv` the folder to `changes/archive/YYYY-MM-DD-$change/`.
3. Show me the diff of `specs/` (that's the part worth reading) and the new archive path.
4. Propose the commit `docs: archive change $change`; commit only when I say so.
