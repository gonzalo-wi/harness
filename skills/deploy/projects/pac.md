# PAC (treasury reconciliation)

Repos (local): backend `~/Documents/Proyectos/pac/pac` (gonzalo-wi/BackendPAC, never push to the
`hercules` remote), frontend `~/Documents/Proyectos/NewPacFront` (gonzalo-wi/FrontendPAC).

## Homologación (first deploy 2026-11-01, running `main` since 2026-11-02)
| Part | Server folder | Compose | Port | Container |
|---|---|---|---|---|
| Backend | `/opt/apps/pac/homologacion/backend` | `docker-compose.deploy.yml` | 8097 (host network) | `pac-api-homologacion` |
| Frontend | `/opt/apps/pac/homologacion/frontend` | `docker-compose.yml` | 8098 → 80 | `pac-front-homologacion` |

- URL: http://192.168.0.42:8098 (nginx proxies `/api` → `http://192.168.0.42:8097`,
  `/api/reparto-comprobantes` → `http://192.168.0.58`).
- Commands: backend `docker compose -f docker-compose.deploy.yml up -d --build`; frontend
  `docker compose up -d --build`.
- `.env` files (server only, user copies them):
  - backend ← `~/Documents/Proyectos/pac/pac/.env`: `DB_*` (Postgres 192.168.0.160, the same
    development database Loop uses), `URL_BASE_MINIBANK`, `URL_BASE_AGUAS`,
    `URL_BASE_AGUAS_COBRANZA`, `BANK_*`, `USERNAME_/PASSWORD_MINIBANK`, `RABBITMQ_*`
    (192.168.0.55:5673), `OPENAI_API_KEY` and `URL_BASE_COMPROBANTES=http://192.168.0.58` (receipt
    AI reading, spec 007; without them `POST /api/receipts/{id}/ai-reading` answers 503).
  - frontend: no secrets since spec 007 (the OpenAI key moved to the backend). Never put a secret
    in a `VITE_*` var: Vite bakes it into the bundle.
- Deploy files are in `main` of both repos: backend `docker-compose.deploy.yml` + `.dockerignore`,
  frontend `Dockerfile`, `deploy/nginx.conf.template`, `docker-compose.yml`. Deploy `origin/main`
  (`git archive origin/main`) unless the user asks to test unmerged branches; then merge them into a
  local throwaway `deploy/homologacion` branch and never push it.

## PAC-specific checks
- Receipt AI reading: `POST /api/receipts/999999999/ai-reading` through the front (:8098) must
  answer 404 "Comprobante no encontrado" (503 = key or receipts URL missing). A real id costs one
  OpenAI call; the bundle must not contain `api.openai.com`.
- The guard hook blocks any command that names `.env`, even `grep -c`: verify config by behavior.
- Backend runs in Argentine time (`PacTime.ZONE`); the API's `lastSuccessAt` must match local time.
- `GET /api/integrations/status` lists the 4 Minibank cashiers (and Aguas rows after a plant refresh).
- Schema changes run with Flyway on startup (spec 006): migrations in
  `src/main/resources/db/migration`, history table `public.pac_flyway_schema_history` in database
  `pac_db` (PostgreSQL 16, separate from Loop's database). Check the startup log for
  "Successfully validated" / "up to date" or the applied version; a failed migration stops startup.
- Only one PAC instance should write to the shared database at a time with a given code version;
  old local instances with another clock confuse the live status for a while.

## Producción
Not created yet. Mirror homologación under `/opt/apps/pac/produccion` with new free ports and its
own `.env`, after the user approves.
