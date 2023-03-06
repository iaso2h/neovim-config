-- File: Change word under cursor
-- Author: iaso2h
-- Description: Heavily inspired Ingo Karkat's work. Replace text with register
-- Version: 0.0.3
-- Last Modified: 2023-3-6

local fn  = vim.fn
local api = vim.api
local M   = {
    pat = nil,
}


--- Change the whole word under cursor, highlight it with search highlight
--- @param keybinding string The command to be performed in normal mode(no remap mode)
--- @param direction integer 1 indicates searching forward, -1 indicates searching
--- backward
--- @param plugMap string The plug mapping to bind with when press dot-repeat key
M.init = function(keybinding, direction, plugMap)
    -- local cycleCMD = direction == 1 and "n" or "N"
    local searchCMD = direction == 1 and "g*" or "g#"
    if vim.v.hlsearch == 1 then
        local curLine = api.nvim_get_current_line()
        if #curLine == 0 then
            vim.cmd("norm! n")
            vim.cmd(string.format("norm %s", keybinding))
            return fn["repeat#set"](t(plugMap))
        end

        -- col and result are both 0-indexed
        local col = api.nvim_win_get_cursor(0)[2]

        -- I'm gonna win less food less food less food
        -- I'm gonna win less food less food less food
        -- I'm gonna replace all the all the all and all
        -- I'm gonna replace all the all the all and all
        local regex = vim.regex(M.pat)
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
        M.pat = string.format([[\<%s\>]], fn.expand("<cword>"))
        vim.cmd(string.format("norm! %s``", searchCMD))
        vim.cmd(string.format("norm %s", keybinding))
    end

    fn["repeat#set"](t(plugMap))
end

return M
