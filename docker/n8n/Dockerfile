# ============================================================
# Dockerfile for n8n (Executive Compliance Automation Hub)
# ============================================================
# Build context: docker/n8n/
# Usage:         docker build -t executive-n8n:latest docker/n8n/
# ============================================================

# ---- Base Image ----
# Use the official n8n image as our starting point.
# The 'latest' tag tracks the n8n team's stable releases.
# For production, pin to a specific version like '1.50.0' for reproducibility.
FROM n8nio/n8n:latest

# ---- Metadata ----
# LABEL adds metadata to the image. Visible via 'docker inspect'.
LABEL maintainer="Executive Compliance Automation Hub"
LABEL version="0.2.0"
LABEL description="Custom n8n image for executive compliance workflows"

# ---- Switch to root for installations ----
# n8n image runs as 'node' user by default. We need root to install packages.
USER root

# ---- Install system dependencies ----
# Why: Some custom nodes need build tools (gcc, python) for native modules.
# We install minimal packages to keep the image small.
RUN apk add --no-cache \
    # Required for some npm packages with native bindings
    build-base \
    # Python is needed by some custom nodes (e.g., code node helpers)
    python3 \
    py3-pip \
    # Git is useful for custom node installation from GitHub
    git \
    # Curl for health checks
    curl \
    # Clean up package cache to reduce image size
    && rm -rf /var/cache/apk/*

# ---- Create custom nodes directory ----
# n8n loads custom community nodes from ~/.n8n/custom
# We create it here so we can add nodes later via volumes
RUN mkdir -p /home/node/.n8n/custom \
    && chown -R node:node /home/node/.n8n

# ---- Switch back to non-root user ----
# Security best practice: never run containers as root in production.
USER node

# ---- Expose n8n port ----
# Tells Docker this container listens on port 5678.
# 'EXPOSE' is documentation; actual port mapping happens in docker-compose.
EXPOSE 5678

# ---- Health check ----
# Docker will periodically check if n8n is responding.
# If 3 consecutive checks fail, the container is marked unhealthy.
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

# ---- Default command ----
# CMD runs when the container starts (unless overridden).
# 'n8n start' launches the n8n server.
# The 'CMD' is in exec form (JSON array) — preferred over shell form.
CMD ["n8n", "start"]
