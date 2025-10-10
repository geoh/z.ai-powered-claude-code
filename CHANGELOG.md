# Changelog

All notable changes to the Z.AI CLI Wrapper project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

#### Cross-Platform Compatibility
- **Config File Detection**: Enhanced all wrapper scripts (z, z.cmd, z.ps1) to properly detect config files across different platforms
  - Added support for `XDG_CONFIG_HOME` environment variable
  - Added support for `HOME/.config` location (Git Bash compatibility on Windows)
  - Added support for `USERPROFILE/.config` location (Windows alternative)
  - Improved config file search order consistency across all platforms
- **Windows Bash Script**: Fixed permission checks to skip on Windows (Git Bash/MSYS/Cygwin environments)
  - Detects Windows environment via `$OSTYPE`, `$WINDIR`, or `$SYSTEMROOT`
  - Prevents false permission warnings on Windows filesystems
- **Windows CMD Script**: Fixed variable quoting issues that could cause environment variable problems
  - All environment variables now properly quoted with `set "VAR=value"` syntax
  - Prevents issues with special characters in paths

#### Status Line
- **Settings Configuration**: Fixed `claude/settings.json` command syntax for proper bash invocation
  - Changed from `bash ~/.claude/statusLine.sh` to `bash -c '. "$HOME/.claude/statusLine.sh"'`
  - Ensures proper script sourcing and environment handling
- **Documentation**: Added comprehensive header to `statusLine.sh` explaining its purpose and usage
  - Warns users not to run manually (will hang waiting for stdin)
  - Clarifies it's designed to be called by Claude Code via settings.json
- **Windows Limitations**: Added clear documentation about status line limitations on Windows
  - Status line **only works with Git Bash** (`z` script)
  - Does **not work** with CMD (`z.cmd`) or PowerShell (`z.ps1`) due to stdin piping limitations
  - Updated README.md and INSTALL.md with prominent warnings

#### Configuration Creation
- **Output Redirection**: Fixed interactive prompts in bash script to use stderr (`>&2`)
  - Prevents prompts from interfering with script output parsing
  - Ensures clean stdout for automation scenarios
- **JSON Syntax**: Fixed JSON syntax error in config template (extra comma after `haikuModel`)
- **Missing Field**: Added `subagentModel` field to config creation in all scripts
  - Ensures consistency with documented configuration options
  - Prevents errors when subagent model is referenced

#### Uninstall Scripts
- **Better Error Handling**: Improved all uninstall scripts to handle cases where no files are found
  - Scripts now check if files exist before prompting for removal
  - Cleaner output when nothing needs to be uninstalled
  - Prevents confusing prompts about non-existent files
- **Output Formatting**: Standardized success messages across scripts
  - Windows batch files now use `[OK]` instead of `✓` for better compatibility
  - Consistent formatting across all platforms

#### Git Commit Attribution
- **System Prompt Override**: Added `--append-system-prompt` to all wrapper scripts
  - Instructs Claude to use proper GLM model name and Z.AI email in git commits
  - Format: `Co-Authored-By: [model name] <noreply@z.ai>`
  - Ensures proper attribution when AI assists with commits

### Added

#### Debugging
- **Debug Output**: Added debug line in `z.cmd` for troubleshooting model configuration
  - Outputs `ANTHROPIC_DEFAULT_OPUS_MODEL` value to stderr
  - Can be commented out after testing
  - Helps diagnose model selection issues

### Changed

#### Documentation
- **README.md**: Enhanced platform-specific notes section
  - Added prominent warning about Windows status line limitations
  - Clarified which scripts support which features
  - Improved troubleshooting section with Windows-specific guidance
- **INSTALL.md**: Updated troubleshooting section
  - Added detailed explanation of Windows status line limitations
  - Improved bash installation instructions for Windows users
  - Clarified Git for Windows requirement for full functionality

## [2.0.0] - 2025-10-10

### Added

