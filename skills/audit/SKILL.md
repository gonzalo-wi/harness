---
name: audit
description: Focused review of code through one or more lenses (resilience, performance, observability, api). Only when the user runs /audit or asks for an audit with a named lens.
argument-hint: "<lens[,lens...]|all> [target]"
arguments: [lenses]
disable-model-invocation: true
---

# Audit

Request: $ARGUMENTS
Lenses requested: `$lenses` (the rest of the request is the target).

Available lenses (each file is the checklist and its rule IDs):
- `resilience` → `${CLAUDE_SKILL_DIR}/lenses/resilience.md`
- `performance` → `${CLAUDE_SKILL_DIR}/lenses/performance.md`
- `observability` → `${CLAUDE_SKILL_DIR}/lenses/observability.md`
- `api` → `${CLAUDE_SKILL_DIR}/lenses/api.md`

`all` means the four. If a lens name doesn't exist, say so and list the available ones; don't guess.

## Target
- Nothing after the lenses: the uncommitted changes (`git diff HEAD` plus untracked files).
- A path or folder: that code.
- A branch: `git diff <base>...<branch>`, where base is the default branch.
- A spec folder (`specs/NNN-name`): the code that spec touched, according to its plan.md.

## How to run it
1. Use the `reviewer` subagent ONCE PER LENS, in parallel. Pass each one: the lens file path,
   the target, the project's `CLAUDE.md` and `docs/constitution.md` if they exist, and the
   instruction "audit mode: review ONLY through this lens".
2. Merge the results: one block per lens with its verdict, then a combined verdict
   (CHANGES REQUIRED if any lens requires changes). Drop duplicates that two lenses reported.
3. Don't fix anything. At the end, offer: pass the blocking findings to the `implementer`
   (if there's a spec) or plan them with /feature.

## What audits are NOT
Correctness bugs are `/code-review`; reuse and simplification are `/simplify`; security is
`/security-review`. A lens only reports those when they are inside its own scope (e.g. secrets
in logs belongs to observability).
