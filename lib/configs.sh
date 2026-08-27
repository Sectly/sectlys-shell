#!/usr/bin/env bash

REPO_ROOT="$(dirname "${BASH_SOURCE[0]}")/.."
CONFIGS_DIR="$REPO_ROOT/configs"
DOTFILES_DIR="$REPO_ROOT/dotfiles"

deploy_configs() {
    log_section "Configuration deployment"

    if _stamp_check "configs"; then
        info "Configs already deployed (stamp found), applying updates only"
    fi

    step "Deploy system environment"
    _deploy_environment

    step "Deploy Niri configuration"
    _deploy_config_dir "niri" ".config/niri"

    step "Deploy Alacritty configuration"
    _deploy_config_dir "alacritty" ".config/alacritty"

    step "Deploy mpv configuration"
    _deploy_config_dir "mpv" ".config/mpv"

    step "Deploy Quickshell configuration"
    _deploy_config_dir "quickshell" ".config/quickshell"

    step "Deploy GTK configuration"
    _deploy_gtk

    step "Deploy Starship prompt configuration"
    _deploy_file "starship/starship.toml" ".config/starship.toml"

    step "Deploy Fastfetch configuration"
    _deploy_config_dir "fastfetch" ".config/fastfetch"

    step "Deploy MIME associations"
    _deploy_mime

    step "Deploy wallpapers"
    _deploy_wallpapers

    step "Deploy dotfiles"
    _deploy_dotfiles

    step "Configure XDG portals"
    _configure_portals

    step "Configure ly display manager"
    _configure_ly

    step "Configure Niri session"
    _configure_niri_session

    step "Install shell scripts to PATH"
    _install_scripts

    step "Set file ownership"
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config" "$TARGET_HOME/.local" 2>/dev/null || true

    step "Update desktop database"
    update-desktop-database /usr/share/applications 2>/dev/null || true
    sudo -u "$TARGET_USER" xdg-user-dirs-update

    _stamp_done "configs"
}

_deploy_config_dir() {
    local src_name="$1"
    local dst_rel="$2"
    local src="$CONFIGS_DIR/$src_name"
    local dst="$TARGET_HOME/$dst_rel"

    [[ -d "$src" ]] || { warn "Config dir not found: $src, skipping"; return 0; }

    mkdir -p "$dst"
    cp -r "$src/." "$dst/"
    success "Deployed: $src_name -> $dst_rel"
}

_deploy_file() {
    local src_rel="$1"
    local dst_rel="$2"
    local src="$CONFIGS_DIR/$src_rel"
    local dst="$TARGET_HOME/$dst_rel"

    [[ -f "$src" ]] || { warn "File not found: $src, skipping"; return 0; }

    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    success "Deployed: $src_rel -> $dst_rel"
}

_deploy_gtk() {
    local gtk3_dir="$TARGET_HOME/.config/gtk-3.0"
    local gtk4_dir="$TARGET_HOME/.config/gtk-4.0"
    local src="$CONFIGS_DIR/gtk/settings.ini"

    [[ -f "$src" ]] || { warn "GTK settings not found, skipping"; return 0; }

    mkdir -p "$gtk3_dir" "$gtk4_dir"
    [[ -f "$gtk3_dir/settings.ini" ]] || cp "$src" "$gtk3_dir/settings.ini"
    [[ -f "$gtk4_dir/settings.ini" ]] || cp "$src" "$gtk4_dir/settings.ini"

    if command -v dconf &>/dev/null; then
        sudo -u "$TARGET_USER" dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'" 2>/dev/null || true
        sudo -u "$TARGET_USER" dconf write /org/gnome/desktop/interface/gtk-theme "'adwaita-dark'" 2>/dev/null || true
    fi

    success "GTK dark theme configured"
}

_deploy_mime() {
    local src="$CONFIGS_DIR/xdg/mimeapps.list"
    local dst="$TARGET_HOME/.config/mimeapps.list"

    [[ -f "$src" ]] || { warn "mimeapps.list not found, skipping"; return 0; }
    [[ -f "$dst" ]] || cp "$src" "$dst"

    cp "$src" /usr/share/applications/mimeapps.list 2>/dev/null || true
    success "MIME associations deployed"
}

_deploy_dotfiles() {
    local src dst

    for src in "$DOTFILES_DIR"/.*; do
        [[ -f "$src" ]] || continue
        local fname
        fname=$(basename "$src")
        dst="$TARGET_HOME/$fname"
        cp "$src" "$dst"
        info "Deployed: $fname"
    done
    success "Dotfiles deployed"
}

_deploy_wallpapers() {
    local src="$REPO_ROOT/wallpapers"
    local sys_dst="/usr/share/sectlys-shell/wallpapers"
    local user_dst="$TARGET_HOME/Pictures/Wallpapers"

    [[ -d "$src" ]] || { warn "wallpapers/ dir not found, skipping"; return 0; }

    mkdir -p "$sys_dst"
    cp -n "$src/"* "$sys_dst/" 2>/dev/null || true

    mkdir -p "$user_dst"
    cp -n "$src/"* "$user_dst/" 2>/dev/null || true

    success "Wallpapers deployed"
}

