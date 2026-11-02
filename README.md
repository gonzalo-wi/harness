# my-harness

My development standard for Claude Code: global rules, Spec-Driven Development flow,
subagents and per-stack skills (Go, Java/Spring, TS/React, React Native, Vue, Rust).

## Install
```bash
git clone <this-repo> ~/code/my-harness
cd ~/code/my-harness
./install.sh            # add --codex to use the same standard in Codex
```
Everything is installed into `~/.claude/`. If something with the same name already existed,
a `*.bak-<date>` backup is kept. `./install.sh --uninstall` removes what was installed and
the harness entries in `settings.json` (your own settings stay).

Requirements: `bash` (Git Bash on Windows) and `node` (hooks parse JSON with `jq`, `node` or
`python`, whichever is available; the settings merge uses `node`).

### Windows
- Symlinks need **Developer Mode** (Settings → For developers). With it, editing the repo
  applies instantly. Without it, `install.sh` installs **copies** and warns you: re-run
  `./install.sh` after every change in the repo.
- The repo forces LF line endings (`.gitattributes`): `.sh` files with CRLF break bash.
- The guard hook covers both `Bash` and `PowerShell` tools.

## What's inside
| Folder | Goes to | Purpose |
|---|---|---|
| `global/CLAUDE.md` | `~/.claude/CLAUDE.md` | Standard that applies to every project |
| `skills/sdd/` | `~/.claude/skills/sdd/` | SDD flow + templates (spec, constitution, CLAUDE.md, MEMORY.md) |
| `skills/stack-*/` | `~/.claude/skills/` | Per-language rules; loaded automatically by their description |
| `skills/deploy/` | `~/.claude/skills/deploy/` | Deploys to the shared Docker server (pac-server): access, ports, steps, one file per project (PAC, Loop) |
| `agents/` | `~/.claude/agents/` | `planner`, `implementer`, `reviewer` |
| `commands/` | `~/.claude/commands/` | `/sdd-*`, `/feature` |
| `hooks/` + `settings.harness.json` | `~/.claude/hooks/`, `settings.json` | Auto-format and the guard (below) |

### Hooks
- `guard.sh` (PreToolUse on `Bash|PowerShell|Read`) blocks: force-push / `+refspec` / remote deletes, `--no-verify` /
  `commit -n`, `reset --hard`, `clean -f`, `checkout`/`restore` over the whole tree,
  `branch -D`, `stash clear`, any other `--force`, recursive deletes of `/`, `~`, a drive or `.`,
  and reading or staging `.env*` (except `.env.example` and friends), keys and `secrets/`.
- `format.sh` (PostToolUse on edits): gofmt/goimports, rustfmt (with the crate's edition),
  and prettier when the project has it installed (searched upward, monorepo-friendly).
- Tests: `bash hooks/test-guard.sh`. Add a case there whenever you change `guard.sh`.

## Usage
**New or existing project I want to run with SDD**
1. `/sdd-init` → generates the project `CLAUDE.md` (real commands), `MEMORY.md`, `docs/`, `specs/`.
2. `/sdd-constitution` → the project's non-negotiable principles.

**Large feature (step by step)**
`/sdd-spec 001-name idea` → `/sdd-clarify 001-name` → approve (Status: approved) →
`/sdd-plan 001-name` → `/sdd-tasks 001-name` → `/sdd-implement 001-name T1` (one at a time) →
`/sdd-validate 001-name`. Requirement changes: `/sdd-change`. Where am I: `/sdd-status`.

**Large feature (coordinated)**
`/sdd-run I want to add X` → the main session coordinates the three subagents and stops at every approval.

**Small change**: `/feature X`. **Reviewing a diff**: "use the reviewer on my changes".

**Audits (focused reviews)**
`/audit <lens[,lens...]|all> [target]` runs one `reviewer` per lens, in parallel, read-only.
Lenses: `resilience`, `performance`, `observability`, `api` (in `skills/audit/lenses/`, each
rule with an ID like `RES-3`). Target: nothing = uncommitted changes, or a path, branch or
`specs/NNN-name`. Examples: `/audit resilience`, `/audit api,performance src/orders`.
- In SDD: `/sdd-validate 001-name resilience` adds lenses to the validation, and the
  constitution can list lenses that are always required.
- They don't replace Claude Code's built-ins: `/code-review` (bugs), `/simplify`
  (reuse/simplification), `/security-review` (security).
- New lens: add `skills/audit/lenses/<name>.md` with the same structure and list it in
  `skills/audit/SKILL.md`.

## Layers
- Global (this repo): how I always work.
- Project (repo `CLAUDE.md`): only the delta. Commands, domain pitfalls, constitution, specs.
  If it contradicts the global one, the project wins.
- Projects shared with the team: whatever everyone must follow is committed in the project
  repo, because this harness only lives on my machine.

## Memory
- `MEMORY.md` in the project repo: project state and decisions. Versioned, the team sees it,
  and the project `CLAUDE.md` imports it with `@MEMORY.md` so it is always loaded.
- Claude Code's automatic memory (`~/.claude/projects/...`): only my personal preferences.
  Project facts don't go there.

## Notes
- In Claude Code, subagents cannot call other subagents: that's why the coordinator is a
  command (`/sdd-run`) running in the main session, not an agent.
- Models: `implementer` uses sonnet (cheaper, bounded tasks); `planner` and `reviewer`
  inherit the session model. Change it in each agent's frontmatter.
- The `planner`'s write restriction (only `specs/`) is by instruction; tools can't be
  limited per folder.
