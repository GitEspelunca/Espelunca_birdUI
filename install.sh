#!/bin/bash

################################################################################
# Bird UI Installation Script for Glitch Soc v4.7.0-alpha.1+
# 
# Usage:
#   bash install.sh --path /path/to/glitch-soc [OPTIONS]
#
# Options:
#   --path PATH              Path to Glitch Soc installation (REQUIRED)
#   --default                Set Bird UI as default theme
#   --no-backup              Skip backup creation
#   --verbose                Enable verbose output
#   --help                   Show this help message
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MASTODON_PATH=""
SET_DEFAULT="false"
CREATE_BACKUP="true"
VERBOSE="false"
LOG_FILE="${SCRIPT_DIR}/install.log"
ERROR_LOG="${SCRIPT_DIR}/error.log"

# Version
VERSION="1.0.0"

################################################################################
# Logging Functions
################################################################################

log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        INFO)
            echo -e "${BLUE}[INFO]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        SUCCESS)
            echo -e "${GREEN}[✓]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        WARN)
            echo -e "${YELLOW}[⚠]${NC} $message" | tee -a "$LOG_FILE"
            ;;
        ERROR)
            echo -e "${RED}[✗]${NC} $message" | tee -a "$ERROR_LOG" >&2
            ;;
        DEBUG)
            if [ "$VERBOSE" = "true" ]; then
                echo -e "${CYAN}[DEBUG]${NC} $message" | tee -a "$LOG_FILE"
            fi
            ;;
    esac
}

header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║   Bird UI para Glitch Soc v4.7.0-alpha.1+                  ║"
    echo "║   Complete Installation Package                            ║"
    echo "║   Version: $VERSION                                         ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

error_exit() {
    log ERROR "$1"
    cleanup_on_error
    exit 1
}

cleanup_on_error() {
    log WARN "Limpando arquivos temporários após erro..."
    # Cleanup logic here
}

################################################################################
# Validation Functions
################################################################################

validate_path() {
    if [ ! -d "$1" ]; then
        error_exit "Diretório não encontrado: $1"
    fi
    
    if [ ! -f "$1/config/themes.yml" ]; then
        error_exit "Não é uma instalação Mastodon/Glitch válida: $1"
    fi
    
    if [ ! -d "$1/app/javascript/flavours" ]; then
        error_exit "Estrutura de flavours não encontrada em: $1"
    fi
}

check_dependencies() {
    log INFO "Verificando dependências..."
    
    local missing_deps=()
    
    if ! command -v bash &> /dev/null; then
        missing_deps+=("bash")
    fi
    
    if ! command -v cp &> /dev/null; then
        missing_deps+=("cp")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        error_exit "Dependências faltando: ${missing_deps[*]}"
    fi
    
    log SUCCESS "Todas as dependências presentes"
}

################################################################################
# Backup Functions
################################################################################

backup_mastodon() {
    if [ "$CREATE_BACKUP" = "false" ]; then
        log WARN "Backup desabilitado - pulando backup"
        return 0
    fi
    
    log INFO "Criando backup de segurança..."
    
    local backup_dir="${MASTODON_PATH}_backup_birdui_$(date +%s)"
    local files_to_backup=(
        "config/themes.yml"
        "config/locales/en.yml"
        "app/javascript/flavours"
        "app/javascript/skins"
        "app/javascript/styles"
    )
    
    mkdir -p "$backup_dir"
    
    for file in "${files_to_backup[@]}"; do
        if [ -e "${MASTODON_PATH}/$file" ]; then
            mkdir -p "$(dirname "$backup_dir/$file")"
            cp -r "${MASTODON_PATH}/$file" "$backup_dir/$file"
            log DEBUG "Backed up: $file"
        fi
    done
    
    log SUCCESS "Backup criado em: $backup_dir"
    echo "$backup_dir" > "${SCRIPT_DIR}/.backup_path"
}

################################################################################
# Installation Functions
################################################################################

setup_flavour() {
    log INFO "Configurando flavour Bird UI..."
    
    local flavour_src="${SCRIPT_DIR}/flavour/bird-ui"
    local flavour_dst="${MASTODON_PATH}/app/javascript/flavours/bird-ui"
    
    if [ ! -d "$flavour_src" ]; then
        error_exit "Flavour Bird UI não encontrado em: $flavour_src"
    fi
    
    log DEBUG "Copiando arquivos do flavour..."
    mkdir -p "$flavour_dst"
    cp -r "$flavour_src"/* "$flavour_dst/"
    
    log SUCCESS "Flavour Bird UI instalado"
}

setup_skins() {
    log INFO "Configurando skins Bird UI..."
    
    local skins_src="${SCRIPT_DIR}/skins/bird-ui"
    local skins_dst="${MASTODON_PATH}/app/javascript/skins/bird-ui"
    
    if [ ! -d "$skins_src" ]; then
        error_exit "Skins Bird UI não encontrado em: $skins_src"
    fi
    
    log DEBUG "Copiando arquivos dos skins..."
    mkdir -p "$skins_dst"
    cp -r "$skins_src"/* "$skins_dst/"
    
    log SUCCESS "Skins Bird UI instalados (Dark, Light, Contrast, Accessible)"
}

setup_entry_points() {
    log INFO "Configurando entry points de tema..."
    
    local entry_points_src="${SCRIPT_DIR}/entry-points"
    local entry_points_dst="${MASTODON_PATH}/app/javascript/styles"
    
    if [ ! -d "$entry_points_src" ]; then
        error_exit "Entry points não encontrado em: $entry_points_src"
    fi
    
    log DEBUG "Copiando arquivos de entry points..."
    cp "${entry_points_src}"/*.scss "$entry_points_dst/"
    
    log SUCCESS "Entry points instalados"
}

update_themes_config() {
    log INFO "Atualizando config/themes.yml..."
    
    local themes_file="${MASTODON_PATH}/config/themes.yml"
    
    if [ ! -f "$themes_file" ]; then
        error_exit "themes.yml não encontrado: $themes_file"
    fi
    
    # Create a backup of the current themes.yml
    cp "$themes_file" "${themes_file}.backup_birdui"
    
    # Execute the update script
    bash "${SCRIPT_DIR}/scripts/update-themes-yml.sh" "$themes_file"
    
    log SUCCESS "config/themes.yml atualizado"
}

update_locales() {
    log INFO "Atualizando localizações..."
    
    bash "${SCRIPT_DIR}/scripts/update-locales.sh" "$MASTODON_PATH"
    
    log SUCCESS "Localizações atualizadas"
}

set_permissions() {
    log INFO "Configurando permissões de arquivos..."
    
    local bird_ui_path="${MASTODON_PATH}/app/javascript/flavours/bird-ui"
    local skins_path="${MASTODON_PATH}/app/javascript/skins/bird-ui"
    
    chmod -R a+r "$bird_ui_path" 2>/dev/null || true
    find "$bird_ui_path" -type d -exec chmod a+rx {} \; 2>/dev/null || true
    
    chmod -R a+r "$skins_path" 2>/dev/null || true
    find "$skins_path" -type d -exec chmod a+rx {} \; 2>/dev/null || true
    
    log SUCCESS "Permissões configuradas"
}

################################################################################
# Post-Installation Functions
################################################################################

show_next_steps() {
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                    ✓ INSTALAÇÃO CONCLUÍDA                  ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}Próximas etapas:${NC}"
    echo ""
    echo "1. Recompile os assets:"
    echo -e "   ${YELLOW}cd $MASTODON_PATH${NC}"
    echo -e "   ${YELLOW}RAILS_ENV=production bundle exec rails assets:precompile${NC}"
    echo ""
    echo "2. Reinicie os serviços:"
    echo -e "   ${YELLOW}sudo systemctl restart mastodon-web${NC}"
    echo ""
    echo "3. Acesse Preferences > Appearance > Theme"
    echo -e "   ${GREEN}Você verá as opções Bird UI disponíveis${NC}"
    echo ""
    echo -e "${CYAN}Documentação:${NC}"
    echo "   - Detalhes: $SCRIPT_DIR/docs/INSTALLATION.md"
    echo "   - Arquitetura: $SCRIPT_DIR/docs/ARCHITECTURE.md"
    echo "   - Customização: $SCRIPT_DIR/docs/CUSTOMIZATION.md"
    echo ""
    echo -e "${YELLOW}Logs de instalação: $LOG_FILE${NC}"
    echo ""
}

################################################################################
# Argument Parsing
################################################################################

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--path)
                MASTODON_PATH="$2"
                shift 2
                ;;
            -d|--default)
                SET_DEFAULT="true"
                shift
                ;;
            --no-backup)
                CREATE_BACKUP="false"
                shift
                ;;
            -v|--verbose)
                VERBOSE="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Argumento desconhecido: $1${NC}"
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
  --default                Set Bird UI as default theme
  --no-backup              Skip backup creation
  --verbose                Enable verbose output
  --help                   Show this help message

Examples:
  # Basic installation
  bash install.sh --path /opt/mastodon

  # Installation with Bird UI as default
  bash install.sh --path /opt/mastodon --default

  # Verbose installation
  bash install.sh --path /opt/mastodon --verbose
EOF
}

################################################################################
# Main Installation Flow
################################################################################

main() {
    header
    
    # Parse arguments
    parse_arguments "$@"
    
    # Validate arguments
    if [ -z "$MASTODON_PATH" ]; then
        echo -e "${YELLOW}Caminho para Glitch Soc não especificado.${NC}"
        read -p "Digite o caminho para instalação do Glitch Soc: " MASTODON_PATH
    fi
    
    if [ -z "$MASTODON_PATH" ]; then
        error_exit "Caminho não pode estar vazio"
    fi
    
    # Initialize logs
    > "$LOG_FILE"
    > "$ERROR_LOG"
    
    log INFO "Bird UI Installation Script v$VERSION"
    log INFO "Instalando em: $MASTODON_PATH"
    
    # Validation
    check_dependencies
    validate_path "$MASTODON_PATH"
    
    # Backup
    backup_mastodon
    
    # Installation
    log INFO "Iniciando instalação..."
    log INFO ""
    
    setup_flavour
    setup_skins
    setup_entry_points
    update_themes_config
    update_locales
    set_permissions
    
    # Post-installation
    show_next_steps
    
    log SUCCESS "Instalação concluída com sucesso!"
}

# Run main function
main "$@"
