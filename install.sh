#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LOG_FILE="/var/log/sectlys-shell-install.log"

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
NO_NETWORK=0

usage() {
    echo "Usage: $0 [-y] [-n]"
    echo "  -y   Skip confirmation prompt and install immediately"
    echo "  -n   Skip network checks and all network operations (repos, packages, flatpak)"
    echo "       Use this only to redeploy configs on an existing installation."
    exit 0
}

parse_args() {
    while getopts ":ynh" opt; do
        case "$opt" in
            y) AUTO_YES=1 ;;
            n) NO_NETWORK=1 ;;
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

    if [[ "$NO_NETWORK" -eq 1 ]]; then
        echo ""
        echo -e "  ${_YELLOW}!${_RESET} ${_BOLD}Offline mode (-n):${_RESET} skipping repos, packages, and flatpak."
        echo -e "  ${_YELLOW}!${_RESET} Only configs and services will be deployed."
        echo -e "  ${_YELLOW}!${_RESET} Do not use this for a fresh install — packages will be missing."
        echo ""
    else
        # Install curl, pv, etc. before anything that needs them
        bootstrap_installer

        # Network check uses curl (now guaranteed present)
        check_network
    fi

    confirm_install

    log_section "Detecting target user"
    detect_user

    if [[ "$NO_NETWORK" -eq 0 ]]; then
        setup_repositories
        install_all_packages
        setup_flatpak
    fi

    deploy_configs
    enable_services

    if [[ "$NO_NETWORK" -eq 0 ]]; then
        step "Final system update"
        run_quiet "Syncing and updating system" xbps-install -Syu \
            || warn "Final update had warnings, check $LOG_FILE"
    fi

    # Register ly - takes effect on next boot
    step "Register ly display manager"
    if [[ -d /etc/sv/ly ]]; then
        if [[ ! -L /var/service/ly ]]; then
            ln -sf /etc/sv/ly /var/service/ly
            success "ly registered - will start on next boot"
        else
            info "ly already registered"
        fi
    else
        warn "ly service not found in /etc/sv, skipping"
    fi

    step "Done"
    print_summary
    echo -e "  ${_GREEN}${_BOLD}Sectly's Shell is ready.${_RESET} Reboot to start your desktop."
    echo ""

    read -rp "  Reboot now? [Y/n] " _reply
    case "${_reply,,}" in
        ""|y|yes) reboot ;;
        *) echo -e "  ${_DIM}Reboot when ready:${_RESET} sudo reboot" ;;
    esac
}

main "$@"
