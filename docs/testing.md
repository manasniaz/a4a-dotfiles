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

## Testing the new modules (session 27)

- **Enterprise Wi-Fi:** `echo '<form-json>' | a4a-wifi-join --test` builds the 802.1X
  settings and prints them with the password masked, without touching NetworkManager.
  Add `--legacy` to see the legacy-TLS variant. A real attempt reads the same JSON on
  stdin; watch `journalctl -u wpa_supplicant` (raise detail with
  `sudo wpa_cli -i <dev> log_level DEBUG`) for the EAP/TLS trace. MSCHAPv2 error 691 =
  wrong username/password; "unsupported protocol" = needs legacy TLS.
- **Bluetooth pairing:** `a4a-bt-agent --test confirm|authorize|service|pin|passkey|display`
  pops the real pairing card for a pretend device (no BlueZ), prints the answer BlueZ
  would get. With no `quickshell` on PATH it uses the notification fallback instead.
- **A throwaway MPRIS player** (for the track item / media card): a small GLib script
  that owns `org.mpris.MediaPlayer2.a4atest` and reports a playing track. `playerctl -p
  a4atest play-pause` drives it; kill it to test the empty state.
- **Driving the pointer without root:** `hyprctl dispatch 'hl.dsp.cursor.move({ x=…, y=… })'`
  moves the cursor for hover shots (no ydotoold needed). Clicks and typing still need
  ydotool. Remember ydotool absolute coords are **half** the physical pixels.
- **A component in isolation:** a tiny `shell.qml` that imports the repo through a
  symlink (`import "a4a"`, with `a4a -> …/quickshell`) and shows one component in its own
  `PanelWindow`, run with `quickshell -p <that file>`. Absolute import paths are rejected.
