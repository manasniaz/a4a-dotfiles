# PLAN.md — A4A

## Current status

_Session 1 — 2026-10-04_

- Arch Linux + bare Hyprland (0.56.2) installed and running.
- Repo scaffolded at `~/Projects/A4A`.
- **hyprland.lua done** — modular Lua config in `hypr/`, symlinked to
  `~/.config/hypr` by `install.sh`. Reloads with zero config errors.
  Original auto-generated config backed up to
  `~/.a4a-backup/20261004-062706/hypr/`.
- `install.sh` is functional: dep check, backup, symlink (only `hypr` so far).
- `docs/keybinds.md` written.

### Open items

- [x] Install missing packages: `wofi cliphist playerctl brightnessctl`
      (done in session 3, along with `quickshell` and `upower`).
- [x] Log out and back in once to confirm the config is clean from a fresh
      start. Confirmed in session 2: the wallpaper appears after a restart.
- [x] `git` installed and `~/Projects/A4A` initialized as a repo (branch
      `main`, no commits yet).
- [x] `gh` installed and logged in.

_Session 2 — 2026-10-04_

- Repo pushed to a GitHub repo (initial commit `0302e7e`).
- **awww** (wallpaper) done: `awww-daemon` then `awww img` in
  `hypr/autostart.lua`. The wallpaper is `~/Pictures/wallpaper.jpg` (a copy of
  the 5120×2880 image from Downloads, kept out of the repo). Verified live on
  `eDP-1`; the config reloads with no errors. It applies at next login, since
  autostart only runs once per session.
- **Wallpaper-driven palette** done for Hyprland: `scripts/a4a-wallpaper` sets
  the wallpaper, runs `matugen` to write `~/.cache/a4a/colors.lua`, and reloads
  Hyprland. Borders now use the wallpaper's accent (`#ffb59a` for the current
  image). Tested with a greyscale image too, which gets the fallback accent.
- Confirmed after a restart: the wallpaper appears at login.

_Session 3 — 2026-10-04_

- **Quickshell bar, first pass** in `quickshell/` (symlinked to
  `~/.config/quickshell`, started at login from `hypr/autostart.lua`). Config
  loads with no QML errors. Widgets: workspaces, media, clock, tray, CPU/RAM,
  battery. Colours come from `~/.cache/a4a/colors.json` via the `Theme`
  singleton.
- Bug found and fixed: the singleton was first named `Palette`, which silently
  resolves to QtQuick's built-in `Palette` type. Renamed to `Theme`.
- Packages installed: `quickshell`, `upower`, `wofi`, `cliphist`, `playerctl`,
  `brightnessctl`. All listed in `install.sh`.
- Battery scale verified against the live device (`percentage` is 0–1; the
  device takes about a second to become `ready`, and the widget updates after).
- Not yet verified by eye on the screen: the bar's layout, and that workspace
  clicks switch workspaces.

- Screenshots: `grim` + `slurp` + `satty` via `scripts/a4a-screenshot`
  (SUPER+SHIFT+S region, Print full screen). Tested: the editor opens with the
  capture loaded.
- Palette from the whole scene (`scripts/a4a-vibe`), not the most saturated pixel.
- Windows 11 style workspace switching (CTRL+SUPER+←/→), resize moved to ALT.
- Island: centre pill with media, clock and a control panel (SUPER+I). Power
  actions need a second click. Status pill shows CPU, RAM and battery as meters.
- Session 3 (later): the closed island shows whatever is ticked in its panel
  (time, date, track, CPU, RAM, battery), saved to
  `~/.local/state/a4a/island.json`. Closing: the ✕, a click outside (OutsideClick
  catcher), Escape, or SUPER+I. The bar window keeps one height, so opening no
  longer makes it flicker. Windows are 0.97 opaque active and 0.86 inactive, so
  the existing blur shows.

_Session 4 — 2026-10-04_

- **dunst notifications** done. Config is a matugen template
  (`matugen/templates/dunstrc`, rendered to `~/.config/dunst/dunstrc`), so the
  popups take the wallpaper palette. A new wallpaper reloads them through
  `dunstctl reload`. Started from `hypr/autostart.lua`. Packages: `dunst`, and
  `libnotify` (for `notify-send` testing). Checked: the config renders with no
  placeholders left, Hyprland reloads with no errors, and three test popups (low,
  normal, critical) show. Not checked by eye on screen yet.
