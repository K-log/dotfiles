#!/usr/bin/env bash

# Dotfiles Setup Script
# Works on macOS and Linux (Debian/Arch)

set -euo pipefail

# ============================================================================
# CONFIGURATION - Edit paths here
# ============================================================================
# Format: "source:destination"
# - source: relative to dotfiles directory
# - destination: relative to $HOME, or absolute path
# ============================================================================

declare -a DOTFILE_LINKS=(
    # Vim
    ".vimrc:~/.vimrc"
    ".ideavimrc:~/.ideavimrc"

    # Git
    ".global-gitignore:~/.global-gitignore"

    # Neovim
    "nvim:~/.config/nvim"

    # GitHub Copilot
    "github-copilot/global-copilot-instructions.md:~/.config/github-copilot/global-copilot-instructions.md"
    "github-copilot/global-git-commit-instructions.md:~/.config/github-copilot/global-git-commit-instructions.md"
    "github-copilot/mcp.json:~/.config/github-copilot/mcp.json"
)

# ============================================================================
# END CONFIGURATION
# ============================================================================

# Colors for output (respect NO_COLOR or non-TTY)
if [[ -n "${NO_COLOR:-}" || ! -t 1 ]]; then
    RED=""; GREEN=""; YELLOW=""; BLUE=""; NC="";
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
fi

# Get the dotfiles directory (where this script is located)
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global variables
OS=""
FORCE_MODE=false
DRY_RUN=false
VERBOSE=false

# Action result (per processed link)
ACTION_RESULT=""

# Counters (global so summary can access)
LINKED_COUNT=0
ALREADY_COUNT=0
SKIPPED_MISSING_COUNT=0
SKIPPED_USER_COUNT=0
ERROR_COUNT=0
BACKUP_COUNT=0

# Timestamp helper
_ts() { date +%H:%M:%S; }

# Show usage information
show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Setup dotfiles by creating symlinks to configured locations.

OPTIONS:
    -f, --force     Skip all confirmation prompts
    -d, --dry-run   Show what would be done without making changes
    -v, --verbose   Show detailed output
    -h, --help      Show this help message

EXAMPLES:
    $(basename "$0")              # Interactive mode with prompts
    $(basename "$0") -f           # Skip all prompts
    $(basename "$0") -d           # Preview changes
    $(basename "$0") -fv          # Force mode with verbose output

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--force)
                FORCE_MODE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/debian_version ]]; then
            OS="debian"
        elif [[ -f /etc/arch-release ]]; then
            OS="arch"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="mac"
    else
        OS="unknown"
    fi

    if [[ "$VERBOSE" == true ]]; then
        print_info "Detected OS: $OS"
    fi
}

# Print colored messages
print_info() { echo -e "${BLUE}[$(_ts) INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[$(_ts) OK]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[$(_ts) WARN]${NC} $1"; }
print_error() { echo -e "${RED}[$(_ts) ERR]${NC} $1"; }
print_verbose() { if [[ "$VERBOSE" == true ]]; then echo -e "${BLUE}[$(_ts) VERBOSE]${NC} $1"; fi; }

# Convert Unix path to OS-specific path
convert_path() {
    local path="$1"

    # Expand tilde to $HOME
    path="${path/#\~/$HOME}"

    # Convert .config paths for macOS github-copilot
    if [[ "$OS" == "mac" ]]; then
        local search='/.config/github-copilot'
        local replace='/Library/Application Support/github-copilot'
        # Replace first occurrence only (sufficient for our use case)
        path="${path/$search/$replace}"
    fi

    echo "$path"
}

# Create backup of existing file
backup_file() {
    local file="$1"
    # Return codes: 0 = no existing file OR backed up; 1 = user declined overwrite
    if [[ -e "$file" || -L "$file" ]]; then
        # Portable timestamp (avoid %N for macOS/BSD); add RANDOM to reduce collision risk
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)_$RANDOM"
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY-RUN] Would backup: $file -> $backup"
            BACKUP_MADE=false
            return 0
        fi
        if [[ "$FORCE_MODE" == false ]]; then
            echo ""
            print_warning "File already exists: $file"
            echo -e "${YELLOW}Backup will be created at: $backup${NC}"
            local reply=""
            read -rp "$(echo -e "${YELLOW}Overwrite? (y/n): ${NC}")" -n 1 reply || true
            echo ""
            # Lower-case reply safely (portable for Bash 3.x)
            reply=$(printf '%s' "$reply" | tr '[:upper:]' '[:lower:]')
            if [[ "$reply" != "y" ]]; then
                print_info "User declined overwrite: $file"
                BACKUP_MADE=false
                return 1
            fi
        fi
        print_verbose "Creating backup: $file -> $backup"
        mv "$file" "$backup"
        BACKUP_MADE=true
        ((BACKUP_COUNT++))
        print_success "Backup created: $backup"
    else
        BACKUP_MADE=false
    fi
    return 0
}

# Create symlink
_resolve_path() {
    # Best-effort real path resolution without GNU realpath dependency
    local p="$1"
    if [[ -e "$p" || -L "$p" ]]; then
        local dir base
        dir=$(cd "$(dirname "$p")" 2>/dev/null && pwd -P)
        base="$(basename "$p")"
        printf '%s/%s' "$dir" "$base"
    else
        printf '%s' "$p"
    fi
}

