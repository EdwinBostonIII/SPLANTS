#!/bin/bash

# ============================================
# SPLANTS Marketing Engine - Installation Verification Script
# ============================================
#
# PURPOSE:
#   Verifies that SPLANTS was installed correctly and is working
#   Run this AFTER installation to confirm everything is operational
#
# WHAT IT CHECKS:
#   1. Configuration file (.env) exists and is valid
#   2. Docker containers are running
#   3. Services are healthy (database, API, web UI)
#   4. API endpoints respond correctly
#   5. Database connection works
#   6. OpenAI API key is valid
#
# USAGE:
#   ./scripts_verify-installation.sh
#
# ============================================

echo "================================================"
echo "SPLANTS Marketing Engine - Installation Verification"
echo "================================================"
echo ""
echo "This script will verify your SPLANTS installation is working correctly"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track status
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

info() {
    echo -e "${BLUE}ℹ️  INFO${NC}: $1"
}

# Determine Docker Compose command
DOCKER_COMPOSE=""
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    echo -e "${RED}❌ ERROR${NC}: Docker Compose not found!"
    echo "Cannot verify installation without Docker Compose"
    exit 1
fi

# ============================================
# Check 1: Configuration File
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 1: Configuration File (.env)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f .env ]; then
    pass_check ".env file exists"
    
    # Check for required variables
    if grep -q "OPENAI_API_KEY=sk-" .env; then
        pass_check "OpenAI API key appears to be set"
    else
        fail_check "OpenAI API key not properly configured" "Edit .env and add your OpenAI API key"
    fi
    
    if grep -q "API_KEY=" .env && ! grep -q "API_KEY=change-this" .env; then
        pass_check "System API key is configured"
    else
        warn_check "System API key appears to be default" "Consider changing it for security"
    fi
    
    if grep -q "DATABASE_URL=" .env; then
        pass_check "Database URL is configured"
    else
        fail_check "Database URL not found" "Check .env file has DATABASE_URL"
    fi
else
    fail_check ".env file not found" "Run ./scripts_quick-start.sh to create it"
fi

echo ""

# ============================================
# Check 2: Docker Containers
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 2: Docker Containers Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if containers are running
CONTAINERS_RUNNING=$($DOCKER_COMPOSE ps -q 2>/dev/null | wc -l)

if [ "$CONTAINERS_RUNNING" -ge 3 ]; then
    pass_check "Docker containers are running ($CONTAINERS_RUNNING containers)"
else
    fail_check "Not enough containers running ($CONTAINERS_RUNNING/3)" "Run: $DOCKER_COMPOSE up -d"
fi

# Check individual services
check_service() {
    SERVICE_NAME=$1
    if $DOCKER_COMPOSE ps "$SERVICE_NAME" 2>/dev/null | grep -q "Up"; then
        pass_check "Service '$SERVICE_NAME' is running"
        return 0
    else
        fail_check "Service '$SERVICE_NAME' is not running" "Check logs: $DOCKER_COMPOSE logs $SERVICE_NAME"
        return 1
    fi
}

check_service "db"
check_service "app"
check_service "web"

echo ""

# ============================================
# Check 3: Health Endpoints
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 3: Service Health Checks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

info "Waiting 5 seconds for services to stabilize..."
sleep 5

# Check API health endpoint
if command -v curl &> /dev/null; then
    # Test API health
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health 2>/dev/null)
    if [ "$HTTP_CODE" = "200" ]; then
        pass_check "API health endpoint responding (HTTP 200)"
    else
        fail_check "API health endpoint not responding (HTTP $HTTP_CODE)" "Check logs: $DOCKER_COMPOSE logs app"
    fi
    
    # Test Web UI
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null)
    if [ "$HTTP_CODE" = "200" ]; then
        pass_check "Web UI is accessible (HTTP 200)"
    else
        warn_check "Web UI not responding (HTTP $HTTP_CODE)" "Try waiting 30 more seconds and check: $DOCKER_COMPOSE logs web"
    fi
