-- File: /buf/close.lua
-- Author: iaso2h
-- Description: Delete buffer without change the window layout
-- Similar Work: https://github.com/ojroques/nvim-bufdel
-- Version: 0.0.39
-- Last Modified: 2023-4-28
-- DEBUG: 3 wins, 2 wins with same buffers, exe Q on either of the 2 wins
local u   = require("buffer.util")
local var = require("buffer.var")
local M   = {}


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
                ">>> &Save\n&Unload save\n&Discard\n&Cancel", 3, "Question")
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
--- @param loneWin boolean Whether to check other windows that have the
--- same buffer instance as the one to be close. Only useful when wipe
--- a standard buffer
local function bufHandler(loneWin) -- {{{
    -- Close buffer depending on buffer type

    if u.isSpecBuf() then
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
                vim.api.nvim_win_close(var.winId, true)
            elseif string.match(var.bufName, [[%[nvim%-lua%]$]]) then
                -- Check for Lua pad
                if u.bufsVisibleOccur() >= 1 then
                    if not u.bufSwitchAlter(var.winId) then
                        return
                    end
                else
                    u.bufClose(var.bufNr)
                end
            else
                u.bufClose(var.bufNr)
            end
        elseif var.bufType == "prompt" then
            u.bufClose(var.bufNr)
        elseif var.bufType == "nowrite" then
            if vim.startswith(var.bufName, "diffview") then
                vim.cmd [[DiffviewClose]]
            end
        else
            -- Always wipe the special buffer if window count is 1
            if not saveModified(var.bufNr) then return end
            u.bufClose(var.bufNr)
        end
    else
        -- Scratch files
        if u.isScratchBuf() then
            -- Close NNP
            if package.loaded["no-neck-pain"] and
                require("no-neck-pain").state.enabled and
                var.fileType == "no-neck-pain" then

                return require("no-neck-pain").toggle()
            end

            -- Abort the processing when cancel is evaluated
            if not saveModified(var.bufNr) then return end

            if u.bufsVisibleOccur() > 1 then
                return u.bufClose(var.bufNr)
            else
                return vim.cmd("q!")
            end

        end

        -- Standard buffer -- {{{
        -- Store closed file path
        var.lastClosedFilePath = vim.fn.expand("%:p")

        -- Always prompt for unsaved change, so that buffer is ready to be
        -- deleted safely. Abort the processing when false is evaluated
        if not saveModified(var.bufNr) then return end

        -- Whether to check other windows that might have the same buffer instance
        if not loneWin or u.winsOccur() == 1 then
            if u.bufsVisibleOccur() == 1 then
                u.bufClose(var.bufNr)
                local postBufNr = vim.api.nvim_get_current_buf()
                if vim.api.nvim_buf_get_name(postBufNr) == "" then
                    return require("historyStartup").display(true)
                else
                    Print(var.bufNrs)
                    return vim.notify(
                        "Unabled to enter the historyStartup correctly for the last scratch file",
                        vim.log.levels.ERROR)
                end
            else
                if not u.bufSwitchAlter(var.winId) then
                    return
                end
                return u.bufClose(var.bufNr)
            end
        end


        -- 1+ Windows

        -- Get count of buffer instance that display at Neovim windows {{{
        local winIDBufNrTbl = {}
        local bufInstanceCnt  = 0
        local specInstanceCnt = 0
        -- Create a table containing all different window ID as keys and the
        -- corresponding buffer number as values
        for _, win in ipairs(var.winIds) do
            if vim.api.nvim_win_is_valid(win) then
                local bufNr = vim.api.nvim_win_get_buf(win)

                winIDBufNrTbl[win] = vim.api.nvim_win_get_buf(win)
                if u.isSpecBuf(vim.api.nvim_buf_get_option(bufNr, "buftype")) then
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
            if bufNr == var.bufNr then
                if not u.bufSwitchAlter(winID) then
                    return
                end
            end
        end
        u.bufClose(var.bufNr)

        -- Always restore window focus, window might be unavailable when the
        -- last buffer is deleted
        if vim.api.nvim_win_is_valid(var.winId) then
            vim.api.nvim_set_current_win(var.winId)
        end

        -- Merge when there are two windows sharing the last buffer
        -- NOTE: If this evaluated to true, then the current length of bufNr
        -- table has been reduced to 1, #bufNrTbl is just a value of previous state
        if u.winsOccur() == 2 and bufInstanceCnt == 2 and u.bufsVisibleOccur() == 2 then
            vim.cmd "only"
        end

        -- After finishing buffer wiping, prevent Neovim from setting the
        -- current window to display a special window. e.g. quickfix list
        -- or terminal. This means you have to at least have 2 buffers
        if u.bufsVisibleOccur() >= 2 then
            local unwantedBufType = {"quickfix", "terminal", "help"}
            for _ = 1, u.bufsVisibleOccur() - 1 + specInstanceCnt do
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


local winHandler = function() -- {{{
    if u.isSpecBuf() then
        -- Close window containing special buffer

        -- NOTE: more details see ":help buftype"
        if var.bufType == "nofile" or var.bufType == "prompt" then
            -- Commandline expand window which can be accessed by pressing <C-f>
            if var.fileType == "vim" then
                vim.api.nvim_feedkeys(t "<CMD>q<CR>", "t", false)
                return
            elseif var.fileType == "tsplayground" then
                return vim.cmd [[TSPlaygroundToggle]]
            elseif var.fileType == "DiffviewFileHistory" then
                return vim.cmd [[DiffviewClose]]
            else
                -- Other special buffer
                if u.winsOccur() > 1 then
                    u.winClose(var.winId)
                else
                    -- Override the default behavior, treat it like performing a buffer delete
                    u.bufClose(var.bufNr)
                end
            end
        elseif var.bufType == "nowrite" then
            if vim.startswith(var.bufName, "diffview") then
                return vim.cmd [[DiffviewClose]]
            end
        elseif var.bufType == "terminal" then
            u.winClose(var.winId)
        else
            -- Other special buffer
            if u.winsOccur() > 1 then
                u.winClose(var.winId)
            else
                -- Override the default behavior, treat it like performing a buffer delete
                u.bufClose(var.bufNr)
            end
        end
    else
        -- Close window containing buffer

        if u.isScratchBuf() then
            -- Close NNP
            if package.loaded["no-neck-pain"] and
                require("no-neck-pain").state.enabled and
                var.fileType == "no-neck-pain" then

                return require("no-neck-pain").toggle()
            end
            -- Scratch files. Override the default behavior, treat it like performing a buffer delete
            if u.bufOccurInWins(var.bufNr) > 1 then
                u.winClose(var.winId)
            else
                bufHandler(false)
            end
        else
            -- Standard buffer
            if u.winsOccur() == 1 then
                -- 1 Window
                -- Override the default behavior, treat it like performing
                -- a buffer delete until there are no more buffers loaded
                bufHandler(false)
            else
                -- 1+ Windows
                -- In situation where there are multiple buffers loaded
                -- with only one standard buffer display in one of the
                -- windows
                local bufInstanceCount = u.bufsOccurInWins()
                if bufInstanceCount ~= 1 then
                    -- Multiple buffer instances or no instances
                    u.winClose(var.winId)
                else
                    -- 1 buffer instance
                    -- Override the default behavior, treat it like performing
                    -- a buffer delete until there are no more buffers loaded
                    bufHandler(false)
                end
            end
        end
    end
end -- }}}


--- Close window safely and wipe buffer without modifying the layout
--- @param type string Expect string value. possible value: "buffer", "window"
function M.init(type) -- {{{
    u.initBuf()

    if type == "window" then
        winHandler()
    elseif type == "buffer" then
        bufHandler(true)
    end
end -- }}}

return M
