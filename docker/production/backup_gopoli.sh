#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

RETENTION_DAYS="${GOPOLI_BACKUP_DAYS:-14}"
umask 077
mkdir -p backups
file="backups/gopoli-$(date +%Y%m%d-%H%M%S).dump"

echo "Creando respaldo de la base de datos..."
docker exec gopoli-db sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -F c' > "$file.partial"
mv "$file.partial" "$file"
find backups -name 'gopoli-*.dump' -mtime +"$RETENTION_DAYS" -delete

echo "Respaldo creado: $file ($(du -h "$file" | cut -f1))"