else
    warn_check "curl not installed" "Cannot test HTTP endpoints. Install curl to enable this check"
fi

echo ""

# ============================================
# Check 4: Database Connection
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 4: Database Connection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Try to connect to database
if $DOCKER_COMPOSE exec -T db psql -U splants splants -c "SELECT 1;" &> /dev/null; then
    pass_check "Database connection successful"
else
    fail_check "Cannot connect to database" "Check logs: $DOCKER_COMPOSE logs db"
fi

echo ""

# ============================================
# Check 5: API Functionality
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 5: API Functionality"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v curl &> /dev/null; then
    # Get API key from .env
    if [ -f .env ]; then
        API_KEY=$(grep "^API_KEY=" .env | cut -d'=' -f2)
        
        # Test root endpoint
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
            -H "X-API-Key: $API_KEY" \
            http://localhost:3000/api/ 2>/dev/null)
        
        if [ "$HTTP_CODE" = "200" ]; then
            pass_check "API root endpoint responding"
        elif [ "$HTTP_CODE" = "403" ]; then
            fail_check "API authentication failed" "Check your API_KEY in .env file"
        else
            warn_check "API root endpoint issue (HTTP $HTTP_CODE)" "May still be initializing"
        fi
        
        # Test system status endpoint (doesn't require auth)
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
            http://localhost:3000/api/v1/system/status 2>/dev/null)
        
        if [ "$HTTP_CODE" = "200" ]; then
            pass_check "System status endpoint responding"
        else
            warn_check "System status endpoint issue (HTTP $HTTP_CODE)" "May still be initializing"
        fi
    fi
else
    info "curl not available - skipping API tests"
fi

echo ""

# ============================================
# Check 6: Logs for Errors
# ============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Check 6: Recent Log Errors"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check app logs for errors
ERROR_COUNT=$($DOCKER_COMPOSE logs --tail=100 app 2>/dev/null | grep -ci "error" || echo "0")
if [ "$ERROR_COUNT" -eq 0 ]; then
    pass_check "No errors in recent app logs"
elif [ "$ERROR_COUNT" -lt 5 ]; then
    warn_check "$ERROR_COUNT error messages in app logs" "Review with: $DOCKER_COMPOSE logs app"
else
    fail_check "Multiple errors in app logs ($ERROR_COUNT)" "Check: $DOCKER_COMPOSE logs app"
fi

echo ""

# ============================================
# Summary
# ============================================

echo "================================================"
echo "Verification Summary"
echo "================================================"
echo ""
echo "Checks Passed:   ${GREEN}${CHECKS_PASSED}${NC}"
echo "Warnings:        ${YELLOW}${CHECKS_WARNING}${NC}"
echo "Checks Failed:   ${RED}${CHECKS_FAILED}${NC}"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ SPLANTS installation is working!${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Access Your SPLANTS System:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  🌐 Web UI:         http://localhost:3000"
    echo "  📚 API Docs:       http://localhost:3000/api/docs"
    echo "  ❤️  Health Check:  http://localhost:3000/api/health"
    echo "  📊 System Status:  http://localhost:3000/api/v1/system/status"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Next Steps:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  1. Open http://localhost:3000 in your browser"
    echo "  2. Try the interactive API docs at /api/docs"
    echo "  3. Generate your first content!"
    echo "  4. Check README.md for usage examples"
    echo ""
    
    if [ $CHECKS_WARNING -gt 0 ]; then
        echo "Note: There were some warnings. Review them above if you experience issues."
        echo ""
    fi
    
    exit 0
else
    echo -e "${RED}❌ Installation has issues that need attention${NC}"
    echo ""
    echo "Common fixes:"
    echo "  • Wait 60 seconds and run this script again"
    echo "  • Check logs: $DOCKER_COMPOSE logs"
    echo "  • Restart services: $DOCKER_COMPOSE restart"
    echo "  • See TROUBLESHOOTING.md for detailed help"
    echo ""
    exit 1
fi
