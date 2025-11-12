#!/bin/bash

# ============================================
# SPLANTS Marketing Engine - Quick Start Script
# ============================================
#
# PURPOSE:
#   This script automates the initial setup and launch of SPLANTS
#   Perfect for first-time users who want a guided experience
#
# WHAT IT DOES:
#   1. Checks if Docker is installed and running
#   2. Creates .env file from template if it doesn't exist
#   3. Prompts you to add your OpenAI API key
#   4. Builds and starts all services (database + application)
#   5. Waits for services to become ready
#   6. Shows you how to access the system
#
# REQUIREMENTS:
#   - Docker Desktop installed and running
#   - OpenAI API key (get from platform.openai.com)
#   - 5-10 minutes for first-time setup
#
# USAGE:
#   ./scripts_quick-start.sh
#
# TROUBLESHOOTING:
#   If this script fails:
#   - Make sure Docker is running (look for whale icon)
#   - Check: docker --version
#   - See TROUBLESHOOTING.md for detailed help
#
# ============================================

# Exit immediately if any command fails
# This prevents cascading errors
set -e

echo "================================================"
echo "SPLANTS Marketing Engine - Quick Start"
echo "================================================"
echo ""
echo "This script will help you set up SPLANTS in 5-10 minutes"
echo ""

# ============================================
# STEP 1: Check for Docker
# ============================================

echo "Step 1/5: Checking Docker installation..."
echo ""

# Check if 'docker' command exists
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo ""
    echo "Docker is required to run SPLANTS. It's like a 'virtual container'"
    echo "that has everything the software needs to run."
    echo ""
    echo "How to install Docker:"
    echo "  1. Go to: https://docker.com/get-started"
    echo "  2. Download Docker Desktop for your system"
    echo "  3. Install it (takes about 5 minutes)"
    echo "  4. Look for the whale icon in your system tray"
    echo "  5. Run this script again"
    echo ""
    echo "For detailed instructions, see SETUP_GUIDE.md"
    exit 1
fi

# Check if 'docker-compose' command exists
# Note: Newer Docker versions use 'docker compose' (no dash)
if ! command -v docker-compose &> /dev/null; then
    echo "⚠️  Warning: docker-compose not found"
    echo "Newer Docker Desktop uses 'docker compose' (without dash)"
    echo "We'll try to use that instead..."
    echo ""
    # Create an alias for the rest of this script
    shopt -s expand_aliases
    alias docker-compose='docker compose'
fi

echo "✅ Docker is installed"
echo ""

# ============================================
# STEP 2: Create .env Configuration File (Interactive)
# ============================================

echo "Step 2/5: Setting up configuration..."
echo ""

