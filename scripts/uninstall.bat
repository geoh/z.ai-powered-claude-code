@echo off
setlocal enabledelayedexpansion

rem Z.AI CLI Wrapper Uninstallation Script for Windows (CMD)

set INSTALL_DIR=%USERPROFILE%\.local\bin
set CLAUDE_DIR=%USERPROFILE%\.claude

echo.
echo ===============================================================
echo          Z.AI CLI Wrapper Uninstallation Script
echo ===============================================================
echo.

rem Check for installed files
set FILES_FOUND=0
if exist "%INSTALL_DIR%\z" set FILES_FOUND=1
if exist "%INSTALL_DIR%\z.cmd" set FILES_FOUND=1
if exist "%INSTALL_DIR%\z.ps1" set FILES_FOUND=1
if exist "%INSTALL_DIR%\glm" set FILES_FOUND=1
if exist "%INSTALL_DIR%\glm.cmd" set FILES_FOUND=1
if exist "%INSTALL_DIR%\glm.ps1" set FILES_FOUND=1

if %FILES_FOUND%==0 (
    echo No Z.AI wrapper scripts found in %INSTALL_DIR%
) else (
    echo Found Z.AI wrapper scripts in %INSTALL_DIR%
    echo.
    set /p REMOVE_SCRIPTS="Remove wrapper scripts (including glm shims)? [y/N]: "

    if /i "!REMOVE_SCRIPTS!"=="y" (
        if exist "%INSTALL_DIR%\z" (
            del "%INSTALL_DIR%\z"
            if errorlevel 1 (
                echo Error: Failed to remove %INSTALL_DIR%\z
            ) else (
                echo [OK] Removed %INSTALL_DIR%\z
            )
        )
        if exist "%INSTALL_DIR%\z.cmd" (
            del "%INSTALL_DIR%\z.cmd"
            if errorlevel 1 (
                echo Error: Failed to remove %INSTALL_DIR%\z.cmd
            ) else (
                echo [OK] Removed %INSTALL_DIR%\z.cmd
            )
        )
        if exist "%INSTALL_DIR%\z.ps1" (
            del "%INSTALL_DIR%\z.ps1"
            if errorlevel 1 (
                echo Error: Failed to remove %INSTALL_DIR%\z.ps1
            ) else (
                echo [OK] Removed %INSTALL_DIR%\z.ps1
            )
        )
        if exist "%INSTALL_DIR%\glm" (
            del "%INSTALL_DIR%\glm"
            if errorlevel 1 (
                echo Error: Failed to remove %INSTALL_DIR%\glm
            ) else (
                echo [OK] Removed %INSTALL_DIR%\glm
            )
        )
        if exist "%INSTALL_DIR%\glm.cmd" (
            del "%INSTALL_DIR%\glm.cmd"
            if errorlevel 1 (
                echo Error: Failed to remove %INSTALL_DIR%\glm.cmd
            ) else (
                echo [OK] Removed %INSTALL_DIR%\glm.cmd
            )
        )
        if exist "%INSTALL_DIR%\glm.ps1" (
            del "%INSTALL_DIR%\glm.ps1"
            if errorlevel 1 (
                echo Error: Failed to remove %INSTALL_DIR%\glm.ps1
            ) else (
                echo [OK] Removed %INSTALL_DIR%\glm.ps1
            )
        )
    ) else (
        echo Skipped removing wrapper scripts
    )
)

rem Check for Claude status line
echo.
set STATUS_LINE_FOUND=0
if exist "%CLAUDE_DIR%\statusLine.sh" set STATUS_LINE_FOUND=1
if exist "%CLAUDE_DIR%\settings.json" set STATUS_LINE_FOUND=1

