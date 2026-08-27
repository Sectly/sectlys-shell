#!/usr/bin/env bash

VOIDERS_CONF="/etc/xbps.d/voiders-dev-repo.conf"
VOIDERS_URL="https://repo.voiders.dev"

_repo_installed() {
    xbps-query -l "$1" &>/dev/null
}

setup_repositories() {
    log_section "Repository configuration"

    if _stamp_check "repositories"; then
        info "Repositories already configured, syncing only"
        step "Update XBPS"
        run_quiet "Updating XBPS" xbps-install -Syu xbps || die "Failed to update XBPS"
        step "Synchronize repositories"
        run_quiet "Syncing package repos" xbps-install -S || die "Repository sync failed"
        return 0
    fi

    step "Update XBPS"
    run_quiet "Updating XBPS package manager" xbps-install -Syu xbps \
        || die "Failed to update XBPS"

    step "Enable extra repositories"
    if ! _repo_installed void-repo-nonfree; then
        run_quiet "Enabling nonfree" xbps-install -Sy void-repo-nonfree \
            || die "Failed to enable nonfree repo"
    fi
    if ! _repo_installed void-repo-multilib; then
        run_quiet "Enabling multilib" xbps-install -Sy void-repo-multilib \
            || die "Failed to enable multilib repo"
    fi
    if ! _repo_installed void-repo-multilib-nonfree; then
        run_quiet "Enabling multilib-nonfree" xbps-install -Sy void-repo-multilib-nonfree \
            || die "Failed to enable multilib-nonfree repo"
    fi
    success "Extra repositories enabled"

    step "Configure voiders.dev repository"
    if [[ -f "$VOIDERS_CONF" ]]; then
        info "voiders.dev already configured"
    else
        echo "repository=$VOIDERS_URL" > "$VOIDERS_CONF" || die "Failed to write voiders.dev repo config"
        # printf 'y\n' auto-answers the RSA key trust prompt from xbps on first sync
        run_quiet "Trusting voiders.dev and syncing" bash -c "printf 'y\n' | xbps-install -Sy" \
            || warn "voiders.dev sync had warnings, packages from this repo may not install"
        success "voiders.dev configured"
    fi

    step "Synchronize repositories"
    run_quiet "Syncing package repos" xbps-install -S \
        || die "Repository sync failed"

    _stamp_done "repositories"
}
