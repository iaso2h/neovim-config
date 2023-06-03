-- File: yankPut
-- Author: iaso2h
-- Description: VSCode like copy in visual, normal, input mode; inplace yank & put and convert put
-- Version: 0.1.21
-- Last Modified: 2023-5-19

local util     = require("util")
local operator = require("operator")
local register = require("register")
local M = {
    hlInterval = 250,
    hlGroup    = "Search",
    hlEnable   = true,

    lastYankNs      = vim.api.nvim_create_namespace("inplaceYank"),
    lastYankExtmark = -1,
    lastYankLinewise = false,
    lastPutNs       = vim.api.nvim_create_namespace("inplacePut"),
    lastPutExtmark  = -1,
    lastPutLinewise = false,
}
-- TODO: test cases


-- TODO: Doesn't support target line number exceeding buffer range

--- Move them up or down just like in VS Code
---@param vimMode string Vim mode. See: `:help mode()`
---@param direction string "up" or "down". Determine wether the lines to go up or down
function M.VSCodeLineMove(vimMode, direction) -- {{{
    if not vim.bo.modifiable then
        return vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
    end
    if vimMode == "n"  then
        ---@diagnostic disable-next-line: param-type-mismatch
        if vim.fn.foldclosed('.') ~= -1 then
            -- UGLY: fix the cursor position so that it's at the top of
            -- the fold line
            if vim.fn.line(".") ~= 1 then
                vim.cmd [[noa norm! kj]]
            else
                vim.cmd [[noa norm! jk]]
            end
            local cursorPos = vim.api.nvim_win_get_cursor(0)
            local foldEnd   = vim.fn.foldclosedend(cursorPos[1])
            if direction == "down" then
                -- Avoid clobbering in other foldclosed lines when they are
                -- adjacent to each others
                if vim.fn.foldclosed(foldEnd + 1) ~= -1 then return end
                pcall(vim.api.nvim_command, string.format([[noautocmd keepjump %d,%dm +%d]], cursorPos[1], foldEnd, foldEnd - cursorPos[1] + 1))
            elseif direction == "up" then
                -- Avoid clobbering in other foldclosed lines when they are
                -- adjacent to each others
                if vim.fn.foldclosed(cursorPos[1] - 1) ~= -1 then return end
                pcall(vim.api.nvim_command, string.format([[noautocmd keepjump %d,%dm %d]], cursorPos[1], foldEnd, -2))
            end
        else
            if direction == "down" then
                pcall(vim.api.nvim_command, [[noautocmd keepjump m .+1]])
            elseif direction == "up" then
                pcall(vim.api.nvim_command, [[noautocmd keepjump m .-2]])
            end
        end
    elseif vimMode == "v" then
        if direction == "down" then
            pcall(vim.api.nvim_command, [[noautocmd keepjump '<,'>m '>+1]])
        elseif direction == "up" then
            pcall(vim.api.nvim_command, [[noautocmd keepjump '<,'>m '<-2]])
        end

        vim.cmd [[noautocmd keepjump normal! gv]]
    end
end -- }}}
--- Duplicate the lines and move them up or down just like in VS Code
---@param vimMode string Vim mode. See: `:help mode()`
---@param direction string "up" or "down". Determine wether the new lines to go up or down
function M.VSCodeLineYank(vimMode, direction) -- {{{
    if not vim.bo.modifiable then
        return vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
    end

    if vimMode == "v" then
        vim.cmd([[noa keepjump norm! gv]])
        local cursorPos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[noa keepjump norm! ]] .. t"<Esc>")

        local visualStart = vim.api.nvim_buf_get_mark(0, "<")
        local visualEnd   = vim.api.nvim_buf_get_mark(0, ">")
        local lineDiff    = visualEnd[1] - visualStart[1] + 1
        local lines = vim.api.nvim_buf_get_lines(0, visualStart[1] - 1, visualEnd[1], false)
        if direction == "up" then
            if cursorPos[1] == visualStart[1] then
                vim.api.nvim_put(lines, "l", false, false)
                vim.api.nvim_win_set_cursor(0, {
                    visualEnd[1], cursorPos[2]
                })
                vim.cmd("noa keepjump norm! V")
                vim.api.nvim_win_set_cursor(0, cursorPos)
            elseif cursorPos[1] == visualEnd[1] then
                vim.api.nvim_put(lines, "l", true, false)
                vim.api.nvim_win_set_cursor(0, visualStart)
                vim.cmd("noa keepjump norm! V")
                vim.api.nvim_win_set_cursor(0, {visualEnd[1], cursorPos[2]})
            end
        elseif direction == "down" then
            if cursorPos[1] == visualStart[1] then
                vim.api.nvim_put(lines, "l", false, false)
                vim.api.nvim_win_set_cursor(0, {
                    visualEnd[1] + lineDiff, cursorPos[2]
                })
                vim.cmd("noa keepjump norm! V")
                vim.api.nvim_win_set_cursor(0, {
                    visualEnd[1] + 1, cursorPos[2]
                })
            elseif cursorPos[1] == visualEnd[1] then
                vim.api.nvim_put(lines, "l", true, false)
                vim.api.nvim_win_set_cursor(0, {
                    visualEnd[1] + 1, cursorPos[2]
                })
                vim.cmd("noa keepjump norm! V")
                vim.api.nvim_win_set_cursor(0, {
                    visualEnd[1] + lineDiff, cursorPos[2]
                })
            end
        end
    else
        if vim.fn.foldclosed('.') ~= -1 then
            -- UGLY: fix the cursor position so that it's at the top of
            -- the fold line
            if vim.fn.line(".") ~= 1 then
                vim.cmd [[noa norm! kj]]
            else
                vim.cmd [[noa norm! jk]]
            end
            local cursorPos = vim.api.nvim_win_get_cursor(0)
            local closeEnd  = vim.fn.foldclosedend(cursorPos[1])
            local lines     = vim.api.nvim_buf_get_lines(0, cursorPos[1] - 1, closeEnd, false)
            if direction == "up" then
                vim.api.nvim_put(lines, "l", false, false)
                vim.cmd [[.foldclose]]
            elseif direction == "down" then
                vim.api.nvim_put(lines, "l", true, false)
                vim.api.nvim_win_set_cursor(0, { cursorPos[1] + 1 + closeEnd - cursorPos[1], cursorPos[2] })
            end
        else
            local cursorPos = vim.api.nvim_win_get_cursor(0)
            local lines = {vim.api.nvim_get_current_line()}
            if direction == "up" then
                vim.api.nvim_put(lines, "l", false, false)
                vim.api.nvim_win_set_cursor(0, { cursorPos[1], cursorPos[2] })
            elseif direction == "down" then
                vim.api.nvim_put(lines, "l", true, false)
                vim.api.nvim_win_set_cursor(0, { cursorPos[1] + 1, cursorPos[2] })
            end
        end
    end
end -- }}}
--- Yank text without moving the cursor
---@param opInfo GenericOperatorInfo
function M.inplaceYank(opInfo) -- {{{
    local opts = {hlGroup=M.hlGroup, timeout=M.hlInterval}
    local plugMap  = operator.plugMap
    local curWinId = vim.api.nvim_get_current_win()
    local curBufNr = vim.api.nvim_get_current_buf()
    local posStart = vim.api.nvim_buf_get_mark(0, "[")
    local posEnd   = vim.api.nvim_buf_get_mark(0, "]")

    local regName
    if vim.o.clipboard == "unnamed" then
        regName = vim.v.register == "*" and '' or '"' .. vim.v.register
    elseif string.find(vim.o.clipboard, "unnamedplus") then
        regName = vim.v.register == "+" and '' or '"' .. vim.v.register
    else
        regName = '"' .. vim.v.register
    end

    -- Change the col info to the end of line if motionType is line-wise
    if opInfo.motionType == "line" then
        -- Get the exact end position to avoid surprising posEnd value like {88, 2147483647}
        local lines = #vim.api.nvim_buf_get_lines(0, posEnd[1] - 1, posEnd[1], false)[1]
        if lines ~= 0 then
            posEnd = {posEnd[1], lines - 1}
        else
            -- Avoid negative col index
            posEnd = {posEnd[1], lines}
        end
    end

    if opInfo.motionType == "char" then
        vim.cmd(string.format([[noautocmd normal! g`[vg`]%sy]], regName))
        M.lastYankLinewise = false
    elseif opInfo.motionType == "line" then
        vim.cmd(string.format([[noautocmd normal! g`[Vg`]%sy]], regName))
        M.lastYankLinewise = true
    else
        vim.cmd(string.format([[noautocmd normal! gv%sy]], regName))
        M.lastYankLinewise = false
    end

    -- Create highlight {{{
    -- Creates a new namespace or gets an existing one.
    local newContentExmark
    if M.hlEnable then
        newContentExmark = util.nvimBufAddHl(
            curBufNr,
            posStart,
            posEnd,
            vim.fn.getregtype(),
            opts.hlGroup,
            opts.timeout,
            M.lastYankNs)
    else
        -- Convert into (0, 0) index
        posStart = {posStart[1] - 1, posStart[2]}
        posEnd   = {posEnd[1] - 1, posEnd[2]}
        newContentExmark = vim.api.nvim_buf_set_extmark(
            curBufNr,
            M.lastYankNs,
            posStart[1],
            posStart[2],
            {
                end_row = posEnd[1],
                end_col = posEnd[2]
            })
    end
    if newContentExmark then M.lastYankExtmark = newContentExmark end
    -- }}} Create highlight

    -- Restor cursor position
    if operator.cursorPos then
        vim.api.nvim_win_set_cursor(curWinId, operator.cursorPos)
        -- Always clear M.cursorPos after restoration to avoid restoring
        -- cursor in after repeat command is performed
        operator.cursorPos = nil
    end

    if opInfo.vimMode ~= "n" then
        if vim.fn.exists("g:loaded_repeat") == 1 then
            vim.fn["visualrepeat#set"](t(plugMap))
        end
    end
end -- }}}
--- Enhanced version of putting text
---@param pasteCMD string The literal Vim Ex-command
---@param vimMode string Vim mode. See: `:help mode()`
local function inplacePutExCmd(pasteCMD, vimMode) -- {{{
        -- Execute traditional EX command
    if vimMode == "n" then
        if vim.v.count ~= 0 then
            for _=0, vim.v.count do
                vim.cmd("noautocmd normal! \"" .. vim.v.register .. pasteCMD)
            end
        else
            vim.cmd("noautocmd normal! \"" .. vim.v.register .. pasteCMD)
        end
    else
        vim.cmd("noautocmd normal! gv\"" .. vim.v.register .. pasteCMD)
    end
end -- }}}
--- Put text inplace
---@param vimMode    string Vim mode. See: `:help mode()`
---@param pasteCMD   string Ex-command to be executed. "p" or "P"
---@param convertPut boolean Wether to convert a "V" type register into "v" type register or vice versa
---@param opts       table
function M.inplacePut(vimMode, pasteCMD, convertPut, opts) -- {{{
    if not vim.bo.modifiable then
        return vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
    end

    local curBufNr      = vim.api.nvim_get_current_buf()
    local curWinId      = vim.api.nvim_get_current_win()

    -- Put cursor at the ends of folded line
    if vim.fn.foldclosed('.') ~= -1 then
        if pasteCMD == "p" then
            local cursorPos = vim.api.nvim_win_get_cursor(curWinId)
            local foldEnd   = vim.fn.foldclosedend(cursorPos[1])
            vim.api.nvim_win_set_cursor(curWinId, {foldEnd, cursorPos[2]})
        else
            -- Make sure cursor is always locate at the fold beginning
            if vim.fn.line(".") ~= 1 then
                vim.cmd [[noa norm! kj]]
            else
                vim.cmd [[noa norm! jk]]
            end
        end
    end

    -- Highlight Configuration
    opts = opts or {hlGroup=M.hlGroup, timeout=M.hlInterval}

    local regTypeSave = vim.fn.getregtype()
    local regTypeNew
    -- "Block-wise type register"
    if regTypeSave:lower() ~= "v" then
    -- if regTypeSave == "\0221" then
        if convertPut then
            return
        else
            return inplacePutExCmd(pasteCMD, vimMode)
        end
    end

    -- Initiation
    local regContentSave = vim.fn.getreg(vim.v.register, 1)
    local regContentNew

    local cursorPos     = vim.api.nvim_win_get_cursor(curWinId)
    local cursorNS      = vim.api.nvim_create_namespace("inplacePutCursor")
    local cursorExtmark = vim.api.nvim_buf_set_extmark(curBufNr, cursorNS, cursorPos[1] - 1, cursorPos[2], {})


    -- Format the register content {{{
    if convertPut then
        -- Convert "v" type register into "V" type register and vice versa

        -- Only support in normal mode
        if vimMode ~= "n" then return end

        register.saveReg()
        if regTypeSave == "v" or regTypeSave == "c" then
            regTypeNew = "V"

            local bufferIndent = vim.fn.indent(cursorPos[1])
            -- Get reindent count
            local reindent  = bufferIndent - register.getIndent(regContentSave)

            -- Reindent the lines if counts do not match up
            if reindent ~= 0 then
                regContentNew = register.reindent(reindent, regContentSave)
            else
                regContentNew = regContentSave
            end

        elseif regTypeSave == "V" or regTypeSave == "l" then
            regTypeNew = "v"
            regContentNew = string.gsub(regContentSave, "\n%s+", " ")
            regContentNew = string.gsub(regContentNew, "\n", "")
            regContentNew = string.gsub(regContentNew, "^%s+", "")
        end

        vim.fn.setreg(vim.v.register, regContentNew, regTypeNew)
    else
        regTypeNew = regTypeSave

        -- Reindent the multiple line register before putting it into the editing buffer
        if regTypeSave == "V" or regTypeSave == "l" then
            local bufferIndent = vim.fn.indent(cursorPos[1])
            -- Get reindent count
            local reindent  = bufferIndent - register.getIndent(regContentSave)
            if reindent ~= 0 then
                regContentNew = register.reindent(reindent, regContentSave)
            else
                regContentNew = regContentSave
            end

            vim.fn.setreg(vim.v.register, regContentNew, regTypeSave)
        end
    end
    -- }}} Format the register content

    inplacePutExCmd(pasteCMD, vimMode)

    -- Create highlight {{{
    -- Position of new created content
    local posStart = vim.api.nvim_buf_get_mark(curBufNr, "[")
    local posEnd = vim.api.nvim_buf_get_mark(curBufNr, "]")
    -- Creates a new namespace or gets an existing one.
    local newContentExmark
    if M.hlEnable then
        newContentExmark = util.nvimBufAddHl(
            curBufNr,
            posStart,
            posEnd,
            regTypeNew,
            opts.hlGroup,
            opts.timeout,
            M.lastPutNs)
    else
        -- Convert into (0, 0) index
        posStart = {posStart[1] - 1, posStart[2]}
        posEnd   = {posEnd[1] - 1, posEnd[2]}
        newContentExmark = vim.api.nvim_buf_set_extmark(
            curBufNr,
            M.lastPutNs,
            posStart[1],
            posStart[2],
            {
                end_row = posEnd[1],
                end_col = posEnd[2]
            })
    end
    if newContentExmark then M.lastPutExtmark = newContentExmark end
    -- }}} Create highlight

    -- Restoration {{{
    -- Restore cursor position
    if vimMode == "n" then
        local cursorResExtmark = vim.api.nvim_buf_get_extmark_by_id(curBufNr, cursorNS, cursorExtmark, {})
        vim.api.nvim_win_set_cursor(curWinId, {cursorResExtmark[1] + 1, cursorResExtmark[2]})
        vim.api.nvim_buf_clear_namespace(curBufNr, cursorNS, 0, -1)
    else
        vim.api.nvim_win_set_cursor(curWinId, cursorPos)
    end
    -- Restore register
    if convertPut then
        register.restoreReg()
    end
    -- }}} Restoration

    -- Record the register type for lastYankPut()
    M.lastPutLinewise = regTypeNew == "V" or regTypeNew == "l"
end --  }}}


return M

