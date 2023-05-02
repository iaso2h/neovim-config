local var = require("buffer.var")
local M   = {}


M.close = function(type)
    require("buffer..close").init(type)
end


M.closeOther = function ()
    require("buffer..closeOther").init()
end


M.restoreClosedBuf = function()
    if var.lastClosedFilePath then
        vim.cmd(string.format("e %s", var.lastClosedFilePath))
    end
end


M.newSplit = function(...)
    require("buffer..newSplit").init(...)
end

return M

