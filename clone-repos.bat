@echo off
REM FitSync Multi-Repo Clone Script for Windows
REM This script clones all FitSync repositories for local development/testing

setlocal enabledelayedexpansion

echo ======================================
echo    FitSync Multi-Repo Clone Script
echo ======================================
echo.

REM GitHub organization
set ORG=FitSync-G13

REM List of repositories to clone
set REPOS=fitsync-api-gateway fitsync-user-service fitsync-training-service fitsync-schedule-service fitsync-progress-service fitsync-notification-service fitsync-frontend

REM Get the parent directory
set PARENT_DIR=%~dp0..

echo This script will clone the following repositories:
for %%R in (%REPOS%) do (
    echo   - %%R
)
echo.
echo Repositories will be cloned to: %PARENT_DIR%
echo.

REM Check if git is installed
where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Git is not installed. Please install Git first.
    pause
    exit /b 1
)

echo [OK] Git is installed
echo.

REM Ask for confirmation
set /p CONFIRM="Do you want to proceed? (y/n) "
if /i not "%CONFIRM%"=="y" (
    echo Cancelled.
    exit /b 0
)

echo.
echo Starting repository cloning...
echo.

REM Clone each repository
for %%R in (%REPOS%) do (
    set REPO_PATH=%PARENT_DIR%\%%R

    if exist "!REPO_PATH!" (
        echo [WARNING] %%R already exists, skipping...
    ) else (
        echo Cloning %%R...
        git clone https://github.com/%ORG%/%%R.git "!REPO_PATH!"
        if !ERRORLEVEL! EQU 0 (
            echo [OK] Successfully cloned %%R
        ) else (
            echo [ERROR] Failed to clone %%R
            echo You may need to check your internet connection or repository access
        )
    )
    echo.
)

echo ======================================
echo [OK] Repository Cloning Complete!
echo ======================================
echo.
echo Directory structure:
echo.
echo %PARENT_DIR%\
echo ├── fitsync-docker-compose\     (this repo)
echo ├── fitsync-api-gateway\
echo ├── fitsync-user-service\
echo ├── fitsync-training-service\
echo ├── fitsync-schedule-service\
echo ├── fitsync-progress-service\
echo ├── fitsync-notification-service\
echo └── fitsync-frontend\
echo.
echo Next steps:
echo 1. Ensure Docker Desktop is installed and running
echo 2. Run the setup script:
echo    setup.bat
echo.
echo For detailed instructions, see README.md
echo.
pause
