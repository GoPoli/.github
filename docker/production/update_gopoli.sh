#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

COMPOSE_URL="${GOPOLI_COMPOSE_URL:-https://raw.githubusercontent.com/GoPoli/.github/main/docker/production/docker-compose.yml}"
PROJECT="${GOPOLI_PROJECT:-gopoli}"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "Descargando la versión publicada del docker-compose..."
curl -fsSL "$COMPOSE_URL" -o "$tmp"
docker compose -f "$tmp" --project-directory . config --quiet
install -m 644 "$tmp" docker-compose.yml

echo "Descargando imágenes..."
docker compose -p "$PROJECT" pull

echo "Aplicando cambios..."
docker compose -p "$PROJECT" up -d --remove-orphans

echo "Esperando a que los servicios estén saludables..."
for service in gopoli-api gopoli-web; do
    for _ in $(seq 1 60); do
        status="$(docker inspect -f '{{.State.Health.Status}}' "$service" 2>/dev/null || echo ausente)"
        [ "$status" = "healthy" ] && break
        sleep 3
    done
    echo "  $service: $status"
    [ "$status" = "healthy" ] || { docker logs --tail 50 "$service"; exit 1; }
done

docker image prune -f >/dev/null
echo "GoPoli actualizado."
