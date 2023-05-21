local var = require("buffer.var")
local M   = {}


--- Close the current window or buffer
---@param type string `"buffer"|"window"`
M.close = function(type)
    require("buffer.close").deleteBufferOrWindow(type)
end


--- Reopen the last closed standard buffer
M.restoreClosedBuf = function()
    if var.lastClosedFilePath and vim.loop.fs_stat(var.lastClosedFilePath) then
        vim.cmd(string.format("e %s", var.lastClosedFilePath))
    end
end


-- TODO:
M.newSplit = function(...)
    require("buffer.newSplit").init(...)
end

return M

