# Autologin fallback (getty@tty1)

`autologin-override.conf` is the working autologin setup: getty logs YOUR_USER in on tty1
without a password, then `zsh/.zprofile` starts Hyprland. It's the fallback for the
greetd login screen (see `system/greetd/README.md`).

It is not active while greetd is enabled. To restore it:

    sudo systemctl disable greetd
    sudo install -D -m644 ~/Projects/A4A/system/getty/autologin-override.conf \
        /etc/systemd/system/getty@tty1.service.d/override.conf
    sudo systemctl daemon-reload
    sudo systemctl enable getty@tty1

Reboot after that. Note that `getty@tty2` is enabled as a password console, so a broken
tty1 can always be reached with Ctrl+Alt+F2.
