# ============================================================
# Executive Compliance & Operations Automation Hub
# Makefile — Common development commands
# ============================================================
# Usage: make <target>
# Run 'make help' to see all available commands
# ============================================================

# Use bash for shell commands
SHELL := /bin/bash

# Default target when 'make' is run alone
.DEFAULT_GOAL := help

# ============================================================
# HELP TARGET — Lists all available commands
# ============================================================
.PHONY: help
help: ## Show this help message
	@echo ""
	@echo "Executive Compliance & Operations Automation Hub"
	@echo "=================================================="
	@echo ""
	@echo "Available commands:"
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
	@python3 -m venv venv
	@echo ""
	@echo "Next steps:"
	@echo "  1. Activate venv:  source venv/bin/activate"
	@echo "  2. Install deps:  pip install -r python/requirements.txt"

.PHONY: verify
verify: ## Verify all required tools are installed
	@bash scripts/verify-environment.sh

.PHONY: install
install: ## Install Python dependencies
	@echo "Installing Python dependencies..."
	@pip install -r python/requirements.txt

# ============================================================
# DOCKER COMMANDS
# ============================================================
.PHONY: up
up: ## Start all Docker containers (detached)
	@echo "Starting Docker containers..."
	@cd docker && docker compose up -d
	@echo "✓ Containers started. Run 'make logs' to see output."

.PHONY: down
down: ## Stop all Docker containers
	@echo "Stopping Docker containers..."
	@cd docker && docker compose down
	@echo "✓ Containers stopped."

.PHONY: restart
restart: down up ## Restart all Docker containers

.PHONY: logs
logs: ## View Docker container logs (follow mode)
	@cd docker && docker compose logs -f

.PHONY: ps
ps: ## List running Docker containers
	@cd docker && docker compose ps

.PHONY: rebuild
rebuild: ## Rebuild Docker images from scratch
	@echo "Rebuilding Docker images..."
	@cd docker && docker compose build --no-cache
	@echo "✓ Images rebuilt."

# ============================================================
# PYTHON & TESTING
# ============================================================
.PHONY: test
test: ## Run all Python tests
	@echo "Running tests..."
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
# GIT WORKFLOW HELPERS
# ============================================================
.PHONY: status
status: ## Show Git status
	@git status

.PHONY: log
log: ## Show Git commit history (one line per commit)
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
	@find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	@rm -f *.log
	@echo "✓ Cleanup complete."

.PHONY: clean-all
clean-all: clean ## Remove everything including venv and Docker volumes
	@echo "⚠ This will remove venv and Docker volumes. Are you sure? [y/N]"
	@read -r ans && [ "$$ans" = "y" ] && (rm -rf venv && cd docker && docker compose down -v) || echo "Cancelled."
