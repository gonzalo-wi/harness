---
description: SDD · Interviews me and generates the spec
argument-hint: <NNN-name> <initial idea>
arguments: [spec]
---
DON'T write code. Read `docs/constitution.md` and `MEMORY.md`, and use the sdd skill.

Spec folder: `specs/$spec/` (if `$spec` has no NNN number, use the next free one in `specs/`).
Full request (the first word is the folder, the rest is the idea): $ARGUMENTS

Your job:
1. Ask me questions ONE at a time to remove ambiguity (edge cases, errors, what stays out
   of this version). At most 5 questions.
2. With my answers, generate `specs/NNN-name/spec.md` from `~/.claude/skills/sdd/templates/spec.md`,
   requirements in EARS and "Status: draft".
3. Only the WHAT and the WHY: no stack, architecture or file names.
