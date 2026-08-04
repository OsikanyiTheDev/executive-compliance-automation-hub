# n8n Docker Setup

This directory contains everything needed to run n8n in Docker.

## Files

- `Dockerfile` — Recipe to build our custom n8n image
- `entrypoint.sh` — Startup script (waits for DB, logs info)

## Building the Image

From the project root:

```bash
docker build -t executive-n8n:latest docker/n8n/
```

## Running (without Compose)

```bash
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -e N8N_ENCRYPTION_KEY=your-key \
  executive-n8n:latest
```

We use Docker Compose for the full setup (n8n + PostgreSQL).
See `../docker-compose.yml`.
