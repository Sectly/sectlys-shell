#!/usr/bin/env bash

PACKAGES_DIR="$(dirname "${BASH_SOURCE[0]}")/../packages"

install_manifest() {
    local manifest="$1"
    local label="$2"

    [[ -f "$manifest" ]] || die "Package manifest not found: $manifest"

    local pkgs=()
    while IFS= read -r line; do
        line="${line%%#*}"
        line="${line// /}"
        [[ -n "$line" ]] && pkgs+=("$line")
    done < "$manifest"

    if [[ ${#pkgs[@]} -eq 0 ]]; then
        warn "No packages found in $manifest"
        return 0
    fi

    info "Installing ${#pkgs[@]} packages from $label"

    printf '%s\n' "${pkgs[@]}" \
        | pv -l -s "${#pkgs[@]}" -p -t -e -N "$label" \
        | xargs xbps-install -y \
        || die "Failed installing packages from $label"

    success "$label packages installed"
}

install_morewaita() {
    if [ -d /usr/share/icons/MoreWaita ]; then
        info "MoreWaita icon theme already installed"
        return 0
    fi

    if xbps-query -Rs MoreWaita 2>/dev/null | grep -q "^[-\*] MoreWaita"; then
        xbps-install -y MoreWaita && success "MoreWaita installed via XBPS" && return 0
    fi

    info "Downloading MoreWaita icon theme from GitHub"
    local tmpdir
    tmpdir="$(mktemp -d)"
    local tarball="$tmpdir/morewaita.tar.gz"

    curl -fsSL "https://github.com/somepaulo/MoreWaita/archive/refs/heads/main.tar.gz" \
        | pv -N "MoreWaita" > "$tarball" \
        || die "Failed to download MoreWaita"

    tar -xzf "$tarball" -C "$tmpdir" \
        || die "Failed to extract MoreWaita"

    local srcdir="$tmpdir/MoreWaita-main"
    [ -d "$srcdir" ] || die "MoreWaita source directory not found after extraction"

    install -d /usr/share/icons/MoreWaita
    cp -r "$srcdir/." /usr/share/icons/MoreWaita/
    rm -rf "$tmpdir"

    if command -v gtk-update-icon-cache &>/dev/null; then
        gtk-update-icon-cache -f -t /usr/share/icons/MoreWaita/ 2>/dev/null || true
    fi

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

    info "Downloading Bun installer"
    curl -fsSL https://bun.sh/install | pv -N "bun installer" | bash \
        || die "Bun installation failed"
    success "Bun installed"
}

install_all_packages() {
    log_section "Package installation"

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
}
