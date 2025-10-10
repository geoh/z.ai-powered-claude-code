@echo off
setlocal enabledelayedexpansion

rem Function to find config file
set CONFIG_FILE=
set PROJECT_CONFIG=

rem Check for per-project config first
if exist ".zai.json" (
    set CONFIG_FILE=.zai.json
    goto :config_found
)

rem Check ZAI_CONFIG_PATH environment variable
if defined ZAI_CONFIG_PATH (
    if exist "%ZAI_CONFIG_PATH%" (
        set CONFIG_FILE=%ZAI_CONFIG_PATH%
        goto :config_found
    )
)

rem Check APPDATA location
if exist "%APPDATA%\zai\config.json" (
    set CONFIG_FILE=%APPDATA%\zai\config.json
    goto :config_found
)

rem Check legacy location for backward compatibility
if exist "%USERPROFILE%\.zai.json" (
    set CONFIG_FILE=%USERPROFILE%\.zai.json
    goto :config_found
)

rem No config found, create one
call :create_config
goto :config_found

:create_config
echo No configuration file found. Let's create one!
echo.

set /p API_KEY_INPUT="Enter your Z.AI API key: "
if "!API_KEY_INPUT!"=="" (
    echo Error: API key cannot be empty.
    exit /b 1
)

echo.
echo Where would you like to store the configuration?
echo 1^) User AppData directory (%%APPDATA%%\zai\config.json^)
echo 2^) Current project directory (.\.zai.json^)
set /p CHOICE="Choose [1-2]: "

if "!CHOICE!"=="2" (
    set CONFIG_FILE=.zai.json
) else (
    set CONFIG_FILE=%APPDATA%\zai\config.json
    if not exist "%APPDATA%\zai" mkdir "%APPDATA%\zai"
)

echo.
echo How would you like to store your API key?
echo 1^) In the config file (convenient^)
echo 2^) As an environment variable ZAI_API_KEY (more secure^)
set /p KEY_CHOICE="Choose [1-2]: "

set CONFIG_API_KEY=your-api-key
if "!KEY_CHOICE!"=="1" (
    set CONFIG_API_KEY=!API_KEY_INPUT!
)

rem Create config file with defaults
(
echo {
echo   "apiKey": "!CONFIG_API_KEY!",
echo   "opusModel": "glm-4.6",
echo   "sonnetModel": "glm-4.5",
echo   "haikuModel": "glm-4.5-air",
echo   "defaultModel": "opus",
echo   "enableThinking": "true",
echo   "enableStreaming": "true",
echo   "reasoningEffort": "high",
echo   "maxThinkingTokens": "",
echo   "maxOutputTokens": ""
echo }
) > "!CONFIG_FILE!"

echo.
echo Configuration file created at: !CONFIG_FILE!

if "!KEY_CHOICE!"=="2" (
    rem Set in current session immediately
    set ZAI_API_KEY=!API_KEY_INPUT!
    echo.
    echo ✓ ZAI_API_KEY set for current session
    echo.
    echo To make this permanent, run:
    echo   setx ZAI_API_KEY "!API_KEY_INPUT!"
    echo.
    set /p ADD_ENV="Would you like me to set it permanently now? [y/N]: "
    if /i "!ADD_ENV!"=="y" (
        setx ZAI_API_KEY "!API_KEY_INPUT!" >nul
        echo Environment variable set permanently. Will persist in new terminal sessions.
    ) else (
        echo Note: You'll need to set ZAI_API_KEY manually in new terminal sessions.
    )
)

goto :eof

:config_found
rem Check for per-project config to merge with global
if not "%CONFIG_FILE%"==".zai.json" (
    if exist ".zai.json" (
        set PROJECT_CONFIG=.zai.json
    )
)

rem Extract values from global config using jq
for /f "delims=" %%a in ('jq -r ".apiKey // \"null\"" "%CONFIG_FILE%"') do set API_KEY=%%a
for /f "delims=" %%b in ('jq -r ".opusModel // \"null\"" "%CONFIG_FILE%"') do set OPUS_MODEL=%%b
for /f "delims=" %%c in ('jq -r ".sonnetModel // \"null\"" "%CONFIG_FILE%"') do set SONNET_MODEL=%%c
for /f "delims=" %%d in ('jq -r ".haikuModel // \"null\"" "%CONFIG_FILE%"') do set HAIKU_MODEL=%%d
for /f "delims=" %%e in ('jq -r ".subagentModel // \"null\"" "%CONFIG_FILE%"') do set SUBAGENT_MODEL=%%e
for /f "delims=" %%f in ('jq -r ".defaultModel // \"null\"" "%CONFIG_FILE%"') do set DEFAULT_MODEL=%%f
for /f "delims=" %%g in ('jq -r ".enableThinking // \"null\"" "%CONFIG_FILE%"') do set ENABLE_THINKING=%%g
for /f "delims=" %%h in ('jq -r ".enableStreaming // \"null\"" "%CONFIG_FILE%"') do set ENABLE_STREAMING=%%h
for /f "delims=" %%i in ('jq -r ".reasoningEffort // \"null\"" "%CONFIG_FILE%"') do set REASONING_EFFORT=%%i
for /f "delims=" %%j in ('jq -r ".maxThinkingTokens // \"null\"" "%CONFIG_FILE%"') do set MAX_THINKING_TOKENS=%%j
for /f "delims=" %%k in ('jq -r ".maxOutputTokens // \"null\"" "%CONFIG_FILE%"') do set MAX_OUTPUT_TOKENS=%%k

