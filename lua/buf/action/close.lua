-- File: /buf/close.lua
-- Author: iaso2h
-- Description: Delete buffer without change the window layout
-- Similar Work: https://github.com/ojroques/nvim-bufdel
-- Version: 0.0.35
-- Last Modified: 2023-4-25
local bufUtil = require("buf.util")
local var     = require("buf.var")
local M    = {}


--- Prompt save query for unsaved changes, make sure the buffer is ready to be
--- deleted
--- @param bufNr number Buffer number handler
--- @return boolean When cancel is input, false will be return, otherwise,
---         true will be return
local function saveModified(bufNr) -- {{{
    if not vim.api.nvim_buf_is_valid(bufNr) then return false end

    -- Check whether the file has any unsaved changes
    if not vim.api.nvim_buf_get_option(bufNr, "modified") then
        return true
    else
        if vim.api.nvim_buf_get_option(bufNr, "modified") then
            vim.cmd "noa echohl MoreMsg"
            local answer = vim.fn.confirm("Save modification?",
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


--- Close buffer in a smart way
--- @param checkSpecBuf boolean Whether to check the current buffer is
--- a special buffer or a standard buffer. If false is provided, then the
--- current buffer is treated as a standard buffer
--- @param checkAllBuf boolean Whether to check other windows that have the
--- same buffer instance as the one to be close. Only useful when wipe
--- a standard buffer
local function bufClose(checkSpecBuf, checkAllBuf) -- {{{
    -- Close buffer depending on buffer type

    if checkSpecBuf or bufUtil.isSpecBuf() then
        -- Closing Special buffer
        var.lastClosedFilePath = nil

        -- NOTE: more details see ":help buftype"
        if var.fileType == "vim" then
            return vim.api.nvim_feedkeys(t"<CMD>q<CR>", "t", false)
        elseif var.fileType == "tsplayground" or var.fileType == "query" then
            return vim.cmd [[TSPlaygroundToggle]]
        elseif var.fileType == "DiffviewFileHistory" then
            return vim.cmd [[DiffviewClose]]
        end

        if var.bufType == "nofile" then
            if var.bufName == "[Command Line]" then
                -- This buffer shows up When you hit CTRL-F on commandline
                vim.api.nvim_win_close(var.winID, true)
            elseif string.match(var.bufName, [[%[nvim%-lua%]$]]) then
                -- Check for Lua pad
                if bufUtil.bufValidCnt() >= 1 then
                    bufUtil.switchAlter(var.winID)
                else
                    bufUtil.bufWipe(var.bufNr)
                end
            else
                bufUtil.bufWipe(var.bufNr)
            end
        elseif var.bufType == "prompt" then
            bufUtil.bufWipe(var.bufNr)
        elseif var.bufType == "nowrite" then
            if vim.startswith(var.bufName, "diffview") then
                vim.cmd [[DiffviewClose]]
            end
        else
            -- Always wipe the special buffer if window count is 1
            if not saveModified(var.bufNr) then return end
            bufUtil.bufWipe(var.bufNr)
        end
    else
        -- Scratch files
        if bufUtil.isScratchBuf() then
            -- Abort the processing when cancel is evaluated
            if not saveModified(var.bufNr) then return end

            if bufUtil.bufValidCnt() >= 1 then
                bufUtil.bufWipe(var.bufNr)
            else
                vim.cmd("q!")
            end
        end

        -- Standard buffer -- {{{
        -- Store closed file path
        var.lastClosedFilePath = vim.fn.expand("%:p")

        -- Always prompt for unsaved change, so that buffer is ready to be
        -- deleted safely. Abort the processing when false is evaluated
        if not saveModified(var.bufNr) then return end

        -- Whether to check other windows that might have the same buffer instance
        if not checkAllBuf or bufUtil.winCnt() == 1 and bufUtil.bufValidCnt() == 1 then
            bufUtil.bufWipe(var.bufNr)
            if vim.api.nvim_buf_get_name(0) == "" then
                vim.api.nvim_buf_set_option(0, "buflisted", false)
                require("historyStartup").display(true)
            end
        end

        -- 1+ Windows

        -- Get count of buffer instance that display at Neovim windows {{{
        local winIDBufNrTbl = {}
        local bufInstanceCnt  = 0
        local specInstanceCnt = 0
        -- Create a table containing all different window ID as keys and the
        -- corresponding buffer number as values
        for _, win in ipairs(var.winIDTbl) do
            if vim.api.nvim_win_is_valid(win) then
                local bufNr = vim.api.nvim_win_get_buf(win)

                winIDBufNrTbl[win] = vim.api.nvim_win_get_buf(win)
                if bufUtil.isSpecBuf(vim.api.nvim_buf_get_option(bufNr, "buftype")) then
                    specInstanceCnt = specInstanceCnt + 1
                else
                    bufInstanceCnt = bufInstanceCnt + 1
                end
            end
        end
        -- }}} Get count of buffer instance that display at Neovim windows

        -- Loop through winIDBufNrTbl to check other windows contain the same
        -- buffer number as the one we are going to wipe
        for winID, bufNr in pairs(winIDBufNrTbl) do
            if bufNr == var.bufNr then bufUtil.switchAlter(winID) end
        end
        bufUtil.bufWipe(var.bufNr)

        -- Always restore window focus, window might be unavailable when the
        -- last buffer is deleted
        if vim.api.nvim_win_is_valid(var.winID) then
            vim.api.nvim_set_current_win(var.winID)
        end

        -- Merge when there are two windows sharing the last buffer
        -- NOTE: If this evaluated to true, then the current length of bufNr
        -- table has been reduced to 1, #bufNrTbl is just a value of previous state
        if bufUtil.winCnt() == 2 and bufInstanceCnt == 2 and bufUtil.bufValidCnt() == 2 then
            vim.cmd "only"
        end

        -- After finishing buffer wiping, prevent Neovim from setting the
        -- current window to display a special window. e.g. quickfix list
        -- or terminal. This means you have to at least have 2 buffers
        if bufUtil.bufValidCnt() >= 2 then
            local unwantedBufType = {"quickfix", "terminal", "help"}
            for _ = 1, bufUtil.bufValidCnt() - 1 + specInstanceCnt do
                if vim.tbl_contains(unwantedBufType, vim.bo.buftype) then
                    -- HACK: can still switch to a special buffer
                    vim.cmd "keepjump bp"
                else
                    break
                end
            end
        end
         -- }}}Standard buffer
    end
end -- }}}


--- Close window safely and wipe buffer without modifying the layout
--- @param type string Expect string value. possible value: "buffer", "window"
function M.init(type) -- {{{
    bufUtil.initBuf()

    if type == "window" then
        if bufUtil.isSpecBuf() then
            -- Close window containing special buffer

            -- NOTE: more details see ":help buftype"
            if var.bufType == "nofile" or var.bufType == "prompt" then
                -- Commandline expand window which can be accessed by pressing <C-f>
                if var.fileType == "vim" then
                    vim.api.nvim_feedkeys(t"<CMD>q<CR>", "t", false)
                    return
                elseif var.fileType == "tsplayground" then
                    return vim.cmd [[TSPlaygroundToggle]]
                elseif var.fileType == "DiffviewFileHistory" then
                    return vim.cmd [[DiffviewClose]]
                else
                    -- Other special buffer
                    if bufUtil.winCnt() > 1 then
                        bufUtil.closeWin(var.winID)
                    else
                        -- Override the default behavior, treat it like performing a buffer delete
                        bufUtil.bufWipe(var.bufNr)
                    end
                end
            elseif var.bufType == "nowrite" then
                if vim.startswith(var.bufName, "diffview") then
                    return vim.cmd [[DiffviewClose]]
                end
            elseif var.bufType == "terminal" then
                bufUtil.closeWin(var.winID)
            else
                -- Other special buffer
                if bufUtil.winCnt() > 1 then
                    bufUtil.closeWin(var.winID)
                else
                    -- Override the default behavior, treat it like performing a buffer delete
                    bufUtil.bufWipe(var.bufNr)
                end
            end
        else
            -- Close window containing buffer

            if bufUtil.isScratchBuf() then
                -- Scratch files. Override the default behavior, treat it like performing a buffer delete
                if bufUtil.getCurBufCntsInWins(var.bufNr) > 1 then
                    bufUtil.closeWin(var.winID)
                else
                    bufClose(false, false)
                end
            else
                -- Standard buffer
                if bufUtil.winCnt() == 1 then
                    -- 1 Window
                    -- Override the default behavior, treat it like performing
                    -- a buffer delete until there are no more buffers loaded
                    bufClose(false, false)
                else
                    -- 1+ Windows
                    -- In situation where there are multiple buffers loaded
                    -- with only one standard buffer display in one of the
                    -- windows
                    local bufInstanceCount = bufUtil.getAllBufCntsInWins()
                    if bufInstanceCount ~= 1 then
                        -- Multiple buffer instances or no instances
                        bufUtil.closeWin(var.winID)
                    else
                        -- 1 buffer instance
                        -- Override the default behavior, treat it like performing
                        -- a buffer delete until there are no more buffers loaded
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
