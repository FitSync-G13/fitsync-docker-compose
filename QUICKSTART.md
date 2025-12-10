# FitSync Quick Start Guide

Get FitSync running in 5 minutes!

## Prerequisites

- Docker Desktop installed and running
- Git installed

## Step 1: Clone All Repositories

Create a folder and clone all 8 repositories:

```bash
# Create parent directory
mkdir fitsync-app
cd fitsync-app

# Clone all repositories
git clone https://github.com/FitSync-G13/fitsync-docker-compose.git
git clone https://github.com/FitSync-G13/fitsync-api-gateway.git
git clone https://github.com/FitSync-G13/fitsync-user-service.git
git clone https://github.com/FitSync-G13/fitsync-training-service.git
git clone https://github.com/FitSync-G13/fitsync-schedule-service.git
git clone https://github.com/FitSync-G13/fitsync-progress-service.git
git clone https://github.com/FitSync-G13/fitsync-notification-service.git
git clone https://github.com/FitSync-G13/fitsync-frontend.git
```

**Alternatively**, if you have clone-repos script:
```bash
cd fitsync-docker-compose
./clone-repos.sh      # Linux/Mac
clone-repos.bat       # Windows
```

## Step 2: Run Setup Script

```bash
cd fitsync-docker-compose

# Linux/Mac
chmod +x setup.sh
./setup.sh

# Windows
setup.bat
```

## Step 3: Access the Application

Open your browser and go to:
- **http://localhost:3000**

Login with:
- **Email:** client@fitsync.com
- **Password:** Client@123

## That's It!

You're all set! The application is now running.

## What's Running?

- Frontend (React app) - Port 3000
- API Gateway - Port 4000
- 5 Microservices (User, Training, Schedule, Progress, Notification)
- 4 PostgreSQL Databases
- 1 Redis Cache

All running in Docker containers!

## Test Users

| Role | Email | Password |
|------|-------|----------|
| Client | client@fitsync.com | Client@123 |
| Trainer | trainer@fitsync.com | Trainer@123 |
| Admin | admin@fitsync.com | Admin@123 |
| Gym Owner | gym@fitsync.com | Gym@123 |

## Common Commands

**View logs:**
```bash
docker compose logs -f
```

**Stop everything:**
```bash
docker compose down
```

**Start again:**
```bash
docker compose up -d
```

**Fresh start (delete all data):**
```bash
docker compose down -v
./setup.sh
```

## Need Help?

- See [SETUP.md](SETUP.md) for detailed instructions
- See [README.md](README.md) for Docker Compose documentation
- Check logs: `docker compose logs -f <service-name>`

## Troubleshooting

**Problem:** Port already in use
- Stop other apps using ports 3000-4000
- Or change ports in docker-compose.yml

**Problem:** Docker not running
- Start Docker Desktop
- Wait for the green icon

**Problem:** Can't login
- Re-run the setup script

**Problem:** Services not starting
- Check: `docker compose ps`
- View logs: `docker compose logs <service-name>`
