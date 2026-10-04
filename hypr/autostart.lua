-- Runs once at login, not on reload.
-- Entries are added here as each component is built (awww, quickshell,
-- dunst, cliphist watcher).

local programs = {
    -- The daemon must be up before the wallpaper is restored. The restore
    -- script waits for it, so this order is enough.
    "awww-daemon",
    -- Re-applies the last wallpaper and regenerates the palette from it.
    os.getenv("HOME") .. "/.local/bin/a4a-wallpaper restore",
    -- The bar. It reads the palette file, so it can start before or after the
    -- restore above and it still picks up the right colours.
    "quickshell",
    -- Notifications. It reads the palette file on start, like the bar.
    "dunst",
    -- Answers BlueZ pairing requests (keyboards, mice). Without it pairing fails.
    os.getenv("HOME") .. "/.local/bin/a4a-bt-agent",
    -- GTK 4 apps follow the desktop's colour scheme; the palette is dark.
    "gsettings set org.gnome.desktop.interface color-scheme prefer-dark",
    -- Night light. Starts with no filter; the bar's NightLight sets the right one.
    "hyprsunset -i",
    -- Idle: dims, locks and suspends. Its config is in hypridle/.
    "hypridle -c " .. os.getenv("HOME") .. "/.config/hypridle/hypridle.conf",
}

hl.on("hyprland.start", function()
    for _, cmd in ipairs(programs) do
        hl.exec_cmd(cmd)
    end
end)
