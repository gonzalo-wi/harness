---
description: SDD · Generates the technical plan of an approved change
argument-hint: <NNN-name>
arguments: [change]
---
Path rule: `$change` names a folder inside `changes/` (e.g. `004-cash-closing`). If it already starts with `changes/` (or is an absolute path), use it as is; never write `changes/changes/`. If it does not exist there but `specs/$change/spec.md` does, it is a legacy spec: follow the sdd skill's Legacy layout section.

Read `docs/constitution.md`, `CLAUDE.md`, `changes/$change/proposal.md`, its `deltas/` and the current
specs of the affected capabilities. Use the sdd skill. DON'T write code.

If the proposal isn't in "Status: approved" or has `[NEEDS CLARIFICATION]`, stop and tell me.

Use the `planner` subagent to generate `changes/$change/plan.md` with: files created or changed and their
responsibility, location according to the project's existing architecture, pure logic with
time and dependencies injected, the algorithm in pseudocode if it isn't trivial, technical
decisions with the discarded alternative, and a test strategy with the commands from
`CLAUDE.md`. Mark which `capability/FR-x` each part covers.
Load the `stack-*` skill for the language.
