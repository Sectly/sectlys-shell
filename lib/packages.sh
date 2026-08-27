#!/usr/bin/env bash

PACKAGES_DIR="$(dirname "${BASH_SOURCE[0]}")/../packages"

install_manifest() {
    local manifest="$1"
    local label="$2"

    [[ -f "$manifest" ]] || die "Package manifest not found: $manifest"

    local all_pkgs=()
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line// /}"
        [[ -n "$line" ]] && all_pkgs+=("$line")
    done < "$manifest"

    if [[ ${#all_pkgs[@]} -eq 0 ]]; then
        warn "No packages found in $manifest"
        return 0
    fi

    # Filter out already-installed packages
    local pkgs=()
    for pkg in "${all_pkgs[@]}"; do
        xbps-query -l "$pkg" &>/dev/null || pkgs+=("$pkg")
    done

    local already=$(( ${#all_pkgs[@]} - ${#pkgs[@]} ))
    PKGS_SKIPPED=$(( PKGS_SKIPPED + already ))

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        info "$label: all ${#all_pkgs[@]} already installed"
        return 0
    fi

    [[ $already -gt 0 ]] && info "$label: $already already installed, installing ${#pkgs[@]} new"

    run_quiet "Installing $label (${#pkgs[@]} packages)" \
        xbps-install -y "${pkgs[@]}" \
        || die "Failed installing packages from $label"

    PKGS_INSTALLED=$(( PKGS_INSTALLED + ${#pkgs[@]} ))
}

install_morewaita() {
    if [ -d /usr/share/icons/MoreWaita ]; then
        info "MoreWaita icon theme already installed"
        return 0
    fi

    if xbps-query -Rs MoreWaita 2>/dev/null | grep -q "^[-\*] MoreWaita"; then
        xbps-install -y MoreWaita && success "MoreWaita installed via XBPS" && return 0
    fi

    run_quiet "Downloading MoreWaita icon theme" bash -c '
        tmpdir="$(mktemp -d)"
        curl -fsSL "https://github.com/somepaulo/MoreWaita/archive/refs/heads/main.tar.gz" \
            -o "$tmpdir/morewaita.tar.gz" || exit 1
        tar -xzf "$tmpdir/morewaita.tar.gz" -C "$tmpdir" || exit 1
        install -d /usr/share/icons/MoreWaita
        cp -r "$tmpdir/MoreWaita-main/." /usr/share/icons/MoreWaita/
        rm -rf "$tmpdir"
        command -v gtk-update-icon-cache &>/dev/null && \
            gtk-update-icon-cache -f -t /usr/share/icons/MoreWaita/ 2>/dev/null || true
    ' || die "Failed to install MoreWaita"
    success "MoreWaita icon theme installed"
}

install_bun() {
    if command -v bun &>/dev/null; then
        info "Bun already installed ($(bun --version))"
        return 0
    fi

    if xbps-query -Rs bun 2>/dev/null | grep -q "^[-\*] bun-"; then
        xbps-install -y bun && success "Bun installed via XBPS" && return 0
    fi

    run_quiet "Downloading and installing Bun" \
        bash -c 'curl -fsSL https://bun.sh/install | bash' \
        || die "Bun installation failed"
    PKGS_INSTALLED=$(( PKGS_INSTALLED + 1 ))
}

install_all_packages() {
    log_section "Package installation"

    if _stamp_check "packages"; then
        info "Packages already installed (stamp found), checking for new packages only"
    fi

    step "Install base system packages"
    install_manifest "$PACKAGES_DIR/base.txt" "base"

    step "Install CLI utilities"
    install_manifest "$PACKAGES_DIR/cli.txt" "cli"

    step "Install Wayland / desktop stack"
    install_manifest "$PACKAGES_DIR/desktop.txt" "desktop"

    step "Install desktop applications"
    install_manifest "$PACKAGES_DIR/applications.txt" "applications"

    step "Install development tools"
    install_manifest "$PACKAGES_DIR/development.txt" "development"

    step "Install gaming stack"
    install_manifest "$PACKAGES_DIR/gaming.txt" "gaming"

    step "Install multimedia codecs"
    install_manifest "$PACKAGES_DIR/multimedia.txt" "multimedia"

    step "Install fonts"
    install_manifest "$PACKAGES_DIR/fonts.txt" "fonts"

    step "Install hardware support"
    install_manifest "$PACKAGES_DIR/hardware.txt" "hardware"

    step "Install Bun (JS/TS runtime)"
    install_bun

    step "Install MoreWaita icon theme"
    install_morewaita

    _stamp_done "packages"
}
