#!/usr/bin/env zsh
# Ultimate ZSH Configuration with Fixed Colors and Animations

# ========================
# 1. Core Configuration
# ========================
[[ $- != *i* ]] && return

# Set important paths
export ZDOTDIR=${ZDOTDIR:-$HOME}
ZSH_CUSTOM=${ZSH_CUSTOM:-$ZDOTDIR/.zsh-custom}
ZSH_PLUGINS_DIR=${ZSH_PLUGINS_DIR:-$ZSH_CUSTOM/plugins}
mkdir -p "$ZSH_PLUGINS_DIR"

# ========================
# 2. Color Definitions
# ========================
autoload -U colors && colors
local RED=$fg[red] GREEN=$fg[green] YELLOW=$fg[yellow] 
local BLUE=$fg[blue] MAGENTA=$fg[magenta] CYAN=$fg[cyan]
local RESET=$reset_color BOLD=$bold_color

# ========================
# 3. Animation Utilities
# ========================
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ -d /proc/$pid ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# ========================
# 4. Dependency Management
# ========================
setup_dependencies() {
    echo "${BOLD}${BLUE}[⚙️] Checking system requirements...${RESET}"
    
    # Required packages (using eza instead of exa)
    local -A packages=(
        [git]="git"
        [lolcat]="lolcat"
        [bat]="bat"
        [eza]="eza"
        [neofetch]="neofetch"
    )
    
    # Required plugins
    local -A plugins=(
        [zsh-autosuggestions]="zsh-users/zsh-autosuggestions"
        [zsh-syntax-highlighting]="zsh-users/zsh-syntax-highlighting"
    )
    
    # Check packages
    local missing_pkgs=()
    for pkg in ${(k)packages}; do
        if ! command -v ${packages[$pkg]} >/dev/null; then
            missing_pkgs+=($pkg)
        fi
    done
    
    # Check plugins
    local missing_plugins=()
    for plugin in ${(k)plugins}; do
        if [[ ! -d "$ZSH_PLUGINS_DIR/$plugin" ]]; then
            missing_plugins+=($plugin)
        fi
    done
    
    # Install missing components
    if (( ${#missing_pkgs} > 0 || ${#missing_plugins} > 0 )); then
        echo "${BOLD}${YELLOW}[⚠️] Missing components detected:${RESET}"
        (( ${#missing_pkgs} > 0 )) && echo "  ${CYAN}📦 Packages: ${(j:, :)missing_pkgs}${RESET}"
        (( ${#missing_plugins} > 0 )) && echo "  ${MAGENTA}🧩 Plugins: ${(j:, :)missing_plugins}${RESET}"
        
        read -q "REPLY?${BOLD}${GREEN}[🚀] Proceed with installation? [Y/n] ${RESET}"
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || return 1
        
        # Install packages
        if (( ${#missing_pkgs} > 0 )); then
            echo -n "${BLUE}Installing packages ${RESET}"
            if command -v apt >/dev/null; then
                sudo apt update && sudo apt install -y ${missing_pkgs} & spinner
            elif command -v pacman >/dev/null; then
                sudo pacman -Sy --noconfirm ${missing_pkgs} & spinner
            fi
            echo "${BOLD}${GREEN}✓${RESET}"
        fi
        
        # Install plugins
        if (( ${#missing_plugins} > 0 )) && command -v git >/dev/null; then
            echo -n "${BLUE}Installing plugins ${RESET}"
            for plugin in ${missing_plugins}; do
                git clone --depth 1 "https://github.com/${plugins[$plugin]}.git" \
                    "$ZSH_PLUGINS_DIR/$plugin" &>/dev/null & spinner
            done
            echo "${BOLD}${GREEN}✓${RESET}"
        fi
    else
        echo "${BOLD}${GREEN}[✅] All components ready${RESET}"
    fi
    
    touch "$ZDOTDIR/.zsh_initialized"
}

[[ ! -f "$ZDOTDIR/.zsh_initialized" ]] && setup_dependencies

# ========================
# 5. Custom ASCII Banner
# ========================
display_banner() {
    echo "${CYAN}"
    echo "
███████╗██╗███╗   ███╗██████╗ ██╗     ███████╗
██╔════╝██║████╗ ████║██╔══██╗██║     ██╔════╝
███████╗██║██╔████╔██║██████╔╝██║     █████╗  
╚════██║██║██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝  
███████║██║██║ ╚═╝ ██║██║     ███████╗███████╗
╚══════╝╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝
    " | (command -v lolcat >/dev/null && lolcat || cat)
    echo "${RESET}"
    
    # System info with proper colors
    echo "${BOLD}${MAGENTA}[🌌] System Status:${RESET}"
    echo "${GREEN}  🚀 $(uname -srmo)${RESET}"
    echo "${YELLOW}  ⏱️ $(uptime -p)${RESET}"
    if command -v df >/dev/null; then
        echo "${BLUE}  💾 $(df -h / | awk 'NR==2 {print $4}') free${RESET}"
    fi
    if command -v free >/dev/null; then
        echo "${CYAN}  🧠 $(free -h | awk '/Mem:/ {print $3"/"$2}') RAM${RESET}"
    fi
    echo "\n${BOLD}${GREEN}[🚀] Shell ready for launch!${RESET}\n"
}

# ========================
# 6. Shell Configuration
# ========================
# History settings
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt share_history
setopt hist_ignore_all_dups

# Shell behavior
setopt autocd
setopt extendedglob
setopt nomatch
setopt notify
unsetopt beep

# ========================
# 7. Aliases and Functions
# ========================
# Modern replacements (using eza)
if command -v eza >/dev/null; then
    alias ls='eza --group-directories-first --icons'
    alias ll='eza -lgh --git'
    alias la='eza -lagh --git'
    alias lt='eza --tree --level=2'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -lh'
    alias la='ls -lAh'
fi

# Better defaults
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# ========================
# 8. Plugin System
# ========================
# Syntax highlighting
if [[ -f "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Autosuggestions
if [[ -f "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
fi

# ========================
# 9. Prompt Configuration
# ========================
if command -v starship >/dev/null; then
    eval "$(starship init zsh)"
else
    autoload -Uz vcs_info
    precmd() { vcs_info }
    zstyle ':vcs_info:*' formats '(%b)'
    setopt prompt_subst
    PROMPT='%F{blue}%n@%m%f:%F{yellow}%~%f ${vcs_info_msg_0_}%# '
fi

# ========================
# 10. Completion System
# ========================
autoload -Uz compinit
compinit -d "$ZDOTDIR/.zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ========================
# 11. Final Initialization
# ========================
display_banner
unset -f setup_dependencies display_banner spinner
