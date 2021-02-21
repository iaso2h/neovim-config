-- File: C:\Users\Hashub\AppData\Local\nvim\lua\smartClose.lua
-- Author: iaso2h
-- Description: Close window safely and wipe buffer without modifying the layout
-- Version: 0.0.6
-- Last Modified: 2021-02-21
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

local function saveWipe(bufNr) -- {{{
    if api.nvim_buf_get_option(bufNr, "modified") then
        cmd "echohl MoreMsg"
        local answer = fn.confirm("Save modification?",
                                  ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        cmd "echohl None"
        if answer == 1 then
            cmd "w"
            cmd("bwipe " .. bufNr)
        elseif answer == 2 then
            cmd("bwipe! " .. bufNr)
        end
    else
        cmd("bwipe " .. bufNr)
    end
end -- }}}

local function closeBuf() -- {{{
    -- Wipe unlisted buffer
    if not vim.tbl_contains(bufNrTbl, curBufNr) then
        cmd "bwipe!"
        do return end
    end

    if #bufNrTbl == 1 then  -- 1 Buffer
        if #winIDTbl > 1 then cmd "only" end
        saveWipe(curBufNr)
    else                    -- 1+ Buffers
        winIDBufNrTbl = {}
        for idx, win in ipairs(winIDTbl) do
            winIDBufNrTbl[win] = api.nvim_win_get_buf(win)
        end
        for winID, bufNr in pairs(winIDBufNrTbl) do
            if bufNr == curBufNr then
                api.nvim_set_current_win(winID)
                local altBuf = fn.bufnr("#")
                if altBuf > 0 and vim.tbl_contains(bufNrTbl, altBuf) then
                    api.nvim_win_set_buf(winID, altBuf)
                else
                    cmd "bprevious"
                end
            end
        end
        -- Restore
        api.nvim_set_current_win(curWinID)
        saveWipe(curBufNr)
    end
end -- }}}

function M.smartClose(type) -- {{{
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
            if curBufType == "nofile" then     -- nofile buffer, treated like standard buffer
                if curBufName == "[Command Line]" then
                    cmd "q"
                else
                    if #bufNrTbl == 1 then     -- 1 Buffer
                        if #winIDTbl > 1 then cmd "only" end
                        saveWipe(curBufNr)
                    else                       -- 1+ Buffers
                        if #winIDTbl > 1 then  -- 1+ Windows
                            cmd "q"
                            if api.nvim_buf_get_option(0, "modified") and
                                vim.tbl_contains(bufNrTbl, curBufNr) then
                                cmd("bwipe! " .. curBufNr)
                            end
                        else                   -- 1 Window
                            saveWipe(curBufNr)
                        end
                    end
                end
            elseif curBufType == "terminal" then
                cmd "q"
            else -- other special buffer
                cmd "bwipe"
            end
            -- }}} Close window containing special buffer
        else
            -- Close window containing buffer {{{
            if curBufName == "" then       -- Scratch File
                if #bufNrTbl == 1 then     -- 1 Buffer
                    if #winIDTbl > 1 then cmd "only" end
                    saveWipe(curBufNr)
                    cmd "q"
                else                       -- 1+ Buffers
                    if #winIDTbl > 1 then  -- 1+ Windows
                        cmd "q"
                        if api.nvim_buf_get_option(0, "modified") and
                            vim.tbl_contains(bufNrTbl, curBufNr) then
                            cmd("bwipe! " .. curBufNr)
                        end
                    else                   -- 1 Window
                        saveWipe(curBufNr)
                    end
                end
            else                       -- Standard buffer
                if #winIDTbl > 1 then  -- 1+ Windows
                    local bufInstance = 0
                    for idx, val in ipairs(winIDTbl) do
                        if vim.tbl_contains(bufNrTbl, api.nvim_win_get_buf(val)) then
                            bufInstance = bufInstance + 1
                        end
                    end
                    if bufInstance > 1 then
                        cmd "q"
                    else
                        closeBuf()
                    end
                else                   -- 1 Window
                    saveWipe(curBufNr)
                end
            end
        end
        -- }}} Close window containing buffer
    elseif type == "buffer" then
        closeBuf()
    end
end

return M

