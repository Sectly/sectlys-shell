# Sectly's Shell

An opinionated, reproducible Niri + Quickshell desktop installer for Void Linux (x86_64 glibc).

> **Workflow:** Install Void Linux -> run installer -> reboot -> ly login -> Niri + Quickshell

## Requirements

- Void Linux x86_64 **glibc** (not musl) fully installed to disk - [download](https://voidlinux.org/download/)
  - Boot the live ISO, run `void-installer`, and complete the full install before proceeding
  - Choose **glibc** when prompted for the C library - musl is not supported
  - Create a regular (non-root) user account during setup
- Network access

## Quick start

```bash
# 1. Install git if not already present
xbps-install -Sy git

# 2. Clone
git clone https://github.com/Sectly/sectlys-shell
cd sectlys-shell

# 3. Run the installer as root
sudo bash install.sh
# or without sudo on a fresh install:
su -c 'bash install.sh'

# 4. Reboot when prompted
```

Pass `-y` to skip the confirmation prompt:

```bash
sudo bash install.sh -y
```

The full install log is written to `/var/log/sectlys-shell-install.log`.

## First boot

After rebooting:

1. A boot splash appears briefly on the login TTY
2. **ly** display manager shows the login screen (TTY2)
3. Log in - **Niri** starts with **Quickshell** as the desktop shell
4. A welcome window explains the keybinds and scripts on first launch

## Networking on a fresh Void install

If networking is not working before you run the installer:

```bash
# Wired
ln -s /etc/sv/dhcpcd /var/service/

# Wi-Fi - connect with wpa_supplicant first, then dhcpcd
```

The installer's network check (`check_network`) will tell you if it can't reach the Void repos.

## Update

```bash
update          # confirms before running
update -y       # skip confirmation
```

Or re-run `install.sh` - it is idempotent and picks up any new packages added to the manifests.

## Reset configs

Restores default configs and backs up existing ones first:

```bash
reset-config
```

## Wallpapers

Browse and download from the minimalistic wallpaper collection:

```bash
wallpaper search          # fuzzy search + multi-select with fzf
wallpaper set <filename>  # set a downloaded wallpaper
wallpaper list            # list downloaded wallpapers
wallpaper current         # show active wallpaper
```

## Themes

Switch between Tomorrow color variants (applies to Quickshell + Alacritty):

```bash
set-theme --list
set-theme tomorrow-night-blue
```

Or use the settings panel: **Super + Shift + S**

Available themes: `tomorrow-night-eighties` (default), `tomorrow-night`, `tomorrow-night-blue`, `tomorrow-night-bright`, `tomorrow`

## Keybinds

| Keys | Action |
|---|---|
| Super + Space | Launcher |
| Super + Return / Ctrl + Alt + T | Terminal |
| Super + E | Files |
| Super + B | Browser |
| Super + Q | Close window |
| Super + F | Maximize column |
| Super + Shift + F | Fullscreen |
| Super + H / L | Focus column left / right |
| Super + J / K | Focus window down / up |
| Super + 1-9 | Switch workspace |
| Super + Shift + 1-9 | Move window to workspace |
| Super + Tab | Next workspace |
| Super + Shift + L | Lock screen |
| Super + Shift + / | Keybinds overlay |
| Super + Shift + S | Settings panel |
| Super + Shift + P | Monitors off |
| Super + Shift + E | Quit Niri |
| Print | Screenshot region |
| Shift + Print | Screenshot screen |
| Ctrl + Print | Screenshot window |

## Stack

| Purpose | Package |
|---|---|
| Compositor | Niri |
| Desktop shell | Quickshell |
| Display manager | ly |
| Browser | Helium |
| Terminal | Alacritty |
| File manager | Nautilus |
| Text editor | Mousepad |
| Code editor | Zed |
| JS/TS runtime | Bun |
| Office suite | LibreOffice |
| Media player | mpv |
| Gaming | Steam + Proton |
| Flatpak GUI | Bazaar |
| XBPS GUI | OctoXBPS |
| Audio | PipeWire + WirePlumber |
| Networking | NetworkManager |
| Bluetooth | BlueZ + Blueman |
| Prompt | Starship |
| Shell enhancements | fzf, zoxide, bat, eza, ripgrep, fd |

## Repository structure

```
install.sh          Main installer (run this)
lib/                Installer library modules
packages/           Package manifests by category
configs/            Configs deployed to ~/.config/
dotfiles/           Home dotfiles (.bashrc, .bash_profile)
services/           runit services to enable
scripts/            Post-install tools (update, reset-config, wallpaper, set-theme)
themes/             Tomorrow color variants for Quickshell + Alacritty
wallpapers/         Default wallpaper
```

## Theme

Tomorrow Night Eighties palette. Primary accent: `#ffcc66` (yellow).  
The TTY, ly login screen, terminal, and desktop shell all use the same palette.
