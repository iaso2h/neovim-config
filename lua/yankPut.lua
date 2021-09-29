-- File: yankPut
-- Author: iaso2h
-- Description: VSCode like copy in visual, normal, input mode; inplace yank & put and convert put
-- Version: 0.1.1
-- Last Modified: 2021-09-21

local fn       = vim.fn
local cmd      = vim.cmd
local api      = vim.api
local util     = require("util")
local operator = require("operator")
local M = {}

function M.VSCodeLineMove(vimMode, direction) -- {{{
    if not vim.bo.modifiable then return end
    if fn.foldclosed('.') ~= -1 then return end

    local curWinID = api.nvim_get_current_win()
    local cursorPos = api.nvim_win_get_cursor(curWinID)
    local curIndent = fn.indent(cursorPos[1])
    if vimMode == "n" then
        if direction == "down" then
            local nextIndent = fn.indent(cursorPos[1] + 1)
            cmd [[m .+1]]
            if not (nextIndent == curIndent or nextIndent == 0) then
                if vim.o.equalprg == "" then cmd [[noautocmd normal! ==]] end
            end
        elseif direction == "up" then
            local previousIndent = fn.indent(cursorPos[1] - 1)
            cmd [[m .-2]]
            if not (previousIndent == curIndent or previousIndent == 0) then
                if vim.o.equalprg == "" then cmd [[noautocmd normal! ==]] end
            end
        end
    elseif vimMode == "v" then
        if direction == "down" then
            cmd [['<,'>m '>+1]]
        elseif direction == "up" then
            cmd [['<,'>m '<-2]]
        end
        cmd [[noautocmd normal! gv]]
    end
end -- }}}

-- VSCode yank line {{{
function M.VSCodeLineYank(vimMode, direction)
    if not vim.bo.modifiable then return end
    if fn.foldclosed('.') ~= -1 then return end

    util.saveReg()

    -- Duplication {{{
    if string.lower(vimMode) == "v" then
        cmd [[noautocmd normal! gv]]
        -- Visual mode {{{
        local cursor      = api.nvim_win_get_cursor(0)
        local selectStart = api.nvim_buf_get_mark(0, "<")
        local selectEnd   = api.nvim_buf_get_mark(0, ">")
        cmd(string.format("noautocmd %d,%dyank", selectStart[1], selectEnd[1]))
        if direction == "up" then
            if cursor[1] == selectStart[1] then
                cmd [[noautocmd put!]]
                api.nvim_win_set_cursor(0, selectEnd)
            else
                cmd [[noautocmd put]]
                api.nvim_win_set_cursor(0, selectStart)
            end

            cmd([[noautocmd normal! ]] .. vimMode)
            api.nvim_win_set_cursor(0, cursor)
        elseif direction == "down" then
            if cursor[1] == selectStart[1] then
                cmd [[noautocmd put!]]
                api.nvim_win_set_cursor(0, {
                    selectEnd[1] + selectEnd[1] - selectStart[1] + 1,
                    selectEnd[2]
                })
            else
                cmd [[noautocmd put]]
                api.nvim_win_set_cursor(0, {selectEnd[1] + 1, selectStart[2]})
            end

            cmd([[noautocmd normal! ]] .. vimMode)
            api.nvim_win_set_cursor(0, {
                cursor[1] + selectEnd[1] - selectStart[1] + 1, cursor[2]
            })
        end
        -- }}} Visual mode
    elseif vimMode == "n" then
        -- Normal mode {{{
        local cursor = api.nvim_win_get_cursor(0)
        cmd [[noautocmd yank]]
        if direction == "up" then
            cmd [[noautocmd put!]]
            api.nvim_win_set_cursor(0, cursor)
        elseif direction == "down" then
            cmd [[noautocmd put]]
            api.nvim_win_set_cursor(0, {cursor[1] + 1, cursor[2]})
        end
        -- }}} Normal mode
    end
    -- }}} Duplication

    util.restoreReg()
end
-- }}} VSCode yank line

--- Yank text without moving cursor. Also comes with yanked area highlighted
--- @param args table {motionType, vimMode, plugMap}
---        motionType string Motion type by which how the operator perform.
---                    Can be "line", "char" or "block"
---        vimMode    string Vim mode. See: `:help mode()`
---        plugMap    string eg: <Plug>myplug
---        vimMode    string Vim mode. See: `:help mode()`
function M.inplaceYank(args) -- {{{
    -- TODO add opts
    -- opts = opts or {hlGroup="Search", timeout=500}
    local opts = {hlGroup="Search", timeout=500}
    local motionType = args[1]
    local vimMode    = args[2]
    local plugMap    = operator.plugMap
    local curWinID = api.nvim_get_current_win()
    local curBufNr = api.nvim_get_current_buf()
    local posStart = api.nvim_buf_get_mark(0, "[")
    local posEnd   = api.nvim_buf_get_mark(0, "]")

    -- Change position info to (0,0) index based
    if motionType == "line" then
        posStart = {posStart[1] - 1, 0}
        -- Get the exact end position to avoid surprising posEnd value like {88, 2147483647}
        local lines = #api.nvim_buf_get_lines(0, posEnd[1] - 1, posEnd[1], false)[1]
        if lines ~= 0 then
            posEnd = {posEnd[1] - 1, lines - 1}
        else
            -- Avoid negative col index
            posEnd = {posEnd[1] - 1, lines}
        end
    else
        posStart = {posStart[1] - 1, posStart[2]}
        posEnd = {posEnd[1] - 1, posEnd[2]}
    end

    if motionType == "char" then
        cmd [[noautocmd normal! g`[vg`]y]]
        M.lastYankLinewise = false
    elseif motionType == "line" then
        cmd [[noautocmd normal! g`[Vg`]y]]
        M.lastYankLinewise = true
    else
        cmd [[noautocmd normal! gvy]]
        M.lastYankLinewise = false
    end

    -- Create highlight {{{
    local yankHLNS = api.nvim_create_namespace('inplaceYankHL')
    api.nvim_buf_clear_namespace(curBufNr, yankHLNS, 0, -1)

    local region = vim.region(curBufNr, posStart, posEnd, fn.getregtype(),
        vim.o.selection == "inclusive" and true or false)
    for lineNr, cols in pairs(region) do
        api.nvim_buf_add_highlight(curBufNr, yankHLNS, opts["hlGroup"], lineNr, cols[1], cols[2])
    end

    -- Restor cursor position
    api.nvim_win_set_cursor(curWinID, operator.cursorPos)

    vim.defer_fn(function()
        api.nvim_buf_clear_namespace(curBufNr, yankHLNS, 0, -1)
    end, opts["timeout"])
    -- }}} Create highlight

    -- Set last yank extmark
    if not M.lastYankNS then
        M.lastYankNS = api.nvim_create_namespace('lastYank')
    end
    if not M.lastYankExtmark then
        M.lastYankExtmark = api.nvim_buf_set_extmark(curBufNr, M.lastYankNS, posStart[1],
                                                    posStart[2], {
                                                        end_line = posEnd[1],
                                                        end_col = posEnd[2]
                                                    })
    else
        M.lastYankExtmark = api.nvim_buf_set_extmark(curBufNr, M.lastYankNS, posStart[1],
                                                    posStart[2], {
                                                        end_line = posEnd[1],
                                                        end_col = posEnd[2],
                                                        id = M.lastYankExtmark
                                                    })
    end

    if vimMode ~= "n" then
        fn["visualrepeat#set"](t(plugMap))
    end
end -- }}}

function M.inplacePut(vimMode, pasteCMD, opts) -- {{{
    if not vim.bo.modifiable then return end

    opts = opts or {hlGroup="Search", timeout=500}
    local regType   = fn.getregtype()
    local curLine   = api.nvim_get_current_line()
    local curBufNr  = api.nvim_get_current_buf()
    local curWinID  = api.nvim_get_current_win()
    local cursorPos = api.nvim_win_get_cursor(curWinID)

    -- Use extmark to track strating cursor position in normal mode
    local cursorNS
    local cursorExtmark
    if vimMode == "n" then
        cursorNS      = api.nvim_create_namespace("inplacePutCursor")
        cursorExtmark = api.nvim_buf_set_extmark(curBufNr, cursorNS, cursorPos[1] - 1, cursorPos[2], {})
    end

    if regType == "V" or regType == "l" then
        M.lastPutLinewise = true
    else
        M.lastPutLinewise = false
    end

    -- Execute EX command
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

    -- Position of new created content
    local posStart = api.nvim_buf_get_mark(curBufNr, "[")
    local posEnd = api.nvim_buf_get_mark(curBufNr, "]")
    -- Change to 0-based for extmark creation
    posStart = {posStart[1] - 1, posStart[2]}
    posEnd = {posEnd[1] - 1, posEnd[2]}

    -- Format new created content when possible {{{
    -- Create extmark to track position of new content
    M.inplacePutNewContentNS      = api.nvim_create_namespace("inplacePutNewContent")
    -- BUG: can be out of scope
    M.inplacePutNewContentExtmark = api.nvim_buf_set_extmark(curBufNr, M.inplacePutNewContentNS,
                    posStart[1], posStart[2], {end_line = posEnd[1], end_col = posEnd[2]})

    if regType == "v" then
        -- Format current line if new paste content consists a single line
        if vim.o.equalprg == "" then
            local match = string.match(curLine, '%w')
            if not match then cmd [[noautocmd normal! ==]] end
        end
    end
    -- }}} Format new created content when possible

    -- Create highlight {{{
    local putHLNS = api.nvim_create_namespace('inplacePutHL')
    api.nvim_buf_clear_namespace(curBufNr, putHLNS, 0, -1)

    local newContentResExtmark = api.nvim_buf_get_extmark_by_id(curBufNr,
                                                    M.inplacePutNewContentNS,
                                                    M.inplacePutNewContentExtmark,
                                                    {details = true})
    local newContentResStart = {newContentResExtmark[1], newContentResExtmark[2]}
    local newContentResEnd   = {newContentResExtmark[3]["end_row"], newContentResExtmark[3]["end_col"]}
    local region = vim.region(curBufNr, newContentResStart, newContentResEnd,
                            regType, vim.o.selection == "inclusive" and true or false)
    for lineNr, cols in pairs(region) do
        api.nvim_buf_add_highlight(curBufNr, putHLNS, opts["hlGroup"], lineNr, cols[1],
                                cols[2])
    end

    vim.defer_fn(function()
        api.nvim_buf_clear_namespace(curBufNr, putHLNS, 0, -1)
    end, opts["timeout"])
    -- }}} Create highlight

    -- Restore cursor position
    if vimMode == "n" then
        local cursorResExtmark = api.nvim_buf_get_extmark_by_id(curBufNr, cursorNS, cursorExtmark, {})
        api.nvim_win_set_cursor(curWinID, {cursorResExtmark[1] + 1, cursorResExtmark[2]})
        api.nvim_buf_clear_namespace(curBufNr, cursorNS, 0, -1)
    else
        api.nvim_win_set_cursor(curWinID, cursorPos)
    end
end --  }}}

function M.convertPut(pasteCMD, opts) --  {{{
    if not vim.bo.modifiable then return end
    if fn.foldclosed('.') ~= -1 then return end

    opts = opts or {hlGroup="Search", timeout=500}
    local curBufNr = api.nvim_get_current_buf()
    local curWinID = api.nvim_get_current_win()
    local cursorPos   = api.nvim_win_get_cursor(curWinID)
    local regType = fn.getregtype()
    local savRegContent = fn.getreg(vim.v.register, 1)
    local curLine = api.nvim_get_current_line()
    local cursorNS      = api.nvim_create_namespace("inplacePutCursor")
    local cursorExtmark = api.nvim_buf_set_extmark(curBufNr, cursorNS, cursorPos[1] - 1, cursorPos[2], {})

    -- TODO: when convert a V-regtype register int characterwise mode. Always
    -- check new content whether is comment or not. And preserve a additional
    -- spece for comment

    -- Convert register content
    if regType == "v" or regType == "c" then
        fn.setreg(vim.v.register, savRegContent, "V")
    elseif regType == "V" or regType == "l" then
        local filterStr = string.gsub(savRegContent, "\n%s+", " ")
        filterStr       = string.gsub(filterStr, "\n", "")
        filterStr       = string.gsub(filterStr, "^%s+", "")
        fn.setreg(vim.v.register, filterStr, "v")
    else
        return
    end
    -- Execute EX command
    if vim.v.count ~= 0 then
        for _=0, vim.v.count do
            cmd("noautocmd normal! \"" .. vim.v.register .. pasteCMD)
        end
    else
        cmd("noautocmd normal! \"" .. vim.v.register .. pasteCMD)
    end

    -- Position of new created content
    local posStart = api.nvim_buf_get_mark(curBufNr, "[")
    local posEnd = api.nvim_buf_get_mark(curBufNr, "]")
    -- Change to 0-based for extmark creation
    posStart = {posStart[1] - 1, posStart[2]}
    posEnd = {posEnd[1] - 1, posEnd[2]}

    -- Format new created content when possible {{{
    -- Create extmark to track position of new content
    M.inplacePutNewContentNS      = api.nvim_create_namespace("inplacePutNewContent")
    M.inplacePutNewContentExtmark = api.nvim_buf_set_extmark(curBufNr, M.inplacePutNewContentNS,
                posStart[1], posStart[2], {end_line = posEnd[1], end_col = posEnd[2]})

    if regType == "v" or regType == "c" then
        api.nvim_win_set_cursor(curWinID, {posStart[1] + 1, posStart[2]})
        cmd "noautocmd normal! V"
        api.nvim_win_set_cursor(curWinID, {posEnd[1] + 1, posEnd[2]})
        cmd "noautocmd normal! ="
        M.lastPutLinewise = true
        -- Change to 0-based for extmark creation
    elseif regType == "V" or regType == "l" then
        -- Format current line if new paste content consists a single line
        local match = string.match(curLine, '%w')
        if not match then cmd [[noautocmd normal! ==]] end
        M.lastPutLinewise = false
    end
    -- }}} Format new created content when possible

    -- Create highlight {{{
    local putHLNS = api.nvim_create_namespace('inplacePutHL')
    api.nvim_buf_clear_namespace(curBufNr, putHLNS, 0, -1)

    local newContentResExtmark = api.nvim_buf_get_extmark_by_id(curBufNr,
                                            M.inplacePutNewContentNS,
                                            M.inplacePutNewContentExtmark,
                                            {details = true})
    local newContentResStart = {newContentResExtmark[1], newContentResExtmark[2]}
    local newContentResEnd   = {newContentResExtmark[3]["end_row"], newContentResExtmark[3]["end_col"]}
    local region = vim.region(curBufNr, newContentResStart, newContentResEnd,
                            regType, vim.o.selection == "inclusive" and true or false)
    for lineNr, cols in pairs(region) do
        api.nvim_buf_add_highlight(curBufNr, putHLNS, opts["hlGroup"], lineNr, cols[1], cols[2])
    end

    vim.defer_fn(function()
        api.nvim_buf_clear_namespace(curBufNr, putHLNS, 0, -1)
    end, opts["timeout"])
    -- }}} Create highlight

    -- Restore cursor position
    local cursorResExtmark = api.nvim_buf_get_extmark_by_id(curBufNr, cursorNS, cursorExtmark, {})
    api.nvim_win_set_cursor(curWinID, {cursorResExtmark[1] + 1, cursorResExtmark[2]})
    api.nvim_buf_clear_namespace(curBufNr, cursorNS, 0, -1)

    -- Restore register content
    fn.setreg(vim.v.register, savRegContent, regType)
end --  }}}

function M.lastYankPut(hlType) -- {{{
    -- Create jump location in jumplist
    cmd [[normal! mz`z]]

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
        api.nvim_echo({{"No record found on current buffer", "WarningMsg"}}, false, {})
        return
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

