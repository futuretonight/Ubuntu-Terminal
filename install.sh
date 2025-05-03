#!/usr/bin/env bash
# ZSH Configuration Installer

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}Error: Do not run this script as root!${NC}"
    exit 1
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
