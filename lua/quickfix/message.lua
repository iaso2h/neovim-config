-- File: cc.lua
-- Author: iaso2h
-- Description: Enhance version of the :cc
-- Version: 0.0.7
-- Last Modified: Mon 01 May 2023
-- TODO: live update

local filterChk = false

--- Pip neovim message into quickfix
--- Capture messages output and get ready to redirect
---@return table, table
local getMsg = function()
    local msg = vim.api.nvim_cmd({cmd = "messages"}, {output = true})
    local function split(str, sep)
        local result = {}
        local regex = ("([^%s]+)"):format(sep)
        for each in str:gmatch(regex) do
            table.insert(result, each)
        end
        return result
    end

    local msgTbl = split(msg, "\n")

    -- Filter messages
    if filterChk then
        msgTbl = vim.tbl_filter(function(m)
            local regex1 = vim.regex([=[^\d\+ more line\(s\)\?;]=])
            local regex2 = vim.regex([=[^\d\+ lines\? less;]=])
            local regex3 = vim.regex([=[^\d\+ fewer line\(s\)\?$]=])
            local regex4 = vim.regex([=[^\d\+ change\(s\)\?; \(before\|after\) #\d\+]=])
            if not regex1:match_str(m) and
                not regex2:match_str(m) and
                not regex3:match_str(m) and
            not regex4:match_str(m) then
                return true end
            -- if string.match(m, [=[%d more line; before]=])
        end, msgTbl)
    end
    if not next(msgTbl) then
        return vim.notify("No messages", vim.log.levels.INFO)
    end

    -- Refine and format
    local errorLineNrTbl = {}
    local checkIndent = false
    local msgRefinedTbl = {}
    for _, m in ipairs(msgTbl) do -- {{{
        -- Replace special characters
        if checkIndent then
            if string.find(m, "^\t") then
                local reindentMsg = string.gsub(m, "^\t", string.rep(" ", vim.o.tabstop))
                -- Close check in next iteration
                if m == reindentMsg then
                    checkIndent = false
                else
                    m = reindentMsg
                end
            elseif string.find(m, "^%^I") then
                local indentMsg = string.gsub(m, "^%^I", string.rep(" ", vim.o.tabstop))
                -- Close check in next iteration
                if m == indentMsg then
                    checkIndent = false
                else
                    m = indentMsg
                end
            else
                checkIndent = false
            end
        end
        msgRefinedTbl[#msgRefinedTbl+1] = {text = m}

        -- Checking vim error code
        if string.find(m, [=[^E%d+: .*[^:]$]=]) or
        string.find(m, [[^Error executing vim.schedule lua callback]]) then
            errorLineNrTbl[#errorLineNrTbl+1] = #msgRefinedTbl
            checkIndent = true
        else
            if string.find(m, [[^E%d+: .*:$]]) or
                string.find(m, [[^stack traceback:]]) or
                string.find(m, [[^Error executing l?L?ua]]) or
                string.find(m, [[module '.\{-}' not found:$]])
                then
                -- Checking indent in the follow iteration
                errorLineNrTbl[#errorLineNrTbl+1] = #msgRefinedTbl
                checkIndent = true
            end
        end
    end -- }}}

    return msgRefinedTbl, errorLineNrTbl
end

return function(des) -- {{{
    local msgTbl, errorLineNrTbl = getMsg()

    if des == "quickfix" then
        require("quickfix.highlight").clear()
        vim.fn.setqflist({}, "r", {title = "Messages", items = msgTbl})
        vim.cmd [[copen | clast]]

        local ns = vim.api.nvim_create_namespace("myQuickfix")
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        vim.defer_fn(function()
            require("quickfix.highlight").addLines(
                errorLineNrTbl,
                "ErrorMsg",
                ns
            )
        end, 0)
    elseif des == "scratch" then
        local msg = vim.tbl_map(function(m)
            return m.text
        end, msgTbl)
        if _G._message_scratch_buf and vim.api.nvim_buf_is_valid(_G._message_scratch_buf) then
            -- if scratch buffer is visible, populate the date into it
            local visibleTick = false
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == _G._message_scratch_buf then
                    vim.api.nvim_buf_set_lines(_G._message_scratch_buf, 0, -1, false, msg)
                    vim.api.nvim_win_set_cursor(win, {#msg, 0})
                    visibleTick = true
                    break
                end
            end
            if not visibleTick then
                vim.cmd [[vsplit]]
                vim.api.nvim_set_current_buf(_G._message_scratch_buf)
                vim.api.nvim_buf_set_lines(_G._message_scratch_buf, 0, -1, false, msg)
                vim.api.nvim_win_set_cursor(0, {#msg, 0})
                vim.cmd "wincmd p"
            end
        elseif vim.api.nvim_buf_get_name(0) == "" and vim.bo.modifiable and
                vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
            -- Use current file as the scratch buffer
            _G._message_scratch_buf = vim.api.nvim_get_current_buf()
            vim.api.nvim_buf_set_option(_G._message_scratch_buf, "buflisted", false)
            vim.api.nvim_buf_set_option(_G._message_scratch_buf, "bufhidden", "wipe")
            vim.api.nvim_buf_set_option(_G._message_scratch_buf, "buftype", "nofile")
            vim.api.nvim_buf_set_lines(_G._message_scratch_buf, 0, -1, false, msg)
            vim.cmd "noa keepjumps G"
        else
            -- TODO: how to determine performing a vertical split or a horizontal split
            vim.cmd [[vsplit]]
            _G._message_scratch_buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_option(_G._message_scratch_buf, "bufhidden", "wipe")
            vim.api.nvim_set_current_buf(_G._message_scratch_buf)
            vim.api.nvim_put(msg, "l", true, true)
            vim.api.nvim_buf_set_lines(_G._message_scratch_buf, 0, -1, false, msg)
            vim.api.nvim_win_set_cursor(0, {#msg, 0})
            vim.cmd "wincmd p"
        end

        local ns = vim.api.nvim_create_namespace("myQuickfix")
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        require("quickfix.highlight").addLines(
            errorLineNrTbl,
            "ErrorMsg",
            ns,
            _G._message_scratch_buf
        )
    else
        vim.notify("Doesn't support redirect into " .. des, vim.log.levels.ERROR)
    end

end -- }}}