# Check if .env file already exists
if [ ! -f .env ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Interactive Setup Wizard"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "I'll help you configure SPLANTS by asking a few questions."
    echo ""
    
    # Step 2a: Get OpenAI API Key
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1. OpenAI API Key (Required)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "What is an OpenAI API key?"
    echo "  - It's like a password that lets SPLANTS use OpenAI's AI"
    echo "  - Required for content generation"
    echo "  - Get one at: https://platform.openai.com/api-keys"
    echo ""
    echo "Please paste your OpenAI API Key below:"
    echo "(It should start with 'sk-' or 'sk-proj-')"
    echo ""
    read -p "OpenAI API Key: " OPENAI_KEY
    echo ""
    
    # Validate OpenAI key format
    if [[ ! $OPENAI_KEY =~ ^sk- ]]; then
        echo "⚠️  Warning: Your key doesn't start with 'sk-'"
        echo "This might not be a valid OpenAI API key."
        echo ""
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Setup cancelled. Please run this script again with a valid API key."
            exit 1
        fi
    fi
    
    # Step 2b: Generate or provide API_KEY
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "2. System API Key (Required)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "What is a System API Key?"
    echo "  - Password that protects YOUR SPLANTS system"
    echo "  - Only people with this key can use your system"
    echo "  - Must be secure (at least 12 characters)"
    echo ""
    echo "Would you like me to generate a secure key for you?"
    echo ""
    read -p "Generate secure key automatically? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Generate a secure random API key
        SYSTEM_API_KEY="SPLANTS-$(date +%s)-$(openssl rand -hex 16 2>/dev/null || head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)"
        echo "✅ Generated secure API key"
    else
        echo ""
        echo "Please enter your own API key (minimum 12 characters):"
        read -p "System API Key: " SYSTEM_API_KEY
        
        # Validate length
        if [ ${#SYSTEM_API_KEY} -lt 12 ]; then
            echo "❌ Error: API key must be at least 12 characters"
            exit 1
        fi
    fi
    echo ""
    
    # Step 2c: Monthly Budget (Optional)
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "3. Monthly AI Budget (Optional)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Set a monthly spending limit to control costs?"
    echo "  - Recommended: \$50 (covers ~150-200 pieces of content)"
    echo "  - Light use: \$30"
    echo "  - Heavy use: \$100"
    echo "  - 0 for unlimited (not recommended)"
    echo ""
    read -p "Monthly budget in USD (press Enter for \$50): " MONTHLY_BUDGET
    MONTHLY_BUDGET=${MONTHLY_BUDGET:-50}
    echo ""
    
    # Step 2d: Create .env file
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Creating .env configuration file..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Copy template and update with user values
    cp .env.example .env
    
    # Use sed to replace values in .env
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS version
        sed -i '' "s|OPENAI_API_KEY=.*|OPENAI_API_KEY=${OPENAI_KEY}|" .env
        sed -i '' "s|API_KEY=.*|API_KEY=${SYSTEM_API_KEY}|" .env
        sed -i '' "s|MONTHLY_AI_BUDGET=.*|MONTHLY_AI_BUDGET=${MONTHLY_BUDGET}|" .env
    else
        # Linux version
        sed -i "s|OPENAI_API_KEY=.*|OPENAI_API_KEY=${OPENAI_KEY}|" .env
        sed -i "s|API_KEY=.*|API_KEY=${SYSTEM_API_KEY}|" .env
        sed -i "s|MONTHLY_AI_BUDGET=.*|MONTHLY_AI_BUDGET=${MONTHLY_BUDGET}|" .env
    fi
    
    echo "✅ Configuration file created successfully!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  IMPORTANT: Save this information!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Your System API Key (save this in a safe place):"
    echo ""
    echo "  ${SYSTEM_API_KEY}"
    echo ""
    echo "You'll need this to access your SPLANTS system."
    echo "Add it to API requests with the header: X-API-Key"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Pause to let user save the key
    read -p "Press Enter when you've saved your API key..."
    echo ""
else
    echo "✅ .env file already exists"
    echo ""
fi

# ============================================
# STEP 3: Build Docker Images
# ============================================

echo "Step 3/5: Building Docker images..."
echo ""
echo "This may take 5-10 minutes on first run"
echo "(Downloading required software)"
echo ""

# Build the Docker images
# --quiet: Less output, cleaner display
# On error, this will stop due to 'set -e' above
docker-compose build

echo ""
echo "✅ Docker images built successfully"
echo ""

# ============================================
# STEP 4: Start Services
# ============================================

echo "Step 4/5: Starting services..."
echo ""

# Start all services in detached mode (background)
# -d: detached mode (runs in background)
docker-compose up -d

echo ""
echo "✅ Services started"
echo ""

# ============================================
# STEP 5: Wait for Services to Be Ready
# ============================================

echo "Step 5/5: Waiting for services to be ready..."
echo ""
echo "Services need 30-60 seconds to fully initialize"
echo "(Database is creating tables, app is connecting)"
echo ""

# Show a progress indicator
for i in {1..6}; do
    echo "⏳ Waiting... ($i of 6) - $(($i * 10)) seconds elapsed"
    sleep 10
done

echo ""

# ============================================
# STEP 6: Verify Services Are Running
# ============================================

# Check if services are actually running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 SPLANTS Marketing Engine is ready!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📍 Access Points:"
    echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   Web UI:         http://localhost:3000  👈 Start here!"
    echo "   API Docs:       http://localhost:3000/api/docs"
    echo "   Health Check:   http://localhost:3000/api/health"
    echo "   System Status:  http://localhost:3000/api/v1/system/status"
    echo ""
    echo "📚 Quick Commands:"
    echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   View logs:      docker-compose logs -f"
    echo "   Stop services:  docker-compose down"
    echo "   Restart:        docker-compose restart"
    echo "   Check status:   docker-compose ps"
    echo ""
    echo "🎯 Next Steps:"
    echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   1. Open http://localhost:3000 in your browser"
    echo "   2. Configure your API key in Settings"
    echo "   3. Start generating content!"
    echo ""
    echo "📖 Documentation:"
    echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "   Complete Guide:     README.md"
    echo "   Setup Guide:        SETUP_GUIDE.md"
    echo "   Troubleshooting:    TROUBLESHOOTING.md"
    echo "   FAQ:                FAQ.md"
    echo "   API Reference:      docs_API_GUIDE.md"
    echo ""
    echo "💡 Pro Tips:"
    echo "   - Use the web UI for the easiest experience"
    echo "   - Check costs daily in the Dashboard"
    echo "   - Run weekly backups: ./scripts_backup.sh"
    echo "   - See FAQ.md for common questions"
    echo ""
else
    echo "❌ Services failed to start"
    echo ""
    echo "Troubleshooting steps:"
    echo "  1. Check if Docker is running (whale icon)"
    echo "  2. View logs: docker-compose logs"
    echo "  3. See TROUBLESHOOTING.md for solutions"
    echo "  4. Try restarting: docker-compose down && docker-compose up -d"
    echo ""
    exit 1
fi