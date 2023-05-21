local fn  = vim.fn
local api = vim.api
local M   = {}

M.sep = _G._os_uname.sysname == "Windows_NT" and "\\" or "/"

--- Make the drive character uppercase
---@param fullPathStr string
---@return string
M.upperCaseWindowsDrive = function(fullPathStr) -- {{{
    if not string.sub(fullPathStr, 1, 1):match("[a-z]") then
        return fullPathStr
    end

    return string.sub(fullPathStr, 1, 1):upper() .. string.sub(fullPathStr, 2, -1)
end -- }}}
--- Get the tail string of a given path string.
--r.g: **/autoreload/util.lua -> util.lua; **/autoreload/myFolder/ -> myFolder
---@param fileStr string
---@return string # Tail of the file path
M.getTail = function(fileStr) -- {{{
    if fileStr:sub(-1, -1) == M.sep then
        fileStr = fileStr:sub(1, -2)
    end

    local idx = {string.find(fileStr, ".*()" .. M.sep)}
    if idx then
        return fileStr:sub(idx[2] + 1, -1)
    else
        return fileStr
    end
end -- }}}


return M
