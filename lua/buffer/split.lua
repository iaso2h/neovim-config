-- File: buffer.split
-- Author: iaso2h
-- Description: Split a buffer by its layout
-- Version: 0.0.1
-- Last Modified: 2023-08-29

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
M.handler = function(prefixCmdChk)
    local vertCmd = prefixCmdChk and "vertical" or "vsplit"
    local horiCmd = prefixCmdChk and "horizontal" or "split"

    -- Get layout from nonspecial buffer
    local layout
    if u.isSpecialBuf(vim.api.nvim_get_current_buf()) then
        local bufNrs = u.bufNrs(true, false)
        if #bufNrs ~= 0 then
            local altBufNr = vim.fn.bufnr("#")
            if vim.list_contains(bufNrs, altBufNr) then
                local altBufWinId = vim.fn.bufwinid(altBufNr)
                layout = u.winLayout(altBufWinId)
                vim.api.nvim_set_current_win(altBufWinId)
            end
        else
            -- Fallback method
            layout = u.winLayout()
        end
    else
        layout = u.winLayout()
    end

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
