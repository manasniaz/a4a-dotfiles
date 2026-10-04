local c = require("colors")

hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 6,
        border_size = 2,

        col = {
            active_border   = c.accent,
            inactive_border = c.muted,
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 8,
        rounding_power = 2,

        -- Blur only shows through translucent pixels. The active window is
        -- nearly opaque (light blur), inactive windows are see-through (clear blur).
        active_opacity   = 0.97,
        inactive_opacity = 0.86,

        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = c.shadow,
        },

        -- Kept light: this is an Intel iGPU.
        blur = {
            enabled = true,
            size    = 4,
            passes  = 2,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        background_color        = c.bg,
    },
})

-- Short and calm: fast in, faster out, no bounce.
hl.curve("out",    { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("linear", { type = "bezier", points = { {0, 0},    {1, 1}    } })

hl.animation({ leaf = "global",     enabled = true, speed = 6,   bezier = "out" })
-- Windows grow in and fade out at the same pace, and a resize or move glides
-- instead of snapping, so nothing looks random when it opens, closes or resizes.
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3.5, bezier = "out", style = "popin 92%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2.5, bezier = "out", style = "popin 92%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3.5, bezier = "out", style = "slide" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2.5, bezier = "out" })
hl.animation({ leaf = "border",     enabled = true, speed = 4,   bezier = "out" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3,   bezier = "out",    style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3,   bezier = "out",    style = "slide" })