#### Configuration Enhancements
- **Environment Variable Support**: Added `ZAI_API_KEY` environment variable for secure API key storage (highest priority)
- **Custom Config Path**: Added `ZAI_CONFIG_PATH` environment variable to specify custom configuration file location
- **XDG Base Directory Support** (Linux/macOS): Config files now follow XDG Base Directory specification
  - Checks `$XDG_CONFIG_HOME/zai/config.json`
  - Falls back to `~/.config/zai/config.json`
  - Maintains backward compatibility with `~/.zai.json`
- **Windows AppData Support**: Added support for `%APPDATA%\zai\config.json` location
- **Per-Project Configuration**: Support for `.zai.json` in project directories with shallow merge of global settings
- **Interactive Configuration Wizard**: First-time setup wizard that guides users through:
  - API key entry
  - Configuration location selection (user home vs. project directory)
  - API key storage method (config file vs. environment variable)
  - Automatic environment variable setup with immediate effect (no terminal restart required)
- **File Permission Checks** (Unix): Warns if config files have overly permissive permissions
- **Automatic Permission Setting** (Unix): Sets chmod 600 on newly created config files

#### Installation & Deployment
- **Automated Installation Scripts** (in `scripts/` directory):
  - `scripts/install.sh` for Linux/macOS with shell profile detection and PATH management
  - `scripts/install.ps1` for Windows PowerShell with user PATH management
  - `scripts/install.bat` for Windows CMD with setx PATH management
  - Automatic detection of existing installations with upgrade/reinstall option
  - Seamless upgrade path for future versions
- **Automated Uninstallation Scripts** (in `scripts/` directory):
  - `scripts/uninstall.sh` for Linux/macOS with PATH cleanup
  - `scripts/uninstall.ps1` for Windows PowerShell with PATH and environment variable cleanup
  - `scripts/uninstall.bat` for Windows CMD with environment variable cleanup
- **Optional Claude Status Line Installation**: Installers now prompt for opt-in status line setup
- **Dependency Checking**: Installers check for jq and provide installation instructions
- **PATH Management**: Automated PATH configuration with user confirmation

#### Documentation
- **INSTALL.md**: Comprehensive installation guide covering:
  - Automated and manual installation for all platforms
  - PATH configuration instructions
  - Verification steps
  - Detailed troubleshooting
- **CONFIGURATION.md**: Detailed configuration reference including:
  - All configuration options explained
  - Config file locations and priority order
  - Environment variable reference
  - Per-project configuration examples
  - Security best practices
  - Migration guide from old setup
- **CONFIG_EXAMPLE.md**: Annotated example configuration with:
  - Detailed explanation of each option
  - Common configuration scenarios
  - Security recommendations
- **Enhanced README.md**: Updated with:
  - Quick start section
  - Environment variable documentation
  - Configuration priority explanation
  - Per-project config usage
  - Security best practices
  - Uninstallation instructions

#### Project Files
- **.gitignore**: Added comprehensive gitignore covering:
  - `.zai.json` files (may contain secrets)
  - OS-specific files (macOS, Windows, Linux)
  - IDE files (VS Code, JetBrains, Sublime, Vim, Emacs)
  - Backup and temporary files
- **.zai.json.example**: Example configuration file for easy setup

### Changed

#### Configuration Priority
- **New Priority Order for API Key**:
  1. `ZAI_API_KEY` environment variable (highest)
  2. `apiKey` from config file
  3. Error if neither available or value is placeholder

- **New Config File Search Order** (Linux/macOS):
  1. `./.zai.json` (per-project)
  2. `$ZAI_CONFIG_PATH` (if set)
  3. `$XDG_CONFIG_HOME/zai/config.json` (if XDG_CONFIG_HOME set)
  4. `~/.config/zai/config.json` (XDG default)
  5. `~/.zai.json` (legacy, backward compatible)

- **New Config File Search Order** (Windows):
  1. `.\.zai.json` (per-project)
  2. `%ZAI_CONFIG_PATH%` (if set)
  3. `%APPDATA%\zai\config.json`
  4. `%USERPROFILE%\.zai.json` (legacy, backward compatible)

