# Decisions log (history)

Moved out of CLAUDE.md so the standing context stays short. Read this when you need
the reason behind something. The current rules are in CLAUDE.md.

## Decisions log

- Session 1: Hyprland config split into modules under `hypr/`; palette lives in
  `hypr/colors.lua` (neutral dark + muted blue-grey accent `#8aa1b1`). Laptop
  panel eDP-1 at 1.5 scale, XWayland zero-scaling on. vim keys + arrows for
  directions. SUPER+V is reserved for clipboard, so float toggle is
  SUPER+SHIFT+Space.
- Session 1: Repo scaffolded at `~/Projects/A4A`. Personal use only — no
  license, no public docs. Bar is **Quickshell** (not waybar). Launcher is
  wofi, clipboard is cliphist, notifications are dunst, wallpaper is awww.
- Session 2: swww was renamed to **awww** upstream; the Arch package is now
  `awww` (binaries `awww`, `awww-daemon`). Use the new name everywhere.
  The wallpaper is `~/Pictures/wallpaper.jpg`, outside the repo: wallpaper
  images are large and personal, so they are never committed.
- Session 2: **the whole palette now comes from the wallpaper.** `matugen`
  (Material You, dark mode, `--prefer saturation`, fallback `#8aa1b1` for
  colourless images) renders `matugen/templates/colors.lua` to
  `~/.cache/a4a/colors.lua`. `hypr/colors.lua` reads that file and falls back to
  the static values until the first run. Every component uses the same slot
  names from that template. Changing the wallpaper is done only with
  `a4a-wallpaper set <image>`, which also remembers the image for login.
  Dark mode is fixed on purpose, to keep the minimal dark look for any wallpaper.
  `matugen` is the one new package: it is in the official repos, and our own
  templates keep the config written from scratch (pywal and wallust were the
  alternatives, and both need more setup).
- Session 3: **Quickshell bar** first pass in `quickshell/`. Widgets: workspaces
  (click to focus), media (MPRIS, click to play/pause), clock, tray (left click
  only), CPU/RAM (read from `/proc`), battery (UPower). Power menu is still to do.
  The bar reads `~/.cache/a4a/colors.json`, a second matugen output from the
  same palette (`matugen/templates/colors.json`), and reloads when it changes.
  New packages, each with a reason: `quickshell` (the framework), `upower`
  (battery; `UPower` needs its daemon), `wofi`, `cliphist`, `playerctl`,
  `brightnessctl` (the session-1 list, now installed).
- Session 3: **palette now comes from the whole scene, not one pixel.** matugen's
  own pick (`--prefer saturation`) is the single most saturated pixel, so a
  sunset streak set the theme. `scripts/a4a-vibe` clusters a 64×36 copy of the
  image (k-means, stdlib only, ffmpeg to decode) and picks the cluster that covers
  the most area while still being coloured. `a4a-wallpaper` then runs
  `matugen color hex` on that colour. For the current wallpaper it gives
  `#a6c8ff` on a cool dark background, which matches the glacier.
- Session 3: **Windows 11 workspace keys.** CTRL+SUPER+←/→ moves to the
  previous/next workspace with `r±1`, so empty desktops count, as in Windows.
  That chord was the window-resize bind, so resize moved to **SUPER+ALT+dir**.
  The scratchpad send moved to **SUPER+ALT+S** so SUPER+SHIFT+S can take the
  snipping shortcut.
- Session 3: **screenshots** are `scripts/a4a-screenshot`: `grim` captures,
  `slurp` selects a region, and `satty` is the annotate editor (the Snipping Tool
  equivalent). SUPER+SHIFT+S is region, Print is full screen. The editor
  floats and is centred. Output goes to `~/Pictures/Screenshots` and the clipboard.
- Session 3: **the island.** The centre pill shows the track and the clock. Click
  it, or press SUPER+I (`quickshell ipc call island toggle`), and it opens a panel
  with the time, media controls, screenshots, launcher, clipboard, and the power
  actions. Power actions need a second click. The bar only takes clicks on its
  pills, so the open panel doesn't block the windows underneath.
- Session 3 (later): **the bar window has one fixed height.** Resizing it when
  the island opens made the whole bar flicker. Clicks are limited with a `Region`
  mask instead. Blur is set through opacity: it only shows through translucent
  windows, so `active_opacity` 0.97 and `inactive_opacity` 0.86 in `hypr/look.lua`.