create_symlink() {
    local source="$1" target="$2"
    ACTION_RESULT=""

    if [[ ! -e "$source" ]]; then
        print_warning "Source missing, skip: $source"
        ACTION_RESULT="missing_source"
        return 0
    fi

    # If target already a symlink to source (idempotent check)
    if [[ -L "$target" ]]; then
        local existing
        existing=$(readlink "$target")
        # Resolve both paths for comparison
        local resolved_existing resolved_source
        resolved_existing=$(_resolve_path "$existing")
        resolved_source=$(_resolve_path "$source")
        if [[ "$resolved_existing" == "$resolved_source" ]]; then
            print_verbose "Already linked (no action): $target -> $source"
            ACTION_RESULT="already"
            return 0
        fi
    fi

    # Ensure parent directory exists
    local target_dir
    target_dir=$(dirname "$target")
    if [[ ! -d "$target_dir" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY-RUN] Would create directory: $target_dir"
        else
            print_verbose "Creating directory: $target_dir"
            mkdir -p "$target_dir"
        fi
    fi

    if ! backup_file "$target"; then
        ACTION_RESULT="skipped_user"
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY-RUN] Would link: $target -> $source"
        ACTION_RESULT="linked"
        return 0
    fi

    print_verbose "Creating symlink: $target -> $source"
    if ln -sfn "$source" "$target"; then
        print_success "Linked: $target -> $source"
        ACTION_RESULT="linked"
    else
        print_error "Failed to link: $target"
        ACTION_RESULT="error"
    fi
    return 0
}

# Setup function
setup_dotfiles() {
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}=== DRY RUN MODE - No changes will be made ===${NC}"
        echo ""
    fi

    print_info "Starting dotfiles setup from: $DOTFILES_DIR"
    echo ""

    # Process each configured link
    for link_config in "${DOTFILE_LINKS[@]}"; do
        IFS=':' read -r source_rel dest_path <<< "$link_config"
        local source="$DOTFILES_DIR/$source_rel"
        local dest
        dest=$(convert_path "$dest_path")

        create_symlink "$source" "$dest"
        case "$ACTION_RESULT" in
            linked) ((LINKED_COUNT++)) ;;
            already) ((ALREADY_COUNT++)) ;;
            missing_source) ((SKIPPED_MISSING_COUNT++)) ;;
            skipped_user) ((SKIPPED_USER_COUNT++)) ;;
            error) ((ERROR_COUNT++)) ;;
        esac
    done

    # Configure git to use global gitignore if git is available
    if command -v git &> /dev/null && [[ -f "$HOME/.global-gitignore" ]]; then
        echo ""
        if [[ "$DRY_RUN" == true ]]; then
            print_info "[DRY-RUN] Would configure git global excludesfile"
        else
            print_info "Configuring git to use global gitignore"
            git config --global core.excludesfile "$HOME/.global-gitignore"
            print_success "Git global excludesfile configured"
        fi
    fi

    echo ""
    print_info "Summary (raw counts shown in final report)"
    echo ""

    if [[ "$DRY_RUN" == false ]]; then
        print_success "Dotfiles setup complete!"
    else
        print_info "Dry run complete - no changes were made"
    fi
}

# Print summary
print_summary() {
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}  Setup Summary${NC}"
    echo -e "${GREEN}================================${NC}"
    echo -e "Dotfiles directory: ${BLUE}$DOTFILES_DIR${NC}"
    echo -e "OS detected: ${BLUE}$OS${NC}"

    if [[ "$FORCE_MODE" == true ]]; then
        echo -e "Mode: ${YELLOW}Force (no prompts)${NC}"
    fi
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "Mode: ${YELLOW}Dry run (no changes)${NC}"
    fi
    if [[ "$VERBOSE" == true ]]; then
        echo -e "Mode: ${YELLOW}Verbose${NC}"
    fi

    echo ""
    echo -e "Configured symlinks:"

    for link_config in "${DOTFILE_LINKS[@]}"; do
        IFS=':' read -r source_rel dest_path <<< "$link_config"
        local dest source status_symbol status_note
        dest=$(convert_path "$dest_path")
        source="$DOTFILES_DIR/$source_rel"
        if [[ ! -e "$source" ]]; then
            status_symbol="${RED}✗${NC}"; status_note="${YELLOW}source missing${NC}"
        elif [[ -L "$dest" && $(readlink "$dest" 2>/dev/null) == *"$source"* ]]; then
            status_symbol="${GREEN}✓${NC}"; status_note="already linked"
        elif [[ -L "$dest" ]]; then
            status_symbol="${YELLOW}↺${NC}"; status_note="will relink"
        elif [[ -e "$dest" ]]; then
            status_symbol="${YELLOW}!${NC}"; status_note="exists (backup planned)"
        else
            status_symbol="${BLUE}•${NC}"; status_note="pending"
        fi
        echo -e "  $status_symbol $dest ${status_note:+($status_note)}"
    done

    echo ""
    echo -e "${BLUE}Counts:${NC} linked=$LINKED_COUNT already=$ALREADY_COUNT missing_source=$SKIPPED_MISSING_COUNT user_skipped=$SKIPPED_USER_COUNT backups=$BACKUP_COUNT errors=$ERROR_COUNT"
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}Dry run: no filesystem changes were made.${NC}"
    else
        echo -e "${YELLOW}Note:${NC} User-skipped items not modified."
        echo -e "${YELLOW}Note:${NC} Backups include random suffix to reduce collisions."
    fi
    echo -e "${GREEN}Done.${NC}"
}

# Main execution
main() {
    # Parse command line arguments
    parse_args "$@"

    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}  Dotfiles Setup Script${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""

    detect_os

    if [[ "$OS" == "unknown" ]]; then
        print_error "Unknown or unsupported operating system. This script supports macOS and Linux only."
        exit 1
    fi

    setup_dotfiles
    print_summary
}

main "$@"
