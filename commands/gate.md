---
description: Quality gate - runs the project's tests, typecheck and lint and reports a short verdict
argument-hint: "[part of the project, e.g. api|mobile|panel|all]"
---
Run the quality gate for: $ARGUMENTS (empty = the whole project of the current working directory).

Where the commands come from, in this order:
1. The **Commands** section of the project's `CLAUDE.md` (and of the sub-project's `CLAUDE.md`
   when I name a part of a monorepo). If it defines a gate command (e.g. `make check`), use only that.
2. Otherwise, a `check` target in the `Makefile` or a `check` script in `package.json`.
3. Otherwise, the tests, typecheck and lint commands listed there, one by one.
If nothing is defined, stop and say which commands are missing. Don't guess them.

Known issues: if `CLAUDE.md` marks a check as known broken, don't run it and report it as
`N/A (known issue)`.

Rules:
- Only run checks. Don't edit files, don't fix anything, don't commit.
- Run long commands in the background and wait for them once; independent parts in parallel.

Reply in Spanish with one line per check: ✅/❌, the command, and the counts (tests passed/failed/skipped,
type errors, lint errors). For each failure, the first relevant error lines (file:line + message),
at most 10 per check. End with one verdict line: **GATE VERDE** or **GATE ROJO**, and nothing else.