if %STATUS_LINE_FOUND%==0 (
    echo No Claude status line configuration found
) else (
    echo Found Claude status line configuration
    echo.
    set /p REMOVE_STATUS="Remove Claude status line configuration? [y/N]: "
    
    if /i "!REMOVE_STATUS!"=="y" (
        if exist "%CLAUDE_DIR%\statusLine.sh" (
            del "%CLAUDE_DIR%\statusLine.sh"
            if errorlevel 1 (
                echo Error: Failed to remove %CLAUDE_DIR%\statusLine.sh
            ) else (
                echo [OK] Removed %CLAUDE_DIR%\statusLine.sh
            )
        )
        
        if exist "%CLAUDE_DIR%\settings.json" (
            echo.
            echo Warning: settings.json may contain other Claude configurations.
            set /p REMOVE_SETTINGS="Remove settings.json anyway? [y/N]: "
            
            if /i "!REMOVE_SETTINGS!"=="y" (
                for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set DATE=%%c%%a%%b
                for /f "tokens=1-2 delims=: " %%a in ('time /t') do set TIME=%%a%%b
                set BACKUP_FILE=%CLAUDE_DIR%\settings.json.backup.!DATE!_!TIME!
                move "%CLAUDE_DIR%\settings.json" "!BACKUP_FILE!" >nul
                echo [OK] Backed up and removed settings.json ^(backup: !BACKUP_FILE!^)
            ) else (
                echo Kept settings.json
                echo To manually remove the status line, edit %CLAUDE_DIR%\settings.json
                echo and remove the 'statusLine' section.
            )
        )
    ) else (
        echo Skipped removing Claude status line
    )
)

rem Ask about PATH cleanup
echo.
echo PATH Cleanup
echo The installer may have added %INSTALL_DIR% to your PATH.
echo.
echo Note: Automatic PATH removal is not supported in CMD batch scripts.
echo To remove manually, you can:
echo   1. Open System Properties ^> Environment Variables
echo   2. Edit the 'Path' variable under User variables
echo   3. Remove the entry: %INSTALL_DIR%
echo.
echo Or use PowerShell to remove it automatically.
echo.
pause

rem Ask about config files
echo.
set CONFIG_FOUND=0
if exist "%USERPROFILE%\.zai.json" set CONFIG_FOUND=1
if exist "%APPDATA%\zai\config.json" set CONFIG_FOUND=1
if exist "%APPDATA%\zai" set CONFIG_FOUND=1

if %CONFIG_FOUND%==0 (
    echo No Z.AI configuration files found
) else (
    echo Configuration Files
    echo Your Z.AI configuration files may contain your API key and settings.
    echo.
    echo Possible locations:
    if exist "%USERPROFILE%\.zai.json" echo   - %USERPROFILE%\.zai.json ^(found^)
    if exist "%APPDATA%\zai\config.json" echo   - %APPDATA%\zai\config.json ^(found^)
    if exist "%APPDATA%\zai" echo   - %APPDATA%\zai\ directory ^(found^)
    echo.
    set /p REMOVE_CONFIG="Remove configuration files? [y/N]: "

    if /i "!REMOVE_CONFIG!"=="y" (
        if exist "%USERPROFILE%\.zai.json" (
            del "%USERPROFILE%\.zai.json"
            if errorlevel 1 (
                echo Error: Failed to remove %USERPROFILE%\.zai.json
            ) else (
                echo [OK] Removed %USERPROFILE%\.zai.json
            )
        )

        if exist "%APPDATA%\zai\config.json" (
            del "%APPDATA%\zai\config.json"
            if errorlevel 1 (
                echo Error: Failed to remove %APPDATA%\zai\config.json
            ) else (
                echo [OK] Removed %APPDATA%\zai\config.json
            )
        )

        if exist "%APPDATA%\zai" (
            rmdir "%APPDATA%\zai" 2>nul
            if not exist "%APPDATA%\zai" (
                echo [OK] Removed %APPDATA%\zai directory
            )
        )

        echo.
        echo Note: Per-project .zai.json files ^(if any^) were not removed.
        echo You may want to clean those up manually in your project directories.
    ) else (
        echo Kept configuration files
    )
)

rem Check for ZAI_API_KEY environment variable
echo.
set ZAI_KEY_SET=0
if defined ZAI_API_KEY set ZAI_KEY_SET=1

if %ZAI_KEY_SET%==1 (
    echo Found ZAI_API_KEY environment variable
    set /p REMOVE_ENV="Remove ZAI_API_KEY environment variable? [y/N]: "
    
    if /i "!REMOVE_ENV!"=="y" (
        reg delete "HKCU\Environment" /v ZAI_API_KEY /f >nul 2>&1
        if errorlevel 1 (
            echo Error: Failed to remove environment variable.
            echo You may need to remove it manually from System Properties.
        ) else (
            echo [OK] Removed ZAI_API_KEY environment variable
            echo     Please restart your terminal for changes to take effect.
        )
    )
)

rem Uninstallation complete
echo.
echo ===============================================================
echo              Uninstallation Complete!
echo ===============================================================
echo.
echo If you made PATH or environment variable changes,
echo restart your terminal for them to take effect.
echo.
pause

