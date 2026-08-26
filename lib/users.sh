#!/usr/bin/env bash

TARGET_USER=""
TARGET_HOME=""

detect_user() {
    if [[ -n "${SUDO_USER:-}" ]] && [[ "$SUDO_USER" != "root" ]]; then
        TARGET_USER="$SUDO_USER"
    else
        TARGET_USER=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 65534 {print $1; exit}')
    fi

    [[ -n "$TARGET_USER" ]] || die "Could not detect a non-root user. Create a user account first."

    TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
    [[ -d "$TARGET_HOME" ]] || die "Home directory not found for $TARGET_USER: $TARGET_HOME"

    info "Target user: $TARGET_USER ($TARGET_HOME)"
}

setup_xdg_dirs() {
    sudo -u "$TARGET_USER" xdg-user-dirs-update
    success "XDG directories created"
}
