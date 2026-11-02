
# Read-only smoke check after a deploy. Copy to the scratchpad, set the variables, then run:
#   (Get-Content -Raw smoke.sh) -replace "`r","" | ssh -o BatchMode=yes pac-server 'bash -s'
# The empty first line absorbs the BOM PowerShell adds.
API_CONTAINER=pac-api-homologacion
API_PORT=8097
API_PATH=/api/integrations/status
FRONT_URL=http://localhost:8098

sleep 40
echo "== containers"
docker ps --filter "name=${API_CONTAINER%-*}" --format '{{.Names}} {{.Status}} {{.Ports}}'
echo "== startup log"
docker logs "$API_CONTAINER" 2>&1 | grep -E "Started |ERROR|Exception|refused|HikariPool|Tomcat started" | cut -c1-220 | tail -20
echo "== api"
curl -s -m 20 "http://localhost:$API_PORT$API_PATH" | head -c 600; echo
echo "== front"
curl -s -o /dev/null -m 10 -w "index %{http_code}\n" "$FRONT_URL/"
curl -s -o /dev/null -m 20 -w "proxy /api %{http_code}\n" "$FRONT_URL$API_PATH"
echo "== time zone"
docker exec "$API_CONTAINER" date
