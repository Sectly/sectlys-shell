#!/usr/bin/env bash

BOOTSTRAP_DEPS=(
    curl
    pv
    git
    rsync
)

bootstrap_installer() {
    log_section "Installer bootstrap"
    step "Install installer dependencies"

    local missing=()
    for dep in "${BOOTSTRAP_DEPS[@]}"; do
        command -v "$dep" &>/dev/null || missing+=("$dep")
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        success "All installer dependencies already present"
        return 0
    fi

    info "Installing missing: ${missing[*]}"
    xbps-install -Sy "${missing[@]}" || die "Failed to install installer dependencies: ${missing[*]}"
    success "Installer dependencies ready"
}
