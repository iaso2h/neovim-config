-- File: smartClose.lua
-- Author: iaso2h
-- Description: Close window safely and wipe buffer without modifying the layout
-- Version: 0.0.9
-- Last Modified: 2021-03-23
-- TODO: Q on qf not working well
-- TODO: q on coc showouput not working well
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local vim = vim
local util = require("util")
local M = {}
local curBufName
local curBufNr
local curBufType
local curWinID
local winIDTbl
local winIDBufNrTbl
local bufNrTbl


----
-- Function: saveModified: Check buffer modification and ask save
--
-- @param bufNr: buffer number(buffer handler)
-- @return: always return except that "cancel" is input
----
local function saveModified(bufNr) -- {{{
    if not api.nvim_buf_is_valid(bufNr) then return true end
    if api.nvim_buf_get_option(bufNr, "modified") then
        cmd "echohl MoreMsg"
        local answer = fn.confirm("Save modification?",
                                  ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        cmd "echohl None"
        if answer == 1 then
            cmd "update"
            return true
        elseif answer == 2 then
            return true
        else
            return false
        end
    else
        return true
    end
end -- }}}


-- Function: bwipe :perform a bufferline update for barbar.nvim after the origin vim bwipe
--
-- @param bufNr: bufNr, same as the origin vim bwipe
----
local function bwipe(bufNr)
    if bufNr then
        cmd("bwipe! " .. bufNr)
    else
        cmd "bwipe!"
    end
    if fn.exists("g:bufferline") == 1 then
        fn['bufferline#update']()
    end
end


----
-- Function: wipeBuf: Wipe buffer on all windows
--
-- @param checkBuftype: check if current buffer is special buffer or a standard
-- buffer. If false is provided, then the current buffer is considered as a standard_
-- buffer
-- @return: 0
----
local function wipeBuf(checkBuftype) -- {{{
    -- Wipe unlisted buffer
    if not vim.tbl_contains(bufNrTbl, curBufNr) then
        bwipe()
        return
    end
    -- Check if it's called from a special buffer
    if curBufType ~= "" then
        -- Special buffer {{{
        cmd "q"
        -- }}} Special buffer
    else
        -- Standard buffer {{{
        if not vim.bo.modifiable then return end
        -- Return when false is evaluated
        if not saveModified(curBufNr) then return end
        if #winIDTbl == 1 then -- 1 Window
            bwipe(curBufNr)
        else -- 1+ Windows
            winIDBufNrTbl = {}
            local bufInstance = 0
            -- Create table with all different window ID as key, buffer number as value
            for idx, win in ipairs(winIDTbl) do
                winIDBufNrTbl[win] = api.nvim_win_get_buf(win)
            end
            -- Loop through winIDBufNrTbl to check other window contain the same
            -- buffer number(buffer handler) as the on we are going to wipe
            for winID, bufNr in pairs(winIDBufNrTbl) do
                if vim.bo.buftype == "" then
                    bufInstance = bufInstance + 1
                end
                if bufNr == curBufNr then
                    api.nvim_set_current_win(winID)
                    local altBuf = fn.bufnr("#")
                    -- Switch to alternative buffer whenever it's available
                    if altBuf > 0 and vim.tbl_contains(bufNrTbl, altBuf) then
                        api.nvim_win_set_buf(winID, altBuf)
                    else
                        cmd "bprevious"
                    end
                end
            end
            -- Restore window focus
            api.nvim_set_current_win(curWinID)
            bwipe(curBufNr)
            -- Merge when there are two windows sharing the last buffer
            -- Note: eif this evaluated to true, then the current length of bufNrtble
            -- has been reduced to 1, #bufNrTbl is just a value of previous state
            if #winIDTbl == 2 and bufInstance == #winIDTbl and #bufNrTbl == 2 then
                cmd "only"
            end
        end
        -- After finishing buffer wipe, prevent the next buffer revealed in current window is set to quickfix list and terminal
        if #bufNrTbl - 1 > 2 then
            local unwantedBufType = {"quickfix", "terminal"}
            if vim.tbl_contains(unwantedBufType, vim.bo.buftype) then cmd "bp" end
        end
        -- }}} Standard buffer
    end
end -- }}}

function M.main(type) -- {{{
    curBufName = api.nvim_buf_get_name(0)
    curBufNr = api.nvim_get_current_buf()
    curBufType = vim.o.buftype
    curWinID = api.nvim_get_current_win()
    winIDTbl = api.nvim_list_wins()
    bufNrTbl = vim.tbl_map(function(buf)
        return tonumber(string.match(buf, "%d+"))
    end, util.tblLoaded(false))
    if type == "window" then
        if curBufType ~= "" then
            -- Close window containing special buffer {{{
            if curBufType == "nofile" then
                -- nofile buffer, treated like standard buffer {{{
                if curBufName == "[Command Line]" then
                    cmd "q"
                else
                    wipeBuf(false)
                    if #winIDTbl > 1 then cmd "q" end
                end
                -- }}} nofile buffer, treated like standard buffer
            elseif curBufType == "terminal" then
                cmd "q"
            else -- other special buffer
                cmd "bwipe"
            end
            -- }}} Close window containing special buffer
        else
            -- Close window containing buffer {{{
            if curBufName == "" then
                if api.nvim_win_get_config(0)['relative'] ~= '' then
                    -- Close floating window
                    cmd "q"
                else
                    -- Scratch File
                    wipeBuf(false)
                    saveModified(curBufNr)
                    if #winIDTbl > 1 then cmd "q" end
                end
            else -- Standard buffer
                if #winIDTbl > 1 then -- 1+ Windows
                    local bufInstance = 0
                    for idx, val in ipairs(winIDTbl) do
                        if vim.tbl_contains(bufNrTbl, api.nvim_win_get_buf(val)) then
                            bufInstance = bufInstance + 1
                        end
                    end
                    if bufInstance == 0 or bufInstance > 1 then
                        cmd "q"
                    else -- 1 buffer instance
                        -- Return 0 when false is evaluated
                        if not saveModified(curBufNr) then
                            return
                        end
                        bwipe(curBufNr)
                    end
                else -- 1 Window
                    -- Return 0 when false is evaluated
                    if not saveModified(curBufNr) then return end
                    bwipe(curBufNr)
                end
            end
        end
        -- }}} Close window containing buffer
    elseif type == "buffer" then
        wipeBuf(true)
    end
end

return M