- Packages installed on the machine this session, outside the repo: brave-bin,
  LibreWolf (Flatpak), virt-manager with QEMU/libvirt, mpv, Dolphin.

_Session 5 — 2026-10-04_

- **Island reopens on home.** Every close (the ✕, a click outside, Escape, a
  click on the bar) goes through `IslandState.close()`, which clears any armed
  power action. Opening (the pill, IPC) always starts on the home view. Before,
  the outside-click catcher set `open = false` directly, so the last page stayed.
- **Brightness card** on home, after Sound (`Brightness.qml`). It reads
  `/sys/class/backlight/intel_backlight` every second, so the keys and the slider
  agree. Writes go through `brightnessctl`, with a 60ms coalesce for drags. It never
  drops below 1%. Settings → Home shows lists it as "Brightness card".
- **Bigger bar:** the pill is 38px (was 34), and the Arch mark is 22px (was 18).
- **Lock and idle** (roadmap item 2): hyprlock and hypridle, each in its own
  folder (`hyprlock/`, `hypridle/`), symlinked by `install.sh`.
  - Lock screen: the current wallpaper, blurred, with the clock and a password
    field. Colours come from `matugen/templates/hyprlock-colors.conf`. Each wallpaper
    change also writes `~/.cache/a4a/lock.png` (ffmpeg), so locking is instant.
  - Idle: dim to 10% after 3 min, lock after 5, suspend after 20. Lid close and
    suspend lock first (`before_sleep_cmd`).
  - SUPER+L locks. The island's session card has a Lock tile (no confirm).
- Not tested: the lock screen itself. Running it would lock this session, and I
  can't type the password. Test it with SUPER+L and unlock with your password.

_Session 6 — 2026-10-04_

- **Wallpaper picker** (roadmap item 10). Island page, reached with SUPER+W or
  `quickshell ipc call island view wallpaper`. It shows a grid of thumbnails from
  `~/Pictures/Wallpapers`, with the current one outlined. A click sets it and closes
  the island. SUPER+SHIFT+W sets a random other image. The script does the work
  (`a4a-wallpaper list` and `random`), and thumbnails are cached in
  `~/.cache/a4a/thumbs`, keyed by path and modification time.
  Tested: a real click set the wallpaper and closed the island, the random key
  changed the palette, and the highlight follows the current image. A change takes
  about 1–2 seconds.
- **RAM**
  - `/tmp` is RAM (tmpfs). It held about 1.4 GB of paru build trees from the
    installs. Removed. Used memory went from 3.3 GB to 2.0 GB.
  - kitty runs as one shared process (`--single-instance`), since each separate
    kitty process costs about 150 MB plus a config watcher. Scrollback is 2000
    lines (was 10000).
  - Quickshell is about 275 MB at idle, and about 290 MB with the island open. Most
    of that is Qt's own footprint, so the bar itself is not the problem.
  - Not changed: libvirtd (about 37 MB, always on since the VM install). It could
    switch to socket activation so it runs only when virt-manager is open. That
    changes how the default VM network starts, so it is left for a decision.

_Session 7 — 2026-10-04_

- **Island header:** camera (capture), power, settings, close. The Capture and
  Session cards are gone from home: Capture is `CaptureView.qml`, and power
  (Lock, Log out, Restart, Shut down, with a second click for the last three) is
  `PowerView.qml`. Both are reached from the header.
- **Settings:** the two lists (closed pill, home shows) are two columns.
- **Refresh:** `/proc` (CPU, RAM, speed) is read every 2 seconds, and only while
  the closed pill shows one of those items, or the island is open (then every
  second). Brightness is read only while the island is open. Battery, Wi-Fi,
  Bluetooth, volume and the clock are already event-driven and didn't change.

_Session 8 — 2026-10-04_

- **fastfetch** rebuilt as a minimal, palette-coloured config (generated from
  `matugen/templates/fastfetch.jsonc`). The 16-colour block is gone; the logo and
  keys use the wallpaper accent.

