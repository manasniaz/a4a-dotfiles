#!/usr/bin/env bash
# A4A installer. Safe to re-run: existing configs are moved to a timestamped
# backup, never deleted, and already-linked components are skipped.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_DIR="$HOME/.a4a-backup/$(date +%Y%m%d-%H%M%S)"

# Pacman packages the configs rely on. Grouped by the component that needs them.
PACKAGES=(
    # hypr
    hyprland xdg-desktop-portal-hyprland qt5-wayland qt6-wayland
    kitty firefox wireplumber brightnessctl playerctl
    # Browsers: firefox (SUPER+B), brave-bin (AUR, paru), and LibreWolf (Flatpak: flatpak install flathub io.gitlab.librewolf-community).
    # shell: zsh, its two plugins (autosuggestions, highlighting), and the prompt
    zsh zsh-autosuggestions zsh-syntax-highlighting starship
    wofi cliphist wl-clipboard
    # swww was renamed to awww upstream; the package is now awww.
    awww
    # palette generated from the wallpaper
    matugen
    # a4a-vibe decodes the wallpaper (it runs ffmpeg)
    ffmpeg
    # screenshots: capture, region select, annotate (a4a-screenshot)
    grim slurp satty
    # quickshell: the bar. Framework only, every widget is ours.
    # upower feeds the battery widget.
    quickshell upower
    # wifi and bluetooth come from NetworkManager and bluez (the island controls them)
    networkmanager bluez bluez-utils
    # terminal: the emulator, the monitors and the system info tool
    cava btop fastfetch
    # power modes: power-profiles-daemon runs the modes, powerprofilesctl sets them
    power-profiles-daemon
    # notifications: the daemon, and notify-send for testing it
    dunst libnotify
    # lock and idle: the lock screen, and the daemon that locks, dims and suspends
    hyprlock hypridle
    # login screen: greetd runs gtkgreet, and cage is the compositor it runs in.
    # greetd-gtkgreet is an AUR package (install by hand or with paru).
    greetd cage greetd-gtkgreet
)

# Repo folder -> $CONFIG_DIR/<same name>.
COMPONENTS=(
    hypr
    hyprlock
    hypridle
    matugen
    quickshell
    kitty
    btop
    zsh
)

# Repo scripts -> $BIN_DIR/<same name>.
BIN_DIR="$HOME/.local/bin"
SCRIPTS=(
    a4a-wallpaper
    a4a-vibe
    a4a-screenshot
    a4a-palette
    a4a-greeter
    a4a-bt-agent
    a4a-workspace
)

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }

check_deps() {
    local missing=()
    for pkg in "${PACKAGES[@]}"; do
        pacman -Qq "$pkg" &>/dev/null || missing+=("$pkg")
    done
    if ((${#missing[@]})); then
        warn "Missing packages: ${missing[*]}"
        warn "Install with: sudo pacman -S --needed ${missing[*]}"
    else
        info "All dependencies installed."
    fi
}

# link_path <repo-relative source> <absolute destination>
link_path() {
    local src="$REPO_DIR/$1" dst="$2"

    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
        info "$dst already linked"
        return
    fi

    if [[ -e "$dst" || -L "$dst" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        info "Backed up $dst -> $BACKUP_DIR/"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    info "Linked $dst -> $src"
}

main() {
    check_deps
    for comp in "${COMPONENTS[@]}"; do
        link_path "$comp" "$CONFIG_DIR/$comp"
    done
    # ~/.zshenv only points zsh at the config folder, so it is a single file link.
    link_path "zsh/zshenv" "$HOME/.zshenv"
    for script in "${SCRIPTS[@]}"; do
        link_path "scripts/$script" "$BIN_DIR/$script"
    done
    if grep -q YOUR_USER "$REPO_DIR/btop/btop.conf"; then
        info "Set your user name in btop/btop.conf (replace YOUR_USER), then restart btop."
    fi
    info "Done."
}

main "$@"
