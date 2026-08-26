#!/usr/bin/env bash

SERVICES_FILE="$(dirname "${BASH_SOURCE[0]}")/../services/enabled.txt"

enable_services() {
    log_section "runit services"

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
            info "Already enabled: $svc"
            skipped=$((skipped + 1))
        else
            ln -sf "/etc/sv/$svc" "/var/service/$svc"
            info "Enabled: $svc"
            enabled=$((enabled + 1))
        fi
    done < "$SERVICES_FILE"

    success "Services: $enabled enabled, $skipped already active or skipped"
}
