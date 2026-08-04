#!/bin/sh
# ============================================================
# n8n Entrypoint Script
# ============================================================
# Runs before n8n starts. Used for:
#   1. Waiting for PostgreSQL to be ready
#   2. Custom initialization
#   3. Startup logging
# ============================================================

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}  Executive Compliance & Operations Automation Hub${NC}"
echo -e "${BLUE}  n8n Container Starting...${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# Print environment info
echo -e "${GREEN}[INFO]${NC} Node version: $(node --version)"
echo -e "${GREEN}[INFO]${NC} n8n version:  $(n8n --version 2>/dev/null || echo 'unknown')"
echo -e "${GREEN}[INFO]${NC} Working dir:  $(pwd)"
echo -e "${GREEN}[INFO]${NC} User:         $(whoami)"
echo ""

# ============================================================
# Wait for PostgreSQL to be ready
# ============================================================
# This prevents n8n from crashing if it starts before Postgres.
# We use a simple loop with timeout.
# ============================================================

if [ -n "$DB_POSTGRESDB_HOST" ]; then
    echo -e "${YELLOW}[WAIT]${NC} Waiting for PostgreSQL at ${DB_POSTGRESDB_HOST}:${DB_POSTGRESDB_PORT:-5432}..."

    # Try to connect for up to 60 seconds
    COUNTER=0
    MAX_TRIES=30

    while [ $COUNTER -lt $MAX_TRIES ]; do
        if nc -z "$DB_POSTGRESDB_HOST" "${DB_POSTGRESDB_PORT:-5432}" 2>/dev/null; then
            echo -e "${GREEN}[OK]${NC}   PostgreSQL is ready!"
            break
        fi

        COUNTER=$((COUNTER + 1))
        echo -e "${YELLOW}[WAIT]${NC}   Attempt ${COUNTER}/${MAX_TRIES} — Postgres not ready yet..."
        sleep 2
    done

    if [ $COUNTER -eq $MAX_TRIES ]; then
        echo -e "${RED}[FAIL]${NC} Could not connect to PostgreSQL after ${MAX_TRIES} attempts."
        echo -e "${RED}[FAIL]${NC} n8n may fail to start. Check your database configuration."
    fi
    echo ""
fi

# ============================================================
# Print final startup message
# ============================================================
echo -e "${GREEN}[START]${NC} Launching n8n..."
echo -e "${GREEN}[START]${NC} Once running, access the UI at:"
echo -e "${GREEN}[START]${NC}   ${N8N_PROTOCOL:-http}://${N8N_HOST:-localhost}:${N8N_PORT:-5678}"
echo ""

# ============================================================
# Execute the original n8n command
# ============================================================
# 'exec' replaces this shell process with the n8n process.
# This is important for proper signal handling (Ctrl+C, docker stop, etc.)
# ============================================================
exec "$@"
