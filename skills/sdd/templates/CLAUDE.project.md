# <Project>
<One or two sentences: what it is, who it's for and what its goal is.>

## Stack and structure
- <Language, version, framework>.
- <What's in each important folder (only what isn't obvious)>.

## Architecture
- <The one the project already has: layered (controller → service → repository),
  feature-based, hexagonal...>. New code follows it.

## Commands
- Tests: `<go test ./... | mvn test | pnpm test | cargo test>`
- Lint: `<golangci-lint run | mvn spotless:check | pnpm lint | cargo clippy -- -D warnings>`
- Typecheck/build: `<go build ./... | mvn compile | pnpm tsc --noEmit | pnpm vue-tsc --noEmit | cargo build>`

## Domain rules / known pitfalls
- <What's easy to get wrong and can't be deduced from reading the code>.

## SDD
- `specs/<capability>/spec.md` = what the system does today; `changes/NNN-name/` = work in progress.
- Before touching code: read the active change (proposal, deltas, plan, tasks) and the specs of the
  capabilities it touches. A `/feature` that changes a requirement updates its spec in the same commit.
- Constitution: @docs/constitution.md

## Language exceptions
- <Only if needed: e.g. "Domain terms stay in Spanish in code, specs and docs: Envase, Comodato...".>

## Deploy
- <Where the deploy instructions live: `.claude/skills/deploy-*/`, `docs/runbooks/deploy.md`...>

## Memory
- Project memory: @MEMORY.md
- When a task is done, update it (max ~50 lines).
- If something becomes a permanent rule, propose moving it to this file.
