-- Apps don't get to maximize themselves; layout decides.
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fixes dragging glitches with some XWayland popups.
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Browser picture-in-picture (LibreWolf, Brave): float and stay on top.
hl.window_rule({
    name  = "browser-pip",
    match = { title = "^Picture-in-Picture$" },
    float = true,
    pin   = true,
})

-- The screenshot editor floats in the middle at a fixed size, like the Windows
-- snipping tool: big enough to annotate, never filling the screen.
hl.window_rule({
    name   = "screenshot-editor",
    match  = { class = "^com\\.gabm\\.satty$" },
    float  = true,
    center = true,
    size   = { 1100, 720 },
})

-- File pickers and similar dialogs float.
hl.window_rule({
    name  = "float-dialogs",
    match = { title = "^(Open File|Save As|Open Folder|File Upload).*" },
    float = true,
})
