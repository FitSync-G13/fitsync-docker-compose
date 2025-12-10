#!/bin/bash

# FitSync - Clone All Repositories Script
# Download and run this script first to clone all FitSync repositories

set -e

echo "======================================"
echo "   FitSync Repository Cloner"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# GitHub organization
ORG="FitSync-G13"

# All repositories
REPOS=(
    "fitsync-docker-compose"
    "fitsync-api-gateway"
    "fitsync-user-service"
    "fitsync-training-service"
    "fitsync-schedule-service"
    "fitsync-progress-service"
    "fitsync-notification-service"
    "fitsync-frontend"
)

echo -e "${BLUE}This script will clone all FitSync repositories${NC}"
echo ""
echo "Repositories to clone:"
for repo in "${REPOS[@]}"; do
    echo "  - $repo"
done
echo ""
echo -e "They will be cloned to: ${YELLOW}$(pwd)${NC}"
echo ""

# Check git
if ! command -v git &> /dev/null; then
    echo "ERROR: Git is not installed"
    exit 1
fi

# Confirm
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

echo ""
echo "Cloning repositories..."
echo ""

# Clone each repo
for repo in "${REPOS[@]}"; do
    if [ -d "$repo" ]; then
        echo -e "${YELLOW}⚠ $repo already exists, skipping${NC}"
    else
        echo -e "${BLUE}Cloning $repo...${NC}"
        if git clone "https://github.com/$ORG/$repo.git"; then
            echo -e "${GREEN}✓ $repo cloned${NC}"
        else
            echo "ERROR: Failed to clone $repo"
        fi
    fi
    echo ""
done

echo "======================================"
echo -e "${GREEN}✓ All repositories cloned!${NC}"
echo "======================================"
echo ""
echo "Directory structure:"
echo ""
pwd
for repo in "${REPOS[@]}"; do
    if [ -d "$repo" ]; then
        echo "├── $repo/"
    fi
done
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Make sure Docker Desktop is running"
echo "2. Run setup:"
echo "   ${GREEN}cd fitsync-docker-compose${NC}"
echo "   ${GREEN}./setup.sh${NC}"
echo ""
echo "3. Open http://localhost:3000 in your browser"
echo "4. Login with: client@fitsync.com / Client@123"
echo ""
