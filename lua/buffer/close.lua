-- File: /buf/close.lua
-- Author: iaso2h
-- Description: Delete buffer without change the window layout
-- Similar Work: https://github.com/ojroques/nvim-bufdel
-- Version: 0.0.40
-- Last Modified: 05/02/2023 Tue
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
                vim.cmd "update!"
                return true
            elseif answer == 2 then
                vim.cmd "noa update!"
                return true
            elseif answer == 3 then
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

    if u.isSpecialBuf(var.bufNr) then
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
                if u.bufsOccurInWins() >= 1 then
                    u.bufSwitchAlter(var.winId)
                else
                    u.bufClose(var.bufNr)
                end
            end
        elseif var.bufType == "prompt" then
            u.bufClose(var.bufNr)
        elseif var.bufType == "nowrite" then
            if vim.startswith(var.bufName, "diffview") then
                return vim.cmd [[DiffviewClose]]
            end
        end

        -- Fallback method
        u.bufSwitchAlter(var.winId)
        if not saveModified(var.bufNr) then return end
        u.bufClose(var.bufNr)
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

            if u.bufsOccurInWins() > 1 then
                u.bufSwitchAlter(var.winId)
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
            if u.bufsNonScratchOccurInWins() == 1 then
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
                u.bufSwitchAlter(var.winId)
                return u.bufClose(var.bufNr)
            end
        end


        -- 1+ Windows

        -- Loop through `var.winIds` to check other windows contain the same
        -- buffer number as the one we are going to wipe
        local occurs, occurWinIds = u.bufOccurInWins(var.bufNr)
        if occurs == 1 then
            u.bufSwitchAlter(var.winId)
            u.bufClose(var.bufNr)
        else
            for _, winId in pairs(occurWinIds) do
                u.bufSwitchAlter(winId)
            end
            u.bufClose(var.bufNr)
        end

        -- Always restore window focus, window might be unavailable when the
        -- last buffer is deleted
        if vim.api.nvim_win_is_valid(var.winId) then
            vim.api.nvim_set_current_win(var.winId)
        end

        -- Merge when there are two windows sharing the last buffer
        -- The updated value of `#bufNrTbl` should be 1, but I don't bother
        -- re-calculating it
        if u.winsOccur() == 2 and u.bufOccurInWins(var.bufNr) == 2 and #var.bufNrs == 2 then
            vim.cmd "only"
        end
         -- }}}Standard buffer
    end
end -- }}}


local winHandler = function() -- {{{
    if u.isSpecialBuf(var.bufNr) then
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
            end
        elseif var.bufType == "nowrite" then
            if vim.startswith(var.bufName, "diffview") then
                return vim.cmd [[DiffviewClose]]
            end
        elseif var.bufType == "terminal" then
            u.winClose(var.winId)
        end

        -- Fallback method
        if u.winsOccur() > 1 and u.bufsOccurInWins() ~= 0 then
            u.winClose(var.winId)
        else
            bufHandler(false)
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
