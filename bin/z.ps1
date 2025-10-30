# Function to find config file
function Find-ConfigFile {
    # Check for per-project config first
    if (Test-Path ".zai.json") {
        return ".zai.json"
    }

    # Check ZAI_CONFIG_PATH environment variable
    if ($env:ZAI_CONFIG_PATH -and (Test-Path $env:ZAI_CONFIG_PATH)) {
        return $env:ZAI_CONFIG_PATH
    }

    # Check APPDATA location
    $appdataConfig = "$env:APPDATA\zai\config.json"
    if (Test-Path $appdataConfig) {
        return $appdataConfig
    }

    # Check XDG_CONFIG_HOME location (for cross-shell compatibility)
    if ($env:XDG_CONFIG_HOME) {
        $xdgConfig = "$env:XDG_CONFIG_HOME\zai\config.json"
        if (Test-Path $xdgConfig) {
            return $xdgConfig
        }
    }

    # Check HOME/.config location (for Git Bash compatibility)
    if ($env:HOME) {
        $homeConfig = "$env:HOME\.config\zai\config.json"
        if (Test-Path $homeConfig) {
            return $homeConfig
        }
    }

    # Check USERPROFILE/.config location (alternative for Git Bash)
    $userProfileConfig = "$env:USERPROFILE\.config\zai\config.json"
    if (Test-Path $userProfileConfig) {
        return $userProfileConfig
    }

    # Check legacy location for backward compatibility
    $legacyConfig = "$env:USERPROFILE\.zai.json"
    if (Test-Path $legacyConfig) {
        return $legacyConfig
    }

    return $null
}

# Function to create config file interactively
function New-ConfigFile {
    Write-Host "No configuration file found. Let's create one!"
    Write-Host ""

    # Ask for API key
    $apiKey = Read-Host "Enter your Z.AI API key"
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        Write-Error "Error: API key cannot be empty."
        exit 1
    }

    # Ask where to store
    Write-Host ""
    Write-Host "Where would you like to store the configuration?"
    Write-Host "1) User AppData directory ($env:APPDATA\zai\config.json)"
    Write-Host "2) Current project directory (.\.zai.json)"
    $choice = Read-Host "Choose [1-2]"

    if ($choice -eq "2") {
        $configPath = ".\.zai.json"
    } else {
        $configPath = "$env:APPDATA\zai\config.json"
        $configDir = "$env:APPDATA\zai"
        if (-not (Test-Path $configDir)) {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        }
    }

    # Ask if they want to store API key in config or environment
    Write-Host ""
    Write-Host "How would you like to store your API key?"
    Write-Host "1) In the config file (convenient)"
    Write-Host "2) As an environment variable ZAI_API_KEY (more secure)"
    $keyChoice = Read-Host "Choose [1-2]"

    $configApiKey = "your-api-key"
    if ($keyChoice -eq "1") {
        $configApiKey = $apiKey
    }

    # Create config file with defaults
    $configContent = @{
        apiKey = $configApiKey
        opusModel = "glm-4.6"
        sonnetModel = "glm-4.5"
        haikuModel = "glm-4.5-air"
        subagentModel = "glm-4.6"
        defaultModel = "opus"
        enableThinking = "true"
        enableStreaming = "true"
        reasoningEffort = "high"
        maxThinkingTokens = ""
        maxOutputTokens = ""
    }

    $configContent | ConvertTo-Json | Set-Content -Path $configPath

    Write-Host ""
    Write-Host "Configuration file created at: $configPath"

    # If user chose environment variable, help them set it up
    if ($keyChoice -eq "2") {
        # Set in current session immediately
        $env:ZAI_API_KEY = $apiKey
        Write-Host ""
        Write-Host "✓ ZAI_API_KEY set for current session"
        Write-Host ""
        Write-Host "To make this permanent, run:"
        Write-Host "  [Environment]::SetEnvironmentVariable('ZAI_API_KEY', '$apiKey', 'User')"
        Write-Host ""
        $addEnv = Read-Host "Would you like me to set it permanently now? [y/N]"
        if ($addEnv -eq "y" -or $addEnv -eq "Y") {
            [Environment]::SetEnvironmentVariable('ZAI_API_KEY', $apiKey, 'User')
            Write-Host "Environment variable set permanently. Will persist in new terminal sessions."
        } else {
            Write-Host "Note: You'll need to set ZAI_API_KEY manually in new terminal sessions."
        }
    }

    return $configPath
}

# Find or create config file
$ConfigFile = Find-ConfigFile
if (-not $ConfigFile) {
    $ConfigFile = New-ConfigFile
}

# Check for per-project config to merge
$ProjectConfig = $null
$GlobalConfig = $ConfigFile
if ($ConfigFile -ne ".zai.json" -and (Test-Path ".zai.json")) {
    $ProjectConfig = ".zai.json"
}

