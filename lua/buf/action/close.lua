-- File: /buf/close.lua
-- Author: iaso2h
-- Description: Delete buffer without change the window layout
-- Similar Work: https://github.com/ojroques/nvim-bufdel
-- Version: 0.0.27
-- Last Modified: 2023-3-8
local fn    = vim.fn
local api   = vim.api
local util  = require("buf.util")
local var   = require("buf.var")
local M    = {}


--- Prompt save query for unsaved changes, make sure the buffer is ready to be
--- deleted
--- @param bufNr number Buffer number handler
--- @return boolean When cancel is input, false will be return, otherwise,
---         true will be return
local function saveModified(bufNr) -- {{{
    if not api.nvim_buf_is_valid(bufNr) then return false end

    -- Check whether the file has any unsaved changes
    if not api.nvim_buf_get_option(bufNr, "modified") then
        return true
    else
        if api.nvim_buf_get_option(bufNr, "modified") then
            vim.cmd "noa echohl MoreMsg"
            local answer = fn.confirm("Save modification?",
                ">>> &Save\n&Discard\n&Cancel", 3, "Question")
            vim.cmd "noa echohl None"
            if answer == 1 then
                vim.cmd "noa update!"
                return true
            elseif answer == 2 then
                return true
            else
                return false
            end
        else
            return true
        end
    end

end -- }}}


local function historyStartup()
    if util.bufCnt() == 1 then
        return require("historyStartup").display(true)
    else
        return
    end
end


--- Close buffer in a smart way
--- @param checkSpecBuf boolean Whether to check the current buffer is
--- a special buffer or a standard buffer. If false is provided, then the
--- current buffer is treated as a standard buffer
--- @param checkAllBuf boolean Whether to check other windows that have the
--- same buffer instance as the one to be close. Only useful when wipe
--- a standard buffer
--- @return boolean Represent whether it's safe to delete buffer
local function bufClose(checkSpecBuf, checkAllBuf) -- {{{
    -- Close buffer depending on buffer type

    if checkSpecBuf or util.isSpecBuf() then
        -- Closing Special buffer
        var.lastClosedFilePath = nil

        -- if util.winCnt() ~= 1 then
            -- -- Just close the window. Won't do any damage
            -- api.nvim_win_close(var.winID, true)
        -- else
            -- NOTE: more details see ":help buftype"
            if vim.bo.filetype == "vim" then
                vim.cmd[[q]]
                return true
            elseif var.bufType == "nofile" then
                if var.bufName == "[Command Line]" then
                    -- This buffer shows up When you hit CTRL-F on commandline
                    api.nvim_win_close(var.winID, true)
                elseif string.match(var.bufName, [[%[nvim%-lua%]$]]) then
                    -- Check for Luapad
                    if util.bufCnt() ~= 1 then
                        util.switchAlter(var.winID)
                    else
                        util.bufWipe(var.bufNr)
                    end
                else
                    util.bufWipe(var.bufNr)
                end
            elseif var.bufType == "prompt" then
                util.bufWipe(var.bufNr)
            else
                -- Always wipe the special buffer if window count is 1
                if not saveModified(var.bufNr) then return false end
                util.bufWipe(var.bufNr)
            end
        -- end

        return true
    else
        -- Scratch files {{{
        if util.isScratchBuf() then
            -- Abort the processing when cancel is evaluated
            if not saveModified(var.bufNr) then return false end

            if util.bufCnt() ~= 1 then
                util.bufWipe(var.bufNr)
            else
                vim.cmd("q!")
            end
            return true
        end
        -- }}} Scratch files

        -- Standard buffer -- {{{
        -- Store closed file path
        var.lastClosedFilePath = fn.expand("%:p")

        -- Always prompt for unsaved change, so that buffer is ready to be
        -- deleted safely. Abort the processing when false is evaluated
        if not saveModified(var.bufNr) then return false end

        -- Whether to check other windows that might have the same buffer instance
        if not checkAllBuf or util.winCnt() == 1 then
            historyStartup()
            util.bufWipe(var.bufNr)
            return true
        end

        -- 1+ Windows

        -- Get count of buffer instance that display at Neovim windows {{{
        local winIDBufNrTbl = {}
        local bufInstanceCnt  = 0
        local specInstanceCnt = 0
        -- Create a table containing all different window ID as keys and the
        -- corresponding buffer number as values
        for _, win in ipairs(var.winIDtbl) do
            local bufNr = api.nvim_win_get_buf(win)

            winIDBufNrTbl[win] = api.nvim_win_get_buf(win)
            if util.isSpecBuf(api.nvim_buf_get_option(bufNr, "buftype")) then
                specInstanceCnt = specInstanceCnt + 1
            else
                bufInstanceCnt = bufInstanceCnt + 1
            end
        end
        -- }}} Get count of buffer instance that display at Neovim windows

        -- Loop through winIDBufNrTbl to check other windows contain the same
        -- buffer number as the one we are going to wipe
        for winID, bufNr in pairs(winIDBufNrTbl) do
            if bufNr == var.bufNr then util.switchAlter(winID) end
        end
        util.bufWipe(var.bufNr)

        -- Always restore window focus, window might be unavailable when the
        -- last buffer is deleted
        if api.nvim_win_is_valid(var.winID) then
            api.nvim_set_current_win(var.winID)
        end

        -- Merge when there are two windows sharing the last buffer
        -- NOTE: If this evaluated to true, then the current length of bufNrtble
        -- has been reduced to 1, #bufNrTbl is just a value of previous state
        if util.winCnt() == 2 and bufInstanceCnt == 2 and util.bufCnt() == 2 then
            vim.cmd "only"
        end

        -- After finishing buffer wiping, prevent Neovim from setting the
        -- current window to display a special window. e.g. quickfix list
        -- or terminal. This means you have to at least have 2 buffers
        if util.bufCnt() >= 2 then
            local unwantedBufType = {"quickfix", "terminal", "help"}
            for _ = 1, util.bufCnt() - 1 + specInstanceCnt do
                if vim.tbl_contains(unwantedBufType, vim.bo.buftype) then
                    -- HACK: can still switch to a special buffer
                    vim.cmd "bp"
                else
                    break
                end
            end
        end
         -- }}}Standard buffer

        return true
    end
end -- }}}


