-- File: changeUnder.lua
-- Author: iaso2h
-- Description: Change word under cursor
-- Version: 0.0.4
-- Last Modified: 2023-06-03
local M = {
    dev = false,
    pattern = nil,
}

--- Get the last search pattern string
---@return string
local getLastPattern = function()
    local searchCmdRaw = vim.api.nvim_exec2("history search", {output = true}).output
    local searchRaw = vim.split(searchCmdRaw, "\n", {plain = true})
    if not next(searchRaw) then
        return ""
    end
    local parseResult = { string.match(searchRaw[#searchRaw], "^>?%s*(%d+)%s+(.*)$") }
    return parseResult[2]
end


--- Change the whole word under cursor, highlight it with search highlight
---@param keybinding string The command to be performed in normal mode(Always no remap mode)
---@param direction integer 1 indicates searching forward, -1 indicates searching backward
---@param plugMap string The plug mapping to bind with when press dot-repeat key
M.init = function(keybinding, direction, plugMap) -- {{{
    local searchCMD = direction == 1 and "*" or "#"
    if vim.v.hlsearch == 1 then
        -- Highlight mode is on

        local curLine = vim.api.nvim_get_current_line()
        if #curLine == 0 then
            vim.cmd("norm! n")
            vim.cmd(string.format("norm %s", keybinding))
            if vim.fn.exists("g:loaded_repeat") == 1 then
                vim.fn["repeat#set"](t(plugMap))
            end
            return
        end

        -- Fix pattern
        local lastPattern = getLastPattern()
        if lastPattern == "" then return end

        if not M.pattern or lastPattern ~= M.pattern then
            if M.dev then
                logBuf("Last pattern: " .. lastPattern)
                logBuf("M.pattern: " .. M.pattern)
            end
            M.pattern = lastPattern
        end
        local regex = vim.regex(M.pattern)
        if not regex then return end

        -- Check whether pattern is in current line
        local result = {regex:match_str(curLine)} -- 0-indexed
        if not next(result) then
            vim.cmd("norm! n")
            vim.cmd(string.format("norm %s", keybinding))
        else
            local col = vim.api.nvim_win_get_cursor(0)[2] -- 0-indexed
            if col >= result[1] and col < result[2] then
                -- Cursor is within the region of the string that match the pattern
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
