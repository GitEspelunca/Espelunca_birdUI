#!/bin/bash

################################################################################
# Bird UI Installation Script for Glitch Soc v4.7.0-alpha.1+
# Complete automated installation in a single command
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MASTODON_PATH=""
VERBOSE="false"
VERSION="1.0.0"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[⚠]${NC} $*"
}

log_error() {
    echo -e "${RED}[✗]${NC} $*" >&2
}

error_exit() {
    log_error "$1"
    exit 1
}

show_header() {
    clear
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║              🐦 Bird UI para Glitch Soc v4.7.0-alpha.1+                 ║
║              Complete Automated Installation Package                     ║
║                                                                           ║
║              Version: 1.0.0                                               ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
EOF
    echo ""
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --path)
                MASTODON_PATH="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE="true"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat << EOF
Bird UI Installation Script v$VERSION

Usage:
  bash install.sh --path /path/to/glitch-soc [OPTIONS]

Required:
  --path PATH              Path to Glitch Soc installation

Options:
  --verbose                Enable verbose output
  --help                   Show this help message

Examples:
  bash install.sh --path /opt/mastodon
  bash install.sh --path /opt/mastodon --verbose
EOF
}

validate_mastodon_path() {
    if [ -z "$MASTODON_PATH" ]; then
        log_warn "Mastodon path not specified."
        read -p "Enter your Glitch Soc installation path: " MASTODON_PATH
    fi

    if [ ! -d "$MASTODON_PATH" ]; then
        error_exit "Directory not found: $MASTODON_PATH"
    fi

    if [ ! -f "$MASTODON_PATH/config/themes.yml" ]; then
        error_exit "Not a valid Mastodon/Glitch installation: $MASTODON_PATH"
    fi

    if [ ! -d "$MASTODON_PATH/app/javascript/flavours" ]; then
        error_exit "Flavours directory not found: $MASTODON_PATH/app/javascript/flavours"
    fi

    log_success "Mastodon path validated: $MASTODON_PATH"
}

check_dependencies() {
    log_info "Checking dependencies..."
    
    local deps=("bash" "cp" "mkdir" "find" "sed")
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error_exit "Missing dependency: $cmd"
        fi
    done
    
    log_success "All dependencies present"
}

backup_installation() {
    log_info "Creating backup..."
    
    local backup_dir="${MASTODON_PATH}_backup_birdui_$(date +%s)"
    mkdir -p "$backup_dir"
    
    local files_to_backup=(
        "config/themes.yml"
        "config/locales/en.yml"
        "app/javascript/flavours"
        "app/javascript/skins"
        "app/javascript/styles"
    )
    
    for file in "${files_to_backup[@]}"; do
        if [ -e "${MASTODON_PATH}/$file" ]; then
            mkdir -p "$(dirname "$backup_dir/$file")"
            cp -r "${MASTODON_PATH}/$file" "$backup_dir/$file" 2>/dev/null || true
        fi
    done
    
    log_success "Backup created: $backup_dir"
    echo "$backup_dir" > "${SCRIPT_DIR}/.last_backup"
}

