-- Unload lua modules
for _, m in ipairs { "onenord", "onenord.lua", "onenord.pallette",
    "onenord.theme", "onenord.util" } do
    if package.loaded[m] then
        package.loaded[m] = nil
    end
end
local util = require("onenord.util")
local theme = require('onenord.theme')
-- Set the theme environment
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
vim.g.colors_name = "onenord"

for group, colors in pairs(theme.editor) do
    util.hi(group, colors)
end
for group, colors in pairs(theme.syntax) do
    util.hi(group, colors)
end
for group, colors in pairs(theme.treesitter) do
    util.hi(group, colors)
end

-- TODO: check fn.has("termguicolors")
theme.loadTerminal()

for group, colors in pairs(theme.lsp) do
    util.hi(group, colors)
end
for group, colors in pairs(theme.plugins) do
    util.hi(group, colors)
end

-- if contrast is enabled, apply it to sidebars and floating windows
-- if vim.g.onenord_contrast == true then
    -- util.contrast()
-- end
