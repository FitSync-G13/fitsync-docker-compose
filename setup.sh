#!/bin/bash
set -e

# FitSync Multi-Repo Setup Script
# This script automates the complete setup process for the FitSync application

echo "======================================"
echo "   FitSync Application Setup"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${BLUE}→${NC} $1"; }

# Check prerequisites
echo "Step 1: Checking prerequisites..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed"
    echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    print_error "Docker is not running"
    echo "Please start Docker Desktop and try again"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not available"
    echo "Please install Docker Compose V2"
    exit 1
fi

print_success "Docker is installed and running"
print_success "Docker Compose is available"
echo ""

# Check if all required repositories exist
echo "Step 2: Verifying repository structure..."
PARENT_DIR="$(cd .. && pwd)"
MISSING_REPOS=()

REQUIRED_REPOS=(
    "fitsync-api-gateway"
    "fitsync-user-service"
    "fitsync-training-service"
    "fitsync-schedule-service"
    "fitsync-progress-service"
    "fitsync-notification-service"
    "fitsync-frontend"
)

for repo in "${REQUIRED_REPOS[@]}"; do
    if [ ! -d "$PARENT_DIR/$repo" ]; then
        MISSING_REPOS+=("$repo")
    fi
done

if [ ${#MISSING_REPOS[@]} -ne 0 ]; then
    print_error "Missing required repositories:"
    for repo in "${MISSING_REPOS[@]}"; do
        echo "  - $repo"
    done
    echo ""
    echo "Please clone all required repositories to the parent directory:"
    echo "$PARENT_DIR"
    echo ""
    echo "See SETUP.md for cloning instructions"
    exit 1
fi

print_success "All required repositories found"
echo ""

# Start Docker services
echo "Step 3: Starting FitSync services..."
docker compose up -d

echo ""
echo "Step 4: Waiting for services to start (30 seconds)..."
sleep 30

# Check service health
echo ""
echo "Step 5: Checking service health..."

# Function to check if a container is running
check_container() {
    if docker compose ps | grep -q "$1.*Up"; then
        print_success "$1 is running"
        return 0
    else
        print_error "$1 is not running"
        return 1
    fi
}

# Check all containers
ALL_RUNNING=true
for service in userdb trainingdb scheduledb progressdb redis \
               user-service training-service schedule-service progress-service \
               notification-service api-gateway frontend; do
    if ! check_container "$service"; then
        ALL_RUNNING=false
    fi
done

if [ "$ALL_RUNNING" = false ]; then
    echo ""
    print_warning "Some services are not running. Checking logs..."
    echo ""
    docker compose ps
    echo ""
    echo "Run 'docker compose logs <service-name>' to check logs"
    exit 1
fi

echo ""
echo "Step 6: Seeding databases with test data..."

# Seed user service database
print_info "Seeding user service database..."
if docker compose exec -T user-service node src/database/seed.js > /dev/null 2>&1; then
    print_success "User database seeded successfully"
else
    print_warning "User database seeding may have failed (could be already seeded)"
fi

# Seed training service database
print_info "Seeding training service database..."
if docker compose exec -T training-service node src/database/seed.js > /dev/null 2>&1; then
    print_success "Training database seeded successfully"
else
    print_warning "Training database seeding may have failed (could be already seeded)"
fi

echo ""
echo "======================================"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo "======================================"
echo ""
echo "Application URLs:"
echo "  Frontend:    http://localhost:3000"
echo "  API Gateway: http://localhost:4000"
echo ""
echo "Test Credentials:"
echo "  Email:    client@fitsync.com"
echo "  Password: Client@123"
echo ""
echo "Other test users:"
echo "  - admin@fitsync.com    / Admin@123"
echo "  - trainer@fitsync.com  / Trainer@123"
echo "  - gym@fitsync.com      / Gym@123"
echo ""
echo "Useful Commands:"
echo "  docker compose logs -f           # View logs"
echo "  docker compose logs -f <service> # View specific service logs"
echo "  docker compose restart <service> # Restart a service"
echo "  docker compose down              # Stop all services"
echo "  docker compose down -v           # Stop and remove all data"
echo ""
echo -e "${GREEN}Happy testing! 🎉${NC}"
echo ""
