---
description: SDD · Prepares a project for SDD (CLAUDE.md, MEMORY.md, docs/, specs/, changes/)
---
Prepare this project to work with SDD. Use the sdd skill.

1. Read the code, the README and `CLAUDE.md` if it exists. Detect the stack, the existing
   architecture/conventions and the real test, lint and build commands (Makefile,
   package.json, pom.xml, Cargo.toml, go.mod...).
2. If there's no `CLAUDE.md`, propose one from `~/.claude/skills/sdd/templates/CLAUDE.project.md`
   with the real commands. If it exists, propose only the sections it's missing (Commands,
   Architecture, SDD, Memory). At most 40 lines.
3. If it doesn't exist, create `MEMORY.md` from `~/.claude/skills/sdd/templates/MEMORY.md`.
4. Create `docs/`, `specs/` and `changes/archive/` if they don't exist (with a `.gitkeep` where empty).
5. If the project already has legacy `specs/NNN-*` folders, don't touch them: mention `/sdd-migrate`.

Show me the proposed `CLAUDE.md` and wait for my approval before writing it.
The constitution comes afterwards with /sdd-constitution.
