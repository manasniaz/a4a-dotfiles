-- Mouse and touchpad, set to match Windows 11.

hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,

        -- Pointer speed in the middle, with acceleration on, like Windows' default.
        sensitivity  = 0,
        accel_profile = "adaptive",

        touchpad = {
            -- Scroll the way the content moves, as Windows does on a touchpad.
            natural_scroll       = true,
            -- 1 finger: left click. 2 fingers: right click. 3 fingers: middle click.
            tap_button_map       = "lrm",
            -- Don't register stray touches while typing.
            disable_while_typing = true,
            scroll_factor        = 1.0,
        },
    },
})

-- Four-finger swipe changes desktop, the way Windows 11 does.
hl.gesture({
    fingers   = 4,
    direction = "horizontal",
    action    = "workspace",
})

-- Three-finger swipe switches between open windows: left goes to the next one,
-- right to the previous one.
hl.gesture({
    fingers   = 3,
    direction = "left",
    action    = function() hl.dispatch(hl.dsp.window.cycle_next("next")) end,
})
hl.gesture({
    fingers   = 3,
    direction = "right",
    action    = function() hl.dispatch(hl.dsp.window.cycle_next("prev")) end,
})
