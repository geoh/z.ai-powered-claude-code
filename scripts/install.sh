#!/bin/bash

set -e

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
echo -e "${BLUE}║         Z.AI CLI Wrapper Installation Script              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running from the project directory
if [ ! -f "bin/z" ] || [ ! -f "bin/z.cmd" ] || [ ! -f "bin/z.ps1" ]; then
    echo -e "${RED}Error: Please run this script from the project root directory.${NC}"
    exit 1
fi

# Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: 'jq' is not installed.${NC}"
    echo "The wrapper scripts require jq to parse configuration files."
    echo ""
    echo "Install jq using your package manager:"
    echo "  - Ubuntu/Debian: sudo apt-get install jq"
    echo "  - macOS: brew install jq"
    echo "  - Fedora: sudo dnf install jq"
    echo ""
    read -p "Continue anyway? [y/N]: " continue_install
    if [ "$continue_install" != "y" ] && [ "$continue_install" != "Y" ]; then
        exit 1
    fi
fi

# Create installation directory if it doesn't exist
echo -e "${BLUE}Creating installation directory...${NC}"
mkdir -p "$INSTALL_DIR"

# Copy wrapper scripts
echo -e "${BLUE}Installing wrapper scripts...${NC}"
cp bin/z "$INSTALL_DIR/z"
cp bin/z.cmd "$INSTALL_DIR/z.cmd"
cp bin/z.ps1 "$INSTALL_DIR/z.ps1"

# Make scripts executable
chmod +x "$INSTALL_DIR/z"
chmod +x "$INSTALL_DIR/z.cmd"
chmod +x "$INSTALL_DIR/z.ps1"

echo -e "${GREEN}✓ Wrapper scripts installed to $INSTALL_DIR${NC}"

# Check if INSTALL_DIR is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo -e "${YELLOW}Warning: $INSTALL_DIR is not in your PATH.${NC}"
    echo ""
    
    # Detect shell profiles
    SHELL_PROFILES=()
    [ -f "$HOME/.bashrc" ] && SHELL_PROFILES+=("$HOME/.bashrc")
    [ -f "$HOME/.bash_profile" ] && SHELL_PROFILES+=("$HOME/.bash_profile")
    [ -f "$HOME/.zshrc" ] && SHELL_PROFILES+=("$HOME/.zshrc")
    [ -f "$HOME/.profile" ] && SHELL_PROFILES+=("$HOME/.profile")
    
    if [ ${#SHELL_PROFILES[@]} -eq 0 ]; then
        echo -e "${YELLOW}No shell profile files found.${NC}"
        echo "Please add the following line to your shell profile manually:"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    else
        echo "Detected shell profiles:"
        for i in "${!SHELL_PROFILES[@]}"; do
            echo "  $((i+1))) ${SHELL_PROFILES[$i]}"
        done
        echo ""
        read -p "Would you like to add $INSTALL_DIR to PATH in these profiles? [y/N]: " add_path
        
        if [ "$add_path" = "y" ] || [ "$add_path" = "Y" ]; then
            PATH_EXPORT="export PATH=\"\$HOME/.local/bin:\$PATH\""
            
            for profile in "${SHELL_PROFILES[@]}"; do
                # Check if PATH export already exists
                if grep -q "\.local/bin" "$profile" 2>/dev/null; then
                    echo -e "${YELLOW}  Skipping $profile (already contains .local/bin)${NC}"
                else
                    echo "" >> "$profile"
                    echo "# Added by Z.AI CLI wrapper installer" >> "$profile"
                    echo "$PATH_EXPORT" >> "$profile"
                    echo -e "${GREEN}  ✓ Added to $profile${NC}"
                fi
            done
            
            echo ""
            echo -e "${GREEN}PATH updated. Please restart your terminal or run:${NC}"
            echo "  source ~/.bashrc  # or your shell profile"
        else
            echo ""
            echo "To add $INSTALL_DIR to your PATH manually, add this line to your shell profile:"
            echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        fi
    fi
else
    echo -e "${GREEN}✓ $INSTALL_DIR is already in your PATH${NC}"
fi

# Ask about Claude status line installation
echo ""
echo -e "${BLUE}Claude Status Line Configuration${NC}"
echo "The status line displays model info, git branch, code changes, timing, and cost."
echo ""
read -p "Would you like to install the Claude status line configuration? [y/N]: " install_status

if [ "$install_status" = "y" ] || [ "$install_status" = "Y" ]; then
    echo -e "${BLUE}Installing Claude status line...${NC}"
    
    # Create Claude directory
    mkdir -p "$CLAUDE_DIR"
    
    # Copy status line script
    cp claude/statusLine.sh "$CLAUDE_DIR/statusLine.sh"
    chmod +x "$CLAUDE_DIR/statusLine.sh"
    
    echo -e "${GREEN}✓ Status line script installed to $CLAUDE_DIR${NC}"
    
    # Handle settings.json
    SETTINGS_FILE="$CLAUDE_DIR/settings.json"
    
    if [ -f "$SETTINGS_FILE" ]; then
        echo ""
        echo -e "${YELLOW}Existing settings.json found.${NC}"
        echo "Options:"
        echo "  1) Merge with existing settings (recommended)"
        echo "  2) Backup existing and replace"
        echo "  3) Skip settings.json update"
        read -p "Choose [1-3]: " settings_choice
        
        case "$settings_choice" in
            1)
                # Merge using jq
                if command -v jq &> /dev/null; then
                    BACKUP_FILE="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
                    cp "$SETTINGS_FILE" "$BACKUP_FILE"
                    jq -s '.[0] * .[1]' "$SETTINGS_FILE" claude/settings.json > "$SETTINGS_FILE.tmp"
                    mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
                    echo -e "${GREEN}✓ Settings merged (backup saved to $BACKUP_FILE)${NC}"
                else
                    echo -e "${RED}Error: jq is required for merging. Please merge manually.${NC}"
                fi
                ;;
            2)
                BACKUP_FILE="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
                mv "$SETTINGS_FILE" "$BACKUP_FILE"
                cp claude/settings.json "$SETTINGS_FILE"
                echo -e "${GREEN}✓ Settings replaced (backup saved to $BACKUP_FILE)${NC}"
                ;;
            3)
                echo -e "${YELLOW}Skipped settings.json update${NC}"
                echo "To enable the status line, add this to $SETTINGS_FILE:"
                cat claude/settings.json
                ;;
        esac
    else
        # No existing settings, just copy
        cp claude/settings.json "$SETTINGS_FILE"
        echo -e "${GREEN}✓ Settings file created${NC}"
    fi
else
    echo -e "${YELLOW}Skipped Claude status line installation${NC}"
fi

# Installation complete
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Installation Complete!                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or source your shell profile)"
echo "  2. Run 'z' to configure your Z.AI API key (first-time setup)"
echo "  3. Use 'z' instead of 'claude' to launch Claude Code with Z.AI"
echo ""
echo "For more information, see README.md"
echo ""

