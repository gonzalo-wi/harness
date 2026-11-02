# Loop (delivery driver app)

Surveyed read-only on 2026-11-01; confirm with the user before relying on anything marked "check".

## Homologación
| Part | Server folder | Compose | Port | Container |
|---|---|---|---|---|
| Backend | `/opt/apps/loop/homologacion/backend/new_loop_backend/new-loop-api` | `docker-compose.yml` | 8095 (host network, `SERVER_PORT=${PORT:-8096}`; the server `.env` sets 8095, check) | `loop-api-app` |
| Frontend | `/opt/apps/loop/homologacion/frontend/new_loop_frontend` | `docker-compose.yml` | 8080 → 80 | `new_loop_frontend-web-1` |

- The backend compose also runs `loop-api-prometheus` (9090) and `loop-api-grafana` (3000), all
  host network. `prometheus-config` is a one-shot init container.
- APK storage persists in `/opt/apps/loop/homologacion/app/apk-storage` (mounted volume): never
  delete it.
- Database: Postgres on 192.168.0.160 (the same development database PAC uses); Flyway migrates on
  startup.
- The frontend folder is a git clone (has `.git`); the backend folder is a copy (no `.git`).
  Check with the user how they update each one before choosing pull vs archive.
- The frontend reads `BACKEND_URL` at runtime (nginx) and `VITE_GOOGLE_MAPS_API_KEY` at build time.
- The backend's own `DEPLOY.md` on the server is partly outdated (it still says port mapping
  8096:8080, the compose now uses host network).

## Loop-specific checks
- `docker ps` shows `loop-api-app` up; `ss -tln` shows its port listening.
- The frontend container reported `unhealthy` on 2026-11-01 while serving: check its healthcheck
  before assuming a deploy broke it.

## Producción
`/opt/apps/loop/produccion/` exists with empty subfolders (2026-11-01). Nothing deployed there yet.
