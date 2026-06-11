hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        allow_tearing = false,
        resize_on_border = false,
        layout = "dwindle",
        col = {
            active_border = {colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45},
            inactive_border = "rgba(595959aa)",
        }
    },
    cursor = {
        -- no_hardware_cursors = true,
    },
    xwayland = {
        force_zero_scaling = true
    },
    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)"
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696
        }
    },
    animations = {
        enabled = false
    },
})

hl.config({
    dwindle = {
        preserve_split = true
    }
})

hl.config({
    master = {
        new_status = "master"
    }
})

hl.config({
    misc = {
        disable_hyprland_logo = true,
        force_default_wallpaper = 0
    }
})