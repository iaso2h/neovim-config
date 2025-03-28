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
        vim.api.nvim_echo({{"Error detected while setting highlight for " .. groupName,}}, true, {err=true})
        vim.api.nvim_echo({{msgOrVal,}}, true, {err=true})
    end
end

return M
