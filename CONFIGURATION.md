# Configuration Guide

This guide provides detailed information about configuring the Z.AI CLI wrapper.

## Table of Contents

- [Configuration Methods](#configuration-methods)
- [Configuration File Locations](#configuration-file-locations)
- [Configuration Options](#configuration-options)
- [Environment Variables](#environment-variables)
- [Per-Project Configuration](#per-project-configuration)
- [Priority and Merging](#priority-and-merging)
- [Security Best Practices](#security-best-practices)
- [Examples](#examples)
- [Migration Guide](#migration-guide)

## Configuration Methods

The Z.AI wrapper supports three configuration methods:

1. **Environment Variables** - Highest priority, most secure for API keys
2. **Configuration Files** - Flexible, supports multiple locations
3. **Interactive Setup** - First-time wizard for easy configuration

## Configuration File Locations

The wrapper searches for configuration files in the following order (first found wins):

### Linux/macOS

1. **`./.zai.json`** - Per-project configuration (current directory)
2. **`$ZAI_CONFIG_PATH`** - Custom path set via environment variable
3. **`$XDG_CONFIG_HOME/zai/config.json`** - XDG Base Directory (if `XDG_CONFIG_HOME` is set)
4. **`~/.config/zai/config.json`** - XDG default location
5. **`~/.zai.json`** - Legacy location (backward compatibility)

### Windows

1. **`.\.zai.json`** - Per-project configuration (current directory)
2. **`%ZAI_CONFIG_PATH%`** - Custom path set via environment variable
3. **`%APPDATA%\zai\config.json`** - Windows AppData location (CMD/PowerShell)
4. **`%XDG_CONFIG_HOME%\zai\config.json`** - XDG location (if set, for Git Bash compatibility)
5. **`%HOME%\.config\zai\config.json`** - HOME/.config location (Git Bash compatibility)
6. **`%USERPROFILE%\.config\zai\config.json`** - Alternative .config location (Git Bash)
7. **`%USERPROFILE%\.zai.json`** - Legacy location (backward compatibility)

**Note**: The additional XDG and HOME/.config locations (4-6) provide better cross-shell compatibility on Windows, especially when using Git Bash or other Unix-like shells.

### Recommended Locations

- **Global config**: `~/.config/zai/config.json` (Linux/macOS) or `%APPDATA%\zai\config.json` (Windows)
- **Per-project config**: `./.zai.json` in your project directory
- **API key**: `ZAI_API_KEY` environment variable (most secure)

## Configuration Options

Configuration files use JSON format with the following options:

```json
{
  "apiKey": "your-api-key-here",
  "opusModel": "glm-4.6",
  "sonnetModel": "glm-4.5",
  "haikuModel": "glm-4.5-air",
  "subagentModel": "glm-4.5-air",
  "defaultModel": "opus",
  "enableThinking": "true",
  "enableStreaming": "true",
  "reasoningEffort": "high",
  "maxThinkingTokens": "",
  "maxOutputTokens": ""
}
```

### Option Details

#### apiKey
- **Type**: String
- **Required**: Yes (unless `ZAI_API_KEY` environment variable is set)
- **Description**: Your Z.AI API key
- **Security**: Consider using `ZAI_API_KEY` environment variable instead

#### opusModel
- **Type**: String
- **Default**: `"glm-4.6"`
- **Description**: Z.AI model to use for Claude opus tier requests
- **Example**: `"glm-4.6"`, `"glm-4.5"`

#### sonnetModel
- **Type**: String
- **Default**: `"glm-4.5"`
- **Description**: Z.AI model to use for Claude sonnet tier requests
- **Example**: `"glm-4.5"`, `"glm-4.5-air"`

#### haikuModel
- **Type**: String
- **Default**: `"glm-4.5-air"`
- **Description**: Z.AI model to use for Claude haiku tier requests
- **Example**: `"glm-4.5-air"`

#### subagentModel
- **Type**: String
- **Default**: `"glm-4.5-air"`
- **Description**: Z.AI model to use for Claude Code subagent operations
- **Example**: `"glm-4.5-air"`

#### defaultModel
- **Type**: String
- **Default**: `"opus"`
- **Description**: Default model tier to use when not specified
- **Options**: `"opus"`, `"sonnet"`, `"haiku"`, or a specific model name
- **Example**: `"sonnet"` for faster responses, `"opus"` for best quality

#### enableThinking
- **Type**: String (boolean)
- **Default**: `"true"`
- **Description**: Enable AI thinking capabilities
- **Options**: `"true"`, `"false"`
- **Note**: Experimental feature, depends on Z.AI API support

#### enableStreaming
- **Type**: String (boolean)
- **Default**: `"true"`
- **Description**: Enable streaming responses
- **Options**: `"true"`, `"false"`

#### reasoningEffort
- **Type**: String
- **Default**: `"high"`
- **Description**: Level of reasoning effort for AI thinking
- **Options**: `"auto"`, `"low"`, `"medium"`, `"high"`, `"max"`
- **Note**: Experimental feature. These settings are passed through to the API, but actual behavior depends on the Z.AI API's implementation and may not be fully supported

#### maxThinkingTokens
- **Type**: String (number)
- **Default**: `""` (empty, no limit)
- **Description**: Maximum tokens allocated for thinking
- **Example**: `"1000"`, `"2000"`

#### maxOutputTokens
- **Type**: String (number)
- **Default**: `""` (empty, no limit)
- **Description**: Maximum tokens for output
- **Example**: `"4000"`, `"8000"`

## Environment Variables

### ZAI_API_KEY

Your Z.AI API key. This is the **recommended** way to store your API key.

**Priority**: Highest (overrides config file `apiKey`)

**Setting the variable:**

**Linux/macOS (bash/zsh):**
```bash
# Temporary (current session)
export ZAI_API_KEY="your-api-key-here"

# Permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export ZAI_API_KEY="your-api-key-here"' >> ~/.bashrc
source ~/.bashrc
```

**Windows (PowerShell):**
```powershell
# Temporary (current session)
$env:ZAI_API_KEY = "your-api-key-here"

# Permanent (user-level)
[Environment]::SetEnvironmentVariable('ZAI_API_KEY', 'your-api-key-here', 'User')
# Restart terminal after setting
```

**Windows (CMD):**
```cmd
rem Temporary (current session)
set ZAI_API_KEY=your-api-key-here

rem Permanent (user-level)
setx ZAI_API_KEY "your-api-key-here"
rem Restart terminal after setting
```

### ZAI_CONFIG_PATH

Custom path to your configuration file.

**Example:**
```bash
export ZAI_CONFIG_PATH="/path/to/my/custom/config.json"
```

### XDG_CONFIG_HOME

XDG Base Directory for configuration files (Linux/macOS only).

**Default**: `~/.config`

**Example:**
```bash
export XDG_CONFIG_HOME="$HOME/.config"
```

The wrapper will look for config at `$XDG_CONFIG_HOME/zai/config.json`.

## Per-Project Configuration

You can create a `.zai.json` file in your project directory to override global settings.

### Use Cases

1. **Different models per project**: Use faster models for simple projects
2. **Project-specific settings**: Different reasoning effort or token limits
3. **Team configurations**: Share non-sensitive settings via version control

### Example Per-Project Config

```json
{
  "defaultModel": "sonnet",
  "reasoningEffort": "medium"
}
```

This overrides only `defaultModel` and `reasoningEffort`, inheriting all other settings from the global config.

### Important: Security

**Never commit API keys to version control!**

Add `.zai.json` to your `.gitignore`:

```gitignore
# Z.AI configuration (may contain API key)
.zai.json
```

**Best practice**: Use per-project configs without `apiKey`, relying on:
- Global config file for the API key, or
- `ZAI_API_KEY` environment variable (recommended)

## Priority and Merging

### API Key Resolution

1. **`ZAI_API_KEY` environment variable** (highest priority)
2. **`apiKey` from config file**
3. **Error** if neither is set or value is `"your-api-key"`

### Config File Resolution

1. **Per-project** `./.zai.json` (if exists)
2. **Custom path** `$ZAI_CONFIG_PATH` (if set)
3. **XDG location** `$XDG_CONFIG_HOME/zai/config.json` or `~/.config/zai/config.json`
4. **Legacy location** `~/.zai.json`

### Config Merging

When a per-project config exists:
1. Global config is loaded first
2. Per-project config values **override** global values (shallow merge)
3. Unspecified values in per-project config are inherited from global config

**Example:**

**Global config** (`~/.config/zai/config.json`):
```json
{
  "apiKey": "global-key",
  "opusModel": "glm-4.6",
  "defaultModel": "opus",
  "reasoningEffort": "high"
}
```

**Project config** (`./.zai.json`):
```json
{
  "defaultModel": "sonnet",
  "reasoningEffort": "medium"
}
```

**Effective configuration**:
```json
{
  "apiKey": "global-key",           // from global
  "opusModel": "glm-4.6",           // from global
  "defaultModel": "sonnet",         // overridden by project
  "reasoningEffort": "medium"       // overridden by project
}
```

## Security Best Practices

### 1. Use Environment Variables for API Keys

**Recommended:**
```bash
export ZAI_API_KEY="your-api-key"
```

**Not recommended:**
```json
{
  "apiKey": "your-api-key"
}
```

### 2. Set Restrictive File Permissions

On Unix systems, config files should only be readable by you:

```bash
chmod 600 ~/.config/zai/config.json
```

The wrapper will warn you if permissions are too open.

### 3. Add .zai.json to .gitignore

Always add per-project configs to `.gitignore`:

```gitignore
.zai.json
```

### 4. Use Per-Project Configs Without API Keys

**Good** (`./.zai.json`):
```json
{
  "defaultModel": "sonnet"
}
```

**Bad** (`./.zai.json`):
```json
{
  "apiKey": "your-api-key",
  "defaultModel": "sonnet"
}
```

### 5. Never Commit Secrets

- Don't commit files containing API keys
- Don't share config files with API keys
- Use environment variables or secure secret management

## Examples

### Example 1: Minimal Global Config with Environment Variable

**~/.config/zai/config.json:**
```json
{
  "opusModel": "glm-4.6",
  "sonnetModel": "glm-4.5",
  "haikuModel": "glm-4.5-air"
}
```

**Environment:**
```bash
export ZAI_API_KEY="your-api-key-here"
```

### Example 2: Full Global Config

**~/.config/zai/config.json:**
```json
{
  "apiKey": "your-api-key-here",
  "opusModel": "glm-4.6",
  "sonnetModel": "glm-4.5",
  "haikuModel": "glm-4.5-air",
  "subagentModel": "glm-4.5-air",
  "defaultModel": "sonnet",
  "enableThinking": "true",
  "enableStreaming": "true",
  "reasoningEffort": "high",
  "maxThinkingTokens": "",
  "maxOutputTokens": ""
}
```

### Example 3: Per-Project Override

**Global** (`~/.config/zai/config.json`):
```json
{
  "defaultModel": "opus",
  "reasoningEffort": "high"
}
```

**Project** (`./.zai.json`):
```json
{
  "defaultModel": "haiku",
  "reasoningEffort": "low"
}
```

Use case: Fast, lightweight model for a simple project.

### Example 4: Custom Config Path

```bash
export ZAI_CONFIG_PATH="/secure/location/my-zai-config.json"
z
```

## Migration Guide

### From Legacy Location

If you're using the old `~/.zai.json` location:

**Option 1: Keep using it** (backward compatible)
- No action needed, it still works

**Option 2: Migrate to XDG location**

```bash
# Create XDG directory
mkdir -p ~/.config/zai

# Move config
mv ~/.zai.json ~/.config/zai/config.json

# Set permissions
chmod 600 ~/.config/zai/config.json
```

### From Config File to Environment Variable

1. Note your API key from config file
2. Set environment variable:
   ```bash
   export ZAI_API_KEY="your-api-key"
   # Add to ~/.bashrc or ~/.zshrc
   ```
3. Remove `apiKey` from config file or set to `"your-api-key"` as placeholder
4. Test: `z --help`

### Adding Per-Project Configs

1. Create `.zai.json` in project directory
2. Add only the settings you want to override
3. Add `.zai.json` to `.gitignore`
4. Test from project directory: `z --help`

## Troubleshooting

### Config Not Found

**Problem**: "Configuration file not found"

**Solution**: Run `z` to start interactive setup, or create config manually in one of the supported locations.

### API Key Invalid

**Problem**: "Valid API key not found"

**Solutions**:
- Check `ZAI_API_KEY` environment variable is set correctly
- Verify `apiKey` in config file is not `"your-api-key"` placeholder
- Ensure config file is readable: `ls -l ~/.config/zai/config.json`

### Per-Project Config Not Working

**Problem**: Project config seems to be ignored

**Solutions**:
- Verify `.zai.json` is in current working directory
- Check file permissions: `ls -l .zai.json`
- Ensure JSON is valid: `jq . .zai.json`
- Remember: per-project config merges with (doesn't replace) global config

### Permission Warnings

**Problem**: "Config file has overly permissive permissions"

**Solution**:
```bash
chmod 600 ~/.config/zai/config.json
```

**Note**: Permission checks are automatically skipped on Windows systems (Git Bash/MSYS/Cygwin) as Windows filesystems handle permissions differently.

## Platform-Specific Notes

### Windows

#### Multiple Shell Support

Windows users have three wrapper scripts available:
- **`z`** (Git Bash) - Full feature support including status line
- **`z.cmd`** (Command Prompt) - Core functionality, no status line
- **`z.ps1`** (PowerShell) - Core functionality, no status line

#### Status Line Limitation

The Claude Code status line feature **only works with Git Bash** (`z` script) on Windows. It does not work with CMD (`z.cmd`) or PowerShell (`z.ps1`) due to stdin piping limitations when Claude Code invokes external commands.

**To use the status line on Windows:**
1. Install Git for Windows (includes Git Bash)
2. Use the `z` command from Git Bash
3. Ensure `~/.claude/statusLine.sh` is installed and configured

#### Config File Locations

Windows scripts now support multiple config file locations for better cross-shell compatibility:
- Native Windows paths: `%APPDATA%\zai\config.json`, `%USERPROFILE%\.zai.json`
- Unix-style paths (Git Bash): `~/.config/zai/config.json`, `~/.zai.json`
- XDG-compliant paths: `$XDG_CONFIG_HOME/zai/config.json`

All three wrapper scripts (z, z.cmd, z.ps1) will search all these locations, ensuring consistent behavior regardless of which shell you use.

### Linux/macOS

#### Permission Security

On Unix-like systems, the wrapper scripts check config file permissions and warn if they are too permissive (not 600 or 400). This helps protect your API key from unauthorized access.

#### XDG Base Directory Support

The wrapper follows the XDG Base Directory specification:
- Respects `$XDG_CONFIG_HOME` if set
- Falls back to `~/.config` as the default
- Maintains backward compatibility with `~/.zai.json`

## Additional Resources

- [README.md](README.md) - Overview and quick start
- [INSTALL.md](INSTALL.md) - Installation guide
- [CONFIG_EXAMPLE.md](CONFIG_EXAMPLE.md) - Annotated configuration examples

