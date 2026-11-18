---
description: SDD · Interviews me and generates a change proposal with its deltas
argument-hint: <NNN-name> <initial idea>
arguments: [change]
---
Path rule: `$change` names a folder inside `changes/` (e.g. `004-cash-closing`). If it already starts with `changes/` (or is an absolute path), use it as is; never write `changes/changes/`. If it does not exist there but `specs/$change/spec.md` does, it is a legacy spec: follow the sdd skill's Legacy layout section.

DON'T write code. Read `docs/constitution.md`, `MEMORY.md` and the current `specs/`, and use the sdd skill.

Change folder: `changes/$change/` (if `$change` has no NNN number, use the next free one across
`changes/` and `changes/archive/`).
Full request (the first word is the folder, the rest is the idea): $ARGUMENTS

Your job:
1. Ask me questions ONE at a time to remove ambiguity (edge cases, errors, what stays out
   of this version). At most 5 questions.
2. Tell me which capabilities in `specs/` it touches (and any new one, with why) before writing.
3. With my answers, use the `planner` subagent to write `changes/NNN-name/proposal.md` ("Status: draft")
   and one `deltas/<capability>.md` per capability, from the sdd templates. Pass it my answers in my words.
4. Only the WHAT and the WHY: no stack, architecture or file names.
