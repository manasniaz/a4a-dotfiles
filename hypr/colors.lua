-- Palette, read from the wallpaper. matugen writes the generated file (see
-- matugen/ and scripts/a4a-wallpaper); the values below are only the fallback
-- for before the first generation. Other components read the same file.

local generated = os.getenv("HOME") .. "/.cache/a4a/colors.lua"
local ok, palette = pcall(dofile, generated)
if ok then
    return palette
end

return {
    bg       = "rgba(111111ff)",
    surface  = "rgba(1c1c1cff)",
    muted    = "rgba(3a3a3aff)",
    fg       = "rgba(d4d4d4ff)",
    accent   = "rgba(8aa1b1ff)",
    shadow   = "rgba(00000066)",
}
