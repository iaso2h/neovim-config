local fn  = vim.fn
local M   = {}


--- Universally warp around getlocist() and getqflist()
---@vararg any
M.getlist = function(...)
    if vim.b._is_loc then
        return fn.getloclist(0, ...)
    else
        return fn.getqflist(...)
    end
end

return M
