#!/usr/bin/env bash
# Runs before ly takes control of the TTY.
[ -t 1 ] || exit 0

# Set Linux console palette to Tomorrow Night Eighties.
# Escape sequence format: \e]P<hex-index><rrggbb>
printf '\e]P02d2d2d'   # 0  black        -> bg
printf '\e]P1f2777a'   # 1  red
printf '\e]P299cc99'   # 2  green
printf '\e]P3ffcc66'   # 3  yellow       -> accent
printf '\e]P46699cc'   # 4  blue
printf '\e]P5cc99cc'   # 5  magenta
printf '\e]P666cccc'   # 6  cyan
printf '\e]P7cccccc'   # 7  white        -> fg
printf '\e]P8393939'   # 8  bright black -> selection/current-line
printf '\e]P9f2777a'   # 9  bright red
printf '\e]PA99cc99'   # 10 bright green
printf '\e]PBffcc66'   # 11 bright yellow
printf '\e]PC6699cc'   # 12 bright blue
printf '\e]PDcc99cc'   # 13 bright magenta
printf '\e]PE66cccc'   # 14 bright cyan
printf '\e]PFd3d0c8'   # 15 bright white

# Boot splash
DIR="$(dirname "$(readlink -f "$0")")"
if [[ -x "$DIR/bootsplash.sh" ]]; then
    bash "$DIR/bootsplash.sh"
fi
