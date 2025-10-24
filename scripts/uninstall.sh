#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation directories
INSTALL_DIR="$HOME/.local/bin"
CLAUDE_DIR="$HOME/.claude"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Z.AI CLI Wrapper Uninstallation Script            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check for installed files (check all possible scripts regardless of platform)
FILES_FOUND=0
[ -f "$INSTALL_DIR/z" ] && FILES_FOUND=1
[ -f "$INSTALL_DIR/z.cmd" ] && FILES_FOUND=1
[ -f "$INSTALL_DIR/z.ps1" ] && FILES_FOUND=1
[ -f "$INSTALL_DIR/glm" ] && FILES_FOUND=1
[ -f "$INSTALL_DIR/glm.cmd" ] && FILES_FOUND=1
[ -f "$INSTALL_DIR/glm.ps1" ] && FILES_FOUND=1

if [ $FILES_FOUND -eq 0 ]; then
    echo -e "${YELLOW}No Z.AI wrapper scripts found in $INSTALL_DIR${NC}"
else
    echo -e "${BLUE}Found Z.AI wrapper scripts in $INSTALL_DIR${NC}"
    echo ""
    read -p "Remove wrapper scripts (including glm shims)? [y/N]: " remove_scripts

    if [ "$remove_scripts" = "y" ] || [ "$remove_scripts" = "Y" ]; then
        # Remove all scripts if they exist (for backward compatibility with older installations)
        [ -f "$INSTALL_DIR/z" ] && rm "$INSTALL_DIR/z" && echo -e "${GREEN}✓ Removed $INSTALL_DIR/z${NC}"
        [ -f "$INSTALL_DIR/z.cmd" ] && rm "$INSTALL_DIR/z.cmd" && echo -e "${GREEN}✓ Removed $INSTALL_DIR/z.cmd${NC}"
        [ -f "$INSTALL_DIR/z.ps1" ] && rm "$INSTALL_DIR/z.ps1" && echo -e "${GREEN}✓ Removed $INSTALL_DIR/z.ps1${NC}"
        [ -f "$INSTALL_DIR/glm" ] && rm "$INSTALL_DIR/glm" && echo -e "${GREEN}✓ Removed $INSTALL_DIR/glm${NC}"
        [ -f "$INSTALL_DIR/glm.cmd" ] && rm "$INSTALL_DIR/glm.cmd" && echo -e "${GREEN}✓ Removed $INSTALL_DIR/glm.cmd${NC}"
        [ -f "$INSTALL_DIR/glm.ps1" ] && rm "$INSTALL_DIR/glm.ps1" && echo -e "${GREEN}✓ Removed $INSTALL_DIR/glm.ps1${NC}"
    else
        echo -e "${YELLOW}Skipped removing wrapper scripts${NC}"
    fi
fi

# Check for Claude status line
echo ""
STATUS_LINE_FOUND=0
[ -f "$CLAUDE_DIR/statusLine.sh" ] && STATUS_LINE_FOUND=1
[ -f "$CLAUDE_DIR/settings.json" ] && STATUS_LINE_FOUND=1

if [ $STATUS_LINE_FOUND -eq 0 ]; then
    echo -e "${YELLOW}No Claude status line configuration found${NC}"
else
    echo -e "${BLUE}Found Claude status line configuration${NC}"
    echo ""
    read -p "Remove Claude status line configuration? [y/N]: " remove_status
    
    if [ "$remove_status" = "y" ] || [ "$remove_status" = "Y" ]; then
        if [ -f "$CLAUDE_DIR/statusLine.sh" ]; then
            rm "$CLAUDE_DIR/statusLine.sh"
            echo -e "${GREEN}✓ Removed $CLAUDE_DIR/statusLine.sh${NC}"
        fi
        
        if [ -f "$CLAUDE_DIR/settings.json" ]; then
            echo ""
            echo -e "${YELLOW}Warning: settings.json may contain other Claude configurations.${NC}"
            read -p "Remove settings.json anyway? [y/N]: " remove_settings
            
            if [ "$remove_settings" = "y" ] || [ "$remove_settings" = "Y" ]; then
                BACKUP_FILE="$CLAUDE_DIR/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
                mv "$CLAUDE_DIR/settings.json" "$BACKUP_FILE"
                echo -e "${GREEN}✓ Backed up and removed settings.json (backup: $BACKUP_FILE)${NC}"
            else
                echo -e "${YELLOW}Kept settings.json${NC}"
                echo "To manually remove the status line, edit $CLAUDE_DIR/settings.json"
                echo "and remove the 'statusLine' section."
            fi
        fi
    else
        echo -e "${YELLOW}Skipped removing Claude status line${NC}"
    fi
