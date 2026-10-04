hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Prefer native Wayland for Qt and Electron apps.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Intel graphics: video decoding runs on the GPU (VA-API, via intel-media-driver),
-- so playing video costs less CPU and less power.
hl.env("LIBVA_DRIVER_NAME", "iHD")
