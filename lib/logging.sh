#!/usr/bin/env bash

_RED='\033[0;31m'
_GREEN='\033[0;32m'
_YELLOW='\033[0;33m'
_BLUE='\033[0;34m'
_CYAN='\033[0;36m'
_BOLD='\033[1m'
_RESET='\033[0m'

STEP_TOTAL=47
STEP_CURRENT=0

step() {
    STEP_CURRENT=$((STEP_CURRENT + 1))
    local num
    num=$(printf "%02d" "$STEP_CURRENT")
    echo -e "\n${_BOLD}${_CYAN}[${num}/${STEP_TOTAL}]${_RESET} ${_BOLD}$*${_RESET}"
}

info() {
    echo -e "  ${_BLUE}>${_RESET} $*"
}

success() {
    echo -e "  ${_GREEN}+${_RESET} $*"
}

warn() {
    echo -e "  ${_YELLOW}!${_RESET} $*" >&2
}

error() {
    echo -e "  ${_RED}x${_RESET} $*" >&2
}

die() {
    error "$*"
    exit 1
}

log_section() {
    echo -e "\n${_BOLD}=== $* ===${_RESET}"
}
