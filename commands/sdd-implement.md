---
description: SDD · Implements ONE task, tests first
argument-hint: <NNN-name> <Tn>
arguments: [change, task]
---
Path rule: `$change` names a folder inside `changes/` (e.g. `004-cash-closing`). If it already starts with `changes/` (or is an absolute path), use it as is; never write `changes/changes/`. If it does not exist there but `specs/$change/spec.md` does, it is a legacy spec: follow the sdd skill's Legacy layout section.

Use the `implementer` subagent to implement ONLY task $task of `changes/$change/tasks.md`.

Pass it: the path of `changes/$change/` (proposal, deltas, plan, tasks), `docs/constitution.md`, `CLAUDE.md`,
the exact task and any relevant decision of mine from this conversation.

When it returns, show me: task and FRs covered, files changed, test/lint results and
decisions the plan didn't cover. Don't start the next task.
