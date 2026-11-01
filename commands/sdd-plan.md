---
description: SDD · Generates the technical plan of an approved spec
argument-hint: <NNN-name>
arguments: [spec]
---
Path rule: `$spec` names a folder inside `specs/`. If it already starts with `specs/` (or is an absolute path), use it as is; never write `specs/specs/`.

Read `docs/constitution.md`, `CLAUDE.md` and `specs/$spec/spec.md`. Use the sdd skill. DON'T write code.

If the spec isn't in "Status: approved" or has `[NEEDS CLARIFICATION]`, stop and tell me.

Generate `specs/$spec/plan.md` with: files created or changed and their
responsibility, location according to the project's existing architecture, pure logic with
time and dependencies injected, the algorithm in pseudocode if it isn't trivial, technical
decisions with the discarded alternative, and a test strategy with the commands from
`CLAUDE.md`. Mark which FR each part covers.
Load the `stack-*` skill for the language.
