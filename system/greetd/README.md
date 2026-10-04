# Login screen (greetd + gtkgreet under cage)

greetd runs a graphical login box on tty1: `cage` is a minimal Wayland compositor,
`gtkgreet` is the login UI styled from the wallpaper palette (`matugen/templates/gtkgreet.css`),
and after a successful login it starts `start-hyprland`.

## Files

- `system/greetd/config.toml` → `/etc/greetd/config.toml`
- `gtkgreet.css` and `wallpaper.png` → `/etc/greetd/` (copied by `scripts/a4a-greeter`)
- Packages: `cage` (official), `greetd` (official), `greetd-gtkgreet` (AUR, installed by hand)

Refresh the copied files after a wallpaper change: `./scripts/a4a-greeter`, then reboot.

## Why it works now

The first attempt ran `gtkgreet` with no compositor around it. gtkgreet is a Wayland
client, so it exited within a second, greetd gave up after a few restarts, and tty1 had
no login at all (autologin was already removed). This config wraps gtkgreet in cage and
drops `-l` (layer shell, which cage doesn't support).

## Emergency: if the login screen fails

tty2 is a normal password login (`getty@tty2`, enabled), independent of greetd.
Press Ctrl+Alt+F2, log in with your password, then:

    sudo systemctl disable greetd
    sudo systemctl enable getty@tty1

That restores autologin on the next boot (see `system/getty/README.md`).