_deploy_environment() {
    local src="$CONFIGS_DIR/environment"
    local dst="/etc/environment"

    [[ -f "$src" ]] || { warn "environment file not found, skipping"; return 0; }

    if [[ -f "$dst" ]]; then
        while IFS='=' read -r key value; do
            [[ -z "$key" || "$key" == \#* ]] && continue
            grep -q "^${key}=" "$dst" || echo "${key}=${value}" >> "$dst"
        done < "$src"
    else
        cp "$src" "$dst"
    fi

    success "/etc/environment configured"
}

_configure_portals() {
    local portal_dir="/etc/xdg"
    local portal_conf="$portal_dir/xdg-desktop-portal-niri.conf"
    local expected="[preferred]
default=gtk
org.freedesktop.impl.portal.Screenshot=wlr
org.freedesktop.impl.portal.ScreenCast=wlr"

    if [[ -f "$portal_conf" ]] && [[ "$(cat "$portal_conf")" == "$expected" ]]; then
        info "XDG portals already configured, skipping"
        return 0
    fi

    mkdir -p "$portal_dir"
    printf '%s\n' "$expected" > "$portal_conf"
    success "XDG portals configured"
}

_configure_ly() {
    local ly_dir="/etc/ly"
    local src_dir="$CONFIGS_DIR/ly"

    [[ -d "$ly_dir" ]] || die "ly config dir /etc/ly not found. Is ly installed?"

    mkdir -p "$ly_dir/lang" || die "Failed to create $ly_dir/lang"

    # Detect config format by what the installed ly package created.
    # Modern ly (the current Void package) writes config.lua to /etc/ly after install.
    # Older versions wrote config.ini. Fall back to config.lua on ambiguity.
    if [[ -f "$ly_dir/config.ini" ]] && [[ ! -f "$ly_dir/config.lua" ]]; then
        # Legacy ly (config.ini format)
        [[ -f "$src_dir/config.ini" ]] || die "configs/ly/config.ini not found"
        cp "$src_dir/config.ini" "$ly_dir/config.ini" || die "Failed to deploy ly config.ini"
        info "Deployed ly config.ini (legacy ly)"
    else
        # Modern ly (config.lua format)
        [[ -f "$src_dir/config.lua" ]] || die "configs/ly/config.lua not found"
        cp "$src_dir/config.lua" "$ly_dir/config.lua" || die "Failed to deploy ly config.lua"
        info "Deployed ly config.lua"
    fi

    # Lang file
    [[ -f "$src_dir/lang/en.ini" ]] || die "configs/ly/lang/en.ini not found"
    cp "$src_dir/lang/en.ini" "$ly_dir/lang/en.ini" || die "Failed to deploy ly lang file"

    # TTY palette + boot splash scripts
    [[ -f "$src_dir/startup.sh" ]]    || die "configs/ly/startup.sh not found"
    [[ -f "$src_dir/bootsplash.sh" ]] || die "configs/ly/bootsplash.sh not found"
    install -m 755 "$src_dir/startup.sh"    "$ly_dir/startup.sh"    || die "Failed to install startup.sh"
    install -m 755 "$src_dir/bootsplash.sh" "$ly_dir/bootsplash.sh" || die "Failed to install bootsplash.sh"

    # Ensure ly PAM config includes elogind session module so XDG_RUNTIME_DIR gets created
    local pam_ly="/etc/pam.d/ly"
    if [[ -f "$pam_ly" ]]; then
        if ! grep -q "pam_elogind" "$pam_ly"; then
            echo "session optional pam_elogind.so" >> "$pam_ly"
            info "Added pam_elogind to $pam_ly"
        else
            info "pam_elogind already in $pam_ly"
        fi
    else
        # Create a minimal ly PAM config
        cat > "$pam_ly" <<'EOF'
auth    include login
account include login
session include login
session optional pam_elogind.so
EOF
        info "Created $pam_ly with elogind session"
    fi

    success "ly configured"
}

_install_scripts() {
    local scripts_src="$REPO_ROOT/scripts"
    local bin_dst="$TARGET_HOME/.local/bin"

    mkdir -p "$bin_dst"

    # niri-recover must be in a system PATH so ly can find it when launching the session
    install -m 755 "$scripts_src/niri-recover" /usr/local/bin/niri-recover \
        || die "Failed to install niri-recover to /usr/local/bin"

    for src in "$scripts_src"/*; do
        [[ -f "$src" ]] || continue
        local name
        name=$(basename "$src")
        [[ "$name" == "niri-recover" ]] && continue  # already installed system-wide
        local dst="$bin_dst/$name"
        cp "$src" "$dst"
        chmod +x "$dst"
        info "Installed script: $name -> $bin_dst"
    done

    success "Scripts installed to $bin_dst"
}

_configure_niri_session() {
    local src="$CONFIGS_DIR/wayland-sessions/niri.desktop"
    local dst="/usr/share/wayland-sessions/niri.desktop"

    mkdir -p /usr/share/wayland-sessions

    if [[ -f "$dst" ]]; then
        info "niri.desktop already exists, skipping"
    else
        cp "$src" "$dst"
        success "Niri session file installed"
    fi
}
