-- File: buffer.lua
-- Author: iaso2h
-- Description: A few of buffer-related utilities
-- Similar Work: https://github.com/ojroques/nvim-bufdel
-- Version: 0.0.18
-- Last Modified: 2021-08-23
-- BUG: q on startup-log.txt
-- TODO: check for prompt
local fn   = vim.fn
local cmd  = vim.cmd
local api  = vim.api
local util = require("util")
local M    = {}
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
-- @return: always return false except that "cancel" is input
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
        api.nvim_buf_delete(bufNr, {force = true})
    else
        api.nvim_buf_delete(0, {force = true})
        if vim.bo.filetype == "NvimTree" and vim.g.bufferline then
            require "bufferline.state".set_offset(0)
            return
        end
    end

    if vim.g.bufferline and #bufNrTbl ~= 1 then
        fn['bufferline#update'](true)
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
local function smartCloseBuf(checkBuftype) -- {{{
    -- Check if called from Nvim Tree
    if vim.bo.filetype == "NvimTree" and vim.g.bufferline then
        require "bufferline.state".set_offset(0)
        cmd "wincmd q"
        return
    end

    -- Wipe unlisted buffer
    if not vim.tbl_contains(bufNrTbl, curBufNr) then
        bwipe()
        return
    end

    -- Wipe buffer depending on buffer type {{{
    if curBufType ~= "" then
        -- Check if called from a special buffer

        -- Empty closed buffer path
        M.lastClosedFilePath = nil
        -- Special buffer
        if #winIDTbl ~= 1 then
            api.nvim_win_close(curWinID, true)
        else
            bwipe()
        end
    else
        -- Standard buffer -- {{{
        M.lastClosedFilePath = fn.expand("%:p")
        -- Return when file is readonly
        if not vim.bo.modifiable then return end
        -- Return when cancel is return from prompt is evaluated
        if not saveModified(curBufNr) then return end
        -- Check for Luapad
        if vim.bo.filetype == "lua" and fn.match(fn.expand("%"), "Luapad_") ~= -1 then
            bwipe()
            return
        end
        -- Normal wipe
        if #winIDTbl == 1 then -- 1 Window
            bwipe(curBufNr)
        else -- 1+ Windows
            winIDBufNrTbl = {}
            local bufInstance  = 0
            local specInstance = 0
            -- Create table with all different window ID as key, buffer number as value
            for _, win in ipairs(winIDTbl) do
                local bufNr = api.nvim_win_get_buf(win)
                winIDBufNrTbl[win] = bufNr
                if api.nvim_buf_get_option(bufNr, "buftype") ~= "" then
                    specInstance = specInstance + 1
                end
            end
            -- Loop through winIDBufNrTbl to check other windows contain the same
            -- buffer number(buffer handler) as the one we are going to wipe
            for winID, bufNr in pairs(winIDBufNrTbl) do
                if vim.bo.buftype == "" then
                    bufInstance = bufInstance + 1
                end
                -- if bufNr == curBufNr and api.nvim_win_is_valid(winID) then
                if bufNr == curBufNr then
                    -- BUG: Somehow neovim complains "Failed to switch to window xxxx(number)"
                    local execBool
                    local execMsg
                    execBool, execMsg = pcall(api.nvim_set_current_win, winID)
                    if not execBool then
                        api.nvim_echo({{execMsg, "ErrorMsg"}}, true, {})
                    end

                    -- Switch to alternative buffer or previous buffer before wiping buffer
                    local altBuf = fn.bufnr("#")
                    if api.nvim_buf_is_valid(altBuf) and vim.tbl_contains(bufNrTbl, altBuf) then
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
            -- Note: If this evaluated to true, then the current length of bufNrtble
            -- has been reduced to 1, #bufNrTbl is just a value of previous state
            if #winIDTbl == 2 and bufInstance == #winIDTbl and #bufNrTbl == 2 and specInstance == 0 then
                cmd "only"
            end
        end

        -- After finishing buffer wipe, prevent the next buffer revealed in current window is set to quickfix list and terminal
        if #bufNrTbl - 1 > 2 then
            local unwantedBufType = {"quickfix", "terminal"}
            if vim.tbl_contains(unwantedBufType, vim.bo.buftype) then cmd "bp" end
        end -- }}}
    end
    -- }}} Wipe buffer depending on buffer type
end -- }}}

