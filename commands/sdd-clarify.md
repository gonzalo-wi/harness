---
description: SDD · Reviews the spec as QA (only detects, doesn't solve)
argument-hint: <NNN-name>
arguments: [spec]
---
Path rule: `$spec` names a folder inside `specs/`. If it already starts with `specs/` (or is an absolute path), use it as is; never write `specs/specs/`.

Use the `reviewer` subagent to review `specs/$spec/spec.md` in clarification mode
(sdd skill). Pass it the paths of the spec and of `docs/constitution.md`.

Numbered list with:
1. Ambiguities (requirements that can't be verified).
2. Contradictions between requirements.
3. Uncovered edge cases.
4. Conflicts with `docs/constitution.md`.

Don't propose solutions yet: only detect.
