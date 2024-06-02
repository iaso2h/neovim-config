local var  = require("buffer.var")
local u    = require("buffer.util")
local M    = {}


--- Close the current window or buffer
---@param type string `"buffer"|"window"`
M.close = function(type)
    require("buffer.close").deleteBufferOrWindow(type)
end


--- Reopen the last closed standard buffer
M.restoreClosedBuf = function()
    if next(var.lastClosedFilePaths) then
        local bufNrs = u.bufNrs(true)
        for index, path in ipairs(var.lastClosedFilePaths) do
            if vim.tbl_contains(bufNrs, vim.fn.bufnr(path)) then
                -- Skip buffer that is already opened
                table.remove(var.lastClosedFilePaths, index)
            else
                table.remove(var.lastClosedFilePaths, index)
                vim.cmd(string.format("e %s", path))
                return
            end
        end
    end
end


return M

