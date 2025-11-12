#!/bin/bash

# SPLANTS Marketing Engine - Quick Start Script
# This script helps you get started quickly

set -e

echo "================================================"
echo "SPLANTS Marketing Engine - Quick Start"
echo "================================================"
echo ""

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "Please install Docker from https://docker.com/get-started"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed!"
    echo "Please install Docker Compose"
    exit 1
fi

echo "✅ Docker is installed"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "✅ Created .env file"
    echo ""
    echo "⚠️  IMPORTANT: You need to add your OpenAI API key to .env"
    echo "   Edit .env and add your key to OPENAI_API_KEY="
    echo ""
    read -p "Have you added your OpenAI API key? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Please add your OpenAI API key to .env and run this script again"
        exit 1
    fi
else
    echo "✅ .env file exists"
fi

# Build and start services
echo ""
echo "Building and starting services..."
docker-compose build
docker-compose up -d

# Wait for services to be ready
echo ""
echo "Waiting for services to start..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo ""
    echo "✅ Services are running!"
    echo ""
    echo "================================================"
    echo "SPLANTS Marketing Engine is ready!"
    echo "================================================"
    echo ""
    echo "🚀 Access Points:"
    echo "   Main API: http://localhost:8080"
    echo "   API Docs: http://localhost:8080/docs"
    echo "   Health Check: http://localhost:8080/health"
    echo ""
    echo "📚 Quick Commands:"
    echo "   View logs: docker-compose logs -f app"
    echo "   Stop services: docker-compose down"
    echo "   Restart: docker-compose restart"
    echo ""
    echo "📖 Next Steps:"
    echo "   1. Visit http://localhost:8080/docs"
    echo "   2. Try generating your first content"
    echo "   3. Explore the analytics dashboard"
    echo ""
else
    echo "❌ Services failed to start"
    echo "Check logs with: docker-compose logs"
    exit 1
fi