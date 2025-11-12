#!/bin/bash

# ============================================
# SPLANTS Marketing Engine - System Check Script
# ============================================
#
# PURPOSE:
#   Validates that your system meets all requirements for running SPLANTS
#   Run this BEFORE attempting installation to catch issues early
#
# WHAT IT CHECKS:
#   1. Operating system compatibility
#   2. Docker installation and version
#   3. Docker Compose availability
#   4. System resources (RAM, disk space)
#   5. Network connectivity
#   6. Required ports availability
#
# USAGE:
#   ./scripts_check-system.sh
#
# ============================================

echo "================================================"
echo "SPLANTS Marketing Engine - System Requirements Check"
echo "================================================"
echo ""
echo "This script will verify your system is ready to run SPLANTS"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# Helper functions
pass_check() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((CHECKS_PASSED++))
}

fail_check() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    echo "   → $2"
    ((CHECKS_FAILED++))
}

warn_check() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
    echo "   → $2"
    ((CHECKS_WARNING++))
}

# ============================================
# Check 1: Operating System
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 1: Operating System"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    pass_check "Linux operating system detected"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    pass_check "macOS operating system detected"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    pass_check "Windows operating system detected (Git Bash/Cygwin)"
else
    warn_check "Unknown operating system: $OSTYPE" "SPLANTS should still work, but hasn't been tested on this OS"
fi

echo ""

# ============================================
# Check 2: Docker Installation
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 2: Docker Installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    pass_check "Docker is installed (version: $DOCKER_VERSION)"
    
    # Check if Docker is running
    if docker ps &> /dev/null; then
        pass_check "Docker daemon is running"
    else
        fail_check "Docker is installed but not running" "Start Docker Desktop or run 'sudo systemctl start docker'"
    fi
else
    fail_check "Docker is not installed" "Install from https://docker.com/get-started"
fi

echo ""

# ============================================
# Check 3: Docker Compose
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 3: Docker Compose"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

COMPOSE_FOUND=false

# Check for Docker Compose plugin (docker compose)
if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version --short 2>&1)
    pass_check "Docker Compose plugin found (version: $COMPOSE_VERSION)"
    COMPOSE_FOUND=true
fi

# Check for standalone docker-compose
if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    pass_check "Standalone docker-compose found (version: $COMPOSE_VERSION)"
    COMPOSE_FOUND=true
fi

if [ "$COMPOSE_FOUND" = false ]; then
    fail_check "Docker Compose not found" "Should be included with Docker Desktop, or install separately"
fi

echo ""

# ============================================
# Check 4: System Resources
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 4: System Resources"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check available RAM
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    TOTAL_RAM=$(free -m | awk 'NR==2{print $2}')
elif [[ "$OSTYPE" == "darwin"* ]]; then
    TOTAL_RAM=$(( $(sysctl -n hw.memsize) / 1024 / 1024 ))
else
    TOTAL_RAM=0
fi

if [ $TOTAL_RAM -gt 0 ]; then
    if [ $TOTAL_RAM -ge 4096 ]; then
        pass_check "Sufficient RAM available (${TOTAL_RAM}MB / Required: 4GB minimum)"
    elif [ $TOTAL_RAM -ge 2048 ]; then
        warn_check "Low RAM (${TOTAL_RAM}MB)" "Minimum is 4GB. System may be slow with ${TOTAL_RAM}MB"
    else
        fail_check "Insufficient RAM (${TOTAL_RAM}MB)" "SPLANTS requires at least 4GB RAM, you have ${TOTAL_RAM}MB"
    fi
fi

# Check available disk space
if command -v df &> /dev/null; then
    DISK_AVAIL=$(df -BG . | awk 'NR==2{print $4}' | sed 's/G//')
    if [ $DISK_AVAIL -ge 20 ]; then
        pass_check "Sufficient disk space (${DISK_AVAIL}GB / Required: 20GB minimum)"
    elif [ $DISK_AVAIL -ge 10 ]; then
        warn_check "Low disk space (${DISK_AVAIL}GB)" "Recommended: 20GB+. You have ${DISK_AVAIL}GB"
    else
        fail_check "Insufficient disk space (${DISK_AVAIL}GB)" "Need at least 20GB free, you have ${DISK_AVAIL}GB"
    fi
fi

echo ""

# ============================================
# Check 5: Network Connectivity
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 5: Network Connectivity"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check internet connectivity
if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
    pass_check "Internet connectivity is working"
else
    fail_check "No internet connection" "SPLANTS needs internet to download images and access OpenAI API"
fi

# Check DNS resolution
if ping -c 1 -W 2 api.openai.com &> /dev/null || host api.openai.com &> /dev/null; then
    pass_check "DNS resolution is working (can reach api.openai.com)"
else
    warn_check "Cannot reach api.openai.com" "May be temporary or firewall issue. Will be needed at runtime"
fi

echo ""

# ============================================
# Check 6: Port Availability
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 6: Port Availability"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_port() {
    PORT=$1
    NAME=$2
    
    if command -v lsof &> /dev/null; then
        if lsof -Pi :$PORT -sTCP:LISTEN -t &> /dev/null; then
            warn_check "Port $PORT ($NAME) is already in use" "SPLANTS needs this port. Close the application using it"
        else
            pass_check "Port $PORT ($NAME) is available"
        fi
    elif command -v netstat &> /dev/null; then
        if netstat -tuln 2>/dev/null | grep -q ":$PORT "; then
            warn_check "Port $PORT ($NAME) appears to be in use" "SPLANTS needs this port. Close the application using it"
        else
            pass_check "Port $PORT ($NAME) is available"
        fi
    else
        warn_check "Cannot check port $PORT ($NAME)" "Tools 'lsof' or 'netstat' not found. Port may be in use"
    fi
}

check_port 3000 "Web UI"
check_port 5432 "PostgreSQL"

echo ""

# ============================================
# Check 7: Required Utilities
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 7: Required Utilities"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v curl &> /dev/null; then
    pass_check "curl is installed"
else
    warn_check "curl is not installed" "Helpful for testing API but not required"
fi

if command -v git &> /dev/null; then
    pass_check "git is installed"
else
    warn_check "git is not installed" "Needed if you want to pull updates from GitHub"
fi

echo ""

# ============================================
# Summary
# ============================================

echo "================================================"
echo "Summary"
echo "================================================"
echo ""
echo "Checks Passed:   ${GREEN}${CHECKS_PASSED}${NC}"
echo "Warnings:        ${YELLOW}${CHECKS_WARNING}${NC}"
echo "Checks Failed:   ${RED}${CHECKS_FAILED}${NC}"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ System is ready to run SPLANTS!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run: ./scripts_quick-start.sh"
    echo "  2. Follow the interactive setup wizard"
    echo "  3. Start generating content!"
    echo ""
    exit 0
else
    echo -e "${RED}❌ System has issues that need to be fixed${NC}"
    echo ""
    echo "Please fix the failed checks above before installing SPLANTS"
    echo ""
    echo "For help, see:"
    echo "  - README.md - Complete documentation"
    echo "  - SETUP_GUIDE.md - Step-by-step installation"
    echo "  - TROUBLESHOOTING.md - Problem solving guide"
    echo ""
    exit 1
fi
