#!/usr/bin/env bash

_RED='\033[0;31m'
_GREEN='\033[0;32m'
_YELLOW='\033[0;33m'
_BLUE='\033[0;34m'
_CYAN='\033[0;36m'
_DIM='\033[2m'
_BOLD='\033[1m'
_RESET='\033[0m'

STEP_TOTAL=48
STEP_CURRENT=0
_INSTALL_START=0

# Counters for end summary
PKGS_INSTALLED=0
PKGS_SKIPPED=0
SERVICES_ENABLED=0

print_banner() {
    echo -e "${_CYAN}"
    echo "   ███████╗███████╗ ██████╗████████╗██╗  ██╗   ██╗███████╗"
    echo "   ██╔════╝██╔════╝██╔════╝╚══██╔══╝██║  ╚██╗ ██╔╝██╔════╝"
    echo "   ███████╗█████╗  ██║        ██║   ██║   ╚████╔╝ ███████╗"
    echo "   ╚════██║██╔══╝  ██║        ██║   ██║    ╚██╔╝  ╚════██║"
    echo "   ███████║███████╗╚██████╗   ██║   ███████╗██║   ███████║"
    echo "   ╚══════╝╚══════╝ ╚═════╝   ╚═╝   ╚══════╝╚═╝   ╚══════╝"
    echo ""
    echo "    ███████╗██╗  ██╗███████╗██╗     ██╗"
    echo "    ██╔════╝██║  ██║██╔════╝██║     ██║"
    echo "    ███████╗███████║█████╗  ██║     ██║"
    echo "    ╚════██║██╔══██║██╔══╝  ██║     ██║"
    echo "    ███████║██║  ██║███████╗███████╗███████╗"
    echo "    ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝"
    echo -e "${_RESET}"
    echo -e "   ${_DIM}Void Linux Desktop Installer${_RESET}"
    echo ""
    _INSTALL_START=$(date +%s)
}

step() {
    STEP_CURRENT=$((STEP_CURRENT + 1))
    local num
    num=$(printf "%02d" "$STEP_CURRENT")
    echo -e "\n  ${_DIM}[${num}/${STEP_TOTAL}]${_RESET} ${_BOLD}$*${_RESET}"
}

info() {
    echo -e "    ${_BLUE}>${_RESET} ${_DIM}$*${_RESET}"
}

success() {
    echo -e "    ${_GREEN}+${_RESET} $*"
}

warn() {
    echo -e "    ${_YELLOW}!${_RESET} $*" >&2
}

error() {
    echo -e "    ${_RED}x${_RESET} $*" >&2
}

die() {
    error "$*"
    exit 1
}

log_section() {
    echo ""
    echo -e "  ${_BOLD}${_CYAN}--  $*  --${_RESET}"
}

# run_quiet <label> <cmd> [args...]
# Runs cmd silently (stdout+stderr -> log), shows spinner, prints elapsed on done.
run_quiet() {
    local label="$1"
    shift
    local frames=('/' '-' '\' '|')
    local i=0
    local start
    start=$(date +%s)

    tput civis 2>/dev/null || true
    "$@" >>"$LOG_FILE" 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        local elapsed=$(( $(date +%s) - start ))
        printf "\r    ${_CYAN}[%s]${_RESET}  %s  ${_DIM}%ds${_RESET}  " \
            "${frames[$i]}" "$label" "$elapsed"
        i=$(( (i + 1) % 4 ))
        sleep 0.15
    done

    wait "$pid"
    local exit_code=$?
    local elapsed=$(( $(date +%s) - start ))
    tput cnorm 2>/dev/null || true

    if [[ $exit_code -eq 0 ]]; then
        printf "\r    ${_GREEN}+${_RESET}  %-55s ${_DIM}%ds${_RESET}\n" "$label" "$elapsed"
    else
        printf "\r    ${_RED}x${_RESET}  %-55s ${_DIM}%ds${_RESET}\n" "$label" "$elapsed"
        return $exit_code
    fi
}

print_summary() {
    local total_elapsed=$(( $(date +%s) - _INSTALL_START ))
    local mins=$(( total_elapsed / 60 ))
    local secs=$(( total_elapsed % 60 ))

    echo ""
    echo -e "  ${_BOLD}${_CYAN}--  Summary  --${_RESET}"
    echo -e "    ${_GREEN}+${_RESET} Packages installed : ${_BOLD}${PKGS_INSTALLED}${_RESET}"
    echo -e "    ${_BLUE}>${_RESET} Packages skipped   : ${_DIM}${PKGS_SKIPPED} already present${_RESET}"
    echo -e "    ${_GREEN}+${_RESET} Services enabled   : ${_BOLD}${SERVICES_ENABLED}${_RESET}"
    echo -e "    ${_DIM}>${_RESET} Total time         : ${_DIM}${mins}m ${secs}s${_RESET}"
    echo ""
}

# --- Stamp file helpers ---
_STAMP_DIR="/var/lib/sectlys-shell"

_stamp_done() {
    mkdir -p "$_STAMP_DIR"
    touch "$_STAMP_DIR/$1.done"
}

_stamp_check() {
    [[ -f "$_STAMP_DIR/$1.done" ]]
}

_stamp_reset() {
    rm -f "$_STAMP_DIR/$1.done"
}
