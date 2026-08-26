#!/usr/bin/env bash

setup_flatpak() {
    log_section "Flatpak"

    step "Install Flatpak"
    xbps-install -y flatpak || die "Failed to install Flatpak"
    success "Flatpak installed"

    step "Configure Flathub"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo \
        || die "Failed to add Flathub remote"
    success "Flathub configured"

    step "Install Bazaar (Flatpak software store)"
    if xbps-query -Rs bazaar 2>/dev/null | grep -q "^[-\*] bazaar"; then
        xbps-install -y bazaar || warn "Bazaar XBPS install failed, skipping"
    else
        warn "Bazaar not found in repos, install manually from voiders.dev once available"
    fi
}
