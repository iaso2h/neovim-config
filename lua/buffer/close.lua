-- File: /buf/close.lua
-- Author: iaso2h
-- Description: Deleting buffer without changing the window layout
-- Version: 0.1.9
-- Last Modified: 2023-10-23
local u   = require("buffer.util")
local var = require("buffer.var")
local M   = {}


--- Prompt for saving changes
---@param bufNr integer Buffer number handler
---@return boolean # `false` will be returned if cancel in input, otherwise true will be return
local function saveModified(bufNr) -- {{{
    if not vim.api.nvim_buf_is_valid(bufNr) then return false end

    if not vim.api.nvim_buf_get_option(bufNr, "modified") then
        return true
    else
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
    end
end -- }}}
--- Go through different special buffers to delete them properly
---@param postRearrange boolean Whether to rearrange the layout after the deleting the buffer
---@param handler string `"buffer"|"window"` Define the specific way to deal with some special buffers
---@return boolean # `false` will be return if failed to resolve the special buffer
local specialBufHandler = function(postRearrange, handler) -- {{{
    if var.bufType == "nofile" then
        if var.fileType == "tsplayground" then
            vim.cmd [[TSPlaygroundToggle]]
            return true
        elseif var.fileType == "DiffviewFileHistory" then
            vim.cmd [[DiffviewClose]]
            return true
        elseif var.fileType == "NvimTree" then
            require("nvim-tree-api").tree.close()
            return true
        elseif string.match(var.bufName, [[%[nvim%-lua%]$]]) then
            -- Check for Lua pad
            -- The nvim-lua buffer is already included in the `var.bufNrs`
            if u.bufsOccurInWins() >= 2 and postRearrange then
                u.bufSwitchAlter()
            else
                require("historyStartup").display(true)
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
            -- Commandline expand window which can be accessed by pressing <C-f>
            vim.api.nvim_feedkeys(t "<CMD>q<CR>", "tn", false)
            return true
        end
    end

    return false
end -- }}}
--- Handler function for closing special buffers, scratch buffers and standard buffers in smart way. The buffer is in good hand.
---@param postRearrange boolean Whether to rearrange the layout after the deleting the buffer
---@param isSpecial boolean Whether this buffer is a special buffer
M.bufHandler = function(postRearrange, isSpecial) -- {{{
    if isSpecial or u.isSpecialBuf() then
        if not specialBufHandler(postRearrange, "buffer") then
            if not saveModified(var.bufNr) then return end
            u.bufClose(nil, true)
        end
        var.lastClosedFilePath = nil
    else
        if u.isScratchBuf() then -- {{{
            -- Close NNP
            if package.loaded["no-neck-pain"] and
                require("no-neck-pain").state.enabled and
                var.fileType == "no-neck-pain" then

                return require("no-neck-pain").toggle()
            end

            if not saveModified(var.bufNr) then return end

            if not postRearrange then
                return u.bufClose(nil, true)
            else
                if #var.bufNrs > 1 then
                    return u.bufClose(nil, true)
                else
                    -- This's the last resort of Neovim
                    return vim.cmd("q!")
                end
            end
        end -- }}}

        -- Standard buffer: buffer that has a non-empty buffer name and listed in buffer list-- {{{
        -- For future retrieving
        var.lastClosedFilePath = var.bufName

        if not saveModified(var.bufNr) then return end

        if not postRearrange then
            return u.bufClose(nil, true)
        end

        if u.bufsNonScratchOccurInWins() == 1 and #var.bufNrs == 1 then
            u.bufClose(nil, false)

            if not require("historyStartup").isLoaded() then
                -- Neovim will crate a scratch buffer automatically as the
                -- last resort after wiping out the last standard buffer. We
                -- then use that scratch buffer to setup a historyStartup
                -- buffer
                local postBufNr = vim.api.nvim_get_current_buf()
                if u.isScratchBuf(postBufNr) then
                    return require("historyStartup").display(true)
                else
                    -- HACK: hmm mm... I wonder when will this happen
                    Print('DEBUGPRINT[1]: close.lua:146: postBufNr=' .. vim.inspect(postBufNr))
                    Print('DEBUGPRINT[1]: close.lua:147: var.bufNrs=' .. vim.inspect(var.bufNrs))
                    return vim.notify(
                        "Unabled to enter the historyStartup correctly for the last scratch file",
                        vim.log.levels.ERROR)
                end
            else
                -- Use the existing historyStartup as the only buffer in one window
                if u.winsOccur() > 1 then
                    local bufNr = vim.api.nvim_get_current_buf()
                    vim.api.nvim_win_set_buf(var.winId, require("historyStartup").initBuf)
                    vim.api.nvim_buf_delete(bufNr, {unload = false})
                    return vim.cmd [[only]]
                end
            end
        end

        u.bufClose(nil, true)

        -- Merge when there are two windows sharing the last buffer
        -- The updated value of `#bufNrTbl` should be 1, but I don't bother
        -- re-calculating it
        if u.winsOccur() == 2 and u.bufOccurInWins() == 2 and #var.bufNrs == 2 then
            vim.cmd "only"
        end
         -- }}}
    end
end -- }}}
--- Handler function for closing window
---@param resortToBufClose boolean Set it to true to call `bufHandler` to close the window like closing a buffer when necessary
M.winHandler = function(resortToBufClose) -- {{{
    local fallback = function(isSpecial) -- {{{
        if resortToBufClose then
            if u.winsOccur() > 1 then
                if u.bufsOccurInWins() == 0 then
                    M.bufHandler(true, isSpecial)
                elseif u.bufsOccurInWins() == 1 then
                    if u.isSpecialBuf() then
                        u.winClose()
                    else
                        M.bufHandler(true, isSpecial)
                    end
                else
                    u.winClose()
                end
            else
                M.bufHandler(true, isSpecial)
            end
        else
            u.winClose()
        end
    end -- }}}

    if u.isSpecialBuf() then
        if not specialBufHandler(true, "window") then
            fallback(true)
        end
    else
        if u.isScratchBuf() and package.loaded["no-neck-pain"] and
            require("no-neck-pain").state.enabled and
            var.fileType == "no-neck-pain" then
            return require("no-neck-pain").toggle()
        else
            -- Standard buffer
            fallback(false)
        end
    end
end -- }}}
--- Close window safely and wipe buffer without modifying the layout. The window handler function and the buffer handler function both follow the pattern that deal with special buffer first, then scratch buffer, then the standard buffers
---@param type string Expect string value. Possible value: "buffer", "window"
 M.deleteBufferOrWindow = function(type) -- {{{
    u.initBuf()

    if type == "window" then
        M.winHandler(true)
    elseif type == "buffer" then
        M.bufHandler(true, false)
    end
end -- }}}

return M
