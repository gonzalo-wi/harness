---
description: SDD · Reviews a change proposal and its deltas as QA (only detects, doesn't solve)
argument-hint: <NNN-name>
arguments: [change]
---
Path rule: `$change` names a folder inside `changes/` (e.g. `004-cash-closing`). If it already starts with `changes/` (or is an absolute path), use it as is; never write `changes/changes/`. If it does not exist there but `specs/$change/spec.md` does, it is a legacy spec: follow the sdd skill's Legacy layout section.

Use the `reviewer` subagent to review `changes/$change/` (proposal.md and deltas/) in clarification
mode (sdd skill). Pass it the paths of the change, of the current `specs/<capability>/spec.md` of each
affected capability and of `docs/constitution.md`.

Numbered list with:
1. Ambiguities (requirements that can't be verified).
2. Contradictions, inside the change or against the current specs.
3. Uncovered edge cases.
4. Conflicts with `docs/constitution.md`.
5. Delta mistakes (wrong or reused IDs, `Was:` text that doesn't match the spec, wrong capability).

Don't propose solutions yet: only detect.