----
-- Function: M.smartClose Close window safely and wipe buffer without modifying the layout
--
-- @param type: expect string value. possible value: "buffer", "window"
-- @return: 0
----
function M.smartClose(type) -- {{{
    curBufName = api.nvim_buf_get_name(0)
    curBufNr   = api.nvim_get_current_buf()
    curBufType = vim.o.buftype
    curWinID   = api.nvim_get_current_win()
    -- TODO: check relative window
    winIDTbl   = api.nvim_list_wins()
    bufNrTbl   = vim.tbl_map(function(buf)
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
                    smartCloseBuf()
                    if #winIDTbl > 1 and api.nvim_win_is_valid(curWinID) then api.nvim_win_close(curWinID, true) end
                end
                -- }}} nofile buffer, treated like standard buffer
            elseif curBufType == "terminal" then
                api.nvim_win_close(curWinID, true)
            else -- other special buffer
                bwipe()
            end
            -- }}} Close window containing special buffer
        else
            -- Close window containing buffer {{{
            if curBufName == "" then
                if util.isFloatWin then
                    -- Close floating window
                    api.nvim_win_close(curWinID, true)
                else
                    -- Scratch File
                    saveModified(curBufNr)
                    smartCloseBuf()
                    if #winIDTbl > 1 and api.nvim_win_is_valid(curWinID) then
                        api.nvim_win_close(curWinID, true)
                    end
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
                        if api.nvim_win_is_valid(curWinID) then
                            local ok, _ = pcall(api.nvim_win_close, curWinID, true)
                            if not ok then api.nvim_echo({{_, "ErrorMsg"}}, true, {}) end
                        end
                    else -- 1 buffer instance
                        -- Return 0 when false is evaluated
                        if not saveModified(curBufNr) then
                            return
                        end
                        M.lastClosedFilePath = fn.expand("%:p")
                        bwipe(curBufNr)
                    end
                else -- 1 Window
                    -- Return 0 when false is evaluated
                    if not saveModified(curBufNr) then return end
                    M.lastClosedFilePath = fn.expand("%:p")
                    bwipe(curBufNr)
                end
            end
        end
        -- }}} Close window containing buffer
    elseif type == "buffer" then
        smartCloseBuf()
    end
end

----
-- Function: M.wipeOtherBuf wipe all the other buffers except for the special buffers without changing the window layout
--
-- @return: 0
----
function M.wipeOtherBuf() -- {{{
    if vim.o.buftype ~= "" then return end

    -- Check whether call from Nvim Tree
    local nvimTreeCall
    winIDTbl = api.nvim_list_wins()
    if vim.bo.filetype == "NvimTree" then
        if #winIDTbl == 2 then
            cmd [[noautocmd wincmd w]]
            nvimTreeCall = true
        else
            return
        end
    end

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
    -- Reserve windows that contain special buffer like help, quickfix
    if #winIDTbl > 1 then
        for _, winID in ipairs(winIDTbl) do
            if vim.tbl_contains(bufNrTbl, api.nvim_win_get_buf(winID)) and api.nvim_buf_get_option(api.nvim_win_get_buf(winID), "buftype") == "" then
                api.nvim_win_close(winID, false)
            end
        end
    end

    -- Wipe buffers
    for _, bufNr in ipairs(bufNrTbl) do
        if api.nvim_buf_is_valid(bufNrTbl) then
            api.nvim_buf_delete(bufNr, {force = true})
        end
    end

    -- Change focus back to Nvim Tree
    if nvimTreeCall then
        cmd [[noautocmd wincmd w]]
    end

    -- Update barbar.nvim tabline
    if vim.g.bufferline then
        fn['bufferline#update'](true)
    end
end -- }}}


----
-- Function: M.closeOtherWin: Close other windows with nvim tree open checking
----
M.closeOtherWin = function()
    if package.loaded["nvim-tree.view"] and require("nvim-tree.view").win_open() then
        require("bufferline.state").set_offset(0)
        require("nvim-tree.view").close()
    end
    vim.cmd("noautocmd wincmd o")
end

M.restoreClosedBuf = function()
    if M.lastClosedFilePath then
        return cmd(string.format("e %s", M.lastClosedFilePath))
    else
        return
    end
end


function M.quickfixToggle() -- {{{
    -- Toogle off
    if vim.bo.buftype == "quickfix" then
        return cmd "q"
    end

    -- Toggle on
    local winInfo = fn.getwininfo()
    for _, tbl in ipairs(winInfo) do
        if tbl["quickfix"] == 1 then
            return api.nvim_set_current_win(tbl["winid"])
        end
    end
    cmd "copen"
end -- }}}

return M

