# FitSync Multi-Repo Setup Guide

This guide helps you set up the FitSync application for local development and testing.

## Architecture Overview

FitSync uses a multi-repository architecture with the following repositories:

- **fitsync-api-gateway** - API Gateway (GraphQL/REST)
- **fitsync-user-service** - User management & authentication
- **fitsync-training-service** - Workouts, exercises, programs
- **fitsync-schedule-service** - Booking & scheduling
- **fitsync-progress-service** - Progress tracking & analytics
- **fitsync-notification-service** - Notifications
- **fitsync-frontend** - React web application
- **fitsync-docker-compose** - Docker orchestration (this repo)

## Prerequisites

Before you begin, ensure you have:

- **Docker Desktop** installed and running
  - Windows/Mac: [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
  - Linux: [docs.docker.com/engine/install](https://docs.docker.com/engine/install/)
- **Git** installed
- **10 GB** free disk space
- **8 GB RAM** minimum (16 GB recommended)

## Setup Methods

### Method 1: Manual Clone (For Development)

If you want to clone all repositories manually for development:

1. **Create a parent directory:**
   ```bash
   mkdir fitsync-app
   cd fitsync-app
   ```

2. **Clone all repositories:**
   ```bash
   # Clone each repository
   git clone https://github.com/FitSync-G13/fitsync-docker-compose.git
   git clone https://github.com/FitSync-G13/fitsync-api-gateway.git
   git clone https://github.com/FitSync-G13/fitsync-user-service.git
   git clone https://github.com/FitSync-G13/fitsync-training-service.git
   git clone https://github.com/FitSync-G13/fitsync-schedule-service.git
   git clone https://github.com/FitSync-G13/fitsync-progress-service.git
   git clone https://github.com/FitSync-G13/fitsync-notification-service.git
   git clone https://github.com/FitSync-G13/fitsync-frontend.git
   ```

3. **Run the setup:**
   ```bash
   cd fitsync-docker-compose

   # Linux/Mac
   chmod +x setup.sh
   ./setup.sh

   # Windows
   setup.bat
   ```

### Method 2: CI/CD Pipeline (For Deployment)

If repositories are already cloned by your CI/CD pipeline:

1. **Navigate to docker-compose directory:**
   ```bash
   cd fitsync-docker-compose
   ```

2. **Start the application:**
   ```bash
   docker compose up -d
   ```

3. **Wait for services to start (30 seconds):**
   ```bash
   sleep 30
   ```

4. **Seed the databases:**
   ```bash
   docker compose exec user-service node src/database/seed.js
   docker compose exec training-service node src/database/seed.js
   ```

## Expected Directory Structure

After cloning all repositories, your directory structure should look like this:

```
parent-directory/
├── fitsync-docker-compose/     # Docker orchestration (THIS REPO)
│   ├── docker-compose.yml
│   ├── setup.sh
│   ├── setup.bat
│   └── README.md
├── fitsync-api-gateway/
├── fitsync-user-service/
├── fitsync-training-service/
├── fitsync-schedule-service/
├── fitsync-progress-service/
├── fitsync-notification-service/
└── fitsync-frontend/
```

## What the Setup Script Does

The `setup.sh` (Linux/Mac) or `setup.bat` (Windows) script will:

1. Check if Docker is installed and running
2. Start all services using docker-compose
3. Wait for services to be healthy
4. Seed databases with test data
5. Verify all services are running
6. Display access URLs and test credentials

## After Setup

Once setup is complete, you can access:

- **Frontend Application:** http://localhost:3000
- **API Gateway:** http://localhost:4000

### Test Credentials

| Role | Email | Password |
|------|-------|----------|
| Client | client@fitsync.com | Client@123 |
| Trainer | trainer@fitsync.com | Trainer@123 |
| Admin | admin@fitsync.com | Admin@123 |
| Gym Owner | gym@fitsync.com | Gym@123 |

## Common Commands

### View Logs
```bash
cd fitsync-docker-compose

# All services
docker compose logs -f

# Specific service
docker compose logs -f user-service
```

### Stop the Application
```bash
cd fitsync-docker-compose
docker compose down
```

### Restart Services
```bash
cd fitsync-docker-compose
docker compose restart
```

### Start After Stopping
```bash
cd fitsync-docker-compose
docker compose up -d
```

### Complete Reset (Clean Slate)
```bash
cd fitsync-docker-compose
docker compose down -v  # Removes all data!
docker compose up -d
```

## Troubleshooting

### Docker Not Running
```bash
# Check Docker status
docker info

# Start Docker Desktop and wait for it to be ready
```

### Port Conflicts
If ports 3000-4000 are in use:
```bash
# Windows
netstat -ano | findstr :3000

# Linux/Mac
lsof -i :3000
```

Modify ports in `docker-compose.yml` if needed.

### Services Not Starting
```bash
# Check service status
docker compose ps

# Check specific service logs
docker compose logs user-service
docker compose logs frontend
```

### Can't Login
```bash
# Re-seed the databases
cd fitsync-docker-compose
docker compose exec user-service node src/database/seed.js
docker compose exec training-service node src/database/seed.js
```

### Database Connection Issues
```bash
# Check database health
docker compose ps | grep db

# Restart databases
docker compose restart userdb trainingdb scheduledb progressdb
```

## Development Workflow

### Running Services Individually

You can run only the databases and develop services locally:

```bash
# Start only infrastructure
docker compose up -d userdb trainingdb scheduledb progressdb redis

# Run a service locally
cd ../fitsync-user-service
npm install
npm run dev
```

### Rebuilding After Code Changes

```bash
# Rebuild specific service
docker compose build user-service
docker compose up -d user-service

# Rebuild all services
docker compose build
docker compose up -d
```

## CI/CD Integration

For CI/CD pipelines, you can use these commands:

```bash
# Build and start services
docker compose up -d --build

# Wait for services to be healthy
docker compose exec user-service sh -c 'until curl -f http://localhost:3001/health; do sleep 1; done'

# Run database migrations/seeds
docker compose exec user-service node src/database/seed.js
docker compose exec training-service node src/database/seed.js

# Run tests
docker compose exec user-service npm test
docker compose exec frontend npm test

# Stop and cleanup
docker compose down -v
```

## System Requirements

### Minimum
- **CPU:** 2 cores
- **RAM:** 8 GB
- **Disk:** 10 GB free space
- **OS:** Windows 10+, macOS 10.15+, Ubuntu 20.04+

### Recommended
- **CPU:** 4 cores
- **RAM:** 16 GB
- **Disk:** 20 GB free space (SSD preferred)

## Getting Help

1. Check the main [README.md](README.md) in this repository
2. Check service-specific README files in each repository
3. Review logs: `docker compose logs <service-name>`
4. For issues, check GitHub repository issues

## Related Documentation

- [API Gateway Documentation](https://github.com/FitSync-G13/fitsync-api-gateway)
- [User Service Documentation](https://github.com/FitSync-G13/fitsync-user-service)
- [Training Service Documentation](https://github.com/FitSync-G13/fitsync-training-service)
- [Frontend Documentation](https://github.com/FitSync-G13/fitsync-frontend)

## License

MIT
