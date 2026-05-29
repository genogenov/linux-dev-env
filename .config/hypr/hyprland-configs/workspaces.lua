hl.window_rule({
    name = "suppress-maximize-events",
    match = {
        class=".*"
    },
    suppress_event="maximize"
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float=true,
        fullscreen=false,
        pin=false
    },
    no_focus = true
})

-- hl.window_rule({
--     name = "move-hyprland-run",
--     match = {
--         class = "hyprland-run",
--     },
--     move = "{20, monitor_h-120}",
--     float = true
-- })

hl.workspace_rule({
    workspace = "w[tv1]",
    gaps_in = 0,
    gaps_out = 0,
})

hl.workspace_rule({
    workspace = "f[1]",
    gaps_in = 0,
    gaps_out = 0,
})

hl.window_rule({
    match = {
        float = false,
        workspace = "w[tv1]"
    },
    border_size = 1
})

hl.window_rule({
    match = {
        float = false,
        workspace = "w[tv1]"
    },
    rounding = 0
})

hl.window_rule({
    match = {
        float = false,
        workspace = "f[1]"
    },
    border_size = 1
})

hl.window_rule({
    match = {
        float = false,
        workspace = "f[1]"
    },
    rounding = 0
})

hl.window_rule({
    match = {
        class = "com.h.clipse"
    },
    float = true,
    size = "{622, 652}",
    stay_focused = true,
})

hl.window_rule({
    name = "gamemode",
    match = {
        workspace = "n[s:gamemode]"
    },
    no_anim = true,
    no_shadow = true,
    no_blur = true,
    opacity = 1,
    fullscreen_state = "2 0",
    border_size = 1,
    rounding = 0,
    tag="+gamemode",
    content="game"
})

hl.window_rule({
    match = { class = "^(gcr-prompter)$" },
    stay_focused = true,
})

hl.workspace_rule({
    workspace = "1",
    monitor = Monitor1
})

hl.workspace_rule({
    workspace = "2",
    monitor = Monitor2
})

hl.workspace_rule({
    workspace = "3",
    monitor = Monitor3
})

hl.workspace_rule({
    workspace = "4",
    monitor = Monitor1
})

hl.workspace_rule({
    workspace = "5",
    monitor = Monitor2
})

hl.workspace_rule({
    workspace = "6",
    monitor = Monitor3
})

hl.workspace_rule({
    workspace = "7",
    monitor = Monitor1
})

hl.workspace_rule({
    workspace = "8",
    monitor = Monitor2
})

hl.workspace_rule({
    workspace = "9",
    monitor = Monitor1
})

hl.workspace_rule({
    workspace = "10",
    monitor = Monitor1
})

hl.workspace_rule({
    workspace = "name:gamemode",
    monitor = Monitor2,
    gaps_in = 0,
    gaps_out = 0,
    no_shadow = true,
    decorate = false
})