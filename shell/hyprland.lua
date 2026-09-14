-- Veldora / Origin-inspired desktop. Requires Hyprland >= 0.56.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
hl.env("XCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.config({
    general = {
        gaps_in = 7, gaps_out = 20, border_size = 1,
        col = { active_border = "rgba(c8bfd4bb)", inactive_border = "rgba(ffffff20)" },
        layout = "dwindle", resize_on_border = true,
    },
    decoration = {
        rounding = 12, rounding_power = 3,
        shadow = { enabled = true, range = 24, render_power = 3, color = "rgba(07151b55)" },
        blur = { enabled = true, size = 8, passes = 3, vibrancy = 0.16 },
    },
    animations = { enabled = true },
    input = { kb_layout = "us", follow_mouse = 1, touchpad = { natural_scroll = true } },
    dwindle = { preserve_split = true },
    misc = { disable_hyprland_logo = true, force_default_wallpaper = 0 },
})
hl.curve("veldora", { type = "bezier", points = { {0.22, 1}, {0.36, 1} } })
for _, leaf in ipairs({"windows", "layers", "workspaces", "fade"}) do
    hl.animation({ leaf = leaf, enabled = true, speed = 4, bezier = "veldora" })
end
hl.layer_rule({ name = "veldora-glass", match = { namespace = "veldora-.*" }, blur = true, ignore_alpha = 0.1 })
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("veldora-shell")
    hl.exec_cmd("wl-paste --watch cliphist store")
end)
hl.bind("SUPER + Return", hl.dsp.exec_cmd("foot"))
hl.bind("SUPER + Space", hl.dsp.exec_cmd("qs ipc -c ii call search toggle"))
hl.bind("SUPER + A", hl.dsp.exec_cmd("fuzzel"))
hl.bind("SUPER + comma", hl.dsp.exec_cmd("qs -p ~/.config/quickshell/ii/settings.qml"))
hl.bind("SUPER + Escape", hl.dsp.exec_cmd("qs ipc -c ii call session toggle"))
hl.bind("SUPER + S", hl.dsp.exec_cmd("veldora-workbench"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + I", hl.dsp.exec_cmd("veldora-shell --toggle"))
hl.bind("SUPER + SHIFT + M", hl.dsp.exit())
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
for i = 1, 10 do
    hl.bind("SUPER + " .. (i % 10), hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. (i % 10), hl.dsp.window.move({ workspace = i }))
end
for _, direction in ipairs({"left", "right", "up", "down"}) do
    hl.bind("SUPER + " .. direction, hl.dsp.focus({ direction = direction }))
end
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
for key, action in pairs({
    XF86AudioRaiseVolume = "volume-up", XF86AudioLowerVolume = "volume-down",
    XF86AudioMute = "mute", XF86MonBrightnessUp = "brightness-up",
    XF86MonBrightnessDown = "brightness-down",
}) do
    hl.bind(key, hl.dsp.exec_cmd("veldora-shell --control " .. action), { repeating = true })
end
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
