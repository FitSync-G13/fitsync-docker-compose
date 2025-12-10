@echo off
REM FitSync - Clone All Repositories Script for Windows
REM Download and run this script first to clone all FitSync repositories

setlocal enabledelayedexpansion

echo ======================================
echo    FitSync Repository Cloner
echo ======================================
echo.

REM GitHub organization
set ORG=FitSync-G13

REM All repositories
set REPOS=fitsync-docker-compose fitsync-api-gateway fitsync-user-service fitsync-training-service fitsync-schedule-service fitsync-progress-service fitsync-notification-service fitsync-frontend

echo This script will clone all FitSync repositories
echo.
echo Repositories to clone:
for %%R in (%REPOS%) do echo   - %%R
echo.
echo They will be cloned to: %CD%
echo.

REM Check git
where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Git is not installed
    pause
    exit /b 1
)

REM Confirm
set /p CONFIRM="Continue? (y/n) "
if /i not "%CONFIRM%"=="y" (
    exit /b 0
)

echo.
echo Cloning repositories...
echo.

REM Clone each repo
for %%R in (%REPOS%) do (
    if exist "%%R" (
        echo [WARNING] %%R already exists, skipping
    ) else (
        echo Cloning %%R...
        git clone https://github.com/%ORG%/%%R.git
        if !ERRORLEVEL! EQU 0 (
            echo [OK] %%R cloned
        ) else (
            echo ERROR: Failed to clone %%R
        )
    )
    echo.
)

echo ======================================
echo [OK] All repositories cloned!
echo ======================================
echo.
echo Directory structure:
echo.
echo %CD%
for %%R in (%REPOS%) do (
    if exist "%%R" echo ├── %%R\
)
echo.
echo Next steps:
echo 1. Make sure Docker Desktop is running
echo 2. Run setup:
echo    cd fitsync-docker-compose
echo    setup.bat
echo.
echo 3. Open http://localhost:3000 in your browser
echo 4. Login with: client@fitsync.com / Client@123
echo.
pause
