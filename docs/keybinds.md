# Keybinds

`SUPER` is the main key. Source: `hypr/binds.lua`, kept in sync with this file.
Arrows and the vim keys (`h j k l`) do the same thing wherever a direction is needed.
The shortcut layout follows ML4W's defaults, except where noted.

## Apps

| Keys             | Action                            |
|------------------|-----------------------------------|
| SUPER + Return   | Terminal (kitty)                  |
| SUPER + Space    | App launcher (wofi)               |
| SUPER + V        | Clipboard history                 |
| SUPER + B        | Browser (firefox)                 |
| SUPER + CTRL + K | This list, in a terminal          |

## Windows

| Keys                  | Action                                      |
|-----------------------|---------------------------------------------|
| SUPER + Q             | Close window                                |
| SUPER + M             | Maximize (keeps the bar and gaps)           |
| SUPER + F             | Fullscreen                                  |
| SUPER + T             | Toggle floating                             |
| SUPER + SHIFT + Space | Toggle floating (same)                      |
| SUPER + J             | Toggle split direction                      |
| SUPER + K             | Swap split                                  |
| SUPER + P             | Pseudotile                                  |
| SUPER + C             | Center floating window                      |
| SUPER + dir           | Move focus                                  |
| SUPER + SHIFT + dir   | Resize the window by 100 px (hold to keep going) |
| SUPER + ALT + dir     | Swap with the window in that direction      |
| SUPER + LMB drag      | Move window                                 |
| SUPER + RMB drag      | Resize window                               |

## Workspaces

| Keys                  | Action                                  |
|-----------------------|-----------------------------------------|
| SUPER + 1–0           | Go to workspace 1–10                    |
| SUPER + SHIFT + 1–0   | Send window to workspace 1–10           |
| CTRL + SUPER + ←/→    | Previous / next desktop (Windows 11)    |
| SUPER + Tab           | Previous workspace                      |
| SUPER + scroll        | Next / previous workspace               |
| 4-finger swipe        | Next / previous desktop                 |
| 3-finger swipe        | Next / previous window                  |

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

## Island and bar

| Keys    | Action                              |
|---------|-------------------------------------|
| SUPER + I | Open / close the island           |

Scrolling over the workspace pill changes desktop; over the volume in the pill it changes the volume.

## Session

| Keys              | Action           |
|-------------------|------------------|
| SUPER + SHIFT + R | Reload Hyprland  |
| SUPER + SHIFT + E | Exit Hyprland    |
| SUPER + L         | Lock (hyprlock)  |
| SUPER + W         | Wallpaper picker (island) |
| SUPER + E         | File manager (Thunar)            |
| SUPER + SHIFT + W | Random wallpaper |

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
