-- File: buffer.lua
-- Author: iaso2h
-- Description: A few of buffer-related utilities
-- Similar Work: https://github.com/ojroques/nvim-bufdel
-- Version: 0.0.22
-- Last Modified: 2021-11-18
local fn   = vim.fn
local cmd  = vim.cmd
local api  = vim.api
local util = require("util")
local M    = {
    curBufName    = nil,
    curBufNr      = nil,
    curBufType    = nil,
    curWinID      = nil,
    winIDTbl      = nil,
    bufNrTbl      = nil,
}


--- Prompt save query for unsaved changes, make sure the buffer is ready to be
--- deleted
--- @param bufNr number Buffer number handler
--- @return boolean When cancel is input, false will be return, otherwise,
---         true will be return
local function saveModified(bufNr) -- {{{
    if not api.nvim_buf_is_valid(bufNr) then return true end
    if api.nvim_buf_get_option(bufNr, "modified") then
        cmd "noa echohl MoreMsg"
        local answer = fn.confirm("Save modification?",
                                  ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        cmd "noa echohl None"
        if answer == 1 then
            cmd "noa update"
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


local function historyStartup()
    if #M.bufNrTbl == 1 then
        return require("historyStartup").display(true)
    else
        return
    end
end

--- Force wipe the given buffer, if no bufNr is provided, then current buffer
--- will be wiped
--- @param bufNr boolean Buffer number handler
local function bufWipe(bufNr)
    -- Might help to disable treesitter warning
    -- Error executing vim.schedule lua callback: /usr/share/nvim/runtime/lua/vim/lsp/util.lua:1486: Invalid buffer id: 63
    pcall(api.nvim_buf_delete, bufNr and bufNr or 0, {force = true})
end


--- Gather informatioin about buffers and windows for further processing
local initBuf = function()
    M.curBufName = api.nvim_buf_get_name(0)
    M.curBufNr   = api.nvim_get_current_buf()
    M.curBufType = vim.o.buftype
    M.curWinID   = api.nvim_get_current_win()
    M.winIDTbl   = vim.tbl_filter(function(i)
        return api.nvim_win_get_config(i).relative == ""
        end, api.nvim_list_wins())
    -- Do not use results from:
    -- vim.tbl_filter(function(i) return api.nvim_buf_is_loaded(i) end, api.nvim_list_bufs())
    M.bufNrTbl   = vim.tbl_map(function(buf)
        return tonumber(string.match(buf, "%d+"))
        end, util.tblLoaded(false))
end


--- Switch to alternative buffer or previous buffer before wiping current buffer
--- @param winID number Window ID in which alternative will be set
local switchAlter = function(winID)
    local altBuf = fn.bufnr("#")
    if api.nvim_buf_is_valid(altBuf) and vim.tbl_contains(M.bufNrTbl, altBuf) then
        api.nvim_win_set_buf(winID, altBuf)
    else
        -- Fallback method
        if api.nvim_get_current_win() ~= M.curWinID then
            cmd(fn.getwininfo(winID)[1].winnr .. "wincmd w")
        end
        cmd "bprevious"
    end
end


--- Close buffer in a smart way
--- @param checkSpecialBuf boolean Whether to check if current buffer is
--- a special buffer or a standard buffer. If false is provided, then the
--- current buffer is treated as a standard buffer
--- @param checkAllBuf boolean Whether to check other windows that have the
--- same buffer instance as the one going to be close
local function bufClose(checkSpecialBuf, checkAllBuf) -- {{{
    -- Close buffer depending on buffer type
    if checkSpecialBuf or M.curBufType ~= "" then
        -- Closing Special buffer
        M.lastClosedFilePath = nil

        if #M.winIDTbl ~= 1 then
            -- Just close the window. Won't do any damage
            api.nvim_win_close(M.curWinID, true)
        else
            if M.curBufType == "nofile" then
                if M.curBufName == "[Command Line]" then
                    -- This buffer shows up When you hit CTRL-F on commandline
                    return api.nvim_win_close(M.curWinID, true)
                elseif string.match(M.curBufName, [[%[nvim%-lua%]$]]) then
                    -- Check for Luapad
                    return api.nvim_buf_delete(M.curBufNr, {force = false, unload = true})
                else
                    return bufWipe(M.curBufNr)
                end
            elseif M.curBufType == "prompt" then
                return bufWipe(M.curBufNr)
            else
                -- Always wipe the special buffer if window count is 1
                if not saveModified(M.curBufNr) then return end
                return bufWipe(M.curBufNr)
            end
        end
    else
        -- Scratch files {{{
        if M.curBufName == "" or not vim.tbl_contains(M.bufNrTbl, M.curBufNr) then
            -- Scratch File
            -- Abort the processing when cancel is evaluated
            if not saveModified(M.curBufNr) then return end
            return bufWipe(M.curBufNr)
        end
        -- }}} Scratch files

        -- Standard buffer -- {{{
        -- Return when file is readonly
        if not vim.bo.modifiable then return end
        -- Always prompt for unsaved change, so that buffer is ready to be
        -- deleted safely. Abort the processing when cancel is evaluated
        if not saveModified(M.curBufNr) then return end

        -- Store closed file path
        M.lastClosedFilePath = fn.expand("%:p")

        -- Whether to check other windows that might have the same buffer
        -- instance
        if not checkAllBuf or #M.winIDTbl == 1 then
            switchAlter(M.curWinID)
            historyStartup()
            return bufWipe(M.curBufNr)
        end

        -- 1+ Windows
        -- Get count of buffers that display at Neovim window {{{
        local winIDBufNrTbl = {}
        local bufDisplayCount  = 0
        local specDisplayCount = 0
        -- Create a table with all different window ID as key, buffer number as value
        for _, win in ipairs(M.winIDTbl) do
            local bufNr = api.nvim_win_get_buf(win)

            winIDBufNrTbl[win] = api.nvim_win_get_buf(win)
            if api.nvim_buf_get_option(bufNr, "buftype") ~= "" then
                specDisplayCount = specDisplayCount + 1
            else
                bufDisplayCount = bufDisplayCount + 1
            end
        end
        -- }}} Get count of buffers that display at Neovim window

        -- Loop through winIDBufNrTbl to check other windows contain the same
        -- buffer number as the one we are going to wipe
        for winID, bufNr in pairs(winIDBufNrTbl) do
            if bufNr == M.curBufNr then
                switchAlter(winID)
            end
        end

        -- Always restore window focus
        api.nvim_set_current_win(M.curWinID)

        bufWipe(M.curBufNr)

        -- Merge when there are two windows sharing the last buffer
        -- NOTE: If this evaluated to true, then the current length of bufNrtble
        -- has been reduced to 1, #bufNrTbl is just a value of previous state
        if #M.winIDTbl == 2 and bufDisplayCount == 2 and #M.bufNrTbl == 2 then
            cmd "only"
        end

        -- After finishing buffer wipe, prevent Neovim from setting the
        -- current window to display a special window. e.g. quickfix list
        -- or terminal. This means you have to at least have 2 buffers in
        -- bufNrTbl
        if #M.bufNrTbl >= 2 then
            local unwantedBufType = {"quickfix", "terminal", "help"}
            for _ = 1, #M.bufNrTbl - 1 + specDisplayCount do
                if vim.tbl_contains(unwantedBufType, vim.bo.buftype) then
                    cmd "bp"
                else
                    break
                end
            end
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
    initBuf()

    if type == "window" then
        if M.curBufType ~= "" then
            -- Close window containing special buffer {{{
            if M.curBufType == "nofile" or M.curBufType == "prompt" then
                -- Treat it like performing a buffer delete
                bufClose(true, false)
                -- Make sure no lingering window
                if #M.winIDTbl > 1 and api.nvim_win_is_valid(M.curWinID) then
                    api.nvim_win_close(M.curWinID, true)
                end
            elseif M.curBufType == "terminal" then
                api.nvim_win_close(M.curWinID, true)
            else
                -- Other special buffer
                if #M.winIDTbl > 1 then
                    api.nvim_win_close(M.curWinID, true)
                else
                    bufWipe(M.curBufNr)
                end
            end
            -- }}} Close window containing special buffer
        else
        -- Close window containing buffer {{{
            if M.curBufName == "" then
                -- Scratch files
                bufClose(false, false)
                -- Make sure no lingering window
                if #M.winIDTbl > 1 and api.nvim_win_is_valid(M.curWinID) then
                    return api.nvim_win_close(M.curWinID, true)
                else
                    return
                end
            else
                -- Standard buffer
                if #M.winIDTbl == 1 then
                    -- 1 Window
                    -- Override the default behavior, treat it like performing
                    -- a buffer delete untill there is no morebuffers loaded
                    bufClose(false, false)
                else
                    -- 1+ Windows
                    -- In situation like there are multiple buffers loaded
                    -- with only one standard buffer display in one of the
                    -- windows, if you perform
                    local bufDisplayCount = 0
                    for _, val in ipairs(M.winIDTbl) do
                        if vim.tbl_contains(M.bufNrTbl, api.nvim_win_get_buf(val)) then
                            bufDisplayCount = bufDisplayCount + 1
                        end
                    end
                    if bufDisplayCount ~= 1 then
                        -- Multiple buffer instances or no instances
                        local ok, msg = pcall(api.nvim_win_close, M.curWinID, true)
                        if not ok then vim.notify(msg, vim.log.levels.ERROR) end
                    else
                        -- 1 buffer instance
                        -- Override the default behavior, treat it like performing
                        -- a buffer delete untill there is no morebuffers loaded
                        return bufClose(false, false)
                    end
                end
            end
        end
        -- }}} Close window containing buffer
    elseif type == "buffer" then
        return bufClose(false, true)
    end
end -- }}}


----
-- Function: M.wipeOtherBuf wipe all the other buffers except for the special buffers without changing the window layout
--
-- @return: 0
----
function M.wipeOtherBuf() -- {{{
    if vim.o.buftype ~= "" then return end

    initBuf()
    -- Check whether call from Nvim Tree
    M.winIDTbl = api.nvim_list_wins()
    if vim.bo.filetype == "NvimTree" then
        switchAlter(M.curWinID)
        if vim.bo.filetype == "NvimTree" then
            return
        end
    end

    -- Filter out terminal and special buffer, because I don't want close them yet
    local filterBuf = function(bufNr)
        local bufType = vim.bo.buftype
        return bufNr ~= M.curBufNr and (bufType == "" or bufType == "nofile" or bufType == "nowrite")
    end

    M.bufNrTbl = vim.tbl_filter(filterBuf, M.bufNrTbl)
    local unsavedChange = false
    local answer = -1

    -- Check unsaved change
    for _, bufNr in ipairs(M.bufNrTbl) do
        if bufNr ~= M.curBufNr then
            local modified = api.nvim_buf_get_option(bufNr, "modified")
            if modified then unsavedChange = true; break end
        end
    end

    -- Ask for saving, return when cancel is input
    if unsavedChange then
        cmd "noa echohl MoreMsg"
        answer = fn.confirm("Save all modification?",
            ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        cmd "noa echohl None"
        -- Interrupt
        if answer == 3 or answer == 0 then
            return
        elseif answer == 1 then
            cmd "bufdo update"
        end
    end

    -- Close other window that doesn't contain the current buffers
    -- Reserve windows that contain special buffer like help, quickfix
    if #M.winIDTbl > 1 then
        for _, winID in ipairs(M.winIDTbl) do
            if vim.tbl_contains(M.bufNrTbl, api.nvim_win_get_buf(winID))
                and api.nvim_buf_get_option(api.nvim_win_get_buf(winID), "buftype") == "" then

                api.nvim_win_close(winID, false)
            end
        end
    end

    -- Wipe buffers
    for _, bufNr in ipairs(M.bufNrTbl) do
        if api.nvim_buf_is_valid(M.bufNrTbl) then
            api.nvim_buf_delete(bufNr, {force = true})
        end
    end
end -- }}}


M.restoreClosedBuf = function()
    if M.lastClosedFilePath then
        cmd(string.format("e %s", M.lastClosedFilePath))
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

