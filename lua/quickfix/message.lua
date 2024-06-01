-- File: message.lua
-- Author: iaso2h
-- Description: Redirect message to either a quickfix window or a scratch buffer
-- Version: 0.0.10
-- Last Modified: Sat 06 May 2023
-- TODO: live update

--- Pip neovim message into quickfix
--- Capture messages output and get ready to redirect
---@return table, table
local getMsg = function()
    local msgOutput = vim.api.nvim_exec2("messages", {output = true}).output
    local msgs = vim.split(msgOutput, "\n", {plain = true})
    if not next(msgs) then
        return vim.notify("No messages", vim.log.levels.INFO)
    end

    -- Refine and format
    local errorLineNrs = {}
    local checkIndent = false
    local msgsRefined = {}
    for _, m in ipairs(msgs) do -- {{{
        if m ~= "" then

            -- Replace special characters
            if checkIndent then
                local changeTick = false
                for _, pat in ipairs({"^\t", "^%^I"}) do
                    if string.find(m, pat) then
                        local msgRefined, occurrence = string.gsub(m, pat, string.rep(" ", vim.o.tabstop))
                        -- Close check in next iteration
                        if occurrence == 0 then
                            checkIndent = false
                        else
                            m = msgRefined
                        end
                        changeTick = true
                    end
                end

                if not changeTick then
                    checkIndent = false
                else
                    errorLineNrs[#errorLineNrs+1] = #msgsRefined + 1
                end
            end

            -- Checking vim error code
            if string.find(m, [=[^E%d+: [ABCDEFGHIJKLMNOPQRSTUVWXYZ].*]=]) or
                string.find(m, [[^Error executing vim.schedule lua callback]]) or
                string.find(m, [[^Error executing [lL]ua]]) or
                string.find(m, [[^stack traceback:]]) or
                string.find(m, [[module '.\{-}' not found:$]]) then

                errorLineNrs[#errorLineNrs+1] = #msgsRefined + 1
                -- Change the tick and enter next iteration, check and replace
                -- the indent in the next iteration
                checkIndent = true
            end

            -- Append the msg
            msgsRefined[#msgsRefined+1] = {text = m}

        end
    end -- }}}

    return msgsRefined, errorLineNrs
end

--- Redirect the message to either a scratch buffer or a quickfix window
---@param des string "quickfix" or "scratch"
return function(des) -- {{{
    local msgRefined, errorLineNrs = getMsg()
    if not next(msgRefined) then
        return vim.notify("No messages", vim.log.levels.INFO)
    end

    if des == "quickfix" then
        require("quickfix.highlight").generalClear()
        vim.fn.setqflist({}, "r", {title = "Messages", items = msgRefined})
        vim.cmd [[copen | clast]]

        local ns = vim.api.nvim_create_namespace("myQuickfix")
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        vim.defer_fn(function()
            require("quickfix.highlight").addLines(
                errorLineNrs,
                "ErrorMsg",
                ns
            )
        end, 0)
    elseif des == "scratch" then
        local msg = vim.tbl_map(function(m)
            return m.text
        end, msgRefined)
        _G._message_scratch_buf = require("buffer.util").redirScratch(msg, _G._message_scratch_buf)
        vim.api.nvim_set_option_value("filetype", "Messages", {buf = _G._message_scratch_buf})

        local ns = vim.api.nvim_create_namespace("myQuickfix")
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        require("quickfix.highlight").addLines(
            errorLineNrs,
            "ErrorMsg",
            ns,
            _G._message_scratch_buf
        )
    else
        vim.notify("Doesn't support redirect into " .. des, vim.log.levels.ERROR)
    end

end -- }}}