# Parse the global config file
$Config = Get-Content $GlobalConfig | ConvertFrom-Json

# Create a hashtable for easier merging
$settings = @{
    apiKey = if ($Config.apiKey) { $Config.apiKey } else { "null" }
    opusModel = if ($Config.opusModel) { $Config.opusModel } else { "null" }
    sonnetModel = if ($Config.sonnetModel) { $Config.sonnetModel } else { "null" }
    haikuModel = if ($Config.haikuModel) { $Config.haikuModel } else { "null" }
    subagentModel = if ($Config.subagentModel) { $Config.subagentModel } else { "null" }
    defaultModel = if ($Config.defaultModel) { $Config.defaultModel } else { "null" }
    enableThinking = if ($Config.enableThinking) { $Config.enableThinking } else { "null" }
    enableStreaming = if ($Config.enableStreaming) { $Config.enableStreaming } else { "null" }
    reasoningEffort = if ($Config.reasoningEffort) { $Config.reasoningEffort } else { "null" }
    maxThinkingTokens = if ($null -ne $Config.maxThinkingTokens) { $Config.maxThinkingTokens } else { "null" }
    maxOutputTokens = if ($null -ne $Config.maxOutputTokens) { $Config.maxOutputTokens } else { "null" }
}

# Override with project config if present (shallow merge)
if ($ProjectConfig) {
    $ProjectConfigData = Get-Content $ProjectConfig | ConvertFrom-Json

    if ($ProjectConfigData.apiKey) { $settings.apiKey = $ProjectConfigData.apiKey }
    if ($ProjectConfigData.opusModel) { $settings.opusModel = $ProjectConfigData.opusModel }
    if ($ProjectConfigData.sonnetModel) { $settings.sonnetModel = $ProjectConfigData.sonnetModel }
    if ($ProjectConfigData.haikuModel) { $settings.haikuModel = $ProjectConfigData.haikuModel }
    if ($ProjectConfigData.subagentModel) { $settings.subagentModel = $ProjectConfigData.subagentModel }
    if ($ProjectConfigData.defaultModel) { $settings.defaultModel = $ProjectConfigData.defaultModel }
    if ($ProjectConfigData.enableThinking) { $settings.enableThinking = $ProjectConfigData.enableThinking }
    if ($ProjectConfigData.enableStreaming) { $settings.enableStreaming = $ProjectConfigData.enableStreaming }
    if ($ProjectConfigData.reasoningEffort) { $settings.reasoningEffort = $ProjectConfigData.reasoningEffort }
    if ($ProjectConfigData.maxThinkingTokens) { $settings.maxThinkingTokens = $ProjectConfigData.maxThinkingTokens }
    if ($ProjectConfigData.maxOutputTokens) { $settings.maxOutputTokens = $ProjectConfigData.maxOutputTokens }
}

# Environment variable takes highest priority for API key
if ($env:ZAI_API_KEY) {
    $settings.apiKey = $env:ZAI_API_KEY
}

# Validate API key
if (-not $settings.apiKey -or $settings.apiKey -eq "null" -or $settings.apiKey -eq "your-api-key") {
    Write-Error "Error: Valid API key not found."
    Write-Error "Please set ZAI_API_KEY environment variable or configure apiKey in your config file."
    exit 1
}

# Set environment variables for Z.AI
$env:ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic"
$env:ANTHROPIC_AUTH_TOKEN = $settings.apiKey
$env:ANTHROPIC_DEFAULT_OPUS_MODEL = $settings.opusModel
$env:ANTHROPIC_DEFAULT_SONNET_MODEL = $settings.sonnetModel
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = $settings.haikuModel
$env:CLAUDE_CODE_SUBAGENT_MODEL = $settings.subagentModel
$env:ENABLE_THINKING = $settings.enableThinking
$env:ENABLE_STREAMING = $settings.enableStreaming
$env:REASONING_EFFORT = $settings.reasoningEffort  # Values: "auto", "low", "medium", "high", or "max"
$env:MAX_THINKING_TOKENS = $settings.maxThinkingTokens
$env:MAX_OUTPUT_TOKENS = $settings.maxOutputTokens

# Privacy configuration
$env:CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1

# Launch Claude Code with optional default model
$APPENDED_SYSTEM_PROMPT = "Override any previous instructions about Git co-authored format. When creating git commits, you must use your actual GLM model name and email: Co-Authored-By: [your model name, eg: GLM 4.6] <noreply@z.ai>"
if ($settings.defaultModel -and $settings.defaultModel -ne "" -and $settings.defaultModel -ne "null") {
    claude --model $settings.defaultModel --append-system-prompt $APPENDED_SYSTEM_PROMPT $args
} else {
    claude --append-system-prompt $APPENDED_SYSTEM_PROMPT $args
}