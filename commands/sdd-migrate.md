---
description: SDD · Migrates a legacy project (specs/NNN-name) to living specs + changes/
argument-hint: "[capability hints]"
---
Migrate this project from the legacy layout (`specs/NNN-name/` with spec.md, plan.md, tasks.md) to
living specs (`specs/<capability>/spec.md`) plus `changes/` (sdd skill). Hints from me: $ARGUMENTS

DON'T touch code. Work in two steps and stop between them.

**Step 1 — capability map (no writes).** Read every legacy spec and `MEMORY.md`, and the code
where a spec is unclear about what actually shipped. Propose:
- The list of capabilities (few and stable: what the system does, not how features were delivered),
  each with a one-line purpose.
- For every legacy FR: the capability it goes to, its new ID, or "dropped" with the reason
  (superseded by a later spec, never implemented, removed later).
- Legacy specs that are NOT implemented yet (Status draft/approved): they become active changes in
  `changes/NNN-name/` with their spec split into proposal + deltas, keeping their number.
- Contradictions between specs, and FRs whose shipped behavior differs from the text: list them
  as questions for me. The living spec must describe what the code does today.
Wait for my approval of the map.

**Step 2 — write.** With the `planner` subagent:
1. Create each `specs/<capability>/spec.md` from the template, with the final FRs and a History that
   lists the legacy specs it came from.
2. Turn unfinished legacy specs into active changes.
3. `git mv` each implemented legacy folder to `changes/archive/YYYY-MM-DD-NNN-name/` (date of its
   last commit), keeping spec.md, plan.md and tasks.md as they were.
4. Update the project `CLAUDE.md` SDD section from the template and `MEMORY.md`.
Show me the new `specs/` tree and propose one commit: `docs: migrate SDD to living specs`.
