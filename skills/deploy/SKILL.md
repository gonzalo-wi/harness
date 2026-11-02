---
name: deploy
description: Deploy PAC or Loop (backend or frontend) to the shared company Docker server (pac-server, 192.168.0.42) for homologación or producción. Use it whenever the user asks to deploy, redeploy, update a server, check a deployed app, pick ports or folders on the server, or set up SSH access to it.
---

# Deploy to the shared Docker server

One Debian 12 host (`lamp`, 192.168.0.42) runs every app in Docker. Each project has a file in
`projects/` with its folders, ports, compose files and smoke checks: read it before touching the
server. If the project has no file yet, build one from the survey below and add it in a PR.

## Golden rules
- The server is shared (Loop, Airflow, zk, marquee, Portainer). Never stop, restart or edit another
  project's containers, folders or ports.
- Ask the user before every change on the server (create folder, copy, build, start, restart,
  delete). Read-only commands need no approval. Producción needs an explicit OK for that deploy.
- Secrets never go through the chat: the user copies each `.env` with `scp` from their PC. Never
  read, print or `cat` a `.env` (the guard hook blocks it anyway). After copying: `chmod 600`.
- Homologación first, producción only after the user checked homologación.
- Deploy only committed code (`git archive HEAD`), never a dirty working tree. Say which branch and
  commit went to the server.

## Access
- SSH alias `pac-server` in `~/.ssh/config` (user `gwinazki`, key `~/.ssh/pac_server`, no passphrase).
  Check: `ssh -o BatchMode=yes pac-server hostname` → `lamp`.
- Run ssh/scp from the **PowerShell** tool. The Bash tool is sandboxed and its ssh times out.
- If access is missing, guide the user (they type their password only in their own terminal):
  1. `ssh-keygen -t ed25519 -f $env:USERPROFILE\.ssh\pac_server -C "pac-deploy" -N '""'`
  2. `type $env:USERPROFILE\.ssh\pac_server.pub | ssh USER@192.168.0.42 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`
  3. Add the `Host pac-server` block to `~/.ssh/config` (you may write it: it holds no secret).
  A passphrase on the key blocks you (no agent): regenerate it without one.
- PowerShell mangles `|`, `"`, `$`, `{{ }}` inside `ssh '...'` one-liners. For anything beyond a
  simple command, write a script to the scratchpad and run
  `(Get-Content -Raw script.sh) -replace "`r","" | ssh -o BatchMode=yes pac-server 'bash -s'`.
  Start the script with an empty line: PowerShell prepends a BOM that breaks the first line.

## Server facts
- Apps live in `/opt/apps/<project>/<homologacion|produccion>/<backend|frontend>`; group
  `desarrolladores` (setgid), the user can create folders and use Docker without sudo.
- Docker 29 + Compose v5 (`docker compose`, not `docker-compose`). No Java/Node on the host: build
  inside images.
- Backends use `network_mode: host` so they reach the LAN like the host does (Postgres
  192.168.0.160:5432, RabbitMQ 192.168.0.55:5673, Aguas 192.168.0.58, PIMS); with host network the
  app listens straight on its server port (`SERVER_PORT`). Frontends publish `PORT:80` with nginx.
- Containers default to UTC: Java apps must run in `America/Argentina/Buenos_Aires` (TZ env +
  app config). Check with `docker exec <container> date` and with the times the API returns.

## Pick a free port
Busy ports come from two sources: `ss -tln` (includes host-network containers, which do not show in
`docker ps`) and `docker ps --format '{{.Names}} -> {{.Ports}}'`. Also check stopped containers
(`docker ps -a`) that would take a port back when restarted. Known busy (2026-11-01): 22 25 80 443
3000 3306 8080 8081 8082 8090 8095 8097 8098 8787 9090 9443 12321 12322.

## Deploy steps
1. Read `projects/<project>.md`. Confirm with the user: project, environment, branch/commit.
2. Gate locally (the project's test/lint/build commands) on the commit to deploy.
3. `git -C <repo> archive --format=tar -o <scratchpad>/<name>.tar HEAD`, then
   `scp` it to `/tmp/` and `tar -xf` it into the target folder. Extracting over the folder keeps the
   server-only `.env`. Pipes through PowerShell corrupt binary data: always go through a file.
4. First deploy only: the user copies the `.env` (`scp <local .env> pac-server:<folder>/.env`),
   then `chmod 600 <folder>/.env`.
5. `docker compose [-f <file>] up -d --build`. The first build can take minutes: run it in the
   background and wait for the notification.
6. Smoke check (`scripts/smoke-template.sh`, adapt names and ports): container up, startup log
   without errors, DB/broker connected, health or status endpoint, frontend `/` and `/api` proxy
   answer 200, container time zone and the times in API answers are local.
7. Report: what was deployed (branch, commit), URLs, what was verified and what was not.

## Known traps
- A Dockerfile must COPY everything the build reads (e.g. Checkstyle `config/` in PAC).
- The build context ships the whole folder: keep `.env` in `.dockerignore`.
- Old rows written with another zone/clock can look "in the future" to newest-wins logic.
- Build logs: filter with a script (`--progress=plain 2>&1 | grep -E "ERROR|BUILD"`), not inline.
