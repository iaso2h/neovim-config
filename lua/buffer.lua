-- File: buffer.lua
-- Author: iaso2h
-- Description: Close buffer in a smart way
-- Version: 0.0.11
-- Last Modified: 2021-03-31
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


----
-- Function: puregeBufList :Purge buffer list and preserve the current buffer and special buffer
--
-- @return: 0
----
local function puregeBufList()
    curBufNr = api.nvim_get_current_buf()
    bufNrTbl = vim.tbl_map(function(bufNr)
        return tonumber(string.match(bufNr, "%d+"))
    end, util.tblLoaded(false))
    -- Filter out terminal and special buffer, because I don't want close them yet
    local filterBuf = function(bufNr)
        local bufType = vim.bo.buftype
        return bufNr ~= curBufNr and (bufType == "" or bufType == "nofile" or bufType == "nowrite")
    end

    bufNrTbl = vim.tbl_filter(filterBuf, bufNrTbl)
    -- Wipe buffers
    for _, bufNr in ipairs(bufNrTbl) do
        if api.nvim_buf_is_valid(bufNrTbl) then
            cmd("bwipe! " .. bufNr)
        end
    end
end


-- Function: bwipe :perform a bufferline update for barbar.nvim after the origin vim bwipe
--
-- @param bufNr: bufNr, same as the origin vim bwipe
----
local function bwipe(bufNr)
    if bufNr then
        api.nvim_buf_delete(bufNr, {force = true})
    else
        api.nvim_buf_delete(0, {force = true})
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
local function wipeBuf() -- {{{
    -- Wipe unlisted buffer
    if not vim.tbl_contains(bufNrTbl, curBufNr) then
        bwipe()
        return
    end
    -- Check if it's called from a special buffer
    if curBufType ~= "" then
        -- Special buffer
        api.nvim_win_close(curWinID, true)
    else
        -- Standard buffer
        if not vim.bo.modifiable then return end
        -- Return when false is evaluated
        if not saveModified(curBufNr) then return end
        if #winIDTbl == 1 then -- 1 Window
            bwipe(curBufNr)
        else -- 1+ Windows
            winIDBufNrTbl = {}
            local bufInstance = 0
            -- Create table with all different window ID as key, buffer number as value
            for _, win in ipairs(winIDTbl) do
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

    end
end -- }}}

----
-- Function: M.smartClose Close window safely and wipe buffer without modifying the layout
--
-- @param type: expect string value. possible value: "buffer", "window"
-- @return: 0
----
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
            if curBufType == "nofile" then
                -- nofile buffer, treated like standard buffer {{{
                if curBufName == "[Command Line]" then
                    api.nvim_win_close(curWinID, true)
                else
                    wipeBuf()
                    if #winIDTbl > 1 then api.nvim_win_close(curWinID, true) end
                end
                -- }}} nofile buffer, treated like standard buffer
            elseif curBufType == "terminal" then
                api.nvim_win_close(curWinID, true)
            else -- other special buffer
                cmd "bwipe"
            end
            -- }}} Close window containing special buffer
        else
            -- Close window containing buffer {{{
            if curBufName == "" then
                if api.nvim_win_get_config(0)['relative'] ~= '' then
                    -- Close floating window
                    api.nvim_win_close(curWinID, true)
                else
                    -- Scratch File
                    wipeBuf()
                    saveModified(curBufNr)
                    if #winIDTbl > 1 then api.nvim_win_close(curWinID, true) end
                end
            else -- Standard buffer
                if #winIDTbl > 1 then -- 1+ Windows
                    local bufInstance = 0
                    for _, val in ipairs(winIDTbl) do
                        if vim.tbl_contains(bufNrTbl, api.nvim_win_get_buf(val)) then
                            bufInstance = bufInstance + 1
                        end
                    end
                    if bufInstance == 0 or bufInstance > 1 then
                        api.nvim_win_close(curWinID, true)
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
        wipeBuf()
    end
end

----
-- Function: M.wipeOtherBuf wipe all the other buffers except for the special buffers without changing the window layout
--
-- @return: 0
----
function M.wipeOtherBuf() -- {{{
    curBufNr = api.nvim_get_current_buf()
    bufNrTbl = vim.tbl_map(function(bufNr)
        return tonumber(string.match(bufNr, "%d+"))
    end, util.tblLoaded(false))

    -- Filter out terminal and special buffer, because I don't want close them yet
    local filterBuf = function(bufNr)
        local bufType = vim.bo.buftype
        return bufNr ~= curBufNr and (bufType == "" or bufType == "nofile" or bufType == "nowrite")
    end

    bufNrTbl = vim.tbl_filter(filterBuf, bufNrTbl)
    winIDTbl = api.nvim_list_wins()
    local unsavedChange = false
    local answer = -1

    -- Check unsaved change
    for _, bufNr in ipairs(bufNrTbl) do
        if bufNr ~= curBufNr then
            local modified = api.nvim_buf_get_option(bufNr, "modified")
            if modified then unsavedChange = true; break end
        end
    end

    -- Ask for saving, return when cancel is input
    if unsavedChange then
        cmd "echohl MoreMsg"
        answer = fn.confirm("Save modification?",
            ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        cmd "echohl None"
        -- Interrupt
        if answer == 3 or answer == 0 then
            return 0
        elseif answer == 1 then
            cmd "bufdo update"
        end
    end

    -- Close other window that doesn't contain the current buffers
    if #winIDTbl > 1 then
        for _, winID in ipairs(winIDTbl) do
            if vim.tbl_contains(bufNrTbl, api.nvim_win_get_buf(winID)) then
                api.nvim_win_close(winID, false)
            end
        end
    end

    -- Wipe buffers
    for _, bufNr in ipairs(bufNrTbl) do
        if api.nvim_buf_is_valid(bufNrTbl) then
            cmd("bwipe! " .. bufNr)
        end
    end

    -- Update barbar.nvim tabline
    if fn.exists("g:bufferline") == 1 then
        fn['bufferline#update']()
    end
end -- }}}

local hideCursorFileTypeTbl = {
    "NvimTree",
    "qf",
    "startify",
    "coc-explorer"
}
local hideCursorStatus = false
-- TODO: hide cursor in specific buffer type
function M.hideCursor()
    local fileType = vim.bo.filetype
    if vim.tbl_contains(hideCursorFileTypeTbl, fileType) then
        cmd "hi! Cursor guifg=black guibg=bg=white ctermbg=15"
        vim.o.guicursor = "n-v-sm:block,i-c-ci:ver25-Cursor,ve-o-r-cr:hor20"
        hideCursorStatus = true
    end
    if hideCursorStatus then
        cmd "hi! Cursor guibg=#3B4252"
        vim.o.guicursor = "v-sm:block,v-i-c-ci:ver25-Cursor,ve-o-r-cr:hor20"
    end
end

return M

