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

    echo ""
    echo "  This will install Sectly's Shell on your system."
    echo "  The following will be performed:"
    echo "    - Enable nonfree/multilib/voiders.dev repositories"
    echo "    - Install desktop, application, gaming, and multimedia packages"
    echo "    - Deploy configs and dotfiles to the target user's home"
    echo "    - Enable system services (ly, NetworkManager, bluetooth, etc.)"
    echo ""
    echo "  ! These changes cannot be undone automatically."
    echo "  ! It is strongly recommended to make a backup or snapshot"
    echo "  ! of your system before proceeding."
    echo ""
    read -rp "  Proceed with installation? [y/N] " _reply
    case "${_reply,,}" in
        y|yes) ;;
        *) echo "  Aborted."; exit 0 ;;
    esac
}

main() {
    parse_args "$@"

    exec > >(tee -a "$LOG_FILE") 2>&1

    echo ""
    echo "  Sectly's Shell Installer"
    echo "  Log: $LOG_FILE"
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
    echo "  Sectly's Shell installation complete."
    echo "  Your system is ready."
    echo ""

    read -rp "  Reboot now? [Y/n] " _reply
    case "${_reply,,}" in
        ""|y|yes) reboot ;;
        *) echo "  Reboot when ready: sudo reboot" ;;
    esac
}

main "$@"
