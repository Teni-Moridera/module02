#!/bin/bash
# ============================================================
# РЕЗЕРВНОЕ КОПИРОВАНИЕ БД (PostgreSQL)
# ============================================================
BACKUP_DIR="$(dirname "$0")/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"

export PGPASSWORD="${PGPASSWORD:-your_password}"
pg_dump -U postgres -h localhost -F c -b -v -f "$BACKUP_DIR/practice6_$DATE.backup" practice6

echo "Backup saved to $BACKUP_DIR/practice6_$DATE.backup"
