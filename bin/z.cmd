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
for /f "delims=" %%e in ('jq -r ".subagentModel" "%CONFIG_FILE%"') do set SUBAGENT_MODEL=%%e
for /f "delims=" %%f in ('jq -r ".defaultModel" "%CONFIG_FILE%"') do set DEFAULT_MODEL=%%f
for /f "delims=" %%g in ('jq -r ".enableThinking" "%CONFIG_FILE%"') do set ENABLE_THINKING=%%g
for /f "delims=" %%h in ('jq -r ".enableStreaming" "%CONFIG_FILE%"') do set ENABLE_STREAMING=%%h
for /f "delims=" %%i in ('jq -r ".reasoningEffort" "%CONFIG_FILE%"') do set REASONING_EFFORT=%%i
rem REASONING_EFFORT values: "auto", "low", "medium", "high", or "max"
for /f "delims=" %%j in ('jq -r ".maxThinkingTokens" "%CONFIG_FILE%"') do set MAX_THINKING_TOKENS=%%j
for /f "delims=" %%k in ('jq -r ".maxOutputTokens" "%CONFIG_FILE%"') do set MAX_OUTPUT_TOKENS=%%k

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