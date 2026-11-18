# my-harness

My development standard for Claude Code: global rules, Spec-Driven Development flow with living
specs, subagents, per-stack skills (Go, Java/Spring, TS/React, React Native, Vue, Rust), audit
lenses and safety hooks.

Generic on purpose: nothing here names a company, a server or a project. Anything specific to a
project (deploy targets, its own skills, lenses and gate commands) lives in that project's repo.

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
| `skills/sdd/` | `~/.claude/skills/sdd/` | SDD flow with living specs + templates (spec, proposal, delta, constitution, CLAUDE.md, MEMORY.md) |
| `skills/stack-*/` | `~/.claude/skills/` | Per-language rules; loaded automatically by their description |
| `skills/audit/` | `~/.claude/skills/audit/` | `/audit` with global lenses; projects add their own in `.claude/audit-lenses/` |
| `skills/deploy/` | `~/.claude/skills/deploy/` | Generic deploy rules; the where and how of each project live in its repo |
| `agents/` | `~/.claude/agents/` | `planner`, `implementer`, `reviewer` |
| `commands/` | `~/.claude/commands/` | `/sdd-*`, `/feature`, `/gate` |
| `hooks/` + `settings.harness.json` | `~/.claude/hooks/`, `settings.json` | Auto-format and the guard (below) |

### Hooks
- `guard.sh` (PreToolUse on `Bash|PowerShell|Read`) blocks: force-push / `+refspec` / remote deletes, `--no-verify` /
  `commit -n`, `reset --hard`, `clean -f`, `checkout`/`restore` over the whole tree,
  `branch -D`, `stash clear`, any other `--force`, recursive deletes of `/`, `~`, a drive or `.`,
  and reading or staging `.env*` (except `.env.example` and friends), keys and `secrets/`.
- `format.sh` (PostToolUse on edits): gofmt/goimports, rustfmt (with the crate's edition),
  and prettier when the project has it installed (searched upward, monorepo-friendly).
- `check-on-stop.sh` (Stop): when Claude is about to end a turn with uncommitted changes, runs the
  project's fast check and sends failures back so Claude fixes them before saying "done". Opt-in
  per project: an executable `.claude/check-fast.sh` or a `check-fast` target in the root
  `Makefile`; without either it does nothing. It only retries once per turn (no loops).
  `HARNESS_STOP_CHECK=0` turns it off; `HARNESS_STOP_CHECK_TIMEOUT` (default 300 s) limits it.
- Tests: `bash hooks/test-guard.sh` and `bash hooks/test-check-on-stop.sh`. Add a case whenever
  you change a hook.

## Usage
**New or existing project I want to run with SDD**
1. `/sdd-init` → generates the project `CLAUDE.md` (real commands), `MEMORY.md`, `docs/`,
   `specs/`, `changes/`.
2. `/sdd-constitution` → the project's non-negotiable principles.

**How specs work: living specs + changes**
- `specs/<capability>/spec.md` says what the system does **today**, one spec per capability.
- `changes/NNN-name/` is work in progress: `proposal.md`, `deltas/<capability>.md` (ADDED /
  MODIFIED / REMOVED requirements), `plan.md`, `tasks.md`.
- When a change is validated, `/sdd-archive` applies its deltas to `specs/` and moves it to
  `changes/archive/`. So each capability has one current spec instead of many numbered specs
  that drift apart.
- Legacy projects (`specs/NNN-name/`) keep working as before; `/sdd-migrate` converts them.

**Large feature (step by step)**
`/sdd-spec 001-name idea` → `/sdd-clarify 001-name` → approve (Status: approved) →
`/sdd-plan 001-name` → `/sdd-tasks 001-name` → `/sdd-implement 001-name T1` (one at a time) →
`/sdd-validate 001-name` → `/sdd-archive 001-name`. Requirement changes: `/sdd-change`.
Where am I: `/sdd-status`.

**Large feature (coordinated)**
`/sdd-run I want to add X` → the main session coordinates the three subagents and stops at every approval.

**Small change**: `/feature X` (if it changes a requirement, it updates that capability's spec in
the same commit). **Reviewing a diff**: "use the reviewer on my changes".
**Quality gate**: `/gate [part]` runs the checks the project's `CLAUDE.md` defines and answers
GATE VERDE / GATE ROJO.

**Audits (focused reviews)**
`/audit <lens[,lens...]|all> [target]` runs one `reviewer` per lens, in parallel, read-only.
Global lenses: `resilience`, `performance`, `observability`, `api`, `security` (in
`skills/audit/lenses/`, each rule with an ID like `RES-3`). Project lenses: `.claude/audit-lenses/`
in the project repo (a project lens with the same name wins). Target: nothing = uncommitted
changes, or a path, branch or `changes/NNN-name`. Examples: `/audit resilience`,
`/audit api,performance src/orders`.
- In SDD: `/sdd-validate 001-name resilience` adds lenses to the validation, and the
  constitution can list lenses that are always required.
- They don't replace Claude Code's built-ins: `/code-review` (bugs), `/simplify`
  (reuse/simplification), `/security-review` (broad security pass).
- New global lens: add `skills/audit/lenses/<name>.md` with the same structure and list it in
  `skills/audit/SKILL.md`. A lens about one project's domain goes in that project instead.

**Deploys**
The `deploy` skill only has the generic rules (lower environment first, explicit OK for
production, only committed code, secrets never through the chat). Each project says where and how
it deploys in its own repo: `.claude/skills/deploy-<project>/`, `docs/runbooks/deploy.md` or a
Deploy section in its `CLAUDE.md`.

## Layers
- Global (this repo): how I always work.
- Project (repo `CLAUDE.md` + `.claude/`): only the delta. Commands, domain pitfalls,
  constitution, specs, its own skills, lenses, deploy and a `check-fast` for the Stop hook.
  If it contradicts the global one, the project wins.
- Rule of thumb: if it would make sense in any project, even in another business, it goes here.
  If it names the project's domain, infrastructure, commands or people, it goes in the project.
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
- The `planner`'s write restriction (only `specs/` and `changes/`) is by instruction; tools
  can't be limited per folder.
- Cloud sessions and the GitHub Action don't have this harness unless their setup installs it
  (`git clone` + `./install.sh --copy`). Whatever must always hold in a project goes in its repo.
