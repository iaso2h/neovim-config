-- File: changeUnder.lua
-- Author: iaso2h
-- Description: Change word under cursor
-- Version: 0.0.3
-- Last Modified: 2023-3-6
local M   = {
    pattern = nil,
}


--- Change the whole word under cursor, highlight it with search highlight
---@param keybinding string The command to be performed in normal mode(Always no remap mode)
---@param direction integer 1 indicates searching forward, -1 indicates searching backward
---@param plugMap string The plug mapping to bind with when press dot-repeat key
M.init = function(keybinding, direction, plugMap) -- {{{
    local searchCMD = direction == 1 and "*" or "#"
    if vim.v.hlsearch == 1 then
        local curLine = vim.api.nvim_get_current_line()
        if #curLine == 0 then
            vim.cmd("norm! n")
            vim.cmd(string.format("norm %s", keybinding))
            if vim.fn.exists("g:loaded_repeat") == 1 then
                vim.fn["repeat#set"](t(plugMap))
            end
            return
        end

        -- col and result are both 0-indexed
        local col = vim.api.nvim_win_get_cursor(0)[2]

        local regex = vim.regex(M.pattern)
        local result = {regex:match_str(curLine)}
        if not next(result) then
            vim.cmd("norm! n")
            vim.cmd(string.format("norm %s", keybinding))
        else
            if col >= result[1] and col < result[2] then
                vim.cmd(string.format("norm %s", keybinding))
            else
                vim.cmd("norm! n")
                vim.cmd(string.format("norm %s", keybinding))
            end
        end
    else
        M.pattern = vim.fn.expand("<cword>")
        vim.cmd(string.format("norm! %s``", searchCMD))
        vim.cmd(string.format("norm %s", keybinding))
    end

    if vim.fn.exists("g:loaded_repeat") == 1 then
        vim.fn["repeat#set"](t(plugMap))
    end
end -- }}}


return M
