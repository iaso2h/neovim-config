-- File: /buf/close.lua
-- Author: iaso2h
-- Description: Delete buffer without change the window layout
-- Similar Work: https://github.com/ojroques/nvim-bufdel
-- Version: 0.1.0
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


local specialBufHandler = function()
    if var.bufType == "nofile" then
        -- Commandline expand window which can be accessed by pressing <C-f>
        if var.fileType == "tsplayground" then
            vim.cmd [[TSPlaygroundToggle]]
            return true
        elseif var.fileType == "DiffviewFileHistory" then
            vim.cmd [[DiffviewClose]]
            return true
        elseif string.match(var.bufName, [[%[nvim%-lua%]$]]) then
            -- Check for Lua pad
            if u.bufsOccurInWins() >= 1 then
                u.bufSwitchAlter()
            else
                -- HACK: hmm mm... I wonder when will this happen
                u.bufClose(nil, false)
                return vim.notify("Closing lua pad", vim.log.levels.ERROR)
            end
            return true
        end
    elseif var.bufType == "nowrite" then
        if vim.startswith(var.bufName, "diffview") then
            vim.cmd [[DiffviewClose]]
            return true
        end
    elseif var.bufType == "prompt" then
        if var.fileType == "vim" then
            -- This buffer shows up When you hit CTRL-F on commandline
            vim.api.nvim_feedkeys(t "<CMD>q<CR>", "t", false)
            return true
        end
    end

    -- Fail to resolve this special buffer
    return false
end



--- Close buffer in a smart way
local function bufHandler() -- {{{
    -- Close buffer depending on whether it's a scratch buffer
    if u.isSpecialBuf(var.bufNr) then
        -- Call `specialBufHandler` in the condition check to deal with
        -- special buffers first, if it's evaluated to false then execute the
        -- nested code block
        if not specialBufHandler() then
            if not saveModified(var.bufNr) then return end
            u.bufClose(nil, true)
        end
        var.lastClosedFilePath = nil
    else
        -- Scratch files
        if u.isScratchBuf() then
            -- Close NNP
            if package.loaded["no-neck-pain"] and
                require("no-neck-pain").state.enabled and
                var.fileType == "no-neck-pain" then

                return require("no-neck-pain").toggle()
            end

            -- Abort the processing when cancel is input
            if not saveModified(var.bufNr) then return end

            if #var.bufNrs > 1 then
                return u.bufClose(nil, true)
            else
                -- This's the last resort of Neovim
                return vim.cmd("q!")
            end
        end

        -- Standard buffer: buffer that has a non-empty buffer name and listed in buffer list-- {{{
        -- Store closed file path
        var.lastClosedFilePath = vim.fn.expand("%:p")

        -- Always prompt for unsaved change, so that buffer is ready to be
        -- deleted safely. Abort the processing when false is evaluated
        if not saveModified(var.bufNr) then return end

        -- When it comes down to only 1 buffer in 1 window, Neovim
        -- will open up a scratch buffer automatically as the last
        -- resort after wiping out the last standard buffer. We then
        -- use that scratch buffer to setup a historyStartup buffer
        if u.bufsNonScratchOccurInWins() == 1 then
            u.bufClose()
            local postBufNr = vim.api.nvim_get_current_buf()
            if u.isScratchBuf(postBufNr) then
                return require("historyStartup").display(true)
            else
                -- HACK: hmm mm... I wonder when will this happen
                Print(var.bufNrs)
                return vim.notify(
                    "Unabled to enter the historyStartup correctly for the last scratch file",
                    vim.log.levels.ERROR)
            end
        else
            return u.bufClose(nil, true)
        end


        -- 1+ Windows

        -- Loop through `var.winIds` to check other windows contain the same
        -- buffer number as the one we are going to wipe
        u.bufClose(nil, false)


        -- Always restore window focus, window might be unavailable when the
        -- last buffer is deleted
        if vim.api.nvim_win_is_valid(var.winId) then
            vim.api.nvim_set_current_win(var.winId)
        end

        -- Merge when there are two windows sharing the last buffer
        -- The updated value of `#bufNrTbl` should be 1, but I don't bother
        -- re-calculating it
        if u.winsOccur() == 2 and u.bufOccurInWins() == 2 and #var.bufNrs == 2 then
            vim.cmd "only"
        end
         -- }}}
    end
end -- }}}


local winHandler = function() -- {{{
    local fallback = function()
        if u.winsOccur() > 1 and u.bufsOccurInWins() > 1 then
            u.winClose(var.winId)
        else
            bufHandler()
        end
    end


    if u.isSpecialBuf(var.bufNr) then
        -- Call `specialBufHandler` in the condition check to deal with
        -- special buffers first, if it's evaluated to false then use the
        -- fallback method
        if not specialBufHandler() then
            fallback()
        end
    else
        -- Close window containing buffer
        if u.isScratchBuf() and package.loaded["no-neck-pain"] and
                require("no-neck-pain").state.enabled and
                var.fileType == "no-neck-pain" then

            return require("no-neck-pain").toggle()
        else
            -- Standard buffer
            fallback()
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
        bufHandler()
    end
end -- }}}

return M
