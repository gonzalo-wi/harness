---
description: SDD · Splits the plan into small, verifiable tasks
argument-hint: <NNN-name>
arguments: [spec]
---
Path rule: `$spec` names a folder inside `specs/`. If it already starts with `specs/` (or is an absolute path), use it as is; never write `specs/specs/`.

From `specs/$spec/spec.md` and `specs/$spec/plan.md`, generate `specs/$spec/tasks.md` with the
sdd skill's format:
- Small tasks (max 20-30 min), in dependency order.
- Each with the FRs it covers and a verifiable "Done when:" line.
- Checkboxes.
- If there are more than 10, propose splitting the spec.
