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

# Launch Claude Code
claude $args
