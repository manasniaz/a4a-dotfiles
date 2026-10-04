# Testing the rice

How the checks in this repo were run. Read this when you need to test with real input.

## Mouse and keys (ydotool)

Start the daemon (needs sudo):

    sudo ydotoold --socket-path=/tmp/ydotool.sock --socket-own=$(id -u):$(id -g) &
    export YDOTOOL_SOCKET=/tmp/ydotool.sock

- Absolute coordinates are **half** the physical pixel values. Read the result with
  `hyprctl cursorpos`.
- Click: `ydotool click 0xC0` (left), `0xC1` (right).
- Keys use Linux key codes: LEFTMETA 125, `i` 23, `m` 50, `f` 33; volume down 114,
  volume up 115, brightness down 224, brightness up 225.
- Stop the daemon when finished: `sudo pkill ydotoold`.

## Screenshots (grim)

- Region: `grim -g "X,Y WxH" file.png`. The size is `WxH` with a lowercase `x`.
- Full screen: `grim file.png`.
- Save captures in the session scratchpad, then view them with the Read tool.

## Checks

- Bar: `pgrep -x quickshell`, and `grep -ci error` on its log
  (`quickshell >/tmp/.../qs.log 2>&1 &`). Expect 0.
- Hyprland: `hyprctl configerrors` prints nothing.
- Island pages: `quickshell ipc call island view <name>` for home, wifi, bluetooth,
  calendar, clock, media, network, sound, system, settings, wallpaper, power,
  capture, notifications.
- Layers: `hyprctl layers | grep -c quickshell`.
- Idle daemon: `hypridle -v -c ~/.config/hypridle/hypridle.conf` logs its rules.
