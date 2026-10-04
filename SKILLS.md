# SKILLS.md — A4A conventions

Patterns and rules specific to this project. Add to this as decisions are made.

## Sourcing

- **No pre-made dotfile bundles ever get copied in.** No ML4W, end-4, HyDE,
  JaKooLit, or snippets lifted from them. Reading upstream docs is fine; pasting
  someone else's rice is not.
- **Quickshell is used as a framework only.** All QML is written from scratch —
  no starter shells, no copied widget sets.
- **All config is written from scratch** for every component.

## Hyprland

- Config is **Lua** (`hyprland.lua`). Never write `hyprland.conf` syntax.
- `hyprland.lua` is only a list of `require()`s. One module per concern:
  `monitors`, `env`, `look`, `input`, `binds`, `rules`, `autostart`.
- Colors come from the wallpaper-generated palette, read through
  `hypr/colors.lua` (which points at `~/.cache/a4a/colors.lua`). Never hardcode a
  color in any module. Every component reads the same generated file.
- To add a component to the theme, add a template under `matugen/templates/`
  and a matching entry in `matugen/config.toml`. Do not hand-write its colors.
- New autostart programs go in the `programs` list in `autostart.lua`
  (runs once at login, not on reload).
- Every bind change is mirrored in `docs/keybinds.md`.
- Verify new dispatchers/options against the live API (see CLAUDE.md) before
  relying on them.

- The QML singleton is named `Theme`, not `Palette`: QtQuick already has a
  built-in `Palette` type, and the name silently resolves to it instead.
- `quickshell/qmldir` must list every component file, not only the singleton.
  Once a qmldir exists, files in the folder are not visible to each other
  unless they are listed.

- Quickshell's `PanelWindow.mask` takes a `Region` with child `Region`s as a
  union (`Region { Region { item: a } Region { item: b } }`). Use it when a
  window is taller than its visible content, so the empty area doesn't take clicks.
- A layer-shell window with `WlrKeyboardFocus.Exclusive` swallowed pointer
  clicks meant for the bar, even though the bar was on a higher layer. Use
  `OnDemand`. Escape still closes the island after a click on the bar.
- Quickshell's item-based `Region` kept the island's closed size, so clicks on
  the open panel missed. Explicit `Region { x; y; width; height }` didn't fix
  it either. The working fix is a full-window region while the island is open.
- Layer surfaces stack by the `WlrLayershell.layer` they request. The catcher
  must start below the bar's whole window (`margins.top = barSpan`), or it can
  still take clicks from the panel.
- Pills pass clicks through (mask); when the island opens the mask covers the
  whole window, and the catcher closes it on clicks below the window.
- Pills use an opaque colour (`Theme.pill` = surface). A see-through pill lets
  the text of windows behind it show through.

## Layout

- One top-level folder per component, mirroring `~/.config/<name>/`.
- Configs are deployed by symlink via `install.sh` — never copied.
- Anything the user must customise per machine (monitor names, etc.) is kept in
  one clearly marked place.

## Style

- Minimal, clean, consistent palette across all components.
- Comment the *why*, not the *what*.
- Prefer fewer dependencies; justify each new package in PLAN.md/CLAUDE.md.

## install.sh

- Must be safe to re-run (idempotent).
- Never deletes user files — conflicts are moved to a timestamped backup dir.
- Every new component adds its packages and symlink entry here.