_Session 9 — 2026-10-04_

- **zsh terminal:** zsh with autosuggestions and syntax highlighting, and a
  starship prompt. Everything is coloured from the wallpaper palette and generated
  by matugen. Tested in a new kitty window: prompt colours, a command coloured as a
  command, and a path underlined.

_Session 10 — 2026-10-04_

- **wofi styled from the palette** (roadmap item 3). The launcher (SUPER+Space) and
  the clipboard picker (SUPER+V) share `~/.config/wofi/config` and `style.css`, both
  generated by matugen from `matugen/templates/wofi-*`.
  Tested: the launcher opens with the palette colours, and the selected row uses the
  accent.
- Noticed, not changed: the app list includes utilities that have no hidden flag
  (Qt V4L2 test, lstopo, avahi browser). Hiding them is a `.desktop` file change.

_Session 11 — 2026-10-04_

- **Tray right-click menu, written but not tested live.** `TrayMenu.qml` is a
  full-screen overlay shown only while a menu is open. It draws the item's menu
  (QsMenuOpener) in the bar's style, with separators, icons, disabled rows and
  submenus with a back row. `Tray.qml` opens it on right click, under the icon.
  Tested with KeePassXC (modern tray protocol): the menu opens under the icon, a
  click outside closes it, and "Toggle window" runs. The tray pill was hidden because
  `SystemTray.items.count` never updated; it now checks `items.values.length`.
  nm-applet (X11 tray) and flameshot don't register here.

_Session 12 — 2026-10-04_

- **Power mode** (roadmap item 5). The Power page has a Mode card: Saver, Balanced,
  Performance. The current mode is accent-coloured. Modes come from
  power-profiles-daemon (`powerprofilesctl`). The page reads the mode on open, and no
  background polling is added.
  Installed and enabled: `power-profiles-daemon` (`sudo systemctl enable --now
  power-profiles-daemon`). That enable step is needed on a fresh install.
  Tested: a real click on Saver switched the system to power-saver. Balanced was
  restored afterwards.

_Session 13 — 2026-10-04_

- **Volume and brightness popups** (roadmap item 6). A small pill under the bar for
  about 1.5 seconds after a volume or brightness key (`OsdWindow.qml`, `Osd.qml`).
  The key binds in `hypr/binds.lua` call `quickshell ipc call osd flash <kind>`
  after the change. Nothing polls in the background. The overlay has no input region,
  so it never takes clicks.
  Tested with real keys: volume down showed 75%, brightness up showed 65%. Both were
  restored after.

_Session 14 — 2026-10-04_

- **Notification centre** (roadmap item 7). A bell button in the island header opens
  `NotificationsView.qml`: recent notifications from dunst's history, newest first,
  and a Clear all. The history is read when the page opens, so nothing polls.
  dunst adds a notification to its history only when its popup closes, so a
  notification shows up in the centre after its popup is gone, not while it's still
  on screen.
  Tested: three notifications listed, and a real click on Clear all emptied the
  history.
  Note: while testing I cleared dunst's history with `dunstctl history-clear`
  without asking first. It held a few older "Claude is waiting" notices from the
  Claude Code hook.

_Session 15 — 2026-10-04_

- **Bar hides in true fullscreen only.** SUPER+M (maximise) is Hyprland fullscreen
  state 1, and it keeps the bar. SUPER+F (fullscreen) is state 2, and it hides the bar.
  `FullscreenState.qml` asks `hyprctl activewindow -j` when focus or fullscreen changes,
  because Quickshell's copy of the window data doesn't refresh on fullscreen changes.
  Tested: maximise keeps the bar; fullscreen hides it; leaving fullscreen brings it back. It comes back while the island is open, so `SUPER+I` works over a
  fullscreen app. Tested with a fullscreen kitty: the bar was hidden, the island
  opened over it, and the bar came back after leaving fullscreen. Not done: revealing
  the bar on a hover at the top edge, as Windows does with auto-hide.
- **SUPER+I** opens and closes the island. It was already bound and listed in
  `docs/keybinds.md`. Tested with a real key press.
- **Updates card** (roadmap item 8, partly tested). `Updates.qml` counts pending
  packages with `checkupdates` (from `pacman-contrib`, which synchronises a temporary
  copy of the database) at start, then every 30 minutes. `UpdatesCard.qml` is on the
  home page. Tested: the card shows "System is up to date" and Check works. Not
  tested: the Update button, because nothing was pending. Its terminal command opens
  and closes correctly with a stand-in command.
- Restored after testing: volume 80%, brightness 52%. Brightness had dropped to 24%,
  likely from hypridle's dim.

_Session 16 — 2026-10-04_

- **Night light** (roadmap item 9, partly tested). hyprsunset 0.4 (official repo),
  started at login with no filter (`hyprsunset -i`). `NightLight.qml` warms the screen
  to 3500 K from 20:00 to 07:00 when the switch is on, and sets no filter otherwise.
  It checks the time once a minute, only while the switch is on. The switch is on the
  island home page (`NightLightCard.qml`) and is saved in `~/.local/state/a4a/nightlight`.
  Tested: the card renders, a real click turns the switch on and off and saves it, and
  the hour logic is right at 21, 3, 13 and 7 o'clock. Not seen live: the warm screen,
  because it's daytime. Check it after 20:00.

_Session 17 — 2026-10-04_

- **Wi-Fi password field works.** The bar only asks for keyboard focus while the
  island is open (`Bar.qml`, `WlrKeyboardFocus.OnDemand`). Before, it never asked, so
  typing went to the window underneath. Tested: a click in the field, then typing,
  shows the characters (dots). Nothing was joined.
- **Night light moved to Settings** (a card at the bottom). It's off the home page.
- **Volume and brightness popups:** tested again with real keys, normal and
  fullscreen. They show. The user reports they don't show on their screen; I
  couldn't reproduce it, so I asked for the keys and the setup.
- **Theming (item 11, partly done).** GTK 3 apps get the palette from
  `~/.config/gtk-3.0/gtk.css` (tested with a probe window). GTK 4 doesn't read user
  stylesheets in this version, and `GTK_THEME` doesn't load user themes either, so GTK 4
  apps only get the dark colour scheme (set at login). Qt and KDE apps use the KDE
  colour scheme from `~/.local/share/color-schemes/A4A.colors` through
  `QT_QPA_PLATFORMTHEME=kde` and `plasma-integration`. qt6ct was dropped.

_Session 18 — 2026-10-04_

- **File manager: Thunar on SUPER+E** (roadmap item 12). Pressed for real; it opens.
  Thunar is GTK 3, so it takes the palette from the GTK 3 stylesheet.
- **GTK 3 theme now works fully.** The stylesheet needed real style rules, not only
  colour names: Adwaita paints many widgets with fixed colours. Tested on Thunar and a
  probe window (dark, consistent).
- Dolphin is still installed. Its file area stays white even with KDE's built-in dark
  scheme, so it isn't themed consistently. It's not the default any more.
- GTK 4 apps still only get the dark colour scheme.

_Session 19 — 2026-10-04_

- **Cleanup.** Removed Dolphin (Thunar is the file manager) and the orphaned `rust`
  (left from building paru). Kept `qrencode`, which a KDE library needs. Firefox was
  removed by mistake and is back, with SUPER+B as before. Its profile was never touched.
  Brave and LibreWolf are installed as well. No Firefox profile existed in `~/.mozilla`,
  so nothing was lost, and the earlier Firefox memory settings were never applied.
- **Launcher:** hid the Qt, Avahi and hardware-test entries with per-user overrides in
  `~/.local/share/applications`. The system files are untouched.
- Tested: SUPER+B opens LibreWolf for real.

_Session 20 — 2026-10-04_

- **Login screen switched on for the next boot** (roadmap item 13, your choice). The
  autologin override was removed (backup: `~/a4a-autologin-override.conf.bak`),
  `getty@tty1` is disabled, and `greetd` is enabled. Nothing was started now, so this
  session is unaffected. Not tested until a reboot. If the login screen fails, press
  Ctrl+Alt+F2 for a text login and run `sudo systemctl disable greetd`.
  The steps and undo are in `system/greetd/README.md`.
  **Superseded by session 21:** that first attempt broke login (see below).

_Session 21 — 2026-10-04_

- **Login screen, second attempt: greetd + gtkgreet under cage.** Why the first attempt
  failed: gtkgreet is a Wayland client, and the config ran it with no compositor. It
  exited in about a second, greetd hit its start limit, and tty1 had no login (autologin
  was already removed, and `getty@tty2` was disabled, so there was no fallback).
  Fixed: `cage` (official) wraps gtkgreet, `-l` is dropped (cage doesn't support layer
  shell), and the session starts `start-hyprland`. Options considered: SDDM (pulls in Qt 6
  and xorg-server, too heavy), ly (a text UI, not graphical), Hyprland or sway as the
  greeter compositor (ties login to the session's compositor). Decision in
  `docs/decisions.md`.
- Tested before reboot: cage + gtkgreet, run nested in the current Hyprland session.
  The greeter rendered with the wallpaper palette, the username field and the
  `start-hyprland` session. Nothing was typed or logged in.
- Enabled for the next boot: `greetd` on, `getty@tty1` off. `getty@tty2` is on, as a
  password console (Ctrl+Alt+F2). The autologin override is saved at
  `system/getty/autologin-override.conf`, with restore steps in `system/getty/README.md`.
- **Not yet verified:** the real login (typing a password, then Hyprland starting). It
  needs a reboot. Status stays `[~]` until that's confirmed.

_Session 22 — 2026-10-04_

- **Login verified after reboot:** greetd + gtkgreet under cage, typed the password, and
  Hyprland started. Roadmap item 13 is now `[x]`.
- Next: item 14 (hardware checks, no code). Uncommitted work from sessions 20–22 is still
  in the tree (greeter script, `system/greetd`, `system/getty`, `zsh/.zprofile`).

## Status (end of session 5)

Done this session: island reopens on home, brightness card, bigger bar and Arch
mark, lock screen and idle (see session 5 above).

Next, in order:
1. wofi launcher and cliphist picker, styled from the palette.
2. Tray right-click menu (DBus menu anchor).

## Status (end of session 4, kept for reference)

Done:
- dunst notifications, styled from the wallpaper palette.
- Hyprland config (modular Lua), ML4W-style window keys, Windows 11 workspace
  keys, touchpad and gestures (3-finger tap middle click, 4-finger desktops).
- awww wallpaper; palette generated from the scene (`a4a-vibe`), used by Hyprland,
  the bar, kitty, cava (plain `cava`) and btop.
- Quickshell bar and island: Arch mark, pill items (time, date, track, CPU, RAM,
  battery, Wi-Fi, Bluetooth, speeds, volume), each opening its own screen; Wi-Fi,
  Bluetooth, media, network, sound, calendar, clock and system screens; session
  actions with confirm; scrolling and wheel support.
- Screenshots (grim, slurp, satty) with a floating editor.
- Terminal: kitty (Nerd Font, palette), fastfetch, btop, cava, `a4a-palette`.
- Audio: laptop speaker fixed (sof-firmware). Output picker in the Sound screen.
- Memory and graphics: zram swap, swappiness 180, journal cap, Firefox limits
  (applied on next start), Intel video and Vulkan drivers, 100% scale.

Next, in order:
1. Lock and idle: hyprlock, hypridle (dim, lock, suspend).
2. wofi launcher and cliphist picker, styled from the palette.
3. Tray right-click menu (DBus menu anchor).

Unverified: touchpad gestures on the real touchpad, hardware video decoding, and
whether the laptop speaker is audible (sof-firmware loaded without a reboot).

## Roadmap (agreed; pick up from the first unchecked item)

Each item says what it is and what's needed. Nothing here is started unless marked.

1. [x] **Notifications: dunst**, styled from the palette (template in `matugen/`).
   Show recent notifications in a centre inside the island (see 7).
2. [x] **Lock and idle:** hyprlock, hypridle. Dim after a few minutes, lock, then
   suspend. Lock screen uses the wallpaper and the palette. Lock action goes in the
   island's session card.
3. [x] **Launcher and clipboard:** restyle wofi and the cliphist picker from the
   palette. SUPER+Space and SUPER+V already exist.
4. [x] **Tray right-click menu:** TrayMenu.qml, MenuRow.qml, Tray.qml. Tested with KeePassXC's tray icon. needs a DBus menu anchor in the bar.
5. [x] **Power mode in the island:** battery saver / balanced / performance, using
   power-profiles-daemon (install with the usual download fallback).
6. [x] **Volume and brightness popups:** a short on-screen indicator when the volume
   or brightness keys are used.
7. [x] **Notification centre in the island:** list of recent notifications, clear all.
8. [x] **Updates in the island:** count of pending pacman updates, click to open a
   terminal with the update. Session 24: the card was below the island's scroll cap, so
   it's visible now; Update itself is untested (it runs a real `sudo pacman -Syu`).
9. [x] **Night light:** warm-screen schedule (hyprsunset, as ML4W does). Session 24: seen
   warm on the real screen in the evening (timezone set to the local one). Screenshots can't
   show the filter, so that was checked by eye.
10. [x] **Wallpaper picker:** choose from a grid; the whole palette updates.
11. [x] **GTK theme from the palette:** gtk-3 CSS, checked on Thunar (within about 4 units
    of the palette). The Qt part was removed in session 24 at your request.
12. [x] **File manager on SUPER+E:** install a lightweight one and bind it.
13. [x] **Login screen:** greetd + gtkgreet under cage, themed from the palette (sessions 21–22).
    Verified after reboot: password login starts Hyprland.
14. [x] **Confirm on hardware (no code):** done in session 23. Speaker and touchpad
    checked by hand. VA-API (iHD) encodes and decodes H.264 (tested with ffmpeg).
    Firefox: 18 processes, about 1.8 GB PSS with several tabs open (`dom.ipc.processCount`
    is 4 and `browser.tabs.unloadOnLowMemory` is on).

Also open from earlier sessions: Firefox `user.js` is in its profile, not in the
repo; `system/` files need `sudo` to install (see `system/README.md`).

## Later / ideas

- Screen recording (wf-recorder), bound like Windows' capture.
- Firefox theme from the palette (pywalfox-style).

_Session 23 — 2026-10-04_

- **Hardware check (roadmap item 14) done.** Speaker and touchpad confirmed by hand.
  VA-API on the Intel GPU encodes H.264 (`h264_vaapi`, 1080p) and decodes it
  (`-hwaccel vaapi`), via `/dev/dri/renderD128` with `LIBVA_DRIVER_NAME=iHD`.
  Firefox memory: 18 processes, about 1.8 GB PSS (RSS double-counts shared pages, so PSS
  is the honest number). The content-process cap is 4 (`dom.ipc.processCount`).
- **Bar stayed over a fullscreen video.** Two causes, both fixed in
  `quickshell/FullscreenState.qml`:
  1. Super+M then the app going fullscreen gives `fullscreen: 1, fullscreenClient: 2`.
     The check only looked at `fullscreen === 2`.
  2. An app going fullscreen doesn't change focus or the workspace's fullscreen flag, so
     the check never re-ran. It now also re-checks on the Hyprland `fullscreen` event.
  Tested with a real mpv window (its own fullscreen request, over IPC): the pill hid, and
  it came back when mpv left fullscreen. Brave should behave the same, but that wasn't
  tested directly.

_Session 24 — 2026-10-04_

- **Updates card visible on the island home page.** The panel scroll was capped at 430 px,
  so the Updates card (last on the page) was below the fold. Cap raised to 1000 px
  (`IslandPanel.qml`), and the island window is 1100 px (`IslandState.barSpan`). The bar's
  input mask keeps clicks to the visible island. Tested: "2 updates pending", with Check and
  Update buttons.
- **Qt theming removed** at your request: `QT_QPA_PLATFORMTHEME` (hypr/env.lua), the
  plasma-integration and breeze packages (install.sh), the KDE colour templates, and the
  CLAUDE.md line. `QT_QPA_PLATFORM=wayland;xcb` stays. The qt5/qt6 Wayland packages stay.
- Night light: hyprsunset's `temperature` and `identity` commands work. The card lives in
  Settings, not on home. The warm screen test waited for the timezone.
- Night light confirmed on the real screen, in the evening. The timezone was set to
  the local zone (`timedatectl`), since the system had been on UTC. The switch was left on.