- Session 3 (latest): **panel sections are selectable** (Media, Screenshots,
  Apps & clipboard, Session), saved next to the collapsed choices in
  `~/.local/state/a4a/island.json`. The bar window is 470px tall (`IslandState.barSpan`)
  so the full panel fits. The gap under the bar is 4px (`Bar.edge`), and
  Hyprland `gaps_out` is 6.
- Testing the bar: `ydotool` is installed for real clicks. Its daemon needs
  sudo (`sudo ydotoold --socket-path=/tmp/ydotool.sock --socket-own=$(id -u):$(id -g)`),
  and absolute coordinates are half the logical pixel values. Read the cursor
  with `hyprctl cursorpos` before each click.
- Session 3 (latest 2): **CPU, RAM and battery moved off the status pill.** They
  show in the island instead: as text when ticked under "Show when closed", or as
  meters when the "CPU, RAM, battery" section is on in the panel (off by default).
  The status pill holds only the tray, and it hides when the tray is empty. The
  CPU reading was checked against `/proc/stat` (2% idle, 100% under full load),
  and the guest fields are no longer double counted.
- Session 3 (latest 3): **the island is a set of cards.** Home holds Wi-Fi and
  Bluetooth quick cards (open the detail list, or flip the switch), then
  Capture, Launch, System and Session groups. Settings is a page of switches:
  what the closed pill shows, and which home groups are on. Wi-Fi uses
  `Quickshell.Networking` and Bluetooth uses `Quickshell.Bluetooth`, so there's no
  parsing of nmcli or bluetoothctl output. Discovery runs only while a detail
  view is open. The open and close motion is one `progress` value (0 to 1) that
  drives size, radius and the fades.
- Session 3 (latest 3): **terminal theme.** `matugen/templates/kitty-colors.conf`,
  `cava.conf` and `btop.theme` are rendered into `~/.cache/a4a/`. kitty includes
  its colours and reloads on SIGUSR1, cava runs with `-p ~/.cache/a4a/cava.conf`
  (the `cava` alias in `.bashrc`), and btop points at `~/.cache/a4a/btop.theme`.
  cava uses PulseAudio input, because PipeWire's native input wasn't connecting.
  fastfetch runs on each new kitty window from `.bashrc`. `a4a-palette` is run by hand, not on each window.
- Open: the JetBrains Mono Nerd Font package stalls on download from this
  mirror, so kitty uses DejaVu Sans Mono for now. Retry `ttf-jetbrains-mono-nerd`
  and switch `kitty/kitty.conf` once it's in.
- Session 3 (latest 4): **closed-pill status items.** Wi-Fi (one item: icon that fills with the
  signal, then the %), Bluetooth icon (accent when a device is connected),
  download and upload speed. Speed is read from `/proc/net/dev`, summed over all
  interfaces but loopback, once a second, and shown in KB/s or MB/s. Icons are
  drawn on a canvas (`Icon.qml`) because no icon font is installed. The track line
  shows the app's name under the title, since browsers put their own status text
  in the title (Firefox sends "Firefox is playing media").
