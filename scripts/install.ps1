# Z.AI CLI Wrapper Installation Script for Windows (PowerShell)
# Requires PowerShell 5.0 or later

$ErrorActionPreference = "Stop"

# Installation directories
$InstallDir = "$env:USERPROFILE\.local\bin"
$ClaudeDir = "$env:USERPROFILE\.claude"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-ColorOutput "═══════════════════════════════════════════════════════════" "Cyan"
    Write-ColorOutput "  $Text" "Cyan"
    Write-ColorOutput "═══════════════════════════════════════════════════════════" "Cyan"
    Write-Host ""
}

Write-Header "Z.AI CLI Wrapper Installation Script"

# Check if running from the project directory
if (-not (Test-Path "bin\z") -or -not (Test-Path "bin\z.cmd") -or -not (Test-Path "bin\z.ps1")) {
    Write-ColorOutput "Error: Please run this script from the project root directory." "Red"
    exit 1
}

# Check for jq dependency
$jqInstalled = $null -ne (Get-Command jq -ErrorAction SilentlyContinue)
if (-not $jqInstalled) {
    Write-ColorOutput "Warning: 'jq' is not installed." "Yellow"
    Write-Host "The wrapper scripts require jq to parse configuration files."
    Write-Host ""
    Write-Host "Install jq using one of these methods:"
    Write-Host "  - Chocolatey: choco install jq"
    Write-Host "  - Scoop: scoop install jq"
    Write-Host "  - Download from: https://stedolan.github.io/jq/download/"
    Write-Host ""
    $continue = Read-Host "Continue anyway? [y/N]"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 1
    }
}

# Create installation directory if it doesn't exist
Write-ColorOutput "Creating installation directory..." "Blue"
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# Copy wrapper scripts
Write-ColorOutput "Installing wrapper scripts..." "Blue"
Copy-Item "bin\z" -Destination "$InstallDir\z" -Force
Copy-Item "bin\z.cmd" -Destination "$InstallDir\z.cmd" -Force
Copy-Item "bin\z.ps1" -Destination "$InstallDir\z.ps1" -Force

Write-ColorOutput "✓ Wrapper scripts installed to $InstallDir" "Green"

# Check if InstallDir is in PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathNeedsUpdate = $currentPath -notlike "*$InstallDir*"

if ($pathNeedsUpdate) {
    Write-Host ""
    Write-ColorOutput "Warning: $InstallDir is not in your PATH." "Yellow"
    Write-Host ""
    $addPath = Read-Host "Would you like to add $InstallDir to your PATH? [y/N]"
    
    if ($addPath -eq "y" -or $addPath -eq "Y") {
        try {
            # Add to user PATH
            $newPath = "$currentPath;$InstallDir"
            [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
            Write-ColorOutput "✓ Added $InstallDir to your PATH" "Green"
            Write-ColorOutput "  Please restart your terminal for changes to take effect." "Yellow"
        } catch {
            Write-ColorOutput "Error: Failed to update PATH. You may need to run as Administrator." "Red"
            Write-Host "To add manually, run:"
            Write-Host "  [Environment]::SetEnvironmentVariable('Path', `$env:Path + ';$InstallDir', 'User')"
        }
    } else {
        Write-Host ""
        Write-Host "To add $InstallDir to your PATH manually, run:"
        Write-Host "  [Environment]::SetEnvironmentVariable('Path', `$env:Path + ';$InstallDir', 'User')"
    }
} else {
    Write-ColorOutput "✓ $InstallDir is already in your PATH" "Green"
}

# Ask about Claude status line installation
Write-Host ""
Write-ColorOutput "Claude Status Line Configuration" "Blue"
Write-Host "The status line displays model info, git branch, code changes, timing, and cost."
Write-Host ""
$installStatus = Read-Host "Would you like to install the Claude status line configuration? [y/N]"

if ($installStatus -eq "y" -or $installStatus -eq "Y") {
    Write-ColorOutput "Installing Claude status line..." "Blue"
    
    # Create Claude directory
    if (-not (Test-Path $ClaudeDir)) {
        New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
    }
    
    # Copy status line script
    Copy-Item "claude\statusLine.sh" -Destination "$ClaudeDir\statusLine.sh" -Force
    
    Write-ColorOutput "✓ Status line script installed to $ClaudeDir" "Green"
    
    # Handle settings.json
    $settingsFile = "$ClaudeDir\settings.json"
    
    if (Test-Path $settingsFile) {
        Write-Host ""
        Write-ColorOutput "Existing settings.json found." "Yellow"
        Write-Host "Options:"
        Write-Host "  1) Merge with existing settings (recommended)"
        Write-Host "  2) Backup existing and replace"
        Write-Host "  3) Skip settings.json update"
        $settingsChoice = Read-Host "Choose [1-3]"
        
        switch ($settingsChoice) {
            "1" {
                # Merge using PowerShell
                try {
                    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                    $backupFile = "$settingsFile.backup.$timestamp"
                    Copy-Item $settingsFile -Destination $backupFile
                    
                    $existingSettings = Get-Content $settingsFile | ConvertFrom-Json
                    $newSettings = Get-Content "claude\settings.json" | ConvertFrom-Json
                    
                    # Merge settings (new settings override existing)
                    $existingSettings.PSObject.Properties | ForEach-Object {
                        if (-not $newSettings.PSObject.Properties.Name.Contains($_.Name)) {
                            $newSettings | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
                        }
                    }
                    
                    $newSettings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile
                    Write-ColorOutput "✓ Settings merged (backup saved to $backupFile)" "Green"
                } catch {
                    Write-ColorOutput "Error: Failed to merge settings. Please merge manually." "Red"
                }
            }
            "2" {
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                $backupFile = "$settingsFile.backup.$timestamp"
                Move-Item $settingsFile -Destination $backupFile
                Copy-Item "claude\settings.json" -Destination $settingsFile
                Write-ColorOutput "✓ Settings replaced (backup saved to $backupFile)" "Green"
            }
            "3" {
                Write-ColorOutput "Skipped settings.json update" "Yellow"
                Write-Host "To enable the status line, add this to $settingsFile:"
                Get-Content "claude\settings.json"
            }
        }
    } else {
        # No existing settings, just copy
        Copy-Item "claude\settings.json" -Destination $settingsFile
        Write-ColorOutput "✓ Settings file created" "Green"
    }
    
    # Note about Git Bash requirement
    Write-Host ""
    Write-ColorOutput "Note: The status line script requires Git Bash or WSL to run." "Yellow"
    Write-Host "Make sure you have Git for Windows installed with Git Bash."
} else {
    Write-ColorOutput "Skipped Claude status line installation" "Yellow"
}

# Installation complete
Write-Host ""
Write-Header "Installation Complete!"
Write-Host "Next steps:"
Write-Host "  1. Restart your terminal (PowerShell, CMD, or Git Bash)"
Write-Host "  2. Run 'z' to configure your Z.AI API key (first-time setup)"
Write-Host "  3. Use 'z' instead of 'claude' to launch Claude Code with Z.AI"
Write-Host ""
Write-Host "For more information, see README.md"
Write-Host ""

if ($pathNeedsUpdate -and ($addPath -eq "y" -or $addPath -eq "Y")) {
    Write-ColorOutput "IMPORTANT: Please restart your terminal for PATH changes to take effect!" "Yellow"
}

