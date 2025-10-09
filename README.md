# Z.AI-Powered Claude Code

![Z.AI Powering Claude Code](img/z.ai-powering-claude-code.jpg)

A set of wrapper scripts and configuration files to enable Claude Code to use Z.AI's GLM models, providing an alternative to Anthropic's native models with enhanced status line functionality.

## Overview

This project allows you to use Z.AI's GLM models (including GLM-4.6) with Claude Code by setting up the appropriate environment variables and configuration. It includes:

- **Wrapper scripts** for launching Claude Code with Z.AI models
- **Status line configuration** that displays model information, git branch, and usage statistics
- **Cross-platform support** for Windows, macOS, and Linux

## Prerequisites

1. **Claude Code** installed on your system
2. **jq** command-line JSON processor (required for parsing configuration)
3. **Z.AI API key** and account
4. A **configuration file** at `~/.zai.json` with your Z.AI credentials

### Configuration File Format

Copy the example `.zai.json` file from the project root to your home directory and update it with your credentials:

```bash
cp .zai.json ~/.zai.json
```

Then edit `~/.zai.json` and replace the placeholder values with your actual Z.AI API key:

```json
{
  "apiKey": "your-api-key",
  "opusModel": "glm-4.6",
  "sonnetModel": "glm-4.5",
  "haikuModel": "glm-4.5-air",
  "defaultModel": "opus",
  "enableThinking": "true",
  "enableStreaming": "true",
  "reasoningEffort": "high",
  "maxThinkingTokens": "",
  "maxOutputTokens": ""
}
```

Replace `"your-api-key"` with your actual Z.AI API key. You can also modify the model names if you prefer different Z.AI models.

#### Configuration Options

- **apiKey**: Your Z.AI API key (required)
- **opusModel**: Model to use for opus tier requests (default: "glm-4.6")
- **sonnetModel**: Model to use for sonnet tier requests (default: "glm-4.5")
- **haikuModel**: Model to use for haiku tier requests (default: "glm-4.5-air")
- **defaultModel**: Default model to use when no model is specified (default: "opus")
- **enableThinking**: Enable AI thinking capabilities (default: "true")
- **enableStreaming**: Enable streaming responses (default: "true")
- **reasoningEffort**: Reasoning effort level - "auto", "low", "medium", "high", or "max" (default: "high")
- **maxThinkingTokens**: Maximum tokens for thinking (default: "")
- **maxOutputTokens**: Maximum tokens for output (default: "")

## Installation

### Step 1: Install Wrapper Scripts

Copy the appropriate wrapper script(s) from the `bin/` directory to a location that's in your PATH.

#### Option 1: ~/.local/bin (Recommended for cross-platform)

```bash
# Create the directory if it doesn't exist
mkdir -p ~/.local/bin

# Copy the scripts
# For Linux/macOS:
cp bin/z ~/.local/bin/

# For Windows:
copy bin\z.cmd %USERPROFILE%\.local\bin\
copy bin\z.ps1 %USERPROFILE%\.local\bin\
copy bin\z %USERPROFILE%\.local\bin\

# Add ~/.local/bin to your PATH if not already present
# Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export PATH="$HOME/.local/bin:$PATH"
```

#### Option 2: System-wide installation

```bash
# For Linux/macOS
sudo cp bin/z /usr/local/bin/

# For Windows (run as Administrator)
copy bin\z.cmd C:\Windows\System32\
copy bin\z.ps1 C:\Windows\System32\
```

### Step 2: Install Status Line Configuration

1. Copy the status line script to your Claude configuration directory:

```bash
# For Linux/macOS
mkdir -p ~/.claude
cp claude/statusLine.sh ~/.claude/

# For Windows
mkdir %USERPROFILE%\.claude
copy claude\statusLine.sh %USERPROFILE%\.claude\
```

2. Merge the settings.json with your existing Claude settings:

```bash
# If ~/.claude/settings.json doesn't exist, just copy it
cp claude/settings.json ~/.claude/

# If it already exists, merge the statusLine configuration
# You can use jq to merge the files:
jq -s '.[0] * .[1]' ~/.claude/settings.json claude/settings.json > ~/.claude/settings.json.tmp && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
```

### Step 3: Verify Installation

1. Ensure the scripts are executable (Linux/macOS):
```bash
chmod +x ~/.local/bin/z ~/.claude/statusLine.sh
```

2. Test the installation:
```bash
z --help
```

## Usage

Once installed, simply use the `z` command instead of `claude`:

```bash
# Start a new session with the default model (opus)
z

# Use a specific model
z --model sonnet
z --model haiku

# Pass any other claude arguments
z --model opus "Help me write a Python script"
```

### Default Model Configuration

You can set a default model in your `~/.zai.json` configuration file using the `defaultModel` field. When set, the wrapper scripts will automatically use this model unless you explicitly specify a different model with `--model`.

For example, to use `glm-4.5` as your default model:
```json
{
  "defaultModel": "glm-4.5",
  "apiKey": "your-api-key"
}
```

### AI Thinking Capabilities

The wrapper supports AI thinking capabilities through environment variables configured in `~/.zai.json`:

- **ENABLE_THINKING**: Enable/disable thinking mode (default: "true")
- **ENABLE_STREAMING**: Enable streaming responses (default: "true")
- **REASONING_EFFORT**: Set reasoning effort level - "auto", "low", "medium", "high", or "max" (default: "high")
- **MAX_THINKING_TOKENS**: Maximum tokens allocated for thinking (default: "")
- **MAX_OUTPUT_TOKENS**: Maximum tokens for the output (default: "")

Note: These thinking-related environment variables are experimental and their effectiveness depends on whether the Z.AI API supports these features.

## Status Line Features

The status line displays:

- **Model indicator**: 👾 for Claude models, 👹 for Z.AI models
- **Model name**: Currently active model
- **Current directory**: The directory you're working in
- **Git branch**: Current git branch (if in a git repository)
- **Code changes**: Lines added/removed in the session
- **Timing**: API duration and total session time
- **Cost**: Total cost of the session in USD

## Platform-Specific Notes

### Windows
- Three scripts are provided: `z.cmd` (Command Prompt), `z.ps1` (PowerShell), and `z` (Git Bash)
- The scripts automatically detect the Windows user profile directory
- Requires `jq` to be installed and available in PATH

### macOS/Linux
- The `z` script works with bash and other POSIX-compliant shells
- Uses standard Unix paths and environment variables

## Troubleshooting

### "Configuration file not found" error
- Ensure `~/.zai.json` exists with the correct format
- Check that the file is readable by your user account

### "jq not found" error
- Install `jq` using your system package manager:
  - Ubuntu/Debian: `sudo apt-get install jq`
  - macOS: `brew install jq`
  - Windows: `choco install jq` or download from jq website

### Status line not showing
- Verify that `~/.claude/settings.json` contains the statusLine configuration
- Ensure the `statusLine.sh` script is executable (Linux/macOS)
- Check that the script path in settings.json is correct

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues related to:
- **Z.AI API**: Contact Z.AI support
- **Claude Code**: Refer to Anthropic's documentation
- **This wrapper**: Create an issue in the project repository