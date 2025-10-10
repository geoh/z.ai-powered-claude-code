# Z.AI CLI Wrapper Uninstallation Script for Windows (PowerShell)

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

Write-Header "Z.AI CLI Wrapper Uninstallation Script"

# Check for installed files
$filesFound = $false
if (Test-Path "$InstallDir\z") { $filesFound = $true }
if (Test-Path "$InstallDir\z.cmd") { $filesFound = $true }
if (Test-Path "$InstallDir\z.ps1") { $filesFound = $true }

if (-not $filesFound) {
    Write-ColorOutput "No Z.AI wrapper scripts found in $InstallDir" "Yellow"
} else {
    Write-ColorOutput "Found Z.AI wrapper scripts in $InstallDir" "Blue"
    Write-Host ""
    $removeScripts = Read-Host "Remove wrapper scripts? [y/N]"
    
    if ($removeScripts -eq "y" -or $removeScripts -eq "Y") {
        if (Test-Path "$InstallDir\z") {
            Remove-Item "$InstallDir\z" -Force
            Write-ColorOutput "✓ Removed $InstallDir\z" "Green"
        }
        if (Test-Path "$InstallDir\z.cmd") {
            Remove-Item "$InstallDir\z.cmd" -Force
            Write-ColorOutput "✓ Removed $InstallDir\z.cmd" "Green"
        }
        if (Test-Path "$InstallDir\z.ps1") {
            Remove-Item "$InstallDir\z.ps1" -Force
            Write-ColorOutput "✓ Removed $InstallDir\z.ps1" "Green"
        }
    } else {
        Write-ColorOutput "Skipped removing wrapper scripts" "Yellow"
    }
}

# Check for Claude status line
Write-Host ""
$statusLineFound = $false
if (Test-Path "$ClaudeDir\statusLine.sh") { $statusLineFound = $true }
if (Test-Path "$ClaudeDir\settings.json") { $statusLineFound = $true }

if (-not $statusLineFound) {
    Write-ColorOutput "No Claude status line configuration found" "Yellow"
} else {
    Write-ColorOutput "Found Claude status line configuration" "Blue"
    Write-Host ""
    $removeStatus = Read-Host "Remove Claude status line configuration? [y/N]"
    
    if ($removeStatus -eq "y" -or $removeStatus -eq "Y") {
        if (Test-Path "$ClaudeDir\statusLine.sh") {
            Remove-Item "$ClaudeDir\statusLine.sh" -Force
            Write-ColorOutput "✓ Removed $ClaudeDir\statusLine.sh" "Green"
        }
        
        if (Test-Path "$ClaudeDir\settings.json") {
            Write-Host ""
            Write-ColorOutput "Warning: settings.json may contain other Claude configurations." "Yellow"
            $removeSettings = Read-Host "Remove settings.json anyway? [y/N]"
            
            if ($removeSettings -eq "y" -or $removeSettings -eq "Y") {
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                $backupFile = "$ClaudeDir\settings.json.backup.$timestamp"
                Move-Item "$ClaudeDir\settings.json" -Destination $backupFile
                Write-ColorOutput "✓ Backed up and removed settings.json (backup: $backupFile)" "Green"
            } else {
                Write-ColorOutput "Kept settings.json" "Yellow"
                Write-Host "To manually remove the status line, edit $ClaudeDir\settings.json"
                Write-Host "and remove the 'statusLine' section."
            }
        }
    } else {
        Write-ColorOutput "Skipped removing Claude status line" "Yellow"
    }
}

# Ask about PATH cleanup
Write-Host ""
Write-ColorOutput "PATH Cleanup" "Blue"
Write-Host "The installer may have added $InstallDir to your PATH."
Write-Host ""
Write-ColorOutput "Note: Automatic PATH removal is not supported on Windows." "Yellow"
Write-Host "To remove manually, you can:"
Write-Host "  1. Open System Properties > Environment Variables"
Write-Host "  2. Edit the 'Path' variable under User variables"
Write-Host "  3. Remove the entry: $InstallDir"
Write-Host ""
Write-Host "Or run this PowerShell command:"
Write-Host "  `$path = [Environment]::GetEnvironmentVariable('Path', 'User')"
Write-Host "  `$newPath = (`$path -split ';' | Where-Object { `$_ -ne '$InstallDir' }) -join ';'"
Write-Host "  [Environment]::SetEnvironmentVariable('Path', `$newPath, 'User')"
Write-Host ""
$cleanPath = Read-Host "Would you like me to attempt automatic PATH cleanup? [y/N]"

