---
description: Quality gate - runs tests, typecheck and lint of the current LOOP repo and reports a short verdict
argument-hint: "[backend|front|app|all]"
---
Run the quality gate for: $ARGUMENTS (empty = the repo of the current working directory).

Repos (all under `C:\Users\gwinazki.ELJUMILLANO\Desktop`):
- **backend** `new-loop-api`: the Maven project is nested. Run `./mvnw test` from `new-loop-api/new-loop-api`
  (Git Bash). If JUnit reports "ClassSelector ... resolution failed", rerun once with `./mvnw clean test`.
  Postgres-backed tests are skipped without `LOOP_TEST_DB_URL`; report how many were skipped.
- **front** `new-loop-front`: `npx tsc --noEmit`. `npm run lint` is known broken (ESLint 9 without config):
  don't run it, list it as "lint: N/A (known issue)".
- **app** `react-nati`: `npx tsc --noEmit` and `npx jest`. Lint has the same known ESLint 9 issue.
- **all**: the three, backend in the background while the others run.

Rules:
- Only run checks. Don't edit files, don't fix anything, don't commit.
- Run long commands in the background and wait for them once.

Reply in Spanish with one line per check: ✅/❌, the command, and the counts (tests passed/failed/skipped,
TS errors). For each failure, the first relevant error lines (file:line + message), at most 10 per check.
End with one verdict line: **GATE VERDE** or **GATE ROJO**, and nothing else.
