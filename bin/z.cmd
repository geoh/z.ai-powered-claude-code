@echo off
set CONFIG_FILE=%USERPROFILE%\.zai.json

if not exist "%CONFIG_FILE%" (
    echo Error: Configuration file %CONFIG_FILE% not found.
    exit /b 1
)

rem Extract values using FOR /F (note the double %% in batch file)
for /f "delims=" %%a in ('jq -r ".apiKey" "%CONFIG_FILE%"') do set API_KEY=%%a
for /f "delims=" %%b in ('jq -r ".opusModel" "%CONFIG_FILE%"') do set OPUS_MODEL=%%b
for /f "delims=" %%c in ('jq -r ".sonnetModel" "%CONFIG_FILE%"') do set SONNET_MODEL=%%c
for /f "delims=" %%d in ('jq -r ".haikuModel" "%CONFIG_FILE%"') do set HAIKU_MODEL=%%d

rem Set environment variables
set ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic
set ANTHROPIC_AUTH_TOKEN=%API_KEY%
set ANTHROPIC_DEFAULT_OPUS_MODEL=%OPUS_MODEL%
set ANTHROPIC_DEFAULT_SONNET_MODEL=%SONNET_MODEL%
set ANTHROPIC_DEFAULT_HAIKU_MODEL=%HAIKU_MODEL%

rem Launch Claude Code
claude %*
