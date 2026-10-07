# CLAUDE.md — A4A

Standing context for Claude Code. Keep this short: it loads every session.
- Roadmap and status: `PLAN.md`. Conventions for code: `SKILLS.md`.
- Why things are the way they are (history): `docs/decisions.md`.
- Keybinds: `docs/keybinds.md`.

## What this is

A4A is my personal Hyprland rice, at `~/Projects/A4A`. Published as a reference: no license yet.

- **Fully custom.** No ML4W, end-4, HyDE or any dotfile bundle. No oh-my-zsh.
  Every config and every line of QML is ours. Official packages are fine.
- **Minimal.** If it doesn't earn its place on screen, it goes. No "just in case" features.
- **No bloat.** Small dependency list; justify each new package. No background
  daemons or polling unless something on screen needs it.
- **Keyboard first**, mouse where natural.

## Machine

Arch Linux, Hyprland 0.56.2, Intel graphics, Quickshell 0.3.1, laptop (eDP-1, 100%).
Dual boot with Windows 11. Login shell zsh; terminal kitty.

## Rules

- **Hyprland config is Lua** (`hypr/`, symlinked to `~/.config/hypr`). Never write
  `.conf` syntax for Hyprland. Exception: `hyprlock` and `hypridle` read hyprlang
  `.conf` files, and they're started with an explicit `-c` path.
- **Check the Lua API against the running compositor:** `hyprctl repl '<lua>'`,
  `hyprctl getoption`. After any change: `hyprctl reload && hyprctl configerrors`
  must print nothing.
- **Colours come from the wallpaper.** Never hardcode a colour. Templates live in
  `matugen/templates/`, mapped in `matugen/config.toml`, rendered by
  `scripts/a4a-wallpaper`. Generated files aren't repo folders: they go to
  `~/.cache/a4a/` or straight to their `~/.config/` path (cava, dunst, fastfetch,
  starship, wofi, zsh colours).
- **Wallpapers are never committed.** Set them only with `a4a-wallpaper set|random`.
  Picker folder: `~/Pictures/Wallpapers`.
- **Repo folders** map 1:1 to `~/.config/<name>` and are symlinked by `install.sh`.
  Every new component goes in `install.sh` (packages and link). Configs are symlinked,
  never copied.
- **`install.sh` must stay idempotent** and never delete user files (it backs up).
- **Quickshell:** the singleton is `Theme`, never `Palette`. Every QML file goes in
  `quickshell/qmldir`. Import `Quickshell.Io` for `Process`/`FileView`. IPC functions
  can't be named `show` (reserved by `quickshell ipc`).
- **Two panels, each opens where its pill is.** The centre pill is the island
  (personal: clock, media, notifications, wallpaper, capture); the right pill grows
  into the control centre (system: Wi-Fi, Bluetooth, sound, brightness, power, system).
  Both are the `Morph` type over `PanelBody`. Which panel a page lives in is
  `IslandState.owner(view)`; one is open at a time; close only through
  `IslandState.close()`. Pollers run only while something on screen needs them
  (`docs/decisions.md`, session 7).
- **Bar window is full screen height when open**, so a click anywhere off a panel hits
  the background and closes it; the input mask keeps clicks to the pills while closed.
  Keyboard goes to the open panel via `HyprlandFocusGrab` (flipping the focus property
  alone doesn't route keys once the surface is up). No separate outside-click catcher.
- **Bar sizes:** pill 38px, Arch mark 22px, `edge` 6px (matches `gaps_out`). Bar hides
  only for true fullscreen (state 2), not maximise (state 1).
- **Shell:** zsh with official plugins, starship prompt. `.bashrc` and `.bash_profile`
  aren't used. kitty names `/usr/bin/zsh` itself.
- **Login is greetd + gtkgreet under cage** (see `system/greetd/README.md`), on tty1.
  `getty@tty2` is a password console for emergencies. The autologin fallback
  (`system/getty/`) is kept but disabled. Don't switch the login screen without the user
  asking in that session. Don't disable `getty@tty2`.
- **RAM matters.** One kitty process (`--single-instance`). `/tmp` is RAM: delete
  build leftovers after installs.
- **Testing:** test before committing, with real input where possible. `ydotool`
  needs `sudo ydotoold` (see `docs/testing.md`). Don't run `hyprlock` in tests: it
  locks the session. Don't click Log out, Restart, Shut down or Lock in tests.
- **Commits:** work on a branch, fast-forward `main`, push. Commit message ends with
  the `Co-Authored-By:` line for the model that did the work. Only commit when asked.
- **End of session:** update `PLAN.md` (status, roadmap) and add any new decision to
  `docs/decisions.md`. Keep this file short; only rules that still apply go here.
- **Wi-Fi:** WPA-PSK joins through Quickshell's Networking. Enterprise/802.1X (eduroam)
  goes through `scripts/a4a-wifi-join` (NetworkManager D-Bus; form on stdin, so the
  password is never on a command line). It tries normal TLS, then legacy TLS (some
  campus RADIUS servers only speak TLS 1.0, which OpenSSL 3 blocks). `nm-connection-editor`
  is the fallback for anything the form doesn't cover.
- **Bluetooth pairing** needs a BlueZ agent: `scripts/a4a-bt-agent` (at login). It asks
  through the control centre's pairing card (`Pairing.qml`, IPC `pairing`), and falls
  back to a notification when the bar is down. It never auto-accepts.
- **Lock screen** always shows the current wallpaper: `a4a-lock` refreshes
  `~/.cache/a4a/lock.jpg` from what awww is showing, then runs hyprlock. SUPER+L, the
  power page's Lock, and hypridle all go through `a4a-lock`.
- GTK 4 can't be themed from files here; GTK 3 can (`~/.config/gtk-3.0/gtk.css`). The GTK 3 file needs style rules, not only colour names.
- One app per job: file manager Thunar (SUPER+E), browser Firefox (SUPER+B). Brave and
  LibreWolf are also installed. Don't remove an app without asking.
- Use `/usr/bin/grep` in pipelines: the `grep` shim here is unreliable.