#### Wrapper Scripts
- **Enhanced Error Messages**: More helpful error messages with actionable suggestions
- **Improved Config Validation**: Better validation of API keys and config values
- **Modular Functions**: Refactored scripts with helper functions for better maintainability
- **Config Merging**: Implemented shallow merge for per-project configs
- **Immediate Environment Variable Setup**: API keys set via environment variable during interactive setup are now immediately available in the current session (no terminal restart required)

### Security

- **Environment Variable Priority**: API keys from environment variables now take precedence over config files
- **Permission Warnings**: Unix systems now warn about overly permissive config file permissions
- **Secure Defaults**: New config files created with chmod 600 on Unix systems
- **Documentation**: Added comprehensive security best practices documentation

### Backward Compatibility

- **Legacy Config Location**: `~/.zai.json` (Unix) and `%USERPROFILE%\.zai.json` (Windows) still supported
- **Existing Configs**: All existing configurations continue to work without modification
- **No Breaking Changes**: All changes are additive; existing setups remain functional

### Migration Path

Users with existing `~/.zai.json` files can:
1. Continue using the legacy location (fully supported)
2. Migrate to XDG location: `mv ~/.zai.json ~/.config/zai/config.json`
3. Move API key to environment variable for enhanced security

No immediate action required - all existing setups continue to work.

## [1.0.0] - Initial Release

### Added

- Basic wrapper scripts for Linux/macOS (`bin/z`) and Windows (`bin/z.cmd`, `bin/z.ps1`)
- Configuration file support at `~/.zai.json`
- Model mapping (opus, sonnet, haiku to Z.AI GLM models)
- Default model configuration
- AI thinking capabilities configuration
- Claude status line integration with:
  - Model indicator (👾 for Claude, 👹 for Z.AI)
  - Git branch display
  - Code changes tracking
  - Timing information
  - Cost tracking
- Cross-platform support (Linux, macOS, Windows)
- Basic documentation (README.md)

### Configuration Options

- `apiKey`: Z.AI API key
- `opusModel`: Model for opus tier
- `sonnetModel`: Model for sonnet tier
- `haikuModel`: Model for haiku tier
- `subagentModel`: Model for subagent operations
- `defaultModel`: Default model to use
- `enableThinking`: Enable AI thinking
- `enableStreaming`: Enable streaming responses
- `reasoningEffort`: Reasoning effort level
- `maxThinkingTokens`: Max tokens for thinking
- `maxOutputTokens`: Max tokens for output

---

## Version History

- **2.0.0** - Major update with enhanced configuration, automated installation, and comprehensive documentation
- **1.0.0** - Initial release with basic wrapper functionality

---

## Upgrade Guide

### From 1.0.0 to 2.0.0

#### No Action Required

Your existing setup will continue to work without any changes. The 2.0.0 release is fully backward compatible.

#### Optional: Migrate to New Features

1. **Move API Key to Environment Variable** (Recommended for security):
   ```bash
   export ZAI_API_KEY="your-api-key"
   # Add to ~/.bashrc or ~/.zshrc
   ```

2. **Migrate to XDG Location** (Linux/macOS):
   ```bash
   mkdir -p ~/.config/zai
   mv ~/.zai.json ~/.config/zai/config.json
   chmod 600 ~/.config/zai/config.json
   ```

3. **Use Automated Installer** (For new installations):
   ```bash
   bash scripts/install.sh
   ```

4. **Set Up Per-Project Configs**:
   - Create `.zai.json` in project directories
   - Add `.zai.json` to `.gitignore`
   - Store only project-specific overrides (not API keys)

#### Benefits of Upgrading

- Enhanced security with environment variable support
- Better organization with XDG-compliant paths
- Per-project configuration flexibility
- Automated installation and uninstallation
- Comprehensive documentation
- Interactive first-time setup

---

## Contributing

Contributions are welcome! Please see [README.md](README.md) for contribution guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