--- Close window safely and wipe buffer without modifying the layout
--- @param type string Expect string value. possible value: "buffer", "window"
function M.init(type) -- {{{
    util.initBuf()

    if type == "window" then
        if util.isSpecBuf() then
            -- Close window containing special buffer

            -- NOTE: more details see ":help buftype"
            if var.bufType == "nofile" or var.bufType == "prompt" then
                -- Commandline expand window which can be accessed by pressing <C-f>
                if vim.bo.filetype == "vim" then
                    vim.cmd[[q]]
                    return
                end
                -- Override the default behavior, treat it like performing a buffer delete
                if not bufClose(true, false) then return end
                -- Make sure no lingering window after buffer being wiped
                if util.winCnt() > 1 and api.nvim_win_is_valid(var.winID) then
                    util.closeWin(var.winID)
                end
            elseif var.bufType == "terminal" then
                util.closeWin(var.winID)
            else
                -- Other special buffer

                if util.winCnt() > 1 then
                    util.closeWin(var.winID)
                else
                    -- Override the default behavior, treat it like performing a buffer delete
                    util.bufWipe(var.bufNr)
                end
            end
        else
            -- Close window containing buffer

            if util.isScratchBuf() then
                -- Scratch files. Override the default behavior, treat it like performing a buffer delete
                if not bufClose(false, false) then return end
                -- Make sure no lingering window after buffer being wiped
                if util.winCnt() > 1 and api.nvim_win_is_valid(var.winID) then
                    return util.closeWin(var.winID)
                end
            else
                -- Standard buffer
                if util.winCnt() == 1 then
                    -- 1 Window
                    -- Override the default behavior, treat it like performing
                    -- a buffer delete untill there are no more buffers loaded
                    bufClose(false, false)
                else
                    -- 1+ Windows
                    -- In situation where there are multiple buffers loaded
                    -- with only one standard buffer display in one of the
                    -- windows
                    local bufInstanceCount = util.getBufCntInWins()
                    if bufInstanceCount ~= 1 then
                        -- Multiple buffer instances or no instances
                        util.closeWin(var.winID)
                    else
                        -- 1 buffer instance
                        -- Override the default behavior, treat it like performing
                        -- a buffer delete untill there are no more buffers loaded
                        return bufClose(false, false)
                    end
                end
            end
        end

    elseif type == "buffer" then
        return bufClose(false, true)
    end
end -- }}}

return M
