-- File: yankPut
-- Author: iaso2h
-- Description: VSCode like copy in visual, normal, input mode; inplace yank & put and convert put
-- Version: 0.1.17
-- Last Modified: 2023-3-12

local fn       = vim.fn
local cmd      = vim.cmd
local api      = vim.api
local util     = require("util")
local operator = require("operator")
local register = require("register")
local M = {
    hlInterval = 250,
    hlGroup    = "Search",
    hlEnable   = true
}
-- TODO: test cases


function M.VSCodeLineMove(vimMode, direction) -- {{{
    if not vim.bo.modifiable then
        return vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
    end
    ---@diagnostic disable-next-line: param-type-mismatch
    if fn.foldclosed('.') ~= -1 then return end

    if vimMode == "n" then
        if direction == "down" then
            pcall(cmd, [[noautocmd m .+1]])
        elseif direction == "up" then
            pcall(cmd, [[noautocmd m .-2]])
        end
    elseif vimMode == "v" then
        if direction == "down" then
            pcall(cmd, [[noautocmd '<,'>m '>+1]])
        elseif direction == "up" then
            pcall(cmd, [[noautocmd '<,'>m '<-2]])
        end

        cmd [[noautocmd normal! gv]]
    end
end -- }}}


function M.VSCodeLineYank(vimMode, direction) -- {{{
    if not vim.bo.modifiable then
        return vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
    end

    if vimMode == "v" then
        vim.cmd([[noa norm! gv]])
        local cursorPos = api.nvim_win_get_cursor(0)
        vim.cmd([[noa norm! ]] .. t"<Esc>")

        local visualStart = api.nvim_buf_get_mark(0, "<")
        local visualEnd   = api.nvim_buf_get_mark(0, ">")
        local lineDiff    = visualEnd[1] - visualStart[1] + 1
        local lines = api.nvim_buf_get_lines(0, visualStart[1] - 1, visualEnd[1], false)
        if direction == "up" then
            if cursorPos[1] == visualStart[1] then
                api.nvim_put(lines, "l", false, false)
                api.nvim_win_set_cursor(0, {
                    visualEnd[1], cursorPos[2]
                })
                vim.cmd("noa norm! V")
                api.nvim_win_set_cursor(0, cursorPos)
            elseif cursorPos[1] == visualEnd[1] then
                api.nvim_put(lines, "l", true, false)
                api.nvim_win_set_cursor(0, visualStart)
                vim.cmd("noa norm! V")
                api.nvim_win_set_cursor(0, {visualEnd[1], cursorPos[2]})
            end
        elseif direction == "down" then
            if cursorPos[1] == visualStart[1] then
                api.nvim_put(lines, "l", false, false)
                api.nvim_win_set_cursor(0, {
                    visualEnd[1] + lineDiff, cursorPos[2]
                })
                vim.cmd("noa norm! V")
                api.nvim_win_set_cursor(0, {
                    visualEnd[1] + 1, cursorPos[2]
                })
            elseif cursorPos[1] == visualEnd[1] then
                api.nvim_put(lines, "l", true, false)
                api.nvim_win_set_cursor(0, {
                    visualEnd[1] + 1, cursorPos[2]
                })
                vim.cmd("noa norm! V")
                api.nvim_win_set_cursor(0, {
                    visualEnd[1] + lineDiff, cursorPos[2]
                })
            end
        end
    else
        local cursorPos = api.nvim_win_get_cursor(0)
        local currentLine = api.nvim_get_current_line()
        if direction == "up" then
            api.nvim_put({currentLine}, "l", false, false)
            api.nvim_win_set_cursor(0, { cursorPos[1], cursorPos[2] })
        elseif direction == "down" then
            api.nvim_put({ currentLine }, "l", true, false)
            api.nvim_win_set_cursor(0, { cursorPos[1] + 1, cursorPos[2] })
        end
    end
end -- }}}


--- Yank text without moving cursor. Also comes with yanked area highlighted
--- @param args table {motionType, vimMode, plugMap}
---        motionType string Motion type by which how the operator perform.
---                    Can be "line", "char" or "block"
---        vimMode    string Vim mode. See: `:help mode()`
---        plugMap    string eg: <Plug>myplug
---        vimMode    string Vim mode. See: `:help mode()`
function M.inplaceYank(args) -- {{{
    -- opts = opts or {hlGroup="Search", timeout=500}
    local opts = {hlGroup=M.hlGroup, timeout=M.hlInterval}
    local motionType = args[1]
    local vimMode    = args[2]
    local plugMap    = operator.plugMap
    local curWinID   = api.nvim_get_current_win()
    local curBufNr   = api.nvim_get_current_buf()
    local posStart   = api.nvim_buf_get_mark(0, "[")
    local posEnd     = api.nvim_buf_get_mark(0, "]")

    local regName
    if vim.o.clipboard == "unnamed" then
        regName = vim.v.register == "*" and '' or '"' .. vim.v.register
    elseif string.find(vim.o.clipboard, "unnamedplus") then
        regName = vim.v.register == "+" and '' or '"' .. vim.v.register
    else
        regName = '"' .. vim.v.register
    end

    -- Change the col info to the end of line if motionType is line-wise
    if motionType == "line" then
        -- Get the exact end position to avoid surprising posEnd value like {88, 2147483647}
        local lines = #api.nvim_buf_get_lines(0, posEnd[1] - 1, posEnd[1], false)[1]
        if lines ~= 0 then
            posEnd = {posEnd[1], lines - 1}
        else
            -- Avoid negative col index
            posEnd = {posEnd[1], lines}
        end
    end

    if motionType == "char" then
        cmd(string.format([[noautocmd normal! g`[vg`]%sy]], regName))
        M.lastYankLinewise = false
    elseif motionType == "line" then
        cmd(string.format([[noautocmd normal! g`[Vg`]%sy]], regName))
        M.lastYankLinewise = true
    else
        cmd(string.format([[noautocmd normal! gv%sy]], regName))
        M.lastYankLinewise = false
    end

    -- Create highlight {{{
    -- Creates a new namespace or gets an existing one.
    M.lastYankNS = api.nvim_create_namespace("inplacePutNewContent")
    local newContentExmark
    if M.hlEnable then
        newContentExmark = util.nvimBufAddHl(
            curBufNr,
            posStart,
            posEnd,
            fn.getregtype(),
            opts.hlGroup,
            opts.timeout)
    else
        -- Conver into (0, 0) index
        posStart = {posStart[1] - 1, posStart[2]}
        posEnd   = {posEnd[1] - 1, posEnd[2]}
        newContentExmark = api.nvim_buf_set_extmark(
            curBufNr,
            M.lastYankNS,
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
        api.nvim_win_set_cursor(curWinID, operator.cursorPos)
        -- Always clear M.cursorPos after restoration to avoid restoring
        -- cursor in after repeat command is performed
        operator.cursorPos = nil
    end

    if vimMode ~= "n" then
        fn["visualrepeat#set"](t(plugMap))
    end
end -- }}}


--- Execute the Vim Ex command
--- @param pasteCMD string The literal Vim Ex command
--- @param vimMode string Vim mode
local function inplacePutExCmd(pasteCMD, vimMode)
        -- Execute traditional EX command
    if vimMode == "n" then
        if vim.v.count ~= 0 then
            for _=0, vim.v.count do
                cmd("noautocmd normal! \"" .. vim.v.register .. pasteCMD)
            end
        else
            cmd("noautocmd normal! \"" .. vim.v.register .. pasteCMD)
        end
    else
        cmd("noautocmd normal! gv\"" .. vim.v.register .. pasteCMD)
    end
end


--- Put text inplace
--- @param vimMode    string Vim mode. See: `:help mode()`
--- @param pasteCMD   string Normal mode command to execute. "p" or "P"
--- @param convertPut boolean Wether to convert "V" type register into "v"
--- type register or vice versa
--- @param opts       table
function M.inplacePut(vimMode, pasteCMD, convertPut, opts) -- {{{
    if not vim.bo.modifiable then
        return vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
    end
    if fn.foldclosed('.') ~= -1 then return end

    -- Highlight Configuration
    opts = opts or {hlGroup=M.hlGroup, timeout=M.hlInterval}

    local regTypeSave = fn.getregtype()
    local regTypeNew
    -- "Block-wise type register"
    if regTypeSave == "\0221" then
        if convertPut then
            return
        else
            return inplacePutExCmd(pasteCMD, vimMode)
        end
    end

    -- Initiation
    local regContentSave = fn.getreg(vim.v.register, 1)
    local regContentNew

    local curBufNr      = api.nvim_get_current_buf()
    local curWinID      = api.nvim_get_current_win()
    local cursorPos     = api.nvim_win_get_cursor(curWinID)
    local cursorNS      = api.nvim_create_namespace("inplacePutCursor")
    local cursorExtmark = api.nvim_buf_set_extmark(curBufNr, cursorNS, cursorPos[1] - 1, cursorPos[2], {})


    -- Format the register content {{{
    if convertPut then
        -- Convert "v" type register into "V" type register and vice versa

        -- Only support in normal mode
        if vimMode ~= "n" then return end

        register.saveReg()
        if regTypeSave == "v" or regTypeSave == "c" then
            regTypeNew = "V"

            local bufferIndent = fn.indent(cursorPos[1])
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

        fn.setreg(vim.v.register, regContentNew, regTypeNew)
    else
        regTypeNew = regTypeSave

        -- Reindent the multiple line register before putting it into the editing buffer
        if regTypeSave == "V" or regTypeSave == "l" then
            local bufferIndent = fn.indent(cursorPos[1])
            -- Get reindent count
            local reindent  = bufferIndent - register.getIndent(regContentSave)
            if reindent ~= 0 then
                regContentNew = register.reindent(reindent, regContentSave)
            else
                regContentNew = regContentSave
            end

            fn.setreg(vim.v.register, regContentNew, regTypeSave)
        end
    end
    -- }}} Format the register content

    inplacePutExCmd(pasteCMD, vimMode)

    -- Create highlight {{{
    -- Position of new created content
    local posStart = api.nvim_buf_get_mark(curBufNr, "[")
    local posEnd = api.nvim_buf_get_mark(curBufNr, "]")
    -- Creates a new namespace or gets an existing one.
    M.inplacePutNewContentNS = api.nvim_create_namespace("inplacePutNewContent")
    local newContentExmark
    if M.hlEnable then
        newContentExmark = util.nvimBufAddHl(
            curBufNr,
            posStart,
            posEnd,
            regTypeNew,
            opts.hlGroup,
            opts.timeout,
            M.inplacePutNewContentNS)
    else
        -- Conver into (0, 0) index
        posStart = {posStart[1] - 1, posStart[2]}
        posEnd   = {posEnd[1] - 1, posEnd[2]}
        newContentExmark = api.nvim_buf_set_extmark(
            curBufNr,
            M.inplacePutNewContentNS,
            posStart[1],
            posStart[2],
            {
                end_row = posEnd[1],
                end_col = posEnd[2]
            })
    end
    if newContentExmark then M.inplacePutNewContentExtmark = newContentExmark end
    -- }}} Create highlight

    -- Restoration {{{
    -- Restore cursor position
    if vimMode == "n" then
        local cursorResExtmark = api.nvim_buf_get_extmark_by_id(curBufNr, cursorNS, cursorExtmark, {})
        api.nvim_win_set_cursor(curWinID, {cursorResExtmark[1] + 1, cursorResExtmark[2]})
        api.nvim_buf_clear_namespace(curBufNr, cursorNS, 0, -1)
    else
        api.nvim_win_set_cursor(curWinID, cursorPos)
    end
    -- Restore register
    if convertPut then
        register.restoreReg()
    end
    -- }}} Restoration

    -- Record the register type for lastYankPut()
    M.lastPutLinewise = regTypeNew == "V" or regTypeNew == "l"
end --  }}}


function M.lastYankPut(hlType) -- {{{
    -- Create jump location in jumplist
    cmd [[normal! m`]]

    local curBufNr = api.nvim_get_current_buf()
    local curWinID = api.nvim_get_current_win()
    local cursor   = api.nvim_win_get_cursor(curWinID)
    local extmark
    local linewise
    if hlType == "yank" then
        if not M.lastYankNS then return end
        extmark  = api.nvim_buf_get_extmark_by_id(curBufNr, M.lastYankNS,
        M.lastYankExtmark, {details=true})
        linewise = M.lastYankLinewise
    elseif hlType == "put" then
        if not M.inplacePutNewContentNS then return end
        extmark  = api.nvim_buf_get_extmark_by_id(curBufNr, M.inplacePutNewContentNS,
        M.inplacePutNewContentExtmark, {details=true})
        linewise = M.lastPutLinewise
    end
    -- Check valid extmark
    if not next(extmark) then
        return vim.notify("No record found on current buffer", vim.log.levels.WARN)
    end

    local selectStart = {extmark[1] + 1, extmark[2]}
    local selectEnd   = {extmark[3]["end_row"] + 1, extmark[3]["end_col"]}

    -- Determine select directioin
    local startDist = util.posDist(cursor, selectStart)
    local endDist   = util.posDist(cursor, selectEnd)
    if startDist < endDist then
        if linewise then
            api.nvim_win_set_cursor(curWinID, selectEnd)
            cmd [[noautocmd normal! V]]
            api.nvim_win_set_cursor(curWinID, {selectStart[1], cursor[2]})
        else
            api.nvim_win_set_cursor(curWinID, selectEnd)
            cmd [[noautocmd normal! v]]
            api.nvim_win_set_cursor(curWinID, selectStart)
        end
    else
        if linewise then
            api.nvim_win_set_cursor(curWinID, selectStart)
            cmd [[noautocmd normal! V]]
            api.nvim_win_set_cursor(curWinID, {selectEnd[1], cursor[2]})
        else
            api.nvim_win_set_cursor(curWinID, selectStart)
            cmd [[noautocmd normal! v]]
            api.nvim_win_set_cursor(curWinID, selectEnd)
        end
    end

    return 0
end -- }}}

return M