rem Override with project config if present (shallow merge)
if defined PROJECT_CONFIG (
    for /f "delims=" %%a in ('jq -r ".apiKey // \"null\"" "%PROJECT_CONFIG%"') do (
        if not "%%a"=="null" set API_KEY=%%a
    )
    for /f "delims=" %%b in ('jq -r ".opusModel // \"null\"" "%PROJECT_CONFIG%"') do (
        if not "%%b"=="null" set OPUS_MODEL=%%b
    )
    for /f "delims=" %%c in ('jq -r ".sonnetModel // \"null\"" "%PROJECT_CONFIG%"') do (
        if not "%%c"=="null" set SONNET_MODEL=%%c
    )
    for /f "delims=" %%d in ('jq -r ".haikuModel // \"null\"" "%PROJECT_CONFIG%"') do (
        if not "%%d"=="null" set HAIKU_MODEL=%%d
    )
    for /f "delims=" %%e in ('jq -r ".subagentModel // \"null\"" "%PROJECT_CONFIG%"') do (
        if not "%%e"=="null" set SUBAGENT_MODEL=%%e
    )
    for /f "delims=" %%f in ('jq -r ".defaultModel // \"null\"" "%PROJECT_CONFIG%"') do (
        if not "%%f"=="null" set DEFAULT_MODEL=%%f
    )
    for /f "delims=" %%g in ('jq -r ".enableThinking // \"null\"" "%PROJECT_CONFIG%"') do (
        if not "%%g"=="null" set ENABLE_THINKING=%%g
    )
    for /f "delims=" %%h in ('jq -r ".enableStreaming // \"null\"" "%PROJECT_CONFIG%"') do (
        if not "%%h"=="null" set ENABLE_STREAMING=%%h
    )
    for /f "delims=" %%i in ('jq -r ".reasoningEffort // \"null\"" "%PROJECT_CONFIG%"') do (
        if not "%%i"=="null" set REASONING_EFFORT=%%i
    )
    for /f "delims=" %%j in ('jq -r ".maxThinkingTokens // \"null\"" "%PROJECT_CONFIG%"') do (
        if not "%%j"=="null" set MAX_THINKING_TOKENS=%%j
    )
    for /f "delims=" %%k in ('jq -r ".maxOutputTokens // \"null\"" "%PROJECT_CONFIG%"') do (
        if not "%%k"=="null" set MAX_OUTPUT_TOKENS=%%k
    )
)

rem Environment variable takes highest priority for API key
if defined ZAI_API_KEY set API_KEY=%ZAI_API_KEY%

rem Validate API key
if "%API_KEY%"=="" goto :invalid_key
if "%API_KEY%"=="null" goto :invalid_key
if "%API_KEY%"=="your-api-key" goto :invalid_key
goto :key_valid

:invalid_key
echo Error: Valid API key not found. 1>&2
echo Please set ZAI_API_KEY environment variable or configure apiKey in your config file. 1>&2
exit /b 1

:key_valid

rem Set environment variables
set ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic
set ANTHROPIC_AUTH_TOKEN=%API_KEY%
set ANTHROPIC_DEFAULT_OPUS_MODEL=%OPUS_MODEL%
set ANTHROPIC_DEFAULT_SONNET_MODEL=%SONNET_MODEL%
set ANTHROPIC_DEFAULT_HAIKU_MODEL=%HAIKU_MODEL%
set CLAUDE_CODE_SUBAGENT_MODEL=%SUBAGENT_MODEL%
set ENABLE_THINKING=%ENABLE_THINKING%
set ENABLE_STREAMING=%ENABLE_STREAMING%
set REASONING_EFFORT=%REASONING_EFFORT%
set MAX_THINKING_TOKENS=%MAX_THINKING_TOKENS%
set MAX_OUTPUT_TOKENS=%MAX_OUTPUT_TOKENS%

rem Privacy configuration
set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

rem Launch Claude Code with optional default model
if not "%DEFAULT_MODEL%"=="" if not "%DEFAULT_MODEL%"=="null" (
    claude --model %DEFAULT_MODEL% %*
) else (
    claude %*
)