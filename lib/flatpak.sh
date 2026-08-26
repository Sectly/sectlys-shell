#!/usr/bin/env bash

setup_flatpak() {
    log_section "Flatpak"

    step "Install Flatpak"
    if command -v flatpak &>/dev/null; then
        info "Flatpak already installed ($(flatpak --version))"
    else
        xbps-install -y flatpak || die "Failed to install Flatpak"
        success "Flatpak installed"
    fi

    step "Configure Flathub"
    if flatpak remote-list 2>/dev/null | grep -q "^flathub"; then
        info "Flathub already configured, skipping"
    else
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
            || die "Failed to add Flathub remote"
        success "Flathub configured"
    fi

    step "Install Bazaar (Flatpak software store)"
    if xbps-query -l bazaar &>/dev/null; then
        info "Bazaar already installed, skipping"
    elif xbps-query -Rs bazaar 2>/dev/null | grep -q "^[-\*] bazaar"; then
        xbps-install -y bazaar || warn "Bazaar XBPS install failed, skipping"
        success "Bazaar installed"
    else
        warn "Bazaar not found in repos, install manually from voiders.dev once available"
    fi
}
