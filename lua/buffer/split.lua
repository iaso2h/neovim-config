local M = {}
local u = require("buffer.util")


local width
local height

if _G._os_uname.machine == "aarch64" then
    width  = 60
    height = 30
else
    width  = 117
    height = 52
end


--- Setting up the corresponding width and height number for Neovim
---@param opts table `{<width>, <height>}`
M.setup = function(opts)
    width, height = unpack(opts)
end


--- Return ex command for spliting Neovim windows
---@param prefixCmdChk boolean If the function resolve to vertical split solution. Whether to return `vertical` form ex command prefix or `vsplit` to split a window first
---@return string # Neovim ex-command string
-- TODO: avoid split on specifal buffer/filetype like nvim-tree
M.handler = function(prefixCmdChk)
    local vertCmd = prefixCmdChk and "vertical" or "vsplit"
    local horiCmd = prefixCmdChk and "horizontal" or "split"

    local layout = u.winLayout()
    if layout ~= "" and layout ~= "leaf" then
        if layout == "col" then
            return vertCmd
        else
        -- elseif layout == "row" then
            return horiCmd
        end
    else
        local ui = vim.api.nvim_list_uis()[1]
        local uiWidth  = ui.width
        local uiHeight = ui.height
        if uiWidth / uiHeight > width / height then
            return vertCmd
        else
            return horiCmd
        end
    end
end


return M
