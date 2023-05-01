local var = require("buffer.var")
local M   = {}


M.close = function(type)
    require("buffer.action.close").init(type)
end


M.closeOther = function ()
    require("buffer.action.closeOther").init()
end


M.restoreClosedBuf = function()
    if var.lastClosedFilePath then
        vim.cmd(string.format("e %s", var.lastClosedFilePath))
    end
end


M.newSplit = function(...)
    require("buffer.action.newSplit").init(...)
end

return M

