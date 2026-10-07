-- Full reference: docs/keybinds.md — keep the two in sync.

local mod = "SUPER"

-- One kitty process for every window: each separate process costs ~150 MB.
local terminal  = "kitty --single-instance"
local browser   = "firefox"
local launcher  = "wofi --show drun"
local clipboard = "cliphist list | wofi --dmenu | cliphist decode | wl-copy"

local function bind(keys, dispatcher, opts)
    hl.bind(mod .. " + " .. keys, dispatcher, opts)
end

-- Apps
bind("Return", hl.dsp.exec_cmd(terminal))
bind("Space",  hl.dsp.exec_cmd(launcher))
bind("V",      hl.dsp.exec_cmd(clipboard))
bind("B",      hl.dsp.exec_cmd(browser))
-- Files: the file manager (GTK, so it takes the same palette as the rest of the GTK apps).
bind("E",      hl.dsp.exec_cmd("thunar"))
-- Lock the screen (Windows' Win+L); hypridle locks on its own after idle time too.
-- a4a-lock makes sure the lock screen shows the wallpaper that's on screen now.
bind("L",      hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/a4a-lock"))

-- Windows, with ML4W's layout: M maximize, F fullscreen, T float, J split, K swap split.
bind("Q",             hl.dsp.window.close())
bind("M",             hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
bind("F",             hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
bind("T",             hl.dsp.window.float({ action = "toggle" }))
bind("SHIFT + Space", hl.dsp.window.float({ action = "toggle" }))
bind("J",             hl.dsp.layout("togglesplit"))
bind("K",             hl.dsp.layout("swapsplit"))
bind("C",             hl.dsp.window.center())
bind("P",             hl.dsp.window.pseudo())

-- Focus, resize and swap.
--   SUPER + arrow                  move focus
--   SUPER + SHIFT + arrow or hjkl  resize the window by 100 px (hold to keep going)
--   SUPER + ALT + arrow or hjkl    swap the window with its neighbour
-- Focus is arrows only: SUPER+J, K and L are already split, swap split and lock, and
-- a second bind on the same keys ran both (SUPER+L locked *and* moved focus).
local dirs = {
    -- vim key, arrow, focus direction, swap direction, resize x, resize y
    { "h", "left",  "left",  "l",  -100,    0 },
    { "j", "down",  "down",  "d",     0,  100 },
    { "k", "up",    "up",    "u",     0, -100 },
    { "l", "right", "right", "r",   100,    0 },
}
for _, d in ipairs(dirs) do
    local vim, arrow, focusDir, swapDir, dx, dy = d[1], d[2], d[3], d[4], d[5], d[6]
    bind(arrow, hl.dsp.focus({ direction = focusDir }))
    for _, key in ipairs({ vim, arrow }) do
        bind("SHIFT + " .. key, hl.dsp.window.resize({ x = dx, y = dy, relative = true }),
             { repeating = true })
        bind("ALT + " .. key,   hl.dsp.window.swap({ direction = swapDir }))
    end
end

-- Windows' Alt+Tab: the next window on this workspace, raised if it floats.
hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)
-- Pin a floating window on every workspace (a video, a calculator).
bind("Y",         hl.dsp.window.pin())
-- Close a window that doesn't answer SUPER+Q.
bind("SHIFT + Q", hl.dsp.window.kill())

-- Workspaces: SUPER+[1-0] to go, SUPER+SHIFT+[1-0] to send.
-- SUPER+ALT+[1-0] sends it without following, to tidy up and stay put.
for i = 1, 10 do
    local key = i % 10
    bind(key,              hl.dsp.focus({ workspace = i }))
    bind("SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    bind("ALT + " .. key,   hl.dsp.window.move({ workspace = i, follow = false }))
end
-- Any workspace, not only 1-10: SUPER+G asks for a number and goes there,
-- SUPER+SHIFT+G sends the window there (scripts/a4a-workspace).
bind("G",         hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/a4a-workspace go"))
bind("SHIFT + G", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/a4a-workspace move"))
-- As in ML4W, the arrows and the scroll wheel step through the workspaces that
-- exist ("e"), so empty ones are skipped. Desktops are then reached by number.
bind("CTRL + left",  hl.dsp.focus({ workspace = "e-1" }))
bind("CTRL + right", hl.dsp.focus({ workspace = "e+1" }))
-- With SHIFT, the window goes along: carry it to the next or previous desktop.
bind("CTRL + SHIFT + left",  hl.dsp.window.move({ workspace = "r-1" }))
bind("CTRL + SHIFT + right", hl.dsp.window.move({ workspace = "r+1" }))
-- Windows' Win+Ctrl+D: a fresh, empty desktop.
bind("CTRL + D",   hl.dsp.focus({ workspace = "empty" }))
bind("Tab",        hl.dsp.focus({ workspace = "previous" }))
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad: SUPER+S shows it, SUPER+SHIFT+S sends a window to it (ML4W).
bind("S",         hl.dsp.workspace.toggle_special("scratch"))
bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }))

-- Screenshots. Print drags a region (Windows' snipping key), SUPER+Print takes
-- the whole screen (ML4W's key). Both open the editor.
hl.bind("Print", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/a4a-screenshot region"))
bind("Print",    hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/a4a-screenshot full"))

-- Keyboard shortcut reference, opened in a terminal (ML4W's SUPER+CTRL+K).
bind("CTRL + K", hl.dsp.exec_cmd("kitty --single-instance --title a4a-keys -e less " .. os.getenv("HOME") .. "/Projects/A4A/docs/keybinds.md"))

-- The bar's panels, through its IPC handler. Each key opens its page in the panel it
-- belongs to, and closes it when pressed again (IslandState.toggleTo).
--   I  the island's home      A  the control centre (Windows' Win+A)
--   N  notifications (Win+N)   X  power: lock, log out, restart (Win+X)
--   W  wallpaper picker        SHIFT+W a random wallpaper
local function panel(page) return hl.dsp.exec_cmd("quickshell ipc call island go " .. page) end
bind("I", hl.dsp.exec_cmd("quickshell ipc call island toggle"))
bind("A", panel("control"))
bind("N", panel("notifications"))
bind("X", panel("power"))
bind("W", panel("wallpaper"))
bind("SHIFT + W", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/a4a-wallpaper random"))
-- Notifications: clear the popups on screen; do not disturb on or off.
bind("SHIFT + N", hl.dsp.exec_cmd("dunstctl close-all"))
bind("CTRL + N",  hl.dsp.exec_cmd("dunstctl set-paused toggle"))

-- Mouse: SUPER+LMB drag, SUPER+RMB resize
bind("mouse:272", hl.dsp.window.drag(),   { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Session (the power menu is SUPER+X)
bind("SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
-- Restart the bar, after editing it or if it ever stops answering.
bind("CTRL + R",  hl.dsp.exec_cmd("sh -c 'pkill -x quickshell; sleep 0.3; setsid quickshell >/dev/null 2>&1 &'"))
bind("SHIFT + E", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Hardware keys. Each one then tells the bar to show its indicator (see OsdWindow.qml).
local hw = { locked = true, repeating = true }
local function osd(kind) return " && quickshell ipc call osd flash " .. kind end
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+" .. osd("volume")), hw)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" .. osd("volume")),      hw)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" .. osd("volume")),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+" .. osd("brightness")),             hw)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-" .. osd("brightness")),             hw)

local media = { locked = true }
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), media)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), media)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       media)
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   media)
