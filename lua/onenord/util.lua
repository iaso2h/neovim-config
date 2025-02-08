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

return M
