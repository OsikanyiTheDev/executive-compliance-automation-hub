#!/bin/bash
# ============================================================
# verify-environment.sh (FIXED VERSION)
# Purpose: Verify all required tools are installed and working
# Usage:   bash scripts/verify-environment.sh
# ============================================================
# NOTE: Removed 'set -e' so the script continues through all
# checks even if one fails. This way you see ALL problems at once.
# ============================================================

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

check_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    PASSED=$((PASSED + 1))
}

check_fail() {
    echo -e "  ${RED}✗${NC} $1"
    FAILED=$((FAILED + 1))
}

check_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

# ============================================================
# 1. GIT CHECK
# ============================================================
print_header "1. Git (Version Control)"

if command -v git >/dev/null 2>&1; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    check_pass "Git installed: v${GIT_VERSION}"

    # Check Git config
    if git config --global user.name >/dev/null 2>&1; then
        GIT_NAME=$(git config --global user.name)
        check_pass "Git user.name configured: ${GIT_NAME}"
    else
        check_fail "Git user.name not configured"
        echo -e "      ${YELLOW}Fix: git config --global user.name 'Your Name'${NC}"
    fi

    if git config --global user.email >/dev/null 2>&1; then
        GIT_EMAIL=$(git config --global user.email)
        check_pass "Git user.email configured: ${GIT_EMAIL}"
    else
        check_fail "Git user.email not configured"
        echo -e "      ${YELLOW}Fix: git config --global user.email 'you@email.com'${NC}"
    fi
else
    check_fail "Git not installed"
    echo -e "      ${YELLOW}Install from: https://git-scm.com${NC}"
fi

# ============================================================
# 2. DOCKER CHECK
# ============================================================
print_header "2. Docker (Containerization)"

if command -v docker >/dev/null 2>&1; then
    DOCKER_VERSION=$(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')
    if [ -n "$DOCKER_VERSION" ]; then
        check_pass "Docker installed: v${DOCKER_VERSION}"
    else
        check_warn "Docker command found but version could not be read"
    fi
else
    check_fail "Docker not installed"
    echo -e "      ${YELLOW}Install Docker Desktop from: https://docker.com${NC}"
fi

# Check if Docker daemon is running
if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
        check_pass "Docker daemon is running"
    else
        check_fail "Docker daemon not running"
        echo -e "      ${YELLOW}Start Docker Desktop application${NC}"
    fi
fi

# Check Docker Compose
if command -v docker >/dev/null 2>&1; then
    if docker compose version >/dev/null 2>&1; then
        COMPOSE_VERSION=$(docker compose version 2>/dev/null | awk '{print $4}')
        check_pass "Docker Compose installed: v${COMPOSE_VERSION}"
    else
        check_fail "Docker Compose not available"
        echo -e "      ${YELLOW}Update Docker Desktop to get Compose v2${NC}"
    fi
fi

# ============================================================
# 3. PYTHON CHECK
# ============================================================
print_header "3. Python (Programming Language)"

if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    if [ -n "$PYTHON_VERSION" ]; then
        check_pass "Python installed: v${PYTHON_VERSION}"

        # Check version is 3.9+
        PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
        PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)
        if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 9 ]; then
            check_pass "Python version is 3.9+"
        else
            check_warn "Python version < 3.9 — some features may not work"
        fi
    fi
else
    check_fail "Python 3 not installed"
    echo -e "      ${YELLOW}Install from: https://python.org${NC}"
fi

if command -v pip3 >/dev/null 2>&1; then
    PIP_VERSION=$(pip3 --version 2>/dev/null | awk '{print $2}')
    if [ -n "$PIP_VERSION" ]; then
        check_pass "pip installed: v${PIP_VERSION}"
    fi
else
    check_fail "pip not installed"
    echo -e "      ${YELLOW}Fix: python3 -m ensurepip --upgrade${NC}"
fi

# Check if venv is active
if [ -n "$VIRTUAL_ENV" ]; then
    check_pass "Python virtual environment is active: $(basename "$VIRTUAL_ENV")"
else
    check_warn "No Python virtual environment active"
    echo -e "      ${YELLOW}Recommended: source venv/bin/activate${NC}"
fi

# ============================================================
# 4. CURL CHECK
# ============================================================
print_header "4. Curl (HTTP Testing)"

if command -v curl >/dev/null 2>&1; then
    CURL_VERSION=$(curl --version 2>/dev/null | head -n1 | awk '{print $2}')
    check_pass "curl installed: v${CURL_VERSION}"
else
    check_fail "curl not installed"
fi

# ============================================================
# 5. PROJECT STRUCTURE CHECK
# ============================================================
print_header "5. Project Structure"

REQUIRED_DIRS=(
    "docs/architecture"
    "terraform/modules"
    "docker/n8n"
    "n8n/workflows"
    "python/helpers"
    "scripts"
    "dashboard"
    "sample-data"
    "tests"
    ".github/workflows"
    "screenshots"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        check_pass "Directory exists: $dir"
    else
        check_fail "Directory missing: $dir"
    fi
done

# Check critical files
REQUIRED_FILES=(
    "README.md"
    "LICENSE"
    ".gitignore"
    "docs/architecture/01-system-overview.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        check_pass "File exists: $file"
    else
        check_fail "File missing: $file"
    fi
done

# ============================================================
# 6. GIT REPOSITORY CHECK
# ============================================================
print_header "6. Git Repository"

if [ -d ".git" ]; then
    check_pass "Git repository initialized"

    # Check for v0.1.0 tag
    if git tag -l 2>/dev/null | grep -q "v0.1.0"; then
        check_pass "Tag v0.1.0 exists"
    else
        check_warn "Tag v0.1.0 not found"
    fi

    # Check for clean working tree
    if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
        check_pass "Working tree is clean"
    else
        check_warn "Working tree has uncommitted changes:"
        git status --short 2>/dev/null | head -10
    fi
else
    check_fail "Not a Git repository"
fi

# ============================================================
# SUMMARY
# ============================================================
print_header "VERIFICATION SUMMARY"

TOTAL=$((PASSED + FAILED + WARNINGS))
echo ""
echo -e "  Total checks:    ${TOTAL}"
echo -e "  ${GREEN}Passed:${NC}          ${PASSED}"
echo -e "  ${YELLOW}Warnings:${NC}        ${WARNINGS}"
echo -e "  ${RED}Failed:${NC}          ${FAILED}"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}============================================================${NC}"
    echo -e "${GREEN}  Environment is ready for Phase 1!${NC}"
    echo -e "${GREEN}============================================================${NC}"
    exit 0
else
    echo -e "${RED}============================================================${NC}"
    echo -e "${RED}  Please fix the ${FAILED} failed check(s) before continuing.${NC}"
    echo -e "${RED}============================================================${NC}"
    exit 1
fi
