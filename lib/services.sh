#!/usr/bin/env bash

SERVICES_FILE="$(dirname "${BASH_SOURCE[0]}")/../services/enabled.txt"

enable_services() {
    log_section "runit services"

    # seatd conflicts with elogind for seat management — disable it if running
    step "Disable conflicting seat manager (seatd)"
    if [[ -L /var/service/seatd ]]; then
        sv stop seatd 2>/dev/null || true
        rm -f /var/service/seatd
        info "Stopped and unlinked seatd (elogind handles seat management)"
    else
        info "seatd not active, nothing to do"
    fi

    step "Enable system services"

    [[ -f "$SERVICES_FILE" ]] || die "Services list not found: $SERVICES_FILE"

    local enabled=0
    local skipped=0

    while IFS= read -r svc; do
        svc="${svc%%#*}"
        svc="${svc// /}"
        [[ -z "$svc" ]] && continue

        if [[ ! -d "/etc/sv/$svc" ]]; then
            warn "Service not found: /etc/sv/$svc, skipping"
            skipped=$((skipped + 1))
            continue
        fi

        if [[ -L "/var/service/$svc" ]]; then
            skipped=$((skipped + 1))
        else
            ln -sf "/etc/sv/$svc" "/var/service/$svc"
            info "Enabled: $svc"
            enabled=$((enabled + 1))
        fi
    done < "$SERVICES_FILE"

    SERVICES_ENABLED=$(( SERVICES_ENABLED + enabled ))

    if [[ $enabled -eq 0 ]]; then
        info "All services already enabled"
    else
        success "Services: $enabled enabled, $skipped already active"
    fi
}
