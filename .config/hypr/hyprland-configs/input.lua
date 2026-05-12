MainMod = "SUPER"

---@param keys string - the key combination to bind, e.g. "SUPER + Q"
---@param dispatcher HL.Dispatcher|function, opts?: HL.BindOptions
---@return HL.Keybind
function BindMainMod(keys, dispatcher)
    return hl.bind(MainMod .. " + " .. keys, dispatcher)
end

hl.config({
    input = {
        kb_layout = "us,bg",
        kb_variant =",phonetic",
        kb_options = "grp:alt_shift_toggle",
        repeat_delay = 300,
        repeat_rate = 50,
        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = false
        }
    }
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

BindMainMod("Q", hl.dsp.exec_cmd(Terminal))
BindMainMod("C", hl.dsp.window.close())
BindMainMod("E", hl.dsp.exec_cmd(FileManager))
BindMainMod("R", hl.dsp.exec_cmd(Menu))
BindMainMod("P", hl.dsp.window.pseudo())
BindMainMod("J", hl.dsp.layout("togglesplit"))
BindMainMod("F", hl.dsp.window.fullscreen({mode="maximized", action="toggle"}))
BindMainMod("SHIFT + F", hl.dsp.window.fullscreen({mode="fullscreen", action="toggle"}))

BindMainMod("left", hl.dsp.focus({direction="l"}))
BindMainMod("right", hl.dsp.focus({direction="r"}))
BindMainMod("up", hl.dsp.focus({direction="u"}))
BindMainMod("down", hl.dsp.focus({direction="d"}))

BindMainMod("ALT + left", hl.dsp.window.move({direction="l"}))
BindMainMod("ALT + right", hl.dsp.window.move({direction="r"}))
BindMainMod("ALT + up", hl.dsp.window.move({direction="u"}))
BindMainMod("ALT + down", hl.dsp.window.move({direction="d"}))

BindMainMod("1", hl.dsp.focus({workspace=1}))
BindMainMod("2", hl.dsp.focus({workspace=2}))
BindMainMod("3", hl.dsp.focus({workspace=3}))
BindMainMod("4", hl.dsp.focus({workspace=4}))
BindMainMod("5", hl.dsp.focus({workspace=5}))
BindMainMod("6", hl.dsp.focus({workspace=6}))
BindMainMod("7", hl.dsp.focus({workspace=7}))
BindMainMod("8", hl.dsp.focus({workspace=8}))
BindMainMod("9", hl.dsp.focus({workspace=9}))
BindMainMod("0", hl.dsp.focus({workspace=10}))

BindMainMod("F1", hl.dsp.focus({workspace="name:gamemode"}))

BindMainMod("SHIFT + 1", hl.dsp.window.move({workspace=1}))
BindMainMod("SHIFT + 2", hl.dsp.window.move({workspace=2}))
BindMainMod("SHIFT + 3", hl.dsp.window.move({workspace=3}))
BindMainMod("SHIFT + 4", hl.dsp.window.move({workspace=4}))
BindMainMod("SHIFT + 5", hl.dsp.window.move({workspace=5}))
BindMainMod("SHIFT + 6", hl.dsp.window.move({workspace=6}))
BindMainMod("SHIFT + 7", hl.dsp.window.move({workspace=7}))
BindMainMod("SHIFT + 8", hl.dsp.window.move({workspace=8}))
BindMainMod("SHIFT + 9", hl.dsp.window.move({workspace=9}))
BindMainMod("SHIFT + 0", hl.dsp.window.move({workspace=10}))

BindMainMod("V", hl.dsp.exec_cmd(Terminal .. " --class=com.h.clipse -e \"clipse\""))
BindMainMod("S", hl.dsp.workspace.toggle_special("special1"))
BindMainMod("SHIFT + S", hl.dsp.window.move({workspace="special1"}))

BindMainMod("mouse_down",hl.dsp.focus({ workspace = "e+1" }))
BindMainMod("mouse_up", hl.dsp.window.move({ workspace = "e-1" }))

hl.config({
    binds = {
        drag_threshold = 10 -- Fire a drag event only after dragging for more than 10px
    }
})
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })    -- ALT + LMB: Move a window by dragging more than 10px.
hl.bind("ALT + mouse:272", hl.dsp.window.resize(), { mouse = true })  -- ALT + LMB: Floats a window by clicking

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { repeating = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("pidof hyprlock || hyprlock & systemctl suspend"))

BindMainMod("PRINT", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m output"))
BindMainMod("SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))