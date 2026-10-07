# Keybinds

`SUPER` is the main key. Source: `hypr/binds.lua`, kept in sync with this file.
The shortcut layout follows ML4W's defaults and Windows 11 habits, except where noted.

## Apps

| Keys             | Action                            |
|------------------|-----------------------------------|
| SUPER + Return   | Terminal (kitty)                  |
| SUPER + Space    | App launcher (wofi)               |
| SUPER + V        | Clipboard history                 |
| SUPER + B        | Browser (firefox)                 |
| SUPER + E        | File manager (Thunar)             |
| SUPER + CTRL + K | This list, in a terminal          |

## Windows

| Keys                  | Action                                      |
|-----------------------|---------------------------------------------|
| SUPER + Q             | Close window                                |
| SUPER + SHIFT + Q     | Force-kill a window that won't close        |
| SUPER + M             | Maximize (keeps the bar and gaps)           |
| SUPER + F             | Fullscreen (hides the bar)                  |
| SUPER + T             | Toggle floating                             |
| SUPER + SHIFT + Space | Toggle floating (same)                      |
| SUPER + J             | Toggle split direction                      |
| SUPER + K             | Swap split                                  |
| SUPER + P             | Pseudotile                                  |
| SUPER + C             | Center floating window                      |
| SUPER + Y             | Pin a floating window on every workspace    |
| ALT + Tab             | Next window on this workspace, raised       |
| SUPER + arrow         | Move focus                                  |
| SUPER + SHIFT + arrow / hjkl | Resize the window by 100 px (hold to keep going) |
| SUPER + ALT + arrow / hjkl   | Swap with the window in that direction |
| SUPER + LMB drag      | Move window                                 |
| SUPER + RMB drag      | Resize window                               |

Focus is arrows only. `h j k l` with SUPER are split, swap-split, lock and nothing
on their own, so they don't also move focus (SUPER+L would otherwise lock *and* move).

## Workspaces

| Keys                       | Action                                       |
|----------------------------|----------------------------------------------|
| SUPER + 1–0                | Go to workspace 1–10                         |
| SUPER + SHIFT + 1–0        | Send window to workspace 1–10 (and follow)   |
| SUPER + ALT + 1–0          | Send window to workspace 1–10 (stay put)     |
| SUPER + G                  | Go to any workspace: type the number         |
| SUPER + SHIFT + G          | Send window to any workspace: type the number|
| CTRL + SUPER + ←/→         | Previous / next existing workspace           |
| CTRL + SUPER + SHIFT + ←/→ | Carry the window to the prev / next desktop  |
| CTRL + SUPER + D           | Go to a fresh, empty workspace               |
| SUPER + Tab                | Previous workspace                           |
| SUPER + scroll             | Next / previous existing workspace           |
| 4-finger swipe             | Next / previous desktop                      |
| 3-finger swipe             | Next / previous window                       |

## Scratchpad

| Keys              | Action                         |
|-------------------|--------------------------------|
| SUPER + S         | Show / hide the scratchpad     |
| SUPER + SHIFT + S | Send window to the scratchpad  |

## Screenshots

| Keys          | Action                                             |
|---------------|----------------------------------------------------|
| Print         | Drag a region, then annotate (satty)               |
| SUPER + Print | Whole screen, then annotate                        |

Saved to `~/Pictures/Screenshots` and copied to the clipboard.

## Bar: the island and the control centre

The bar has two panels, and each opens where its pill is — the island in the centre,
the control centre from the right pill — so a thing opens where you reach for it. One
panel is open at a time; a page that lives in the other panel moves there. Arrow keys,
typing and Escape work in an open panel with no click first.

| Keys      | Action                                                       |
|-----------|--------------------------------------------------------------|
| SUPER + I | The island (clock, media, notifications, launch) — or close  |
| SUPER + A | The control centre (Wi-Fi, Bluetooth, sound, system) — or close |
| SUPER + N | Notifications — or close                                     |
| SUPER + W | Wallpaper picker (arrows to browse, Enter to keep, Esc to go back) |
| SUPER + X | Power: lock, log out, restart, shut down — or close          |
| SUPER + SHIFT + W | Set a random wallpaper                               |
| SUPER + SHIFT + N | Clear the notification popups on screen              |
| SUPER + CTRL + N  | Do not disturb on / off                              |
| Esc       | Close the open panel                                         |
| Backspace | Back to the panel's front page                               |

Inside a panel, the keys mirror the cards: on the island home, `n` notifications,
`w` wallpaper, `c` capture, `s` settings, `m` media, `t` clock, `d` calendar,
`a` the control centre. In the control centre, `w` Wi-Fi, `b` Bluetooth, `s` sound,
`p` power, `y` system, `i` the island.

Scrolling over the workspace pill changes desktop; over the volume in the right pill
it changes the volume.

## Session

| Keys              | Action                                   |
|-------------------|------------------------------------------|
| SUPER + L         | Lock (hyprlock, on the current wallpaper)|
| SUPER + SHIFT + R | Reload Hyprland                          |
| SUPER + CTRL + R  | Restart the Quickshell bar               |
| SUPER + SHIFT + E | Exit Hyprland                            |

## Touchpad and mouse (Windows 11 style)

| Gesture                   | Action                                  |
|---------------------------|-----------------------------------------|
| 1 finger tap              | Left click                              |
| 2 finger tap              | Right click                             |
| 3 finger tap              | Middle click                            |
| 4 finger swipe left/right | Previous / next desktop                 |
| 3 finger swipe left/right | Next / previous window                  |
| 2 finger scroll           | Scroll the way the content moves        |

## Hardware keys

Volume up/down/mute, mic mute, brightness up/down, media play/pause/next/prev.
These work on the lock screen too.
