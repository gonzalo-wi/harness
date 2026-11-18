---
name: audit
description: Focused review of code through one or more lenses (resilience, performance, observability, api, security, plus the project's own lenses in .claude/audit-lenses/). Only when the user runs /audit or asks for an audit with a named lens.
argument-hint: "<lens[,lens...]|all> [target]"
arguments: [lenses]
disable-model-invocation: true
---

# Audit

Request: $ARGUMENTS
Lenses requested: `$lenses` (the rest of the request is the target).

Lenses come from two places. Each file is the checklist and its rule IDs.
- **Global** (this skill): `${CLAUDE_SKILL_DIR}/lenses/<lens>.md`
  - `resilience`, `performance`, `observability`, `api`, `security`
- **Project**: `.claude/audit-lenses/<lens>.md` at the root of the current repo, for rules that
  only make sense in that project (its domain, its data model, its infrastructure). List that
  folder to see them.

If a project lens has the same name as a global one, the project one wins. `all` means every
global lens plus every project lens. If a lens name doesn't exist in either place, say so and
list the available ones; don't guess.

A new project lens follows the same structure as the global ones: Question, Applies to, Checks
with IDs (a prefix of its own, e.g. `TEN-1`), Stack notes if useful, and Evidence.

## Target
- Nothing after the lenses: the uncommitted changes (`git diff HEAD` plus untracked files).
- A path or folder: that code.
- A branch: `git diff <base>...<branch>`, where base is the default branch.
- A change folder (`changes/NNN-name`, or a legacy `specs/NNN-name`): the code that change touched, according to its plan.md.

## How to run it
1. Use the `reviewer` subagent ONCE PER LENS, in parallel. Pass each one: the lens file path,
   the target, the project's `CLAUDE.md` and `docs/constitution.md` if they exist, and the
   instruction "audit mode: review ONLY through this lens".
2. Merge the results: one block per lens with its verdict, then a combined verdict
   (CHANGES REQUIRED if any lens requires changes). Drop duplicates that two lenses reported.
3. Don't fix anything. At the end, offer: pass the blocking findings to the `implementer`
   (if there's a spec) or plan them with /feature.

## What audits are NOT
Correctness bugs are `/code-review`; reuse and simplification are `/simplify`. The `security`
lens is a focused checklist for the change at hand; for a broad security pass use Claude Code's
`/security-review` too. A lens only reports what is inside its own scope (e.g. secrets in logs
belongs to observability).