if ($cleanPath -eq "y" -or $cleanPath -eq "Y") {
    try {
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
        $pathEntries = $currentPath -split ';' | Where-Object { $_ -ne $InstallDir -and $_ -ne "" }
        $newPath = $pathEntries -join ';'
        
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-ColorOutput "✓ Removed $InstallDir from PATH" "Green"
        Write-ColorOutput "  Please restart your terminal for changes to take effect." "Yellow"
    } catch {
        Write-ColorOutput "Error: Failed to update PATH automatically." "Red"
        Write-Host "Please remove manually using the instructions above."
    }
} else {
    Write-ColorOutput "Skipped PATH cleanup" "Yellow"
}

# Ask about config files
Write-Host ""
Write-ColorOutput "Configuration Files" "Blue"
Write-Host "Your Z.AI configuration files may contain your API key and settings."
Write-Host ""
Write-Host "Possible locations:"
if (Test-Path "$env:USERPROFILE\.zai.json") {
    Write-Host "  - $env:USERPROFILE\.zai.json (found)"
}
if (Test-Path "$env:APPDATA\zai\config.json") {
    Write-Host "  - $env:APPDATA\zai\config.json (found)"
}
if (Test-Path "$env:APPDATA\zai") {
    Write-Host "  - $env:APPDATA\zai\ directory (found)"
}
Write-Host ""
$removeConfig = Read-Host "Remove configuration files? [y/N]"

if ($removeConfig -eq "y" -or $removeConfig -eq "Y") {
    if (Test-Path "$env:USERPROFILE\.zai.json") {
        Remove-Item "$env:USERPROFILE\.zai.json" -Force
        Write-ColorOutput "✓ Removed $env:USERPROFILE\.zai.json" "Green"
    }
    
    if (Test-Path "$env:APPDATA\zai\config.json") {
        Remove-Item "$env:APPDATA\zai\config.json" -Force
        Write-ColorOutput "✓ Removed $env:APPDATA\zai\config.json" "Green"
    }
    
    if (Test-Path "$env:APPDATA\zai") {
        try {
            Remove-Item "$env:APPDATA\zai" -Force -ErrorAction Stop
            Write-ColorOutput "✓ Removed $env:APPDATA\zai directory" "Green"
        } catch {
            # Directory not empty or other error
        }
    }
    
    Write-Host ""
    Write-ColorOutput "Note: Per-project .zai.json files (if any) were not removed." "Yellow"
    Write-Host "You may want to clean those up manually in your project directories."
} else {
    Write-ColorOutput "Kept configuration files" "Yellow"
}

# Check for ZAI_API_KEY environment variable
Write-Host ""
if ($env:ZAI_API_KEY) {
    Write-ColorOutput "Found ZAI_API_KEY environment variable" "Blue"
    $removeEnvVar = Read-Host "Remove ZAI_API_KEY environment variable? [y/N]"
    
    if ($removeEnvVar -eq "y" -or $removeEnvVar -eq "Y") {
        try {
            [Environment]::SetEnvironmentVariable("ZAI_API_KEY", $null, "User")
            Write-ColorOutput "✓ Removed ZAI_API_KEY environment variable" "Green"
            Write-ColorOutput "  Please restart your terminal for changes to take effect." "Yellow"
        } catch {
            Write-ColorOutput "Error: Failed to remove environment variable." "Red"
        }
    }
}

# Uninstallation complete
Write-Host ""
Write-Header "Uninstallation Complete!"
Write-Host "If you made PATH or environment variable changes,"
Write-Host "restart your terminal for them to take effect."
Write-Host ""

