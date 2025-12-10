@echo off
REM FitSync Multi-Repo Setup Script for Windows
REM This script automates the complete setup process for the FitSync application

setlocal enabledelayedexpansion

echo ======================================
echo    FitSync Application Setup
echo ======================================
echo.

REM Check prerequisites
echo Step 1: Checking prerequisites...

REM Check if Docker is installed
where docker >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not installed
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Check if Docker is running
docker info >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not running
    echo Please start Docker Desktop and try again
    pause
    exit /b 1
)

REM Check if Docker Compose is available
docker compose version >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker Compose is not available
    echo Please install Docker Compose V2
    pause
    exit /b 1
)

echo [OK] Docker is installed and running
echo [OK] Docker Compose is available
echo.

REM Check if all required repositories exist
echo Step 2: Verifying repository structure...
set PARENT_DIR=%~dp0..
set MISSING_REPOS=

set REPOS=fitsync-api-gateway fitsync-user-service fitsync-training-service fitsync-schedule-service fitsync-progress-service fitsync-notification-service fitsync-frontend

for %%R in (%REPOS%) do (
    if not exist "%PARENT_DIR%\%%R" (
        set MISSING_REPOS=!MISSING_REPOS! %%R
    )
)

if not "!MISSING_REPOS!"=="" (
    echo [ERROR] Missing required repositories:
    for %%R in (!MISSING_REPOS!) do echo   - %%R
    echo.
    echo Please clone all required repositories to the parent directory:
    echo %PARENT_DIR%
    echo.
    echo See SETUP.md for cloning instructions
    pause
    exit /b 1
)

echo [OK] All required repositories found
echo.

REM Start Docker services
echo Step 3: Starting FitSync services...
docker compose up -d

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to start services
    pause
    exit /b 1
)

echo.
echo Step 4: Waiting for services to start (30 seconds)...
timeout /t 30 /nobreak >nul

REM Check service health
echo.
echo Step 5: Checking service health...

docker compose ps | find "Up" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Some services may not be running
    echo.
    docker compose ps
    echo.
    echo Run 'docker compose logs <service-name>' to check logs
    pause
    exit /b 1
)

echo [OK] Services are running
echo.

REM Seed databases
echo Step 6: Seeding databases with test data...

echo [INFO] Seeding user service database...
docker compose exec -T user-service node src/database/seed.js >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] User database seeded successfully
) else (
    echo [WARNING] User database seeding may have failed (could be already seeded)
)

echo [INFO] Seeding training service database...
docker compose exec -T training-service node src/database/seed.js >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Training database seeded successfully
) else (
    echo [WARNING] Training database seeding may have failed (could be already seeded)
)

echo.
echo ======================================
echo [OK] Setup Complete!
echo ======================================
echo.
echo Application URLs:
echo   Frontend:    http://localhost:3000
echo   API Gateway: http://localhost:4000
echo.
echo Test Credentials:
echo   Email:    client@fitsync.com
echo   Password: Client@123
echo.
echo Other test users:
echo   - admin@fitsync.com    / Admin@123
echo   - trainer@fitsync.com  / Trainer@123
echo   - gym@fitsync.com      / Gym@123
echo.
echo Useful Commands:
echo   docker compose logs -f           # View logs
echo   docker compose logs -f ^<service^> # View specific service logs
echo   docker compose restart ^<service^> # Restart a service
echo   docker compose down              # Stop all services
echo   docker compose down -v           # Stop and remove all data
echo.
echo Happy testing!
echo.
pause