- Session 3 (latest 5): **island icons come from the Nerd Font** (JetBrainsMono
  Nerd Font Mono, installed from the package file, since pacman's download stalled).
  `Icon.qml` picks the glyph from the value: Wi-Fi strength steps, battery level,
  charging bolt, clock, calendar, Bluetooth, arrows. Every closed-pill item opens its
  own screen when clicked: time and date open the calendar, battery, CPU and RAM open
  System, Wi-Fi and speeds open Wi-Fi, Bluetooth opens Bluetooth. The panel scrolls
  inside a Flickable, capped at 430px. `a4a-palette` prints the palette, and
  `.bashrc` runs it in each new kitty window after fastfetch.
- Session 3 (latest 6): **laptop sound.** The Intel SOF audio driver needs
  `sof-firmware`, which wasn't installed, so the laptop had no sound card and only
  Bluetooth outputs worked. Installed it and reloaded the SOF modules; the speaker
  is now a PipeWire sink (`Raptor Lake-P/U/H cAVS Speaker`). `Volume.qml` reads the
  default output through `Quickshell.Services.Pipewire`, and the Sound screen
  switches output with `wpctl set-default`.
- Session 3 (latest 6): **the Arch mark.** It's always first in the closed pill, in
  Arch blue (`Theme.arch`), and it's the only thing that opens the whole island.
  With nothing selected to show it carries "Arch Linux". Each other pill item opens
  only its own screen: time opens Clock, date Calendar, the track Media, speeds
  Network, Wi-Fi and Bluetooth their own screens, CPU, RAM and battery System, and
  volume Sound.
- Session 3 (latest 6): **windows.** The screenshot editor floats at 1100×720 and
  centred. Hyprland matches classes as regular expressions, so write `\\.`, not
  Lua's `%.`. Open, close and move animations share one timing.
- Session 3 (latest 7): **cava reads the palette directly.** matugen writes
  `~/.config/cava/config` (cava's own config file), so plain `cava` uses the
  wallpaper colours. The old `-p` alias was removed. Settings, Wi-Fi and Bluetooth
  no longer have their own scrollers inside the island's panel, so one scroll
  handles every screen. Time and date have no glyph in the closed pill.
- Session 3 (latest 8): **touchpad and mouse.** `hypr/input.lua` sets 3-finger tap
  to middle click (`tap_button_map = "lrm"`), natural touchpad scroll, adaptive
  pointer acceleration, and typing protection. 4-finger swipe changes desktop; 3-finger
  swipe cycles windows. Wheel scrolling works in the island panel, on the workspace
  pill (desktop) and on the volume item. The wheel is tested with a uinput virtual
  mouse (`/dev/uinput`, run with sudo). The bar's wheel area is a MouseArea that takes
  no buttons: a WheelHandler on the pill never fired.
- Session 4: **notifications are dunst, styled from the palette.** Its config is a
  matugen template (`matugen/templates/dunstrc`) that renders straight to
  `~/.config/dunst/dunstrc`, the same way cava's config does, so it is not a repo
  component folder. Each wallpaper change runs `dunstctl reload`, which re-themes
  without a restart. Popups sit top-right, 50px down (below the bar's 38px pill
  plus the window gap). Critical notifications don't time out and use the error
  colour. dunst 1.13 uses `height = (0, X)` and `offset = (X, Y)`; the single-value
  forms are deprecated.
- Session 5: **island reopens on home.** There is one way to close the island,
  `IslandState.close()`, used by the ✕, a click outside, Escape and the bar. Opening
  always starts on the home view (`IslandState.toggle()` and `openTo()`), so a page
  left open is never shown next time. Previously the outside click set `open` and
  kept the last page.
- Session 5: **brightness.** `Brightness.qml` reads the panel's backlight every
  second from sysfs and writes through `brightnessctl`. The device name
  (`intel_backlight`) is per machine and is set at the top of that file. The minimum
  is 1%, so the screen can't go black with no way back.
- Session 5: **bigger bar.** The pill is 38px (was 34), and the Arch mark is 22px.
- Session 5: **lock and idle.** hyprlock's background is `~/.cache/a4a/lock.png`,
  which `a4a-wallpaper` writes with ffmpeg (any input format, scaled to 2560 wide).
  The palette template is `hyprlock-colors.conf`. Idle: dim at 3 min, lock at 5,
  suspend at 20 (`hypridle/hypridle.conf`). SUPER+L locks. Locking runs at once from
  the island's session card, with no confirm.
- Session 6: **wallpaper picker.** Photos live in `~/Pictures/Wallpapers`
  (`FOLDER` at the top of `scripts/a4a-wallpaper`, per machine). The picker is an
  island page (`WallpaperView.qml`). Its folder listing runs only while the page is
  open. `a4a-wallpaper list` prints `thumb<TAB>image` and makes missing thumbnails
  with ffmpeg. `random` never picks the current image. Wallpaper images stay out of
  the repo, as before.
- Session 6: **RAM.** kitty uses one shared process (`--single-instance`, in
  `hypr/binds.lua`). Scrollback is 2000 lines. `/tmp` is tmpfs, so build leftovers
  there cost real RAM: remove them after installs. Quickshell's ~275 MB base is Qt,
  not our code.
- Session 7: **island header and pages.** The header has camera (capture page),
  power (power page), settings and close, in that order. Power actions still need a
  second click, except Lock. The "Screenshots" and "Session" home sections are
  removed; their pages are `CaptureView.qml` and `PowerView.qml`. Settings lists are
  two columns.
- Session 7: **polling.** `Stats` reads `/proc` only while the pill shows CPU, RAM or
  speed, or the island is open (2 s in the pill, 1 s with the island open).
  `Brightness` reads only with the island open. Don't add a background timer
  without a reason to be on screen.
- Session 8: **fastfetch is generated.** `matugen/templates/fastfetch.jsonc` renders
  to `~/.config/fastfetch/config.jsonc`, the same way cava's config does, so the
  `fastfetch/` repo folder is gone. The look: the small Arch mark and six lines
  (OS, uptime, WM, shell, RAM, battery), with the logo and keys in the accent colour
  and values in the text colour. No 16-colour test strip. The shell still runs it on
  each new kitty window (`.bashrc`). `a4a-palette` (the 16-colour strip) was also run there, and
  that was the colour spill; it now runs only by hand.
- Session 9: **the shell is zsh.** Login shell is `/usr/bin/zsh`. Config is the
  repo folder `zsh/` (linked to `~/.config/zsh`, where `ZDOTDIR` points), plus
  `zsh/zshenv` linked to `~/.zshenv`. Plugins are the official Arch packages
  (`zsh-autosuggestions`, `zsh-syntax-highlighting`), not oh-my-zsh: a framework
  would be the kind of bundle these rules keep out. The prompt is starship
  (`matugen/templates/starship.toml` -> `~/.config/starship.toml`). Plugin colours
  are generated too (`matugen/templates/zsh-colors.zsh` -> `~/.cache/a4a/`), and
  they're sourced after the plugins, since the styles are read when typing.
  fastfetch runs in new kitty windows from `.zshrc`. `.bashrc` is still there but
  no longer the login shell.
  kitty names the shell itself (`shell /usr/bin/zsh` in `kitty/kitty.conf`): it
  otherwise copies `$SHELL` from the environment it started with, so a running kitty
  kept starting bash after the login shell changed.
- Session 10: **wofi is generated.** `~/.config/wofi/config` and `style.css` come from
  `matugen/templates/wofi-config` and `wofi-style.css`, with the same palette roles as
  the bar (background, surface, outline, on-surface, primary). The launcher and the
  clipboard picker both use it.
- Session 11: **tray menu.** Right click opens `TrayMenu.qml` (a full-screen overlay
  shown only while a menu is open) under the icon. Submenus push onto a stack with a
  back row. Bind counts with `.values.length`: `SystemTray.items.count` doesn't
  update the bindings that depend on it.
- Session 12: **power modes.** Done with `powerprofilesctl` from power-profiles-daemon,
  not a Quickshell service (Quickshell 0.3 doesn't have one). The Mode card lives on
  the Power page. It reads the mode when the page opens, so nothing polls in the
  background.
- Session 13: **OSD.** Volume and brightness keys call `quickshell ipc call osd flash
  volume|brightness` after they change the level. The bar shows `OsdWindow` for 1.5 s.
  The IPC function is `flash`, not `show`: `quickshell ipc show` is a built-in
  subcommand, so a function named `show` can't be called.
- Session 14: **notification centre.** It reads dunst's history with `dunstctl history`
  (the JSON is a variant tree: `data[0]` holds the entries, each field is `{type, data}`),
  and Clear all runs `dunstctl history-clear`. dunst only adds to its history when a
  popup closes, which is why a brand-new notification isn't listed right away.
- Session 15: **fullscreen hides the bar.** The bar's `visible` is
  `!fullscreen || IslandState.open`. `FullscreenState.trueFullscreen` is state 2 only
  (SUPER+F), not state 1 (SUPER+M, maximised). It asks `hyprctl activewindow -j` on
  focus or fullscreen change. Quickshell's `lastIpcObject` doesn't refresh on those.
- Session 15: **updates.** The count comes from `checkupdates` (pacman-contrib),
  every 30 minutes, not on each island open (it takes ~15 s). The card is on the home
  page, and Update runs `sudo pacman -Syu` in a terminal that waits for Enter.
- Session 16: **night light.** hyprsunset (official repo), started with `-i` at login.
  `NightLight.qml` sets `hyprctl hyprsunset temperature 3500` in the 20:00-07:00 hours
  (only when its switch is on) and `identity` otherwise. `warmNow()` is a function on
  purpose: a property binding would read the clock once and never update.
- Session 3 (latest 9): **memory, graphics, scale, ML4W keys.**
  - RAM: zram swap (3.6 GB, zstd), swappiness 180, journal capped at 100 MB, in
    `system/` (install steps in `system/README.md`). Firefox limited through
    `user.js` in its profile (4 content processes, 64 MB cache), applied on its next start.
  - Graphics: `intel-media-driver` for hardware video decoding (`LIBVA_DRIVER_NAME=iHD`
    in `hypr/env.lua`), `vulkan-intel` for Vulkan.
  - Scale: the laptop panel is now 100%, not 150%.
  - Keys follow ML4W's defaults (read from its repo): SUPER+M maximize, SUPER+F
    fullscreen, SUPER+T float, SUPER+J split, SUPER+K swap split, SUPER+SHIFT+arrows
    resize, SUPER+ALT+arrows swap, SUPER+SHIFT+S scratchpad send, SUPER+Print full
    screenshot, SUPER+CTRL+K this list. Print is still a region screenshot.

- Session 21: **login screen is greetd + gtkgreet under cage.** The first attempt
  (session 20) ran gtkgreet with no compositor: it is a Wayland client, so it exited
  in about a second, greetd hit its start limit, and tty1 had no login. Fixes: cage
  wraps gtkgreet (`cage -s -- gtkgreet -c start-hyprland ...`), `-l` (layer shell) is
  dropped because cage doesn't support it, and tty2 is a password console that doesn't
  depend on greetd. Rejected: SDDM (Qt 6 and xorg-server, too heavy), ly (a text UI,
  not graphical), Hyprland or sway as the greeter compositor (ties login to the session's
  compositor). gtkgreet is an AUR package (greetd-gtkgreet), so an update can break it.
  Fallback: `system/getty/` (autologin override and restore steps).

- Session 23: **the bar's fullscreen check reads both fullscreen fields and re-checks on
  the `fullscreen` IPC event.** An app's own fullscreen request while the window is
  maximised (SUPER+M) leaves `fullscreen: 1` and sets `fullscreenClient: 2`, and it sends
  no focus or workspace change. Polling was rejected (CLAUDE.md: no polling unless
  something needs it); the event is enough.

- Session 24: **the island home page is tall enough for all its cards.** The panel scroll
  cap went from 430 to 1000 px, and the island window to 1100 px. The Updates card sat
  below the fold. Scrolling was the other option; the user chose the taller island.
- Session 24: **Qt theming removed** (QT_QPA_PLATFORMTHEME, plasma-integration, breeze, the
  KDE colour templates). The user doesn't use Qt or KDE apps.
- Session 25: **a BlueZ pairing agent runs at login (`scripts/a4a-bt-agent`).** Keyboards and
  mice failed to pair with "No agent available for request type 2": bluetoothd asks an agent
  to confirm or type a code, and Quickshell has no agent API. The agent accepts confirmation
  requests and shows the code in a notification, so it can be checked against the device. It
  does not ask the user first, which weakens the check against a man-in-the-middle. It
  answers PIN requests with 0000 and rejects passkey typing. The island now calls `pair()` on
  unpaired devices (`connect()` can't work on them) and trusts a device once it's paired, so
  it reconnects after sleep.
- Session 26: **btop and cava follow the wallpaper live, and workspaces match ML4W.**
  - btop never got the wallpaper colours: btop 1.4.7 ignores an absolute path in
    `color_theme` and only looks themes up by name. Now matugen writes
    `~/.config/btop/themes/a4a.theme` (gitignored) and `btop.conf` says `color_theme = "a4a"`.
    btop re-reads its theme on SIGUSR2 (tested on a pty: SIGUSR1 does not reload the
    theme). cava re-reads its colours on SIGUSR2 (cava's README). Both signals are sent by
    matugen's post hooks, with `|| true` for when they aren't running.
  - Workspaces follow ML4W's defaults (read from its repo): SUPER+scroll steps through the
    workspaces that exist (`e±1`), not empty ones. The Windows-style CTRL+arrows and the bar
    wheel use `e±1` too, which replaces the earlier `r±1` (session 3). Reaching a far
    workspace no longer means stepping: SUPER+G asks for a number (`scripts/a4a-workspace`,
    wofi prompt), and SUPER+SHIFT+G sends the window there. Hyprland accepts any number as
    a workspace id, so 98 works. The 1–10 keys stay as they are.

- Session 27 (2026-10-07): **quality pass — bar/island rebuild, enterprise Wi-Fi,
  Bluetooth pairing popup, keybinds, lock-wallpaper sync.** Studied snes19xx/surface-dots
  for layout ideas (information hierarchy: time/workspace loud, CPU/RAM quiet; one hover
  tint everywhere; depth from a hairline + soft shadow). Nothing copied; all written fresh.
  - **Bar hierarchy.** Clock is the loudest text; date and track dim; CPU/RAM small and
    quiet, turning accent only above 85%; battery accent at/below 20%. Wi-Fi is arcs
    (`WifiGlyph`), not the font's triangle-like glyph. Window title sits by the workspaces.
    Fixed-width digits so nothing jiggles. One `Hover` tint for every clickable thing.
  - **Two panels, open where you click.** The right pill grows into a control centre
    (system), the centre island keeps personal things. Before, everything opened from the
    middle, far from where it was clicked. Each page declares its panel
    (`IslandState.owner`); one open at a time; a page moves to its panel if asked from the
    other. `Morph` (pill→panel) and `PanelBody` (the page) are shared by both.
  - **Keyboard.** `HyprlandFocusGrab` routes keys to the open panel (the focus property
    alone didn't once the surface was up), so panels opened by a key take arrows/typing/Esc
    with no click. The bar window is now full screen height, so a background `MouseArea`
    dismisses on any outside click — the separate `OutsideClick` catcher is gone.
  - **Enterprise Wi-Fi (`scripts/a4a-wifi-join`).** Joins 802.1X/eduroam via NetworkManager
    D-Bus; the form (PEAP/TTLS/TLS, identity, password, domain) goes in on stdin, so the
    password is never in argv. Verified against UAF eduroam in range: strict TLS failed
    with OpenSSL 3 "unsupported protocol" (the server only offers TLS 1.0/1.1), so the
    script now retries with legacy TLS (`phase1-auth-flags` enable 1.0/1.1/1.2 +
    `openssl-ciphers=DEFAULT@SECLEVEL=0`) and the form has an "older campus security"
    toggle. With legacy on, the handshake completed to MSCHAPv2 and returned error 691
    (the test password was a stand-in). The profile keeps whatever connected, and secrets
    live in NetworkManager (root-only), so reconnect is automatic. Falls back to the old
    connection on failure, and deletes a profile it made that didn't connect.
  - **Bluetooth pairing (`scripts/a4a-bt-agent`).** Rewritten as a BlueZ agent that asks
    through the control centre's pairing card (`Pairing.qml`/`PairingView.qml`) over IPC —
    a Windows-11-style popup with the code shown large — and answers back on the session
    bus. Confirm, authorize, service, PIN, passkey and display-code are all handled; it
    never auto-accepts (the old agent did). Falls back to an actionable notification when
    the bar is down. A paired device is trusted so it reconnects itself.
  - **Keybinds.** Removed the SUPER+h/j/k/l focus binds that doubled up with split/swap/
    lock (SUPER+L had locked *and* moved focus). Focus is arrows only. Added ALT+Tab,
    SUPER+SHIFT+Q kill, SUPER+Y pin, SUPER+ALT+1–0 send-without-follow, CTRL+SUPER+SHIFT+←/→
    carry-window, CTRL+SUPER+D empty desktop, and the panel keys SUPER+A/N/X/W plus
    SUPER+CTRL+R restart-bar.
  - **Lock wallpaper sync.** `a4a-lock` refreshes `~/.cache/a4a/lock.jpg` from whatever
    awww is showing (JPEG, ~0.25 s vs ~1.1 s for the old PNG) before running hyprlock, so
    the lock screen always matches the desktop even when the wallpaper was set another way.
    The wallpaper picker previews live from cached screen-sized copies, reverts on Esc.
