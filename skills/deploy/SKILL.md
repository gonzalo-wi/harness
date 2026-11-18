---
name: deploy
description: Generic deploy rules for any project. Use it whenever the user asks to deploy, redeploy, release, roll back or check a deployed app. Server- and project-specific facts (hosts, ports, folders, pipelines, smoke checks) live in the project, not here.
---

# Deploy (generic rules)

This skill holds only the rules that apply to every project. Where and how a given project is
deployed lives in that project's repo, so it travels with the code and never leaks between
projects. Look for it in this order and read it before touching anything:

1. A project skill: `.claude/skills/deploy-*/SKILL.md`.
2. A runbook: `docs/runbooks/deploy.md` (and `rollback.md`).
3. The **Deploy** section of the project's `CLAUDE.md`.

If none exists, stop and ask. Offer to write `docs/runbooks/deploy.md` with the user before the
first deploy: target, environments, how a deploy is triggered, smoke checks and rollback.

## Golden rules
- **Lower environment first.** Staging / homologación before production, and production only after
  the user checked the lower one.
- **Production needs an explicit OK for that deploy.** A general "go ahead" earlier in the
  conversation does not count. If the project deploys production through CI with a protected
  environment, the approval happens there; never bypass it.
- **Only committed code.** Deploy a commit or a tag, never a dirty working tree. Say which branch
  and commit went out.
- **Prefer the pipeline.** If the project has a CI/CD workflow for deploys, trigger it instead of
  deploying by hand from this machine.
- **Secrets never go through the chat or the repo.** Never read, print or `cat` a `.env` or a
  secret store (the guard hook blocks it anyway). The user loads secrets in the platform's secret
  manager or copies the file themselves.
- **Shared infrastructure is not yours.** On a shared host or account, never stop, restart or edit
  another project's containers, apps, folders, ports or databases.
- **Ask before every change on a server** (create, copy, build, start, restart, delete). Read-only
  commands (status, logs, `ps`, health checks) need no approval.
- **Migrations:** backward compatible (expand/contract), so a rollback of the code never breaks the
  database. Never run migrations against production by hand unless the runbook says so and the user
  approves that run.

## Steps
1. Read the project's deploy instructions (above). Confirm with the user: environment, branch or
   commit, and anything the runbook marks as "check".
2. Gate locally on the commit to deploy (`/gate`).
3. Deploy the way the project says (pipeline, CLI, archive + compose...). Long builds run in the
   background; wait for them once.
4. Smoke check with the project's checks: the app is up, startup logs without errors, the
   dependencies (DB, broker, external APIs) are reachable, a health/status endpoint answers, the
   frontend and its API proxy answer, and times in API responses are in the expected zone.
5. Report: what went out (branch, commit, version), URLs, what was verified and what was not.

## Rollback
Follow the project's rollback runbook. If there is none: redeploy the previous good commit or
image the same way it was deployed, then smoke check again. Never "fix forward" in production
without the user's OK.

## Known traps
- A Dockerfile must COPY everything the build reads; keep `.env` in `.dockerignore`.
- Stacked PRs: if the base PR is merged first and the stacked PR is then merged into its old base,
  its commits never reach `main`. Check with `git merge-base --is-ancestor <commit> origin/main`
  before saying a change is deployed from main.
- Push everything before the user merges a PR: commits pushed after the merge stay out of main.
- Containers default to UTC: apps that show or compare local times must set their time zone.
- Filter long build logs with a script (`grep -E "ERROR|BUILD"`), not by reading them whole.
