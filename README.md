# Sectly's Shell

An opinionated, reproducible Niri + Quickshell desktop built on x86_64 glibc Void Linux.

## Requirements

- Void Linux x86_64 **glibc** (not musl)
- A non-root user account
- Network access during install

## Install

### 1. Install Void Linux

Download and install the **x86_64 glibc** edition from [voidlinux.org](https://voidlinux.org/download/).
The base (minimal) image is fine. During setup, create a regular user account.

### 2. Set up networking

On a fresh Void install, make sure you have internet access before continuing.
If you used the live image installer, networking is usually already configured via `dhcpcd`.
You can verify with:

```bash
ping -c 1 voidlinux.org
```

If it fails, enable dhcpcd for your interface:

```bash
ln -s /etc/sv/dhcpcd /var/service/
```

Or for Wi-Fi, use `wpa_supplicant` and `dhcpcd` together.

### 3. Get the repository

If `git` is not yet installed:

```bash
xbps-install -Sy git
```

Then clone:

```bash
git clone https://github.com/sectly/sectlys-shell
cd sectlys-shell
```

Or copy the folder from a USB drive.

### 4. Run the installer

```bash
su -c 'bash install.sh'
# or if sudo is already available:
sudo bash install.sh
```

The installer will ask for confirmation before making any changes.
It is recommended to make a backup or snapshot of your system first.

Pass `-y` to skip the confirmation prompt:

```bash
sudo bash install.sh -y
```

### 5. Reboot

The installer prompts to reboot when done. After rebooting:

- The boot splash appears briefly on the login TTY
- ly display manager presents the login screen
- Log in and Niri starts with Quickshell as the desktop shell

## Update

```bash
update
# or to skip confirmation:
update -y
```

Or re-run the installer - it is idempotent and will pick up any new packages added to the manifests.

## Reset configs

Restores default configs, backing up your existing ones first:

```bash
reset-config
```

## Wallpapers

Browse and download wallpapers from the minimalistic wallpaper collection:

```bash
wallpaper search
```

Set a downloaded wallpaper:

```bash
wallpaper set moon-mountain.png
```

## Themes

Switch between Tomorrow color variants:

```bash
set-theme --list
set-theme tomorrow-night-blue
```

## Keybinds

| Keys | Action |
|---|---|
| Super + Space | Launcher |
| Super + Return | Terminal |
| Super + E | Files |
| Super + B | Browser |
| Super + Q | Close window |
| Super + F | Maximize column |
| Super + H / L | Focus left / right |
| Super + Shift + / | Keybinds overlay |
| Super + Shift + S | Settings panel |
| Super + Shift + L | Lock screen |
| Print | Screenshot region |

## Structure

```
install.sh          Main installer
lib/                Installer modules
packages/           Package manifests (one category per file)
configs/            Configs deployed to ~/.config/
dotfiles/           Home directory dotfiles (.bashrc, .bash_profile)
services/           runit services to enable
scripts/            Post-install utilities (update, reset-config, wallpaper, set-theme)
themes/             Tomorrow color variants for Quickshell and Alacritty
wallpapers/         Default wallpaper
```

## Stack

| Purpose | Default |
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
| Office | LibreOffice |
| Media | mpv |
| Gaming | Steam + Proton |
| App store | Bazaar (Flatpak) |
| Package GUI | OctoXBPS (XBPS) |
| Audio | PipeWire + WirePlumber |
| Network | NetworkManager |
| Bluetooth | BlueZ + Blueman |

## Theme

Tomorrow Night Eighties palette. Primary accent: `#ffcc66` (yellow).
Switch variants with `set-theme` or via the settings panel (Super + Shift + S).
