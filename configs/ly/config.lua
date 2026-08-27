ly = {
    -- Tomorrow Night Eighties palette
    -- bg:      #2d2d2d   fg:      #cccccc
    -- yellow:  #ffcc66   red:     #f2777a
    -- green:   #99cc99   cyan:    #66cccc
    -- blue:    #6699cc   magenta: #cc99cc

    -- Colors: 0xSSRRGGBB  SS = style bits (01=bold 02=underline 04=reverse 08=italic)
    bg          = 0x002d2d2d,
    fg          = 0x00cccccc,
    border_fg   = 0x00ffcc66,  -- yellow accent
    error_fg    = 0x01f2777a,  -- bold red
    error_bg    = 0x002d2d2d,

    full_color  = true,

    -- Login box
    box_title        = "Sectly's Shell",
    hide_borders     = false,
    blank_box        = true,
    margin_box_h     = 2,
    margin_box_v     = 1,
    input_len        = 34,

    -- Center the box
    box_position_h   = 0.5,
    box_position_v   = 0.5,

    -- Clock in top-right corner
    clock            = "%H:%M  %a %d %b",
    corner_top_right = "clock numlock,capslock",
    corner_top_left  = "shutdown,restart",
    corner_bottom_left  = "version",
    corner_bottom_right = "",

    -- Input behavior
    allow_empty_password = false,
    clear_password       = true,
    asterisk             = "●",
    default_input        = "login",
    type_username        = false,

    -- No animation, keep it clean
    animation            = "none",

    -- Session handling
    save_file_dir        = "$CONFIG_DIRECTORY/ly",
    waylandsessions      = "$PREFIX_DIRECTORY/share/wayland-sessions",
    xsessions            = "$PREFIX_DIRECTORY/share/xsessions",
    xinitrc              = nil,
    shell                = false,
    vt_switch            = true,

    -- TTY
    tty                  = 2,
    numlock              = false,

    -- Keybinds
    shutdown_key         = "F1",
    restart_key          = "F2",
    brightness_up_key    = nil,
    brightness_down_key  = nil,
    show_password_key    = "F7",

    -- Logging
    ly_log               = "/var/log/ly.log",
    session_log          = ".local/state/ly-session.log",

    -- TTY palette script runs before Ly takes over the terminal
    start_cmd            = "$CONFIG_DIRECTORY/ly/startup.sh",

    lang                 = "en",
    service_name         = "ly",
}
