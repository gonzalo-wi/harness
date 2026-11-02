# PAC (treasury reconciliation)

Repos (local): backend `~/Documents/Proyectos/pac/pac` (gonzalo-wi/BackendPAC, never push to the
`hercules` remote), frontend `~/Documents/Proyectos/NewPacFront` (gonzalo-wi/FrontendPAC).

## Homologación (first deploy 2026-11-01)
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
    (192.168.0.55:5673).
  - frontend ← `~/Documents/Proyectos/NewPacFront/.env`: `VITE_OPENAI_API_KEY` (baked into the
    bundle and visible in the browser; accepted for homologación, FrontendPAC#6).
- The deploy files live in branches `chore/deploy-homologacion` (backend) and `chore/docker-deploy`
  (frontend) until merged.

## PAC-specific checks
- Backend runs in Argentine time (`PacTime.ZONE`); the API's `lastSuccessAt` must match local time.
- `GET /api/integrations/status` lists the 4 Minibank cashiers (and Aguas rows after a plant refresh).
- Schema changes have no Flyway yet (BackendPAC#15): the SQL in the spec's plan is run by hand on
  the database **before** deploying the backend.
- Only one PAC instance should write to the shared database at a time with a given code version;
  old local instances with another clock confuse the live status for a while.

## Producción
Not created yet. Mirror homologación under `/opt/apps/pac/produccion` with new free ports and its
own `.env`, after the user approves.
