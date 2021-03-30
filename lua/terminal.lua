local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

-- File: terminalToggle.vim
-- Author: iaso2h
-- Description: Toggle terminal like VS Code
-- Last Modified: 2021-03-23
-- Version: 0.0.3

----
-- Function: TerminalToggle Toggle terminal on split windows, support Winodows
-- and linux only
-- Return: 0
----

function M.terminalToggle() -- {{{
    local winCount = fn.winnr("$")
    local winInfo = fn.getwininfo()
    if vim.bo.buftype ~= "terminal" then
        require("util").newSplit(require("terminal").openTerminal, {}, "^term.*", false, true)
    else
        if winCount == 1 then
            cmd [[bp]]
        elseif winCount == 2 then
            cmd [[wincmd w]]
            cmd [[only]]
        else
            cmd [[q]]
            -- Switch back last window if exists
            if not require("util").newSplitLastBufNr then
                for _, tbl in winInfo do
                    if api.nvim_win_get_buf(tbl["winid"]) == vim.g.smartSplitLastBufNr then
                        cmd(string.format("%dwincmd w", tbl["winnr"]))
                    end
                end
            end
        end
    end
end -- }}}


----
-- Function: openTerminal Run terminal in a smart way
-- Return: if no terminal found, run a new instance. If one or multiple terminal is
-- found, the smallest buffer number, which is determined by bufnr(), will be
-- invoke
----
function M.openTerminal(newBufNr) -- {{{
    local termBufOutput = vim.api.nvim_exec("ls! R", true)
    if termBufOutput ~= "" then  -- Buffer instance exist
        local termBufInfo = vim.split(termBufOutput, "\n", true)[1]
        cmd("b " .. string.match(termBufInfo, "%d+"))
        cmd "startinsert"
        -- Clear the scratch buffer
        cmd("bwipe! " .. newBufNr)
    else                         -- Create new buffer instance
        if fn.has("win32") then
            cmd "terminal powershell"
        elseif fn.has("unix") then
            cmd "terminal"
        end
    end
end -- }}}

return M

-- let l:winInfo =
-- [{'botline': 91,
-- 'bufnr': 10,
-- 'height': 44,
-- 'loclist': 0,
-- 'quickfix': 0,
-- 'tabnr': 1,
-- 'terminal': 0,
-- 'topline': 47,
-- 'variables':
-- 'width': 143,
-- 'winbar': 0,
-- 'wincol': 1,
-- 'winid': 1000,
-- 'winnr': 1,
-- 'winrow': 2},

-- {'botline': 53,
-- 'bufnr': 10,
-- 'height': 29,
-- 'loclist': 0,
-- 'quickfix': 0,
-- 'tabnr': 1,
-- 'terminal': 0,
-- 'topline': 2,
-- 'variables':
-- 'width': 88,
-- 'winbar': 0,
-- 'wincol': 145,
-- 'winid': 1430,
-- 'winnr': 2,
-- 'winrow': 2},

-- {'botline': 48,
-- 'bufnr': 10,
-- 'height': 14,
-- 'loclist': 0,
-- 'quickfix': 0,
-- 'tabnr': 1,
-- 'terminal': 0,
-- 'topline': 11,
-- 'variables':
-- 'width': 88,
-- 'winbar': 0,
-- 'wincol': 145,
-- 'winid': 1431,
-- 'winnr': 3,
-- 'winrow': 32}]


