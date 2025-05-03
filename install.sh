#!/usr/bin/env bash
# ZSH Configuration Installer
# Install Git hooks
echo -e "${CYAN}Installing Git hooks...${NC}"
HOOKS_DIR=".git/hooks"
mkdir -p "$HOOKS_DIR"
cp .githooks/post-checkout "$HOOKS_DIR/post-checkout"
chmod +x "$HOOKS_DIR/post-checkout"
echo -e "${GREEN}✅ Git hooks installed!${NC}"
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Warn if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}⚠️  Warning: It's not recommended to run this script as root.${NC}"
    read -p "Do you want to continue anyway? (y/N): " CONTINUE
    case "$CONTINUE" in
        [yY][eE][sS]|[yY])
            echo -e "${CYAN}Proceeding as root...${NC}"
            ;;
        *)
            echo -e "${RED}Exiting.${NC}"
            exit 1
            ;;
    esac
fi

echo -e "${CYAN}🚀 Starting ZSH Configuration Setup${NC}"

# Backup existing config
backup_file() {
    if [ -f "$1" ]; then
        echo -e "${YELLOW}Backing up $1 to $1.bak${NC}"
        cp "$1" "$1.bak"
    fi
}

# Backup existing files
backup_file ~/.zshrc
backup_file ~/.zsh_initialized

# Copy new config
echo -e "${GREEN}Installing new configuration...${NC}"
cp .zshrc ~/.zshrc

# Create necessary directories
mkdir -p ~/.zsh-custom/plugins

# Run first-time setup
echo -e "${CYAN}Running first-time setup...${NC}"
zsh -c "source ~/.zshrc"

echo -e "\n${GREEN}✅ Installation complete!${NC}"
echo -e "Restart your terminal or run ${CYAN}source ~/.zshrc${NC} to apply changes"
