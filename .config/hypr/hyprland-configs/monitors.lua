-- ===== OUTPUTS =====
-- Ordered list (left -> right). Order matters: Hyprland may auto-shift
-- monitors if a later config overlaps an earlier one, so we configure
-- left-to-right deterministically.
--
-- Modes are pinned explicitly (not "preferred") so the hardcoded
-- positions can't be invalidated by a surprise preferred mode.

-- Exposed as globals so other config files can reference them by name.
Monitor1 = "HDMI-A-1" -- left,   4K @ scale 1.5 -> logical 2560 wide
Monitor2 = "DP-3"     -- middle, 4K @ scale 1.5 -> logical 2560 wide
Monitor3 = "eDP-1"    -- laptop panel

local LAYOUT = {
    { output = Monitor1, mode = "3840x2160@60", position = "0x0",      scale = 1.5 },
    { output = Monitor2, mode = "3840x2160@60", position = "2560x0",   scale = 1.5 },
    -- eDP-1: 2560x1600 panel. scale 1.0 is not a valid Hyprland scale for this panel
    -- (gets snapped, breaking offsets). Use 1.25 -> logical 2048x1280, or 1.6 -> 1600x1000.
    { output = Monitor3, mode = "preferred",    position = "5120x700", scale = 1 },
}

-- ===== STATE =====
local gen = 0
local last_signature = nil

-- ===== HELPERS =====
local function present_outputs()
    local set = {}
    for _, m in ipairs(hl.get_monitors() or {}) do
        if m.name then set[m.name] = true end
    end
    return set
end

local function signature(present)
    -- Stable signature of outputs we care about that are connected.
    local names = {}
    for _, cfg in ipairs(LAYOUT) do
        if present[cfg.output] then names[#names + 1] = cfg.output end
    end
    return table.concat(names, "|")
end

-- ===== APPLY =====
local function apply_layout()
    local present = present_outputs()
    local sig = signature(present)

    -- Skip redundant reconfigures (the main NVIDIA + locker crash trigger).
    if sig == last_signature then
        return
    end

    for _, cfg in ipairs(LAYOUT) do
        if present[cfg.output] then
            local ok, err = pcall(hl.monitor, {
                output   = cfg.output,
                mode     = cfg.mode,
                position = cfg.position,
                scale    = cfg.scale,
            })
            if not ok then
                hl.notification.create({
                    text    = "monitors.lua: " .. cfg.output .. " failed: " .. tostring(err),
                    timeout = 4000,
                    icon    = "warning",
                })
            end
        end
    end

    last_signature = sig
end

-- ===== DEBOUNCED SCHEDULER =====
local function schedule_apply()
    gen = gen + 1
    local my_gen = gen
    hl.timer(function()
        if my_gen ~= gen then return end -- a newer event superseded us
        apply_layout()
    end, {
        timeout = 2500, -- a bit longer to absorb NVIDIA wake storms
        type    = "oneshot",
    })
end

-- ===== EVENTS =====
hl.on("monitor.added",   schedule_apply)
hl.on("monitor.removed", schedule_apply)
-- config.reloaded fires on `hyprctl reload` / file save; without this the layout
-- never gets (re)applied unless a monitor is physically hotplugged.
hl.on("config.reloaded", function()
    last_signature = nil -- force a re-apply
    schedule_apply()
end)

-- Apply once synchronously on script load. This pins the layout for outputs
-- already present. Late outputs trigger monitor.added -> schedule_apply.
apply_layout()

-- Cold-boot quirk: even after the initial apply + any monitor.added events,
-- waybar/hyprpaper sometimes end up with no layer surface on eDP-1. Doing
-- `hyprctl reload` fixes it instantly because it forces a fresh hl.monitor()
-- call for every output, which makes Hyprland re-emit wl_output events that
-- the layer-shell clients react to. Mimic that once, a few seconds after
-- autostart has launched everything, so cold boot matches the reload path.
hl.on("hyprland.start", function()
    hl.timer(function()
        last_signature = nil -- force a real re-apply, not a skip
        apply_layout()
    end, { timeout = 3000, type = "oneshot" })
end)
