#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/sectlys-shell-install.log"

source "$SCRIPT_DIR/lib/logging.sh"
source "$SCRIPT_DIR/lib/bootstrap.sh"
source "$SCRIPT_DIR/lib/checks.sh"
source "$SCRIPT_DIR/lib/repositories.sh"
source "$SCRIPT_DIR/lib/packages.sh"
source "$SCRIPT_DIR/lib/flatpak.sh"
source "$SCRIPT_DIR/lib/services.sh"
source "$SCRIPT_DIR/lib/users.sh"
source "$SCRIPT_DIR/lib/configs.sh"

AUTO_YES=0

usage() {
    echo "Usage: $0 [-y]"
    echo "  -y   Skip confirmation prompt and install immediately"
    exit 0
}

parse_args() {
    while getopts ":yh" opt; do
        case "$opt" in
            y) AUTO_YES=1 ;;
            h) usage ;;
            *) die "Unknown option: -$OPTARG  (use -h for help)" ;;
        esac
    done
}

confirm_install() {
    if [[ "$AUTO_YES" -eq 1 ]]; then
        return 0
    fi

    echo -e "  ${_BOLD}What this will do:${_RESET}"
    echo -e "  ${_DIM}  - Enable nonfree/multilib/voiders.dev repositories${_RESET}"
    echo -e "  ${_DIM}  - Install desktop, application, gaming, and multimedia packages${_RESET}"
    echo -e "  ${_DIM}  - Deploy configs and dotfiles to the target user's home${_RESET}"
    echo -e "  ${_DIM}  - Enable system services (ly, NetworkManager, bluetooth, etc.)${_RESET}"
    echo ""
    echo -e "  ${_YELLOW}!${_RESET} These changes cannot be undone automatically."
    echo -e "  ${_YELLOW}!${_RESET} Make a backup or VM snapshot before proceeding."
    echo ""
    read -rp "  Proceed with installation? [y/N] " _reply
    case "${_reply,,}" in
        y|yes) ;;
        *) echo "  Aborted."; exit 0 ;;
    esac
    echo ""
}

main() {
    parse_args "$@"

    exec > >(tee -a "$LOG_FILE") 2>&1

    print_banner
    echo -e "  Log: ${_DIM}$LOG_FILE${_RESET}"
    echo ""

    # OS/arch/libc checks require no external tools
    log_section "Pre-flight checks"
    check_root
    check_os
    check_arch
    check_libc

    # Install curl, pv, etc. before anything that needs them
    bootstrap_installer

    # Network check uses curl (now guaranteed present)
    check_network

    confirm_install

    detect_user
    setup_repositories
    install_all_packages
    setup_flatpak
    deploy_configs
    enable_services

    step "Configure graphical login (ly)"
    success "Graphical login configured"

    step "Final system update"
    xbps-install -Syu || warn "Final update had warnings, check log"
    success "System up to date"

    step "Installation complete"

    echo ""
    echo -e "  ${_GREEN}${_BOLD}Installation complete.${_RESET} Your system is ready."
    echo ""

    read -rp "  Reboot now? [Y/n] " _reply
    case "${_reply,,}" in
        ""|y|yes) reboot ;;
        *) echo "  Reboot when ready: sudo reboot" ;;
    esac
}

main "$@"
