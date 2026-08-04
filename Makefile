# ============================================================
# Executive Compliance & Operations Automation Hub
# Makefile — Common development commands
# ============================================================
# Usage: make <target>
# Run 'make help' to see all available commands
# ============================================================

# Use bash for shell commands
SHELL := /bin/bash

# Docker compose command (use 'docker compose' for v2)
DOCKER_COMPOSE := docker compose
COMPOSE_FILE := -f docker/docker-compose.yml

# Default target
.DEFAULT_GOAL := help

# ============================================================
# HELP
# ============================================================
.PHONY: help
help: ## Show this help message
	@echo ""
	@echo "Executive Compliance & Operations Automation Hub"
	@echo "=================================================="
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36mmake %-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ============================================================
# ENVIRONMENT SETUP
# ============================================================
.PHONY: setup
setup: ## Run initial environment setup
	@echo "Setting up development environment..."
	@bash scripts/verify-environment.sh
	@python3 -m venv venv || true
	@echo ""
	@echo "Next steps:"
	@echo "  1. Activate venv:  source venv/bin/activate"
	@echo "  2. Install deps:  make install"
	@echo "  3. Start Docker:  make up"

.PHONY: verify
verify: ## Verify all required tools are installed
	@bash scripts/verify-environment.sh

.PHONY: install
install: ## Install Python dependencies
	@echo "Installing Python dependencies..."
	@pip install -r python/requirements.txt

.PHONY: env-check
env-check: ## Check if .env file exists
	@if [ -f .env ]; then \
		echo "✓ .env file exists"; \
	else \
		echo "✗ .env file missing. Creating from template..."; \
		cp .env.example .env; \
		echo "  Please edit .env with your real values."; \
	fi

# ============================================================
# DOCKER
# ============================================================
.PHONY: up
up: env-check ## Start all Docker containers (detached)
	@echo "Starting Docker containers..."
	@cd docker && $(DOCKER_COMPOSE) $(COMPOSE_FILE) up -d
	@echo ""
	@echo "✓ Containers started!"
	@echo "  Wait ~30 seconds, then access n8n at: http://localhost:5678"
	@echo "  Username: admin    Password: admin"
	@echo "  Run 'make logs' to see startup progress."

.PHONY: down
down: ## Stop all Docker containers
	@echo "Stopping Docker containers..."
	@cd docker && $(DOCKER_COMPOSE) $(COMPOSE_FILE) down
	@echo "✓ Containers stopped."

.PHONY: restart
restart: down up ## Restart all Docker containers

.PHONY: logs
logs: ## View Docker container logs (follow mode)
	@cd docker && $(DOCKER_COMPOSE) $(COMPOSE_FILE) logs -f

.PHONY: logs-n8n
logs-n8n: ## View only n8n logs
	@cd docker && $(DOCKER_COMPOSE) $(COMPOSE_FILE) logs -f n8n

.PHONY: ps
ps: ## List running Docker containers
	@cd docker && $(DOCKER_COMPOSE) $(COMPOSE_FILE) ps

.PHONY: rebuild
rebuild: ## Rebuild Docker images from scratch
	@echo "Rebuilding Docker images..."
	@cd docker && $(DOCKER_COMPOSE) $(COMPOSE_FILE) build --no-cache
	@echo "✓ Images rebuilt."

.PHONY: shell-n8n
shell-n8n: ## Open a shell inside the n8n container
	@cd docker && $(DOCKER_COMPOSE) $(COMPOSE_FILE) exec n8n /bin/sh

.PHONY: shell-db
shell-db: ## Open a psql shell inside the Postgres container
	@cd docker && $(DOCKER_COMPOSE) $(COMPOSE_FILE) exec postgres psql -U n8n -d n8n

# ============================================================
# PYTHON & TESTING
# ============================================================
.PHONY: test
test: ## Run all Python tests
	@pytest tests/ -v

.PHONY: test-unit
test-unit: ## Run unit tests only
	@pytest tests/unit/ -v

.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	@pytest tests/ --cov=python/ --cov-report=html --cov-report=term
	@echo "✓ Coverage report: htmlcov/index.html"

.PHONY: lint
lint: ## Run code linter (flake8)
	@flake8 python/ tests/

.PHONY: format
format: ## Format Python code (black)
	@black python/ tests/

# ============================================================
# GIT
# ============================================================
.PHONY: status
status: ## Show Git status
	@git status

.PHONY: log
log: ## Show Git commit history
	@git log --oneline --graph --decorate -20

.PHONY: tag-list
tag-list: ## List all Git tags
	@git tag -l --sort=-v:refname

# ============================================================
# CLEANUP
# ============================================================
.PHONY: clean
clean: ## Remove temporary files and caches
	@echo "Cleaning up..."
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	@rm -f *.log
	@echo "✓ Cleanup complete."

.PHONY: clean-all
clean-all: ## Remove everything including Docker volumes (DESTRUCTIVE)
	@echo "⚠ This will remove venv, Docker volumes, and ALL DATA."
	@echo "  Are you sure? [y/N]"
	@read -r ans && [ "$$ans" = "y" ] && ( \
		rm -rf venv && \
		cd docker && $(DOCKER_COMPOSE) $(COMPOSE_FILE) down -v \
	) || echo "Cancelled."
