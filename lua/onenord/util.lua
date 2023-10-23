local M   = {}

--- Go trough the table and highlight the group with the color values
---@class colors
---@field link string
---@field style string
---@field fg string
---@field bg string
---@field sp string
---@param groupName string
---@param opts table Highlight definition options
M.hi = function (groupName, opts)
    opts.default = false
    local ok, msgOrVal = pcall(vim.api.nvim_set_hl, 0, groupName, opts)
    if not ok then
        vim.notify("Error detected while setting highlight for " .. groupName, vim.log.levels.ERROR)
        vim.notify(msgOrVal, vim.log.levels.ERROR)
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
