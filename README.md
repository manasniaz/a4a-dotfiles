# A4A

My Hyprland dotfiles. Arch Linux, built from scratch, no pre-made bundles.
Minimal, clean, keyboard-driven.

Each top-level folder (`hypr/`, `quickshell/`, …) is a config dir that gets
symlinked into `~/.config/`, so editing files here edits the live config.

## Reinstalling

On this machine or a fresh Arch install:

```sh
# get the repo onto the machine (copy the folder, or git clone if versioned)
cd ~/Projects/A4A
./install.sh
```

`install.sh` lists missing packages, moves any existing conflicting configs to
`~/.a4a-backup/<timestamp>/`, and symlinks everything into `~/.config/`.
Re-running it is safe.

## Setting up another laptop

1. A fresh Arch install with a user account, and `git` and `base-devel`.
2. Get the repo: `git clone https://github.com/manasniaz/a4a-dotfiles.git ~/Projects/A4A`
   Clone to exactly `~/Projects/A4A`: the keybind list (CTRL+K) and the docs use that path.
3. Install the AUR package the login screen needs, with paru (or any AUR helper):
   `paru -S greetd-gtkgreet`
4. Run `./install.sh`. It installs the packages and links the configs.
5. Set a wallpaper. The repo doesn't include any: `a4a-wallpaper set <image>` makes the
   colours, and `a4a-wallpaper random` picks from `~/Pictures/Wallpapers`.
6. Root-only steps, by hand: `system/README.md` (memory and journal settings), and
   `system/greetd/README.md` (the login screen).

Things to check on the new machine:
- `btop/btop.conf` names its theme (`color_theme = "a4a"`); matugen writes that theme
  into `~/.config/btop/themes/`, so it's the same on any machine. Nothing to change.
- `hypr/monitors.lua` names the built-in panel `eDP-1`. Other screens use the fallback rule.
- The getty fallback in `system/getty/` has a placeholder (`YOUR_USER`) for the user name.
  Replace it with yours if you ever enable it. It's disabled by default and isn't needed
  for the login screen.

## Notes

- Hyprland config is `hyprland.lua` (Lua), not `hyprland.conf`.
- Keybinds and other details go in `docs/`.
- Progress and next steps: `PLAN.md`.
