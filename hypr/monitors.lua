-- Laptop panel: 1920x1200 at 100%, so 1 logical pixel is 1 physical pixel.
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "0x0",
    scale    = 1,
})

-- Anything else that gets plugged in.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- Stop XWayland apps rendering blurry under fractional scaling.
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
