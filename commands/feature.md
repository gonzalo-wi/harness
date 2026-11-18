---
description: Plans a small change before touching code (no full SDD flow)
argument-hint: <feature>
---
I want to add this feature: $ARGUMENTS

Before writing code, prepare a plan with:
1. How you'll implement it, respecting the project's `CLAUDE.md`, its existing architecture
   and the matching `stack-*` skill.
2. Which files you'll change and what changes in each one.
3. Edge cases and the open questions I have to decide.
4. Which tests you'll add.
5. If it changes behavior described in `specs/<capability>/spec.md`, the exact FR edits (same
   commit as the code). If it's too big for that (several capabilities, new rules of the
   business), say so and suggest `/sdd-run` instead.
6. What you'd update in `CLAUDE.md` and `MEMORY.md` (if they exist).

Don't modify any file until I approve the plan.
