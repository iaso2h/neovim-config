local cmd   = vim.cmd
local util  = {}
local theme = require('onenord.theme')
local ok, msg

-- Go trough the table and highlight the group with the color values
util.hi = function (group, color)
    if color.link then
        ok, msg = pcall(cmd, string.format([[highlight! link %s %s]], group, color.link))
    else
        local style = color.style and "gui="   .. color.style or "gui=NONE"
        local fg    = color.fg    and "guifg=" .. color.fg    or "guifg=NONE"
        local bg    = color.bg    and "guibg=" .. color.bg    or "guibg=NONE"
        local sp    = color.sp    and "guisp=" .. color.sp    or ""

        local hl = "highlight " .. group .. " " .. style .. " " .. fg .. " " .. bg .. " " .. sp

        ok, msg = pcall(cmd, hl)
    end

    if not ok then
        vim.notify("Error detect while setting " .. group, vim.log.levels.ERROR)
        vim.notify(msg, vim.log.levels.ERROR)
    end
end

-- Only define onenord if it's the active colorscheme
-- function util.onColorScheme()
    -- if vim.g.colors_name ~= "onenord" then
        -- cmd [[autocmd! onenord]]
        -- cmd [[augroup! onenord]]
    -- end
-- end

-- Change the background for the terminal, packer and qf windows
-- util.contrast = function ()
    -- cmd [[
    -- augroup onenord
    -- autocmd!
    -- autocmd ColorScheme *      lua      require("onenord.util").onColorScheme()
    -- autocmd TermOpen    *      setlocal winhighlight=Normal:NormalFloat,SignColumn:NormalFloat
    -- autocmd FileType    packer setlocal winhighlight=Normal:NormalFloat,SignColumn:NormalFloat
    -- autocmd FileType    qf     setlocal winhighlight=Normal:NormalFloat,SignColumn:NormalFloat
    -- augroup end
    -- ]]
-- end

-- Load the theme
function util.load()
    -- Set the theme environment
    cmd("hi clear")
    if vim.fn.exists("syntax_on") then cmd("syntax reset") end
    vim.g.colors_name   = "onenord"

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
    -- theme.loadTerminal()

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
end

return util
