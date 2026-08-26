#!/usr/bin/env bash

VOIDERS_CONF="/etc/xbps.d/voiders-dev-repo.conf"
VOIDERS_URL="https://repo.voiders.dev"

setup_repositories() {
    log_section "Repository configuration"

    step "Update XBPS"
    xbps-install -Syu xbps || die "Failed to update XBPS"
    success "XBPS updated"

    step "Enable nonfree repository"
    xbps-install -Sy void-repo-nonfree || die "Failed to enable nonfree repo"
    success "nonfree enabled"

    step "Enable multilib repository"
    xbps-install -Sy void-repo-multilib || die "Failed to enable multilib repo"
    success "multilib enabled"

    step "Enable multilib/nonfree repository"
    xbps-install -Sy void-repo-multilib-nonfree || die "Failed to enable multilib/nonfree repo"
    success "multilib/nonfree enabled"

    step "Configure voiders.dev repository"
    if [[ -f "$VOIDERS_CONF" ]]; then
        info "voiders.dev already configured, skipping"
    else
        echo "repository=$VOIDERS_URL" > "$VOIDERS_CONF" || die "Failed to write voiders.dev repo config"
        info "Trusting voiders.dev signing key (fingerprint: a8:f0:05:df:01:c4:37:92:83:f6:8b:9a:ce:ab:73:29)"
        # -y auto-accepts the RSA key trust prompt on first sync of a new repo
        xbps-install -Sy || warn "voiders.dev sync had warnings, packages from this repo may not install"
        success "voiders.dev configured"
    fi

    step "Synchronize repositories"
    xbps-install -S || die "Repository sync failed"
    success "Repositories synchronized"
}
