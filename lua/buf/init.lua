local var = require("buf.var")
local M   = {}


M.close = function(type)
    require("buf.action.close").init(type)
end


M.closeOther = function ()
    require("buf.action.closeOther").init()
end


M.restoreClosedBuf = function()
    if var.lastClosedFilePath then
        vim.cmd(string.format("e %s", var.lastClosedFilePath))
    end
end


M.newSplit = function(...)
    require("buf.action.newSplit").init(...)
end

return M

