# Installation Guide

This guide provides comprehensive installation instructions for the Z.AI CLI wrapper on all supported platforms.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Automated Installation](#automated-installation)
- [Manual Installation](#manual-installation)
- [PATH Configuration](#path-configuration)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required

1. **Claude Code** - Must be installed and accessible via the `claude` command
2. **jq** - JSON processor for parsing configuration files

### Installing jq

#### Linux

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install jq
```

**Fedora/RHEL/CentOS:**
```bash
sudo dnf install jq
# or
sudo yum install jq
```

**Arch Linux:**
```bash
sudo pacman -S jq
```

#### macOS

**Using Homebrew:**
```bash
brew install jq
```

**Using MacPorts:**
```bash
sudo port install jq
```

#### Windows

**Using Chocolatey:**
```cmd
choco install jq
```

**Using Scoop:**
```cmd
scoop install jq
```

**Manual Download:**
Download from [https://stedolan.github.io/jq/download/](https://stedolan.github.io/jq/download/)

### Optional

- **Git Bash** (Windows) - Required for status line functionality on Windows

## Automated Installation

The automated installers handle everything: copying files, setting up PATH, and optionally installing the Claude status line.

**Note:** If you already have Z.AI installed, the installer will detect it and offer to upgrade/reinstall. This makes updating to new versions seamless.

### Linux/macOS

1. Clone or download this repository
2. Navigate to the project directory
3. Run the installer:

```bash
bash scripts/install.sh
```

The installer will:
- Detect and offer to upgrade existing installations
- Check for jq dependency
- Copy wrapper scripts to `~/.local/bin`
- Make scripts executable
- Detect your shell profiles (.bashrc, .zshrc, .bash_profile, .profile)
- Optionally add `~/.local/bin` to PATH
- Optionally install Claude status line configuration

### Windows (PowerShell)

1. Clone or download this repository
2. Open PowerShell
3. Navigate to the project directory
4. Run the installer:

```powershell
.\scripts\install.ps1
```

The installer will:
- Detect and offer to upgrade existing installations
- Check for jq dependency
- Copy wrapper scripts to `%USERPROFILE%\.local\bin`
- Optionally add to user PATH using `[Environment]::SetEnvironmentVariable`
- Optionally install Claude status line configuration

### Windows (Command Prompt)

1. Clone or download this repository
2. Open Command Prompt
3. Navigate to the project directory
4. Run the installer:

```cmd
scripts\install.bat
```

The installer will:
- Detect and offer to upgrade existing installations
- Check for jq dependency
- Copy wrapper scripts to `%USERPROFILE%\.local\bin`
- Optionally add to PATH using `setx` command
- Optionally install Claude status line configuration

## Manual Installation

If you prefer to install manually or need more control over the installation process:

### Linux/macOS

```bash
# 1. Create installation directory
mkdir -p ~/.local/bin

# 2. Copy wrapper script
cp bin/z ~/.local/bin/z

# 3. Make executable
chmod +x ~/.local/bin/z

# 4. Add to PATH (choose your shell)
# For bash (add to ~/.bashrc):
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# For zsh (add to ~/.zshrc):
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

# 5. Reload shell configuration
source ~/.bashrc  # or source ~/.zshrc

# 6. Optional: Install status line
mkdir -p ~/.claude
cp claude/statusLine.sh ~/.claude/
chmod +x ~/.claude/statusLine.sh
cp claude/settings.json ~/.claude/
# Or merge with existing settings.json if you have one
```

### Windows (PowerShell)

```powershell
# 1. Create installation directory
New-Item -ItemType Directory -Path "$env:USERPROFILE\.local\bin" -Force

# 2. Copy wrapper scripts
Copy-Item "bin\z.cmd" -Destination "$env:USERPROFILE\.local\bin\z.cmd"
Copy-Item "bin\z.ps1" -Destination "$env:USERPROFILE\.local\bin\z.ps1"

# 3. Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$newPath = "$currentPath;$env:USERPROFILE\.local\bin"
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

# 4. Restart PowerShell for PATH changes to take effect

# 5. Optional: Install status line
New-Item -ItemType Directory -Path "$env:USERPROFILE\.claude" -Force
Copy-Item "claude\statusLine.sh" -Destination "$env:USERPROFILE\.claude\"
Copy-Item "claude\settings.json" -Destination "$env:USERPROFILE\.claude\"
```

### Windows (Command Prompt)

```cmd
rem 1. Create installation directory
mkdir %USERPROFILE%\.local\bin

rem 2. Copy wrapper scripts
copy bin\z.cmd %USERPROFILE%\.local\bin\z.cmd
copy bin\z.ps1 %USERPROFILE%\.local\bin\z.ps1

rem 3. Add to PATH
setx PATH "%PATH%;%USERPROFILE%\.local\bin"

rem 4. Restart Command Prompt for PATH changes to take effect

rem 5. Optional: Install status line
mkdir %USERPROFILE%\.claude
copy claude\statusLine.sh %USERPROFILE%\.claude\
copy claude\settings.json %USERPROFILE%\.claude\
```

## PATH Configuration

### Verifying PATH

After installation, verify that the installation directory is in your PATH:

**Linux/macOS:**
```bash
echo $PATH | grep -o "$HOME/.local/bin"
```

**Windows (PowerShell):**
```powershell
$env:Path -split ';' | Select-String "\.local\\bin"
```

**Windows (CMD):**
```cmd
echo %PATH% | find ".local\bin"
```

### Manual PATH Configuration

If the automated installer didn't add the directory to your PATH, or you want to do it manually:

#### Linux/macOS

Add to your shell profile:

**Bash (~/.bashrc or ~/.bash_profile):**
```bash
export PATH="$HOME/.local/bin:$PATH"
```

**Zsh (~/.zshrc):**
```bash
export PATH="$HOME/.local/bin:$PATH"
```

**Fish (~/.config/fish/config.fish):**
```fish
set -gx PATH $HOME/.local/bin $PATH
```

Then reload your shell:
```bash
source ~/.bashrc  # or appropriate profile file
```

#### Windows

**PowerShell (Permanent):**
```powershell
$path = [Environment]::GetEnvironmentVariable("Path", "User")
[Environment]::SetEnvironmentVariable("Path", "$path;$env:USERPROFILE\.local\bin", "User")
```

**CMD (Permanent):**
```cmd
setx PATH "%PATH%;%USERPROFILE%\.local\bin"
```

**GUI Method:**
1. Open System Properties (Win + Pause/Break)
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", select "Path" and click "Edit"
5. Click "New" and add: `%USERPROFILE%\.local\bin`
6. Click OK on all dialogs
7. Restart your terminal

## Verification

After installation, verify everything is working:

### 1. Check Command Availability

```bash
# Should show the path to the z command
which z        # Linux/macOS
where z        # Windows
```

### 2. Check jq Installation

```bash
jq --version
```

### 3. Run First-Time Setup

```bash
z
```

This should launch the interactive configuration wizard if no config file exists.

**What to expect:**
- You'll be prompted for your Z.AI API key
- Choose between storing in a config file or environment variable
- If you choose environment variable, it will be set immediately in your current session
- You can start using Z.AI right away without restarting your terminal
- The wizard will optionally add the environment variable to your shell profile for persistence

### 4. Test with Help Command

```bash
z --help
```

This should display Claude Code's help information.

## Troubleshooting

### Command Not Found

**Problem:** `z: command not found` or `'z' is not recognized`

**Solutions:**
1. Verify installation directory exists and contains the scripts
2. Check that the directory is in your PATH (see [Verifying PATH](#verifying-path))
3. Restart your terminal/shell
4. On Windows, ensure you restarted the terminal after PATH changes

### Permission Denied (Linux/macOS)

**Problem:** `Permission denied` when running `z`

**Solution:**
```bash
chmod +x ~/.local/bin/z
```

### jq Not Found

**Problem:** Scripts fail with "jq: command not found"

**Solution:**
Install jq using your package manager (see [Installing jq](#installing-jq))

### PATH Not Persisting

**Problem:** PATH works in current session but not after restart

**Solutions:**

**Linux/macOS:**
- Ensure you added the export to the correct shell profile
- Check which shell you're using: `echo $SHELL`
- Some systems use `.bash_profile` instead of `.bashrc`

**Windows:**
- Use `setx` (CMD) or `[Environment]::SetEnvironmentVariable` (PowerShell)
- Don't use `set` (CMD) or `$env:` (PowerShell) for permanent changes
- Restart terminal after setting

### Status Line Not Working

**Problem:** Status line doesn't appear in Claude Code

**Solutions:**
1. Verify `~/.claude/settings.json` exists and contains statusLine configuration
2. Check that `statusLine.sh` is executable: `chmod +x ~/.claude/statusLine.sh`
3. On Windows, ensure Git Bash is installed and in PATH
4. Verify the path in settings.json matches your installation

### Installation Script Fails

**Problem:** Installation script exits with errors

**Solutions:**
1. Ensure you're running from the project root directory
2. Check that all required files exist in `bin/` and `claude/` directories
3. On Linux/macOS, ensure script is executable: `chmod +x install.sh`
4. On Windows PowerShell, you may need to adjust execution policy:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## Next Steps

After successful installation:

1. **Configure your API key**: Run `z` to start the configuration wizard
2. **Read the configuration guide**: See [CONFIGURATION.md](CONFIGURATION.md)
3. **Test the wrapper**: Try `z --help` or start a session with `z`
4. **Set up per-project configs**: Create `.zai.json` in your projects as needed

## Uninstallation

To remove the Z.AI wrapper, use the uninstall scripts:

**Linux/macOS:**
```bash
bash scripts/uninstall.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\uninstall.ps1
```

**Windows (CMD):**
```cmd
scripts\uninstall.bat
```

The uninstaller will guide you through removing:
- Wrapper scripts
- Claude status line configuration
- PATH entries (Linux/macOS only)
- Configuration files
- Environment variables

