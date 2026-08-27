#!/usr/bin/env bash

_RED='\033[0;31m'
_GREEN='\033[0;32m'
_YELLOW='\033[0;33m'
_BLUE='\033[0;34m'
_CYAN='\033[0;36m'
_DIM='\033[2m'
_BOLD='\033[1m'
_RESET='\033[0m'

STEP_TOTAL=47
STEP_CURRENT=0

print_banner() {
    echo -e "${_CYAN}"
    echo "   ███████╗███████╗ ██████╗████████╗██╗  ██╗   ██╗███████╗"
    echo "   ██╔════╝██╔════╝██╔════╝╚══██╔══╝██║  ╚██╗ ██╔╝██╔════╝"
    echo "   ███████╗█████╗  ██║        ██║   ██║   ╚████╔╝ ███████╗"
    echo "   ╚════██║██╔══╝  ██║        ██║   ██║    ╚██╔╝  ╚════██║"
    echo "   ███████║███████╗╚██████╗   ██║   ███████╗██║   ███████║"
    echo "   ╚══════╝╚══════╝ ╚═════╝   ╚═╝   ╚══════╝╚═╝   ╚══════╝"
    echo -e "${_RESET}"
    echo -e "   ${_BOLD}Sectly's Shell${_RESET}  ${_DIM}-- Void Linux Desktop Installer${_RESET}"
    echo ""
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

# Spinner: run_spinner <pid> <label>
# Shows an animated spinner next to label until <pid> exits.
run_spinner() {
    local pid="$1"
    local label="$2"
    local frames=('  [ / ]' '  [ - ]' '  [ \ ]' '  [ | ]')
    local i=0
    tput civis 2>/dev/null || true
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${_CYAN}%s${_RESET}  %s" "${frames[$i]}" "$label"
        i=$(( (i + 1) % 4 ))
        sleep 0.12
    done
    printf "\r    ${_GREEN}+${_RESET}  %-60s\n" "$label"
    tput cnorm 2>/dev/null || true
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
