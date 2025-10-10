@echo off
setlocal enabledelayedexpansion

rem Z.AI CLI Wrapper Installation Script for Windows (CMD)

set INSTALL_DIR=%USERPROFILE%\.local\bin
set CLAUDE_DIR=%USERPROFILE%\.claude

echo.
echo ===============================================================
echo          Z.AI CLI Wrapper Installation Script
echo ===============================================================
echo.

rem Check if running from the project directory
if not exist "bin\z" (
    echo Error: Please run this script from the project root directory.
    exit /b 1
)
if not exist "bin\z.cmd" (
    echo Error: Please run this script from the project root directory.
    exit /b 1
)
if not exist "bin\z.ps1" (
    echo Error: Please run this script from the project root directory.
    exit /b 1
)

rem Check for existing installation
if exist "%INSTALL_DIR%\z.cmd" (
    echo.
    echo Existing installation detected at %INSTALL_DIR%
    echo.
    echo Options:
    echo   1^) Reinstall/Upgrade ^(recommended - overwrites existing files^)
    echo   2^) Cancel installation
    echo.
    set /p INSTALL_CHOICE="Choose [1-2]: "

    if not "!INSTALL_CHOICE!"=="1" (
        echo Installation cancelled.
        exit /b 0
    )
    echo.
    echo Proceeding with reinstallation/upgrade...
    echo.
)

rem Check for jq dependency
where jq >nul 2>&1
if errorlevel 1 (
    echo Warning: 'jq' is not installed.
    echo The wrapper scripts require jq to parse configuration files.
    echo.
    echo Install jq using one of these methods:
    echo   - Chocolatey: choco install jq
    echo   - Scoop: scoop install jq
    echo   - Download from: https://stedolan.github.io/jq/download/
    echo.
    set /p CONTINUE="Continue anyway? [y/N]: "
    if /i not "!CONTINUE!"=="y" exit /b 1
)

rem Create installation directory if it doesn't exist
echo Creating installation directory...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

rem Copy wrapper scripts
echo Installing wrapper scripts...
copy /Y "bin\z" "%INSTALL_DIR%\z" >nul
copy /Y "bin\z.cmd" "%INSTALL_DIR%\z.cmd" >nul
copy /Y "bin\z.ps1" "%INSTALL_DIR%\z.ps1" >nul

echo [OK] Wrapper scripts installed to %INSTALL_DIR%

rem Check if INSTALL_DIR is in PATH
echo %PATH% | find /i "%INSTALL_DIR%" >nul
if errorlevel 1 (
    echo.
    echo Warning: %INSTALL_DIR% is not in your PATH.
    echo.
    set /p ADD_PATH="Would you like to add %INSTALL_DIR% to your PATH? [y/N]: "
    
    if /i "!ADD_PATH!"=="y" (
        rem Add to user PATH using setx
        setx PATH "%PATH%;%INSTALL_DIR%" >nul 2>&1
        if errorlevel 1 (
            echo Error: Failed to update PATH.
            echo To add manually, run:
            echo   setx PATH "%%PATH%%;%INSTALL_DIR%"
        ) else (
            echo [OK] Added %INSTALL_DIR% to your PATH
            echo     Please restart your terminal for changes to take effect.
        )
    ) else (
        echo.
        echo To add %INSTALL_DIR% to your PATH manually, run:
        echo   setx PATH "%%PATH%%;%INSTALL_DIR%"
    )
) else (
    echo [OK] %INSTALL_DIR% is already in your PATH
)

rem Ask about Claude status line installation
echo.
echo Claude Status Line Configuration
echo The status line displays model info, git branch, code changes, timing, and cost.
echo.
set /p INSTALL_STATUS="Would you like to install the Claude status line configuration? [y/N]: "

if /i "!INSTALL_STATUS!"=="y" (
    echo Installing Claude status line...
    
    rem Create Claude directory
    if not exist "%CLAUDE_DIR%" mkdir "%CLAUDE_DIR%"
    
    rem Copy status line script
    copy /Y "claude\statusLine.sh" "%CLAUDE_DIR%\statusLine.sh" >nul
    
    echo [OK] Status line script installed to %CLAUDE_DIR%
    
    rem Handle settings.json
    set SETTINGS_FILE=%CLAUDE_DIR%\settings.json
    
    if exist "!SETTINGS_FILE!" (
        echo.
        echo Existing settings.json found.
        echo Options:
        echo   1^) Backup existing and replace
        echo   2^) Skip settings.json update
        set /p SETTINGS_CHOICE="Choose [1-2]: "
        
        if "!SETTINGS_CHOICE!"=="1" (
            rem Backup and replace
            for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set DATE=%%c%%a%%b
            for /f "tokens=1-2 delims=: " %%a in ('time /t') do set TIME=%%a%%b
            set BACKUP_FILE=!SETTINGS_FILE!.backup.!DATE!_!TIME!
            move "!SETTINGS_FILE!" "!BACKUP_FILE!" >nul
            copy /Y "claude\settings.json" "!SETTINGS_FILE!" >nul
            echo [OK] Settings replaced ^(backup saved to !BACKUP_FILE!^)
        ) else (
            echo Skipped settings.json update
            echo To enable the status line, add this to !SETTINGS_FILE!:
            type "claude\settings.json"
        )
    ) else (
        rem No existing settings, just copy
        copy /Y "claude\settings.json" "!SETTINGS_FILE!" >nul
        echo [OK] Settings file created
    )
    
    rem Note about Git Bash requirement
    echo.
    echo Note: The status line script requires Git Bash or WSL to run.
    echo Make sure you have Git for Windows installed with Git Bash.
) else (
    echo Skipped Claude status line installation
)

rem Installation complete
echo.
echo ===============================================================
echo              Installation Complete!
echo ===============================================================
echo.
echo Next steps:
echo   1. Restart your terminal ^(CMD, PowerShell, or Git Bash^)
echo   2. Run 'z' to configure your Z.AI API key ^(first-time setup^)
echo   3. Use 'z' instead of 'claude' to launch Claude Code with Z.AI
echo.
echo For more information, see README.md
echo.

if /i "!ADD_PATH!"=="y" (
    echo IMPORTANT: Please restart your terminal for PATH changes to take effect!
    echo.
)

pause