setup_flavour() {
    log_info "Setting up Bird UI flavour..."
    
    local src="${SCRIPT_DIR}/flavour/bird-ui"
    local dst="${MASTODON_PATH}/app/javascript/flavours/bird-ui"
    
    if [ ! -d "$src" ]; then
        error_exit "Bird UI flavour not found at: $src"
    fi
    
    mkdir -p "$dst"
    cp -r "$src"/* "$dst/" 2>/dev/null || true
    
    log_success "Bird UI flavour installed"
}

setup_skins() {
    log_info "Setting up Bird UI skins..."
    
    local src="${SCRIPT_DIR}/skins/bird-ui"
    local dst="${MASTODON_PATH}/app/javascript/skins/bird-ui"
    
    if [ ! -d "$src" ]; then
        error_exit "Bird UI skins not found at: $src"
    fi
    
    mkdir -p "$dst"
    cp -r "$src"/* "$dst/" 2>/dev/null || true
    
    log_success "Bird UI skins installed (Dark, Light, Contrast, Accessible)"
}

setup_entry_points() {
    log_info "Setting up entry points..."
    
    local src="${SCRIPT_DIR}/entry-points"
    local dst="${MASTODON_PATH}/app/javascript/styles"
    
    if [ ! -d "$src" ]; then
        log_warn "Entry points directory not found at: $src"
        return 0
    fi
    
    cp "${src}"/*.scss "$dst/" 2>/dev/null || true
    
    log_success "Entry points installed"
}

update_themes_yml() {
    log_info "Updating config/themes.yml..."
    
    local themes_file="${MASTODON_PATH}/config/themes.yml"
    
    if [ ! -f "$themes_file" ]; then
        error_exit "themes.yml not found: $themes_file"
    fi
    
    # Backup original
    cp "$themes_file" "${themes_file}.backup_birdui"
    
    # Add Bird UI themes if not already present
    if ! grep -q "bird-ui-auto" "$themes_file"; then
        echo "" >> "$themes_file"
        echo "# Bird UI Themes" >> "$themes_file"
        echo "bird-ui-auto: styles/bird-ui-auto.scss" >> "$themes_file"
        echo "bird-ui-accessible: styles/bird-ui-accessible.scss" >> "$themes_file"
        echo "bird-ui-accessible-plus: styles/bird-ui-accessible-plus.scss" >> "$themes_file"
    fi
    
    log_success "config/themes.yml updated"
}

update_locales() {
    log_info "Updating locales..."
    
    local en_locale="${MASTODON_PATH}/config/locales/en.yml"
    local pt_locale="${MASTODON_PATH}/config/locales/pt.yml"
    local es_locale="${MASTODON_PATH}/config/locales/es.yml"
    
    # English
    if [ -f "$en_locale" ] && ! grep -q "bird-ui-auto:" "$en_locale"; then
        sed -i '/^  themes:/a\    bird-ui-auto: Mastodon Bird UI\n    bird-ui-accessible: Mastodon Bird UI (Accessible)\n    bird-ui-accessible-plus: Mastodon Bird UI (Accessible Plus)' "$en_locale" 2>/dev/null || true
    fi
    
    # Portuguese
    if [ -f "$pt_locale" ] && ! grep -q "bird-ui-auto:" "$pt_locale"; then
        sed -i '/^  themes:/a\    bird-ui-auto: Mastodon Bird UI\n    bird-ui-accessible: Mastodon Bird UI (Acessível)\n    bird-ui-accessible-plus: Mastodon Bird UI (Acessível Plus)' "$pt_locale" 2>/dev/null || true
    fi
    
    log_success "Locales updated"
}

set_permissions() {
    log_info "Setting file permissions..."
    
    local bird_ui="${MASTODON_PATH}/app/javascript/flavours/bird-ui"
    local skins="${MASTODON_PATH}/app/javascript/skins/bird-ui"
    
    chmod -R a+r "$bird_ui" 2>/dev/null || true
    find "$bird_ui" -type d -exec chmod a+rx {} \; 2>/dev/null || true
    
    chmod -R a+r "$skins" 2>/dev/null || true
    find "$skins" -type d -exec chmod a+rx {} \; 2>/dev/null || true
    
    log_success "Permissions set"
}

show_next_steps() {
    cat << EOF

${GREEN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}
${GREEN}║                    ✓ INSTALLATION COMPLETED SUCCESSFULLY                  ║${NC}
${GREEN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}

${CYAN}Next steps:${NC}

1. Recompile assets:
   ${YELLOW}cd $MASTODON_PATH${NC}
   ${YELLOW}RAILS_ENV=production bundle exec rails assets:precompile${NC}

2. Restart services:
   ${YELLOW}sudo systemctl restart mastodon-web${NC}

3. Access Preferences > Appearance > Theme
   ${GREEN}You will see Bird UI theme options available!${NC}

${CYAN}Documentation:${NC}
   - Installation Guide: $SCRIPT_DIR/docs/INSTALLATION.md
   - Architecture: $SCRIPT_DIR/docs/ARCHITECTURE.md
   - Customization: $SCRIPT_DIR/docs/CUSTOMIZATION.md
   - Troubleshooting: $SCRIPT_DIR/docs/TROUBLESHOOTING.md

${CYAN}Support:${NC}
   For issues, check the documentation or open an issue on GitHub:
   https://github.com/GitEspelunca/Espelunca_birdUI/issues

EOF
}

main() {
    show_header
    
    parse_args "$@"
    
    validate_mastodon_path
    check_dependencies
    backup_installation
    
    log_info ""
    log_info "Starting installation..."
    log_info ""
    
    setup_flavour
    setup_skins
    setup_entry_points
    update_themes_yml
    update_locales
    set_permissions
    
    show_next_steps
    
    log_success "Installation complete!"
}

main "$@"
