#!/usr/bin/env bash
# Displayed on TTY2 before ly renders. Relies on the palette set by startup.sh.

COLS=$(tput cols  2>/dev/null || echo 80)
ROWS=$(tput lines 2>/dev/null || echo 24)

# ANSI helpers using the Tomorrow Night Eighties TTY palette
_fg()     { printf '\e[3%sm' "$1"; }  # standard fg color (0-7)
_bold()   { printf '\e[1m'; }
_reset()  { printf '\e[0m'; }

_center_text() {
    local text="$1"
    local visible_len="${2:-${#text}}"
    local pad=$(( (COLS - visible_len) / 2 ))
    printf '%*s%s' "$pad" "" "$text"
}

_center_line() {
    local content="$1"
    local visible_len="${2:-${#content}}"
    _center_text "$content" "$visible_len"
    printf '\n'
}

# ---- layout ----
BOX_W=36
BOX_PAD=$(( (COLS - BOX_W) / 2 ))
TOP_PAD=$(( (ROWS - 12) / 2 ))

YELLOW=3   # #ffcc66
WHITE=7    # #cccccc
DARK=0     # #2d2d2d (via HI_BLACK in true 24-bit; here used implicitly as default bg)

clear

# Vertical padding
for (( i=0; i<TOP_PAD; i++ )); do printf '\n'; done

# Top border
printf '%*s' "$BOX_PAD" ""
_fg $YELLOW; _bold
printf '╭'
printf '─%.0s' $(seq 1 $(( BOX_W - 2 )))
printf '╮'
_reset; printf '\n'

# Empty line inside box
printf '%*s' "$BOX_PAD" ""
_fg $YELLOW; printf '│'; _reset
printf '%*s' $(( BOX_W - 2 )) ""
_fg $YELLOW; printf '│'; _reset; printf '\n'

# Title
local_title="  Sectly's Shell  "
local_title_pad=$(( (BOX_W - 2 - ${#local_title}) / 2 ))
printf '%*s' "$BOX_PAD" ""
_fg $YELLOW; printf '│'; _reset
printf '%*s' "$local_title_pad" ""
_fg $YELLOW; _bold; printf '%s' "$local_title"; _reset
printf '%*s' $(( BOX_W - 2 - local_title_pad - ${#local_title} )) ""
_fg $YELLOW; printf '│'; _reset; printf '\n'

# Subtitle
local_sub="  Void Linux  "
local_sub_pad=$(( (BOX_W - 2 - ${#local_sub}) / 2 ))
printf '%*s' "$BOX_PAD" ""
_fg $YELLOW; printf '│'; _reset
printf '%*s' "$local_sub_pad" ""
_fg $WHITE; printf '%s' "$local_sub"; _reset
printf '%*s' $(( BOX_W - 2 - local_sub_pad - ${#local_sub} )) ""
_fg $YELLOW; printf '│'; _reset; printf '\n'

# Divider
printf '%*s' "$BOX_PAD" ""
_fg $YELLOW; printf '├'
printf '─%.0s' $(seq 1 $(( BOX_W - 2 )))
printf '┤'; _reset; printf '\n'

# Empty line
printf '%*s' "$BOX_PAD" ""
_fg $YELLOW; printf '│'; _reset
printf '%*s' $(( BOX_W - 2 )) ""
_fg $YELLOW; printf '│'; _reset; printf '\n'

# Spinner animation: 6 frames, ~1.2s total
frames=('  ◐  starting up' '  ◓  starting up' '  ◑  starting up' '  ◒  starting up' '  ◐  starting up' '  ◓  starting up')
for frame in "${frames[@]}"; do
    printf '%*s' "$BOX_PAD" ""
    _fg $YELLOW; printf '│'; _reset
    local_f_pad=$(( (BOX_W - 2 - ${#frame}) / 2 ))
    printf '%*s' "$local_f_pad" ""
    _fg $WHITE; printf '%s' "$frame"; _reset
    printf '%*s' $(( BOX_W - 2 - local_f_pad - ${#frame} )) ""
    _fg $YELLOW; printf '│'; _reset
    printf '\r'
    sleep 0.2
done
printf '\n'

# Empty line
printf '%*s' "$BOX_PAD" ""
_fg $YELLOW; printf '│'; _reset
printf '%*s' $(( BOX_W - 2 )) ""
_fg $YELLOW; printf '│'; _reset; printf '\n'

# Bottom border
printf '%*s' "$BOX_PAD" ""
_fg $YELLOW; _bold
printf '╰'
printf '─%.0s' $(seq 1 $(( BOX_W - 2 )))
printf '╯'
_reset; printf '\n'

sleep 0.3
clear
