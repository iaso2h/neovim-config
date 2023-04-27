local M   = {}
local ok, msg

-- Go trough the table and highlight the group with the color values
M.hi = function (group, color)
    if color.link then
        ok, msg = pcall(vim.api.nvim_command, string.format([[highlight! link %s %s]], group, color.link))
    else
        local style = color.style and "gui="   .. color.style or "gui=NONE"
        local fg    = color.fg    and "guifg=" .. color.fg    or "guifg=NONE"
        local bg    = color.bg    and "guibg=" .. color.bg    or "guibg=NONE"
        local sp    = color.sp    and "guisp=" .. color.sp    or ""

        local hl = string.format("highlight %s %s %s %s %s", group, style, fg, bg, sp)

        ok, msg = pcall(vim.api.nvim_command, hl)
    end

    if not ok then
        vim.notify("Error detect while setting " .. group, vim.log.levels.ERROR)
        vim.notify(msg, vim.log.levels.ERROR)
    end
end

-- Only define onenord if it's the active colorscheme
-- function M.onColorScheme()
    -- if vim.g.colors_name ~= "onenord" then
        -- cmd [[autocmd! onenord]]
        -- cmd [[augroup! onenord]]
    -- end
-- end

-- Change the background for the terminal, packer and qf windows
-- M.contrast = function ()
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

return M
