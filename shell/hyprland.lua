-- Veldora ISO session. No references to a build-host home directory.
local veldora_config = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.config({
    general = { layout = "dwindle", resize_on_border = true },
    animations = { enabled = true },
    input = { kb_layout = "us", follow_mouse = 1, touchpad = { natural_scroll = true } },
    dwindle = { preserve_split = true },
    misc = { disable_hyprland_logo = true, force_default_wallpaper = 0 },
})
dofile(veldora_config .. "/hypr/veldora-theme.lua")
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("veldora-shell")
end)
-- A bare Super release opens the workspace overview; app search stays available.
hl.bind("Super_L", hl.dsp.exec_cmd("veldora-shell --overview"), { release = true, ignore_mods = true, description = "Veldora overview" })
hl.bind("Super_R", hl.dsp.exec_cmd("veldora-shell --overview"), { release = true, ignore_mods = true })
hl.bind("SUPER + Tab", hl.dsp.exec_cmd("veldora-shell --overview"))
hl.bind("SUPER + Space", hl.dsp.exec_cmd("veldora-shell --launcher"))
hl.bind("SUPER + A", hl.dsp.exec_cmd("veldora-shell --controls"))
hl.bind("SUPER + I", hl.dsp.exec_cmd("veldora-shell --toggle"))
hl.bind("CTRL + SUPER + R", hl.dsp.exec_cmd("veldora-shell --reload"))
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + S", hl.dsp.exec_cmd("veldora-workbench"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + M", hl.dsp.exit())
hl.bind("SUPER + L", hl.dsp.exec_cmd("veldora-shell --lock"))
for veldora_i = 1, 10 do
    hl.bind("SUPER + " .. (veldora_i % 10), hl.dsp.focus({ workspace = veldora_i }))
    hl.bind("SUPER + SHIFT + " .. (veldora_i % 10), hl.dsp.window.move({ workspace = veldora_i }))
end
for _, veldora_direction in ipairs({"left", "right", "up", "down"}) do
    hl.bind("SUPER + " .. veldora_direction, hl.dsp.focus({ direction = veldora_direction }))
end
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
for veldora_key, veldora_action in pairs({
    XF86AudioRaiseVolume = "volume-up", XF86AudioLowerVolume = "volume-down",
    XF86AudioMute = "mute", XF86MonBrightnessUp = "brightness-up",
    XF86MonBrightnessDown = "brightness-down",
}) do
    hl.bind(veldora_key, hl.dsp.exec_cmd("veldora-shell --control " .. veldora_action), { repeating = true })
end
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
