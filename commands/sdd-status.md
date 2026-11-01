---
description: SDD · Current phase and next step of a spec
argument-hint: "[NNN-name]"
arguments: [spec]
---
Path rule: `$spec` names a folder inside `specs/`. If it already starts with `specs/` (or is an absolute path), use it as is; never write `specs/specs/`.

Read `specs/$spec/` (spec.md, plan.md and tasks.md, whichever exist) and `MEMORY.md`.
If I didn't pass a folder, list all specs with their status.

Tell me in a few lines:
1. Which SDD phase it's in and its status.
2. Tasks done and pending (x of y).
3. The exact next step, with the /sdd-* command to run.

Don't modify any file.
