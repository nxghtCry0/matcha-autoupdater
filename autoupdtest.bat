::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAnk
::fBw5plQjdG8=
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF65
::cxAkpRVqdFKZSjk=
::cBs/ulQjdF65
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFA9RSQ6DAE+1BaAR7ebv/NaCnkAcQOE3ecLaz6CBNfAX61HhY8dj02Jf+A==
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: Section 1: Environment Setup
:: ============================================================================
:: Set console to UTF-8 to properly display ASCII art and special characters.
chcp 65001 >nul

:: Set the main executable name to check for running processes.
set "appName=app.exe"


:: ============================================================================
:: Section 2: Administrative Privileges Check
:: ============================================================================
:: This block checks if the script is running with administrator rights.
:: If not, it re-launches itself with elevated permissions.
:: ----------------------------------------------------------------------------
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    cls
    echo.
    echo ====================================
    echo  Requesting Administrator Privileges
    echo ====================================
    echo.
    echo This script requires administrator privileges to run correctly.
    echo Please click "Yes" on the UAC prompt to continue.
    powershell -Command "Start-Process '%~f0' -Verb RunAs" >nul 2>&1
    exit /b
)

:: ============================================================================
:: Section 3: Initial Setup & Welcome Message
:: ============================================================================
title Matcha Software Updater
color 07

cls
echo.
echo  ███╗   ███╗ █████╗ ████████╗ ██████╗██╗  ██╗ █████╗ 
echo  ████╗ ████║██╔══██╗╚══██╔══╝██╔════╝██║  ██║██╔══██╗
echo  ██╔████╔██║███████║   ██║   ██║     ███████║███████║
echo  ██║╚██╔╝██║██╔══██║   ██║   ██║     ██╔══██║██╔══██║
echo  ██║ ╚═╝ ██║██║  ██║   ██║   ╚██████╗██║  ██║██║  ██║
echo  ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝
echo.
echo                    Automatic Updater
echo =========================================================
echo.
color 0B
echo  Official Source: https://gitlab.com/tejascerts/matcha-autoupdater
echo  This tool downloads and extracts the latest version of Matcha.
echo  You still need a valid license to use the software.
echo.
color 07
echo  Press any key to begin the update process...
pause > nul
cls

:: ============================================================================
:: Section 4: Prerequisite Check
:: ============================================================================
echo [*] Checking for required tools...
where bitsadmin >nul 2>&1
if %errorlevel% NEQ 0 (
    color 0C
    echo [ERROR] BITSAdmin tool not found. This tool is required for downloading.
    goto :error_exit
)
where tar >nul 2>&1
if %errorlevel% NEQ 0 (
    color 0C
    echo [ERROR] TAR tool not found. This tool is required for extraction.
    goto :error_exit
)
echo     All required tools are present.
echo.
timeout /t 2 /nobreak >nul

:: ============================================================================
:: Section 5: Download
:: ============================================================================
set "tempDir=%TEMP%\matcha_update_%RANDOM%"
mkdir "%tempDir%" > nul 2>&1
cd /d "%tempDir%"

color 0E
echo [1/3] Downloading latest Matcha version...
echo      Please wait, this may take a moment.
echo.
set "downloadURL=https://gitlab.com/tejascerts/matcha-autoupdater/-/raw/main/matcha.rar?inline=false"
set "downloadFile=%tempDir%\matcha.rar"

bitsadmin /transfer "matchaDownloadJob" "%downloadURL%" "%downloadFile%"
if %errorlevel% NEQ 0 (
    cls
    color 0C
    echo ============================
    echo      DOWNLOAD FAILED
    echo ============================
    echo.
    echo Could not download the update file from the server.
    echo Please check your internet connection and try again.
    echo.
    echo URL: %downloadURL%
    goto :cleanup
)

color 0A
echo.
echo      Download complete!
echo.
color 07
echo  Press any key to select the installation folder...
pause > nul
cls

:: ============================================================================
:: Section 6: Get Extraction Path
:: ============================================================================
set "extractPath="
color 0E
echo [2/3] Select Installation Folder...
echo      Please choose the folder where Matcha should be updated.
echo      This is typically your existing Matcha installation directory.
echo.
color 0C
echo      WARNING: Existing files in the selected folder will be overwritten.
color 0E
echo.

set "psCommand=Add-Type -AssemblyName System.windows.forms; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.Description = 'Select the folder to install/update Matcha'; $folderBrowser.ShowNewFolderButton = $true; if ($folderBrowser.ShowDialog() -eq 'OK') { $folderBrowser.SelectedPath }"
for /f "usebackq delims=" %%i in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "%psCommand%"`) do set "extractPath=%%i"

if not defined extractPath (
    cls
    color 0C
    echo ============================
    echo      NO FOLDER SELECTED
    echo ============================
    echo.
    echo You did not select a folder. The update process has been cancelled.
    goto :cleanup
)
cls

:: ============================================================================
:: Section 7: Check for Running Application
:: ============================================================================
:check_process
color 0E
echo [*] Checking if Matcha is currently running...
tasklist /FI "IMAGENAME eq %appName%" 2>NUL | find /I /N "%appName%">NUL
if "%ERRORLEVEL%"=="0" (
    color 0C
    echo.
    echo      WARNING: Matcha is currently running.
    echo      Please close the application completely before proceeding.
    echo.
    color 07
    echo      Press any key to check again, or close this window to cancel.
    pause >nul
    cls
    goto :check_process
)
echo      Application is not running. Proceeding with installation.
echo.
timeout /t 2 /nobreak >nul

:: ============================================================================
:: Section 8: Extraction
:: ============================================================================
color 0E
echo [3/3] Installing Update...
echo.
echo      Target Folder: "%extractPath%"
echo.
echo      Extracting files...
echo.

tar -xf "%downloadFile%" -C "%extractPath%"
if %errorlevel% NEQ 0 (
    cls
    color 0C
    echo ============================
    echo      EXTRACTION FAILED
    echo ============================
    echo.
    echo Could not extract the update files.
    echo Please ensure you have permissions to write to the selected folder:
    echo "%extractPath%"
    echo.
    echo The downloaded archive may also be corrupt.
    goto :cleanup
)

:: ============================================================================
:: Section 9: Completion & Cleanup
:: ============================================================================
cls
color 0A
echo.
echo   ╔══════════════════════════════════════════════════╗
echo   ║                                                  ║
echo   ║                Update Complete!                  ║
echo   ║                                                  ║
echo   ║   Matcha has been successfully updated.          ║
echo   ║                                                  ║
echo   ╚══════════════════════════════════════════════════╝
echo.
echo.
goto :cleanup

:error_exit
echo.
echo  The script cannot continue and will now exit.

:cleanup
color 07
echo  Cleaning up temporary files...
if exist "%tempDir%" rmdir /s /q "%tempDir%"
echo  Done.
echo.
echo  Press any key to exit.
pause > nul
endlocal
exit /b