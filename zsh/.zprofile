# ~/.config/zsh/.zprofile: read by zsh for login shells (ZDOTDIR is set in zshenv).
# The login screen (greetd) logs the user in on tty1; start Hyprland there. Only on the first login on
# tty1, never inside an existing graphical session or over SSH.
if [[ -z $WAYLAND_DISPLAY && -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
    exec start-hyprland
fi
