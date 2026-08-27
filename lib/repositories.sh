#!/usr/bin/env bash

VOIDERS_CONF="/etc/xbps.d/voiders-dev-repo.conf"
VOIDERS_URL="https://repo.voiders.dev"

_repo_installed() {
    xbps-query -l "$1" &>/dev/null
}

setup_repositories() {
    log_section "Repository configuration"

    if _stamp_check "repositories"; then
        info "Repositories already configured (stamp found), syncing only"
        step "Update XBPS"
        xbps-install -Syu xbps || die "Failed to update XBPS"
        step "Synchronize repositories"
        xbps-install -S || die "Repository sync failed"
        success "Repositories synchronized"
        return 0
    fi

    step "Update XBPS"
    xbps-install -Syu xbps || die "Failed to update XBPS"
    success "XBPS updated"

    step "Enable nonfree repository"
    if _repo_installed void-repo-nonfree; then
        info "nonfree already enabled, skipping"
    else
        xbps-install -Sy void-repo-nonfree || die "Failed to enable nonfree repo"
        success "nonfree enabled"
    fi

    step "Enable multilib repository"
    if _repo_installed void-repo-multilib; then
        info "multilib already enabled, skipping"
    else
        xbps-install -Sy void-repo-multilib || die "Failed to enable multilib repo"
        success "multilib enabled"
    fi

    step "Enable multilib/nonfree repository"
    if _repo_installed void-repo-multilib-nonfree; then
        info "multilib/nonfree already enabled, skipping"
    else
        xbps-install -Sy void-repo-multilib-nonfree || die "Failed to enable multilib/nonfree repo"
        success "multilib/nonfree enabled"
    fi

    step "Configure voiders.dev repository"
    if [[ -f "$VOIDERS_CONF" ]]; then
        info "voiders.dev already configured, skipping"
    else
        echo "repository=$VOIDERS_URL" > "$VOIDERS_CONF" || die "Failed to write voiders.dev repo config"
        info "Trusting voiders.dev signing key"
        # printf 'y\n' auto-answers the RSA key trust prompt from xbps on first sync
        printf 'y\n' | xbps-install -Sy || warn "voiders.dev sync had warnings, packages from this repo may not install"
        success "voiders.dev configured"
    fi

    step "Synchronize repositories"
    xbps-install -S || die "Repository sync failed"
    success "Repositories synchronized"

    _stamp_done "repositories"
}
