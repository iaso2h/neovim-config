local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

-- File: terminalToggle.vim
-- Author: iaso2h
-- Description: Toggle terminal like VS Code does
-- Last Modified: 2021-05-03
-- Version: 0.0.4

--- Toggle terminal on split windows, support Winodows
--- and linux only
function M.terminalToggle() -- {{{
    local winTbl            = api.nvim_list_wins()
    local winNonRelativeTbl = vim.tbl_filter(function(winID) return vim.api.nvim_win_get_config(winID).relative == "" end, winTbl)
    local winCount          = #winNonRelativeTbl
    local winInfo           = fn.getwininfo()

    if vim.bo.buftype ~= "terminal" then
        require("buf").newSplit(require("terminal").openTerminal, {}, "^term.*", false, true)
    else
        if winCount == 1 then
            cmd [[bp]]
        elseif winCount == 2 then
            cmd [[noa wincmd w]]
            cmd [[only]]
        else
            cmd [[q]]
            -- Switch back last window if exists
            if not require("buf.var").newSplitLastBufNr then
                for _, tbl in winInfo do
                    if api.nvim_win_get_buf(tbl["winid"]) == vim.g.smartSplitLastBufNr then
                        cmd(string.format("%dwincmd w", tbl["winnr"]))
                    end
                end
            end
        end
    end
end -- }}}


--- Run terminal in a smart way
--- @param newBufNr integer Buffer number/handler
function M.openTerminal(newBufNr) -- {{{
    -- if no terminal found, run a new instance. If one or multiple terminal is
    -- found, the smallest buffer number, which is determined by bufnr(), will be
    -- invoke
    local termBufOutput = vim.api.nvim_exec("ls! R", true)
    if termBufOutput ~= "" then  -- Buffer instance exist
        local termBufInfo = vim.split(termBufOutput, "\n", true)[1]
        cmd("noa b " .. string.match(termBufInfo, "%d+"))
        cmd "startinsert"

        -- Clear the scratch buffer
        cmd("noa bwipe! " .. newBufNr)
    else                         -- Create new buffer instance
        if jit.os == "Windows" then
            cmd "terminal powershell"
        elseif jit.os == "Linux" then
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


