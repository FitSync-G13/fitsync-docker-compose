# FitSync Docker Compose - File Guide

This document explains all the files in this repository and how testers should use them.

## Files for Testers

### Primary Documentation

1. **[QUICKSTART.md](QUICKSTART.md)** - Start here!
   - 5-minute quick start guide
   - Step-by-step instructions
   - Minimal explanations, maximum action

2. **[SETUP.md](SETUP.md)** - Complete setup guide
   - Detailed setup instructions
   - Both manual and automated methods
   - Troubleshooting section
   - CI/CD integration notes

3. **[README.md](README.md)** - Technical documentation
   - Docker Compose reference
   - Service architecture
   - Development workflow
   - Advanced usage

### Setup Scripts

4. **[clone-all-repos.sh](clone-all-repos.sh)** / **[clone-all-repos.bat](clone-all-repos.bat)**
   - **Purpose:** Clone all 8 FitSync repositories at once
   - **When to use:** When starting from scratch
   - **Usage:** Run this FIRST before anything else
   - **Output:** All repos cloned to current directory

5. **[setup.sh](setup.sh)** / **[setup.bat](setup.bat)**
   - **Purpose:** Complete automated setup of FitSync
   - **When to use:** After cloning all repositories
   - **What it does:**
     - Checks Docker installation
     - Verifies all repos are present
     - Starts all services
     - Seeds databases with test data
     - Shows access URLs and credentials
   - **Usage:** Run this SECOND after cloning repos

6. **[clone-repos.sh](clone-repos.sh)** / **[clone-repos.bat](clone-repos.bat)**
   - **Purpose:** Clone other repos from within docker-compose repo
   - **When to use:** If you cloned docker-compose repo first
   - **Note:** Similar to clone-all-repos but runs from within this repo

### Docker Compose Configuration

7. **[docker-compose.yml](docker-compose.yml)**
   - **Purpose:** Defines all services, databases, and infrastructure
   - **Services defined:**
     - 4 PostgreSQL databases (userdb, trainingdb, scheduledb, progressdb)
     - 1 Redis cache
     - 5 Microservices (user, training, schedule, progress, notification)
     - 1 API Gateway
     - 1 Frontend app
   - **Ports exposed:**
     - 3000 - Frontend
     - 3001-3005 - Microservices
     - 4000 - API Gateway
     - 5432-5435 - PostgreSQL databases
     - 6379 - Redis
     - 8003-8004 - Python services

### Other Files (Legacy/Optional)

8. **init-env.sh** / **init-env.bat**
   - Legacy environment initialization
   - Not needed if using setup scripts

9. **start-all-services.sh** / **start-services.bat**
   - Legacy startup scripts
   - Not needed if using setup scripts

10. **check-secrets.sh** / **check-secrets.bat**
    - Security checker for secrets in code
    - Optional utility

11. **.gitignore**
    - Git ignore rules

## Recommended Workflow for Testers

### First Time Setup

```bash
# Step 1: Download and run clone script
curl -O https://raw.githubusercontent.com/FitSync-G13/fitsync-docker-compose/main/clone-all-repos.sh
chmod +x clone-all-repos.sh
./clone-all-repos.sh

# Step 2: Run setup
cd fitsync-docker-compose
./setup.sh

# Step 3: Access the app
# Open http://localhost:3000
# Login: client@fitsync.com / Client@123
```

### Alternative: Manual Clone

```bash
# Create directory
mkdir fitsync-app && cd fitsync-app

# Clone all repos
git clone https://github.com/FitSync-G13/fitsync-docker-compose.git
git clone https://github.com/FitSync-G13/fitsync-api-gateway.git
git clone https://github.com/FitSync-G13/fitsync-user-service.git
git clone https://github.com/FitSync-G13/fitsync-training-service.git
git clone https://github.com/FitSync-G13/fitsync-schedule-service.git
git clone https://github.com/FitSync-G13/fitsync-progress-service.git
git clone https://github.com/FitSync-G13/fitsync-notification-service.git
git clone https://github.com/FitSync-G13/fitsync-frontend.git

# Run setup
cd fitsync-docker-compose
./setup.sh
```

## Files You Should Commit to Git

When pushing this repository, include:

- [x] README.md
- [x] SETUP.md
- [x] QUICKSTART.md
- [x] FILE_GUIDE.md (this file)
- [x] docker-compose.yml
- [x] setup.sh & setup.bat
- [x] clone-all-repos.sh & clone-all-repos.bat
- [x] clone-repos.sh & clone-repos.bat
- [x] .gitignore

## Files to Share with Testers

Send testers one of these:

**Option 1: Just the clone script**
- Share: `clone-all-repos.sh` or `clone-all-repos.bat`
- They run it, it clones everything, they're done

**Option 2: Link to the docker-compose repo**
- Share: https://github.com/FitSync-G13/fitsync-docker-compose
- They clone it, read QUICKSTART.md, follow instructions

**Option 3: Complete instructions**
- Share: QUICKSTART.md as a text file or PDF
- Self-contained guide with all steps

## Summary

### For Testers (Simplest Path)
1. Read [QUICKSTART.md](QUICKSTART.md)
2. Run `clone-all-repos.sh` or manually clone all 8 repos
3. Run `setup.sh` or `setup.bat`
4. Open http://localhost:3000
5. Done!

### For Developers (Full Details)
1. Read [SETUP.md](SETUP.md) for comprehensive guide
2. Read [README.md](README.md) for Docker Compose reference
3. Understand the multi-repo architecture
4. Use docker-compose for local development

### For CI/CD Pipelines
1. Clone all repos to same directory
2. Run `docker compose up -d` in fitsync-docker-compose
3. Run database seeds
4. Run tests
5. Deploy or tear down

## Questions?

- Check [QUICKSTART.md](QUICKSTART.md) for quick answers
- Check [SETUP.md](SETUP.md) for detailed answers
- Check [README.md](README.md) for Docker Compose specifics
- Check service logs: `docker compose logs -f <service-name>`
