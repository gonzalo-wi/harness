---
name: sdd
description: Spec-Driven Development. Use it whenever the project has docs/constitution.md or a specs/ folder, or when writing, reviewing or changing specs, plans and tasks, or implementing and validating tasks of a spec.
---

# Spec-Driven Development (SDD)

## Flow
Constitution → Spec → Clarification → Plan → Tasks → Implementation → Validation → Change.

- Never move to the next phase without the user's explicit approval.
- The spec rules: if it's not in the spec, it isn't implemented. If a decision is missing, stop and ask.
- A requirement change goes to the spec first, then to the plan and tasks, and to the code last.
- Each spec lives in `specs/NNN-name/` with `spec.md`, `plan.md` and `tasks.md`.
- At the end of each phase, update `MEMORY.md` (state, decisions and why).
- Spec-anchored mode: the spec stays alive and is updated when the code evolves.

## Language
Specs, plans, tasks and `MEMORY.md` are written in English. Keep these literal markers,
other commands search for them: `Status: draft | approved | implemented`,
`[NEEDS CLARIFICATION]`, `Done when:`, `VERDICT: APPROVED | CHANGES REQUIRED`.

## Project commands
This skill is language-agnostic. Test, lint and build commands come from the
**Commands** section of the project's `CLAUDE.md`. If they aren't defined, stop and ask.

## Templates
They live next to this skill, in `templates/`:
- `templates/spec.md`, `templates/constitution.md`, `templates/CLAUDE.project.md`, `templates/MEMORY.md`.

## Spec rules
- Describes the WHAT and the WHY. No stack, architecture or file names.
- Functional requirements in EARS:
  - FR-x: WHEN <event>, THE SYSTEM SHALL <response>.
  - FR-x: IF <unwanted condition>, THEN THE SYSTEM SHALL <response>.
  - FR-x: WHILE <state>, THE SYSTEM SHALL <response>.
  - FR-x: THE SYSTEM SHALL <permanent behavior>.
- Every FR is verifiable: no "fast" or "intense" without a measurable criterion.
- Open questions marked `[NEEDS CLARIFICATION]`. A spec with open questions isn't planned.

## Plan (plan.md)
- Files created or changed and the responsibility of each one.
- Where each thing lives according to the project's existing architecture (layers, features,
  or domain / ports / adapters if it's hexagonal).
- Pure logic with time and external dependencies injected.
- Algorithm in pseudocode when it isn't trivial.
- Technical decisions with the discarded alternative and why.
- Test strategy with the project's commands.
- Which FR each part covers.

## Tasks (tasks.md)
```
- [ ] **Tn. <Description>.** FR-x, FR-y
  - Done when: <verifiable check>.
```
At most 20-30 min per task, in dependency order. If there are more than 10, propose splitting the spec.

## Implementation
One task at a time: test first (red), then the code, tests green, lint and
typecheck clean, mark the task and stop.

## Validation
FR by FR: which test covers it and its result. UI FRs that aren't tested automatically
are verified by hand or with the project's MCP. Final verdict:
`VERDICT: APPROVED` or `VERDICT: CHANGES REQUIRED`.
