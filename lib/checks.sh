#!/usr/bin/env bash

check_root() {
    step "Verify root privileges"
    [[ "$EUID" -eq 0 ]] || die "Run as root. Try: sudo ./install.sh  or  su -c 'bash install.sh'"
    success "Running as root"
}

check_os() {
    step "Verify operating system"

    if [[ ! -f /etc/os-release ]]; then
        die "Not a supported OS. /etc/os-release not found."
    fi

    # shellcheck source=/dev/null
    source /etc/os-release

    if [[ "$ID" != "void" ]]; then
        local name="${NAME:-$ID}"
        die "Unsupported OS: $name. Sectly's Shell requires Void Linux."
    fi

    if [[ ! -x "$(command -v xbps-install)" ]]; then
        die "xbps-install not found. This does not appear to be a functional Void Linux install."
    fi

    success "Void Linux confirmed"
}

check_arch() {
    step "Verify architecture"
    local arch
    arch=$(uname -m)
    [[ "$arch" == "x86_64" ]] || die "Unsupported architecture: $arch. Sectly's Shell requires x86_64."
    success "Architecture: x86_64"
}

check_libc() {
    step "Verify libc"

    local libc="unknown"

    if ldd --version 2>&1 | grep -qi "gnu"; then
        libc="glibc"
    elif [[ -f /lib/libc.so.6 ]]; then
        libc="glibc"
    elif ldd --version 2>&1 | grep -qi "musl"; then
        libc="musl"
    elif [[ -f /lib/ld-musl-x86_64.so.1 ]]; then
        libc="musl"
    fi

    case "$libc" in
        glibc)
            success "libc: glibc"
            ;;
        musl)
            die "Unsupported libc: musl. Sectly's Shell requires the glibc edition of Void Linux. Download the glibc installer from voidlinux.org."
            ;;
        *)
            die "Could not detect libc. Ensure you are running Void Linux x86_64 glibc."
            ;;
    esac
}

check_network() {
    step "Verify network connectivity"
    if curl -sf --max-time 10 https://repo-default.voidlinux.org > /dev/null 2>&1; then
        success "Network reachable"
    else
        die "Cannot reach repo-default.voidlinux.org. Check network connectivity."
    fi
}
