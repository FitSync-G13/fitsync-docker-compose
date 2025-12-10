# FitSync Docker Compose

Docker Compose configuration for running the complete FitSync multi-repository application.

## Overview

This repository contains the Docker Compose orchestration for the FitSync microservices application. It manages all services, databases, and infrastructure components required to run FitSync locally or in deployment environments.

## Quick Start for Testers

If you're testing the FitSync application, see **[SETUP.md](SETUP.md)** for complete setup instructions.

**TL;DR:**
1. Clone all 8 repositories to the same parent directory
2. Navigate to this repository
3. Run `./setup.sh` (Linux/Mac) or `setup.bat` (Windows)
4. Access the app at http://localhost:3000

## Services

The docker-compose.yml includes:

### Application Services
- **API Gateway** (Port 4000) - Request routing and composition
- **User Service** (Port 3001) - Authentication and user management
- **Training Service** (Port 3002) - Workout programs and exercises
- **Schedule Service** (Port 8003) - Booking and availability management
- **Progress Service** (Port 8004) - Progress tracking and analytics
- **Notification Service** (Port 3005) - Multi-channel notifications
- **Frontend** (Port 3000) - React web application

### Infrastructure Services
- **PostgreSQL Databases** (4 instances: ports 5432-5435)
  - userdb - User service database
  - trainingdb - Training service database
  - scheduledb - Schedule service database
  - progressdb - Progress service database
- **Redis** (Port 6379) - Caching and pub/sub messaging

## Prerequisites

- **Docker Desktop** installed and running
- **Docker Compose V2** (included with Docker Desktop)
- **Git** for cloning repositories
- **10 GB** free disk space
- **8 GB RAM** minimum (16 GB recommended)

## Repository Structure

FitSync uses a multi-repository architecture. All repositories must be cloned to the same parent directory:

```
parent-directory/
├── fitsync-docker-compose/         # THIS REPOSITORY - Orchestration
├── fitsync-api-gateway/            # API Gateway
├── fitsync-user-service/           # User management
├── fitsync-training-service/       # Workouts & exercises
├── fitsync-schedule-service/       # Booking system
├── fitsync-progress-service/       # Progress tracking
├── fitsync-notification-service/   # Notifications
└── fitsync-frontend/               # React web app
```

## Quick Start

### Automated Setup (Recommended)

**Linux/Mac:**
```bash
chmod +x setup.sh
./setup.sh
```

**Windows:**
```batch
setup.bat
```

The setup script will:
1. Check Docker installation
2. Verify all repositories are present
3. Start all services
4. Seed databases with test data
5. Display access URLs and credentials

### Manual Setup

If you prefer manual setup or the automated script doesn't work:

1. **Start all services:**
   ```bash
   docker compose up -d
   ```

2. **Wait for services to start (30 seconds):**
   ```bash
   sleep 30
   ```

3. **Seed the databases:**
   ```bash
   docker compose exec user-service node src/database/seed.js
   docker compose exec training-service node src/database/seed.js
   ```

4. **Verify services are running:**
   ```bash
   docker compose ps
   ```

## Access the Application

Once setup is complete:

- **Frontend:** http://localhost:3000
- **API Gateway:** http://localhost:4000

**Test Credentials:**
- Client: `client@fitsync.com` / `Client@123`
- Trainer: `trainer@fitsync.com` / `Trainer@123`
- Admin: `admin@fitsync.com` / `Admin@123`
- Gym Owner: `gym@fitsync.com` / `Gym@123`

## Common Commands

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f user-service
docker compose logs -f frontend
```

### Stop Services
```bash
# Stop all services
docker compose down

# Stop and remove volumes (clean slate)
docker compose down -v
```

### Restart Services
```bash
# Restart all
docker compose restart

# Restart specific service
docker compose restart user-service
```

### Rebuild After Code Changes
```bash
# Rebuild specific service
docker compose build user-service
docker compose up -d user-service

# Rebuild all
docker compose build
docker compose up -d
```

## Service URLs

Once running, access services at:

- **Frontend**: http://localhost:3000
- **API Gateway**: http://localhost:4000
- **User Service**: http://localhost:3001
- **Training Service**: http://localhost:3002
- **Schedule Service**: http://localhost:8003
- **Progress Service**: http://localhost:8004
- **Notification Service**: http://localhost:3005

## Database Connections

All databases are configured with TLS enabled (insecure certificates for development).

Connection strings:
```
postgresql://fitsync:password@localhost:5432/userdb?sslmode=require
postgresql://fitsync:password@localhost:5433/trainingdb?sslmode=require
postgresql://fitsync:password@localhost:5434/scheduledb?sslmode=require
postgresql://fitsync:password@localhost:5435/progressdb?sslmode=require
```

## Development Workflow

### Running Individual Services

```bash
# Start only databases and redis
docker-compose up -d userdb trainingdb scheduledb progressdb redis

# Then run services individually on your host
cd ../fitsync-user-service
npm install
npm run dev
```

### Rebuilding Services

```bash
# Rebuild specific service
docker-compose build user-service

# Rebuild all
docker-compose build

# Rebuild and restart
docker-compose up -d --build user-service
```

### Database Migrations

```bash
# Run migrations for user service
docker-compose exec user-service npm run migrate

# Run migrations for all Node.js services
docker-compose exec user-service npm run migrate
docker-compose exec training-service npm run migrate

# Python services run migrations on startup
```

## Troubleshooting

### Services Not Starting

```bash
# Check logs
docker-compose logs <service-name>

# Check service status
docker-compose ps

# Restart specific service
docker-compose restart <service-name>
```

### Database Connection Issues

```bash
# Check database is running
docker-compose ps | grep db

# Connect to database
docker-compose exec userdb psql -U fitsync -d userdb

# Check database logs
docker-compose logs userdb
```

### Port Conflicts

If ports are already in use, you can modify them in `docker-compose.yml`:

```yaml
services:
  user-service:
    ports:
      - "3001:3001"  # Change first number to use different host port
```

### Reset Everything

```bash
# Stop all services and remove volumes
docker-compose down -v

# Remove all containers, networks, images
docker-compose down -v --rmi all

# Start fresh
docker-compose up -d
```

## Environment Variables

Each service has its own `.env` file created by `init-env.sh`:

- `services/api-gateway/.env`
- `services/user-service/.env`
- `services/training-service/.env`
- `services/schedule-service/.env`
- `services/progress-service/.env`
- `services/notification-service/.env`
- `frontend/.env`

Modify these files to customize service configuration.

## Network

All services communicate via the `fitsync-network` bridge network with service discovery using container names.

## Volumes

Persistent volumes are created for:
- Database data (userdb_data, trainingdb_data, scheduledb_data, progressdb_data)
- Redis data (redis_data)

## Related Repositories

- [fitsync-api-gateway](https://github.com/FitSync-G13/fitsync-api-gateway)
- [fitsync-user-service](https://github.com/FitSync-G13/fitsync-user-service)
- [fitsync-training-service](https://github.com/FitSync-G13/fitsync-training-service)
- [fitsync-schedule-service](https://github.com/FitSync-G13/fitsync-schedule-service)
- [fitsync-progress-service](https://github.com/FitSync-G13/fitsync-progress-service)
- [fitsync-notification-service](https://github.com/FitSync-G13/fitsync-notification-service)
- [fitsync-frontend](https://github.com/FitSync-G13/fitsync-frontend)

## License

MIT