fi

# Ask about PATH cleanup
echo ""
echo -e "${BLUE}PATH Cleanup${NC}"
echo "The installer may have added $INSTALL_DIR to your PATH."
echo ""
read -p "Would you like to remove it from your shell profiles? [y/N]: " clean_path

if [ "$clean_path" = "y" ] || [ "$clean_path" = "Y" ]; then
    # Detect shell profiles
    SHELL_PROFILES=()
    [ -f "$HOME/.bashrc" ] && SHELL_PROFILES+=("$HOME/.bashrc")
    [ -f "$HOME/.bash_profile" ] && SHELL_PROFILES+=("$HOME/.bash_profile")
    [ -f "$HOME/.zshrc" ] && SHELL_PROFILES+=("$HOME/.zshrc")
    [ -f "$HOME/.profile" ] && SHELL_PROFILES+=("$HOME/.profile")
    
    if [ ${#SHELL_PROFILES[@]} -eq 0 ]; then
        echo -e "${YELLOW}No shell profile files found.${NC}"
    else
        for profile in "${SHELL_PROFILES[@]}"; do
            if grep -q "\.local/bin" "$profile" 2>/dev/null; then
                echo ""
                echo "Found .local/bin reference in $profile"
                read -p "Remove from this file? [y/N]: " remove_from_profile
                
                if [ "$remove_from_profile" = "y" ] || [ "$remove_from_profile" = "Y" ]; then
                    # Create backup
                    BACKUP_FILE="$profile.backup.$(date +%Y%m%d_%H%M%S)"
                    cp "$profile" "$BACKUP_FILE"

                    # Remove lines containing .local/bin and the comment before it
                    # Use a temp file for cross-platform compatibility (GNU sed vs BSD sed)
                    grep -v '# Added by Z.AI CLI wrapper installer' "$profile" | grep -v '\.local/bin' > "$profile.tmp"
                    mv "$profile.tmp" "$profile"

                    echo -e "${GREEN}✓ Removed from $profile (backup: $BACKUP_FILE)${NC}"
                fi
            fi
        done
    fi
else
    echo -e "${YELLOW}Skipped PATH cleanup${NC}"
    echo "To manually remove, edit your shell profile and remove lines containing:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# Ask about config files
echo ""
CONFIG_FOUND=0
[ -f "$HOME/.zai.json" ] && CONFIG_FOUND=1
[ -f "$HOME/.config/zai/config.json" ] && CONFIG_FOUND=1
[ -d "$HOME/.config/zai" ] && CONFIG_FOUND=1

if [ $CONFIG_FOUND -eq 0 ]; then
    echo -e "${YELLOW}No Z.AI configuration files found${NC}"
else
    echo -e "${BLUE}Configuration Files${NC}"
    echo "Your Z.AI configuration files may contain your API key and settings."
    echo ""
    echo "Possible locations:"
    [ -f "$HOME/.zai.json" ] && echo "  - $HOME/.zai.json (found)"
    [ -f "$HOME/.config/zai/config.json" ] && echo "  - $HOME/.config/zai/config.json (found)"
    [ -d "$HOME/.config/zai" ] && echo "  - $HOME/.config/zai/ directory (found)"
    echo ""
    read -p "Remove configuration files? [y/N]: " remove_config

    if [ "$remove_config" = "y" ] || [ "$remove_config" = "Y" ]; then
        if [ -f "$HOME/.zai.json" ]; then
            rm "$HOME/.zai.json"
            echo -e "${GREEN}✓ Removed $HOME/.zai.json${NC}"
        fi

        if [ -f "$HOME/.config/zai/config.json" ]; then
            rm "$HOME/.config/zai/config.json"
            echo -e "${GREEN}✓ Removed $HOME/.config/zai/config.json${NC}"
        fi

        if [ -d "$HOME/.config/zai" ]; then
            rmdir "$HOME/.config/zai" 2>/dev/null && echo -e "${GREEN}✓ Removed $HOME/.config/zai directory${NC}"
        fi

        echo ""
        echo -e "${YELLOW}Note: Per-project .zai.json files (if any) were not removed.${NC}"
        echo "You may want to clean those up manually in your project directories."
    else
        echo -e "${YELLOW}Kept configuration files${NC}"
    fi
fi

# Uninstallation complete
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            Uninstallation Complete!                       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "If you made PATH changes, restart your terminal for them to take effect."
echo ""

