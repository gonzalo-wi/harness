---
description: SDD · New requirement - spec first, code later
argument-hint: <NNN-name> <requirement>
arguments: [spec]
---
New requirement for `specs/$spec/` (the first word is the folder, the rest is the requirement): $ARGUMENTS

DON'T touch code. Use the sdd skill.
1. Update `specs/$spec/spec.md`: new FR (or a change to an existing one) in EARS, its edge
   cases and what stays out of scope.
2. Say which parts of `plan.md` and `tasks.md` would need to change afterwards.
3. Show me the spec diff and wait for my approval.
