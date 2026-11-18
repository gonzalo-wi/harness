---
name: sdd
description: Spec-Driven Development with living specs. Use it whenever the project has docs/constitution.md, a specs/ or a changes/ folder, or when writing, reviewing or changing specs, change proposals, deltas, plans and tasks, or implementing, validating and archiving a change.
---

# Spec-Driven Development (SDD) with living specs

Two folders, two jobs:

- **`specs/<capability>/spec.md` = what the system does today.** One spec per capability
  (`specs/billing/`, `specs/sync/`, `specs/auth/`). It is always true for the code in the main
  branch: nothing in `specs/` that isn't implemented, nothing implemented that isn't in `specs/`.
- **`changes/NNN-name/` = what is changing.** Each feature or behavior change is a change folder
  with its proposal, its deltas against the specs, its plan and its tasks. When it's validated, its
  deltas are applied to `specs/` and the folder moves to `changes/archive/`.

This keeps one up-to-date spec per capability instead of the same behavior spread over many
numbered specs that drift and contradict each other.

```
specs/
  <capability>/spec.md
changes/
  NNN-name/
    proposal.md          why, what, affected capabilities, Status
    deltas/<capability>.md   ADDED / MODIFIED / REMOVED requirements
    plan.md
    tasks.md
  archive/
    YYYY-MM-DD-NNN-name/
```

## Flow
Constitution → Proposal + deltas → Clarification → Plan → Tasks → Implementation → Validation → Archive.

- Never move to the next phase without the user's explicit approval.
- The approved change rules: if it's not in the proposal or its deltas, it isn't implemented.
  If a decision is missing, stop and ask.
- A requirement change during a change goes to its deltas first, then to the plan and tasks, and
  to the code last.
- At the end of each phase, update `MEMORY.md` (state, decisions and why).
- Small changes outside SDD (`/feature`) that alter a requirement in `specs/` update that
  capability's `spec.md` in the same commit. The specs never fall behind the code.

## Language
Everything in English, except domain terms if the project's `CLAUDE.md` says they keep the
product's language. Keep these literal markers, other commands search for them:
`Status: draft | approved | implemented`, `[NEEDS CLARIFICATION]`, `Done when:`,
`VERDICT: APPROVED | CHANGES REQUIRED`, and the delta headings `## ADDED Requirements`,
`## MODIFIED Requirements`, `## REMOVED Requirements`.

## Project commands
This skill is language-agnostic. Test, lint and build commands come from the
**Commands** section of the project's `CLAUDE.md`. If they aren't defined, stop and ask.

## Templates
Next to this skill, in `templates/`: `spec.md` (capability), `proposal.md`, `delta.md`,
`constitution.md`, `CLAUDE.project.md`, `MEMORY.md`.

## Requirements (in specs and deltas)
- EARS, one behavior per requirement, each with a stable ID inside its capability:
  - FR-x: WHEN <event>, THE SYSTEM SHALL <response>.
  - FR-x: IF <unwanted condition>, THEN THE SYSTEM SHALL <response>.
  - FR-x: WHILE <state>, THE SYSTEM SHALL <response>.
  - FR-x: THE SYSTEM SHALL <permanent behavior>.
- Outside its own file, a requirement is named `<capability>/FR-x` (e.g. `billing/FR-3`).
- IDs are never reused: a removed FR keeps its number retired; a new one takes the next free number.
- Every FR is verifiable: no "fast" or "intense" without a measurable criterion.
- Only the WHAT and the WHY: no stack, architecture or file names.
- Open questions marked `[NEEDS CLARIFICATION]`. A change with open questions isn't planned.

## Proposal (proposal.md)
Why the change, what changes for the user, which capabilities it touches (one delta file per
capability, new capabilities included), user stories, out of scope, completion criteria, open
questions, and the `Status:` line.

## Deltas (deltas/<capability>.md)
Only what changes in that capability, under three headings (omit the empty ones):
- `## ADDED Requirements`: new FRs with the next free IDs of that capability.
- `## MODIFIED Requirements`: the FULL new text of each changed FR, same ID, plus one line
  `Was: <old text>` so the reviewer sees the difference.
- `## REMOVED Requirements`: the ID, its old text and why it goes.
Plus the edge cases the change adds. A delta for a capability that doesn't exist yet only has
`## ADDED Requirements` and a one-paragraph purpose for the new spec.

## Plan (plan.md)
- Files created or changed and the responsibility of each one.
- Where each thing lives according to the project's existing architecture (layers, features,
  or domain / ports / adapters if it's hexagonal).
- Pure logic with time and external dependencies injected.
- Algorithm in pseudocode when it isn't trivial.
- Technical decisions with the discarded alternative and why.
- Test strategy with the project's commands.
- Which FR (`capability/FR-x`) each part covers.

## Tasks (tasks.md)
```
- [ ] **Tn. <Description>.** billing/FR-4, sync/FR-2
  - Done when: <verifiable check>.
```
At most 20-30 min per task, in dependency order. If there are more than 10, propose splitting the change.

## Implementation
One task at a time: test first (red), then the code, tests green, lint and
typecheck clean, mark the task and stop.

## Validation
FR by FR of the deltas (ADDED and MODIFIED): which test covers it and its result. REMOVED FRs:
the behavior and its tests are gone. Also check that the change didn't break FRs of the current
`specs/` it touches. UI FRs that aren't tested automatically are verified by hand or with the
project's MCP. Final verdict: `VERDICT: APPROVED` or `VERDICT: CHANGES REQUIRED`.

## Archive
Only after an APPROVED validation and the user's OK:
1. Apply each delta to `specs/<capability>/spec.md`: add ADDED, replace MODIFIED (drop the
   `Was:` lines), delete REMOVED. Create the spec from `templates/spec.md` for a new capability.
2. Add the change to the capability's **History** line (`NNN-name`, date).
3. Set the proposal to `Status: implemented` and move the folder to
   `changes/archive/YYYY-MM-DD-NNN-name/`.
4. Update `MEMORY.md`. Archiving is one commit of its own (`docs: archive change NNN-name`).

## Numbering
`NNN` is the next free number across `changes/` and `changes/archive/`.

## Legacy layout
Older projects have `specs/NNN-name/` folders with `spec.md`, `plan.md` and `tasks.md`
(one numbered spec per feature, no `changes/`). While a project has them:
- A command given `NNN-name` that doesn't exist in `changes/` but exists as `specs/NNN-name/`
  works on that folder the old way: its `spec.md` plays the role of proposal + deltas.
- New work goes to `changes/` only if the project was migrated. Don't mix layouts: suggest
  `/sdd-migrate` once, and if the user declines, keep the old layout.
