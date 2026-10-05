# Development standard — Gonza

These rules apply to all my projects. The project's `CLAUDE.md` complements them and,
if it contradicts something here, the project wins.

## How to work
- Understand before touching: read the project's `CLAUDE.md`, `MEMORY.md` if present, and the affected code.
- Large tasks, refactors or design changes: plan first, code only after my approval.
- Small, focused changes. Don't rewrite what works or add things I didn't ask for.
- If a decision is missing, stop and ask. Don't invent requirements.
- If the project has `specs/`, follow the `sdd` skill: the spec rules.
- When done: a short summary of what changed, how you verified it, and what you decided on your own.

## Architecture
- Existing projects: respect the architecture they already have (layered, feature-based, etc.).
  Don't migrate it to another one unless I ask.
- New backends: hexagonal (ports & adapters). The domain doesn't import infrastructure
  (HTTP, DB, queues, SDKs). Dependencies point toward the domain.
- In any architecture: business logic testable without I/O; time ("now") and randomness are injected.
- Frontend: logic outside components (hooks, composables or pure modules); components render.

## Quality
- Tests are the gate: nothing is done with red tests, a broken typecheck or lint errors.
- New logic or bug fix: first the failing test, then the code.
- Explicit errors: never swallow an error silently; add context when propagating it.
- No secrets in code, logs or commits. Credentials come from environment variables.

## Boundaries
- ✅ Always: run the project's test/lint commands from `CLAUDE.md` before closing a task.
- ⚠️ Ask first: new dependencies, schema or persisted-data format changes,
  public API changes, deleting files.
- 🚫 Never: `git push`, `--force`, skipping hooks (`--no-verify`), disabling or deleting tests to make them pass.

## Language and style
- Code, names, commits and code comments in English.
- Talk to me in Spanish (rioplatense). Everything written to files is in English: code, docs,
  specs, plans, `MEMORY.md`, `CLAUDE.md`.
- User-facing UI text: in the product's language (usually Spanish); never mix languages on one screen.
- Commits: Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `chore:`), one per logical change.
- Comments only to explain the why, not the what.

## Stacks
Go, Java/Spring, TypeScript/React, React Native, Vue and Rust. Each stack's rules live in the
`stack-*` skills: load them when you touch files in that language.
