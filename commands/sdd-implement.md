---
description: SDD · Implements ONE task, tests first
argument-hint: <NNN-name> <Tn>
arguments: [spec, task]
---
Path rule: `$spec` names a folder inside `specs/`. If it already starts with `specs/` (or is an absolute path), use it as is; never write `specs/specs/`.

Use the `implementer` subagent to implement ONLY task $task of `specs/$spec/tasks.md`.

Pass it: the path of `specs/$spec/` (spec, plan, tasks), `docs/constitution.md`, `CLAUDE.md`,
the exact task and any relevant decision of mine from this conversation.

When it returns, show me: task and FRs covered, files changed, test/lint results and
decisions the plan didn't cover. Don't start the next task.
