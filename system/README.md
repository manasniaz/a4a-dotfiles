# System files

Copied into `/etc` once, by hand (they need root):

    sudo install -m 644 system/zram-generator.conf /etc/systemd/zram-generator.conf
    sudo install -m 644 system/99-a4a-memory.conf /etc/sysctl.d/99-a4a-memory.conf
    sudo install -d /etc/systemd/journald.conf.d
    sudo install -m 644 system/journald-a4a.conf /etc/systemd/journald.conf.d/a4a.conf
    sudo systemctl daemon-reload && sudo systemctl start systemd-zram-setup@zram0.service
    sudo sysctl --system && sudo systemctl restart systemd-journald

Packages: `zram-generator`, `intel-media-driver`, `vulkan-intel` (see install.sh).
