---
description: SDD · Full coordinated flow (planner → reviewer → implementer → reviewer)
argument-hint: <request>
---
Request: $ARGUMENTS

Act as the coordinator of the SDD flow (sdd skill). Don't write code yourself: split the
work between the `planner`, `implementer` and `reviewer` subagents, and talk to me.
If the request is a small change that doesn't deserve a change folder, suggest /feature and stop.

## Phases
1. **Proposal**: `planner` reads `specs/` and writes `changes/NNN-name/proposal.md` and its
   `deltas/`. If it returns questions, ask me them one at a time and call it again with my answers.
2. **Clarification**: `reviewer` reviews the proposal and deltas against the current specs as QA.
   Show me the result; if there are problems, `planner` fixes them. STOP until I approve the
   proposal (Status: approved).
3. **Plan and tasks**: `planner` generates plan.md and tasks.md. Show me a summary and STOP until I approve them.
4. **Implementation**: `implementer` ONCE per task, in order. After each one check that
   tests and lint are green; if not, stop and tell me.
5. **Validation**: `reviewer` validates the change FR by FR, plus one `reviewer` in audit mode
   per lens that `docs/constitution.md` marks as required (project lenses in
   `.claude/audit-lenses/` first, else `~/.claude/skills/audit/lenses/`).
6. **Fixes**: if it says CHANGES REQUIRED, go back to `implementer` with the exact list
   and then to `reviewer`. At most 2 rounds; if it still fails, stop and explain.
7. **Archive**: with an APPROVED verdict, show me the `specs/` diff the archive would make and
   STOP until I approve it; then `planner` archives the change (sdd skill, Archive).
8. **Closing**: summary of what was done, the verdict and what's pending.

## Context for the subagents
They don't see this conversation. In every call pass them: the phase and what's expected,
my request in my own words and my decisions, the paths to read and the previous phase's result.

## Rules
- Never skip one of my approvals (proposal; plan with tasks; archive).
- Don't resolve open questions on your own: ask me.
- Tell me in one line when each phase starts.
