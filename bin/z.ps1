# Read the configuration file
$ConfigFile = "$env:USERPROFILE\.zai.json"

if (-not (Test-Path $ConfigFile)) {
    Write-Error "Error: Configuration file $ConfigFile not found."
    exit 1
}

# Parse the JSON file
$Config = Get-Content $ConfigFile | ConvertFrom-Json

# Set environment variables for Z.AI
$env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"
$env:ANTHROPIC_AUTH_TOKEN = $Config.apiKey
$env:ANTHROPIC_DEFAULT_OPUS_MODEL = $Config.opusModel
$env:ANTHROPIC_DEFAULT_SONNET_MODEL = $Config.sonnetModel
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = $Config.haikuModel
$env:CLAUDE_CODE_SUBAGENT_MODEL = $Config.subagentModel
$env:ENABLE_THINKING = $Config.enableThinking
$env:ENABLE_STREAMING = $Config.enableStreaming
$env:REASONING_EFFORT = $Config.reasoningEffort  # Values: "auto", "low", "medium", or "high"
$env:MAX_THINKING_TOKENS = $Config.maxThinkingTokens
$env:MAX_OUTPUT_TOKENS = $Config.maxOutputTokens

# Privacy configuration
$env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# Launch Claude Code
claude $args