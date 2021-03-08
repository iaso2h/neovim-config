local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local M = {}
local util = require("util")
local operator = require("operator")

-- VSCode copy line {{{
function M.VSCodeLineYank(visualMode, direction)
    util.saveReg()

    -- Duplication {{{
    if string.lower(visualMode) == "v" then
        -- Visual mode {{{
        local cursor = api.nvim_win_get_cursor(0)
        local selectStart = api.nvim_buf_get_mark(0, "<")
        local selectEnd = api.nvim_buf_get_mark(0, ">")
        cmd(string.format("%d,%dyank", selectStart[1], selectEnd[1]))
        if direction == "up" then
            if cursor[1] == selectStart[1] then
                cmd [[put!]]
                api.nvim_win_set_cursor(0, selectEnd)
            else
                cmd [[put]]
                api.nvim_win_set_cursor(0, selectStart)
            end

            cmd([[normal! ]] .. visualMode)
            api.nvim_win_set_cursor(0, cursor)
        elseif direction == "down" then
            if cursor[1] == selectStart[1] then
                cmd [[put!]]
                api.nvim_win_set_cursor(0, {
                    selectEnd[1] + selectEnd[1] - selectStart[1] + 1,
                    selectEnd[2]
                })
            else
                cmd [[put]]
                api.nvim_win_set_cursor(0, {selectEnd[1] + 1, selectStart[2]})
            end

            cmd([[normal! ]] .. visualMode)
            api.nvim_win_set_cursor(0, {
                cursor[1] + selectEnd[1] - selectStart[1] + 1, cursor[2]
            })
        end
        -- }}} Visual mode
    elseif visualMode == "n" then
        -- Normal mode {{{
        local cursor = api.nvim_win_get_cursor(0)
        cmd [[yank]]
        if direction == "up" then
            cmd [[put!]]
            api.nvim_win_set_cursor(0, cursor)
        elseif direction == "down" then
            cmd [[put]]
            api.nvim_win_set_cursor(0, {cursor[1] + 1, cursor[2]})
        end
        -- }}} Normal mode
    end
    -- }}} Duplication

    util.restoreReg()
end
-- }}} VSCode copy line

function M.inplaceYank(argTbl, opts) -- {{{
    opts = opts or {hlGroup="Search", timeout=500}
    local modeType = argTbl[1]
    local curWinID = api.nvim_get_current_win()
    local curBufNr = api.nvim_get_current_buf()
    local pos1 = api.nvim_buf_get_mark(0, "[")
    local pos2 = api.nvim_buf_get_mark(0, "]")
    if modeType == "line" then
        pos1 = pos1[1] == operator.nvimOperatorCursor[1] and {pos1[1] - 1, 0} or
                                                {pos1[1] - 1, pos1[2]}
        pos2 = {
            pos2[1] - 1, #api.nvim_buf_get_lines(0, pos2[1] - 1, pos2[1], false)[1] - 1
        }
    else
        pos1 = {pos1[1] - 1, pos1[2]}
        pos2 = {pos2[1] - 1, pos2[2]}
    end

    if modeType == "char" then
        cmd [[normal! g`[vg`]y]]
        M.lastYankLinewise = false
    elseif modeType == "line" then
        cmd [[normal! g`[Vg`]y]]
        M.lastYankLinewise = true
    else
        cmd [[normal! gvy]]
        M.lastYankLinewise = false
    end

    -- Create highlight {{{
    local yankHLNS = api.nvim_create_namespace('inplaceYankHL')
    api.nvim_buf_clear_namespace(curBufNr, yankHLNS, 0, -1)

    local region = vim.region(curBufNr, pos1, pos2, fn.getregtype(),
    vim.o.selection == "inclusive" and true or false)
    for lineNr, cols in pairs(region) do
        api.nvim_buf_add_highlight(curBufNr, yankHLNS, opts["hlGroup"], lineNr, cols[1],
        cols[2])
    end

    -- Restor cursor position
    api.nvim_win_set_cursor(curWinID, operator.nvimOperatorCursor)

    vim.defer_fn(function()
        api.nvim_buf_clear_namespace(curBufNr, yankHLNS, 0, -1)
    end, opts["timeout"])
    -- }}} Create highlight

    -- Set last yank extmark
    if not M.lastYankNS then
        M.lastYankNS = api.nvim_create_namespace('lastYank')
    end
    if not M.lastYankExtmark then
        M.lastYankExtmark = api.nvim_buf_set_extmark(curBufNr, M.lastYankNS, pos1[1],
                                                    pos1[2], {
                                                        end_line = pos2[1],
                                                        end_col = pos2[2]
                                                    })
    else
        M.lastYankExtmark = api.nvim_buf_set_extmark(curBufNr, M.lastYankNS, pos1[1],
                                                    pos1[2], {
                                                        end_line = pos2[1],
                                                        end_col = pos2[2],
                                                        id = M.lastYankExtmark
                                                    })
    end

end -- }}}

function M.inplacePut(modeType, pasteCMD, opts) -- {{{
    opts = opts or {hlGroup="Search", timeout=500}
    local regType   = fn.getregtype()
    local curLine   = api.nvim_get_current_line()
    local curBufNr  = api.nvim_get_current_buf()
    local curWinID  = api.nvim_get_current_win()
    local cursorPos = api.nvim_win_get_cursor(curWinID)

    -- Use extmark to track strating cursor position in normal mode
    local cursorNS
    local cursorExtmark
    if modeType == "n" then
        cursorNS      = api.nvim_create_namespace("inplacePutCursor")
        cursorExtmark = api.nvim_buf_set_extmark(curBufNr, cursorNS, cursorPos[1] - 1, cursorPos[2], {})
    end

    -- Execute EX command
    if modeType == "n" then
        if vim.v.count ~= 0 then
            for _=0, vim.v.count do
                cmd("normal! \"" .. vim.v.register .. pasteCMD)
            end
        else
            cmd("normal! \"" .. vim.v.register .. pasteCMD)
        end
    else
        cmd("normal! gv\"" .. vim.v.register .. pasteCMD)
    end

    -- Position of new created content
    local pos1 = api.nvim_buf_get_mark(curBufNr, "[")
    local pos2 = api.nvim_buf_get_mark(curBufNr, "]")
    -- Change to 0-based for extmark creation
    pos1 = {pos1[1] - 1, pos1[2]}
    pos2 = {pos2[1] - 1, pos2[2]}

    -- Format new created content when possible {{{
    -- Create extmark to track position of new content
    M.inplacePutNewContentNS      = api.nvim_create_namespace("inplacePutNewContent")
    M.inplacePutNewContentExtmark = api.nvim_buf_set_extmark(curBufNr, M.inplacePutNewContentNS,
                    pos1[1], pos1[2], {end_line = pos2[1], end_col = pos2[2]})

    if regType == "V" or regType == "l" then
        api.nvim_win_set_cursor(curWinID, {pos1[1] + 1, pos1[2]})
        cmd "normal! V"
        api.nvim_win_set_cursor(curWinID, {pos2[1] + 1, pos2[2]})
        cmd "normal! ="
        M.lastPutLinewise = true
        -- Change to 0-based for extmark creation
    else
        -- Format current line if new paste content consists a single line
        local match = string.match(curLine, '%w')
        if not match then cmd [[normal! ==]] end
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
        api.nvim_buf_add_highlight(curBufNr, putHLNS, opts["hlGroup"], lineNr, cols[1],
                                cols[2])
    end

    vim.defer_fn(function()
        api.nvim_buf_clear_namespace(curBufNr, putHLNS, 0, -1)
    end, opts["timeout"])
    -- }}} Create highlight

    -- Restore cursor position
    if modeType == "n" then
        local cursorResExtmark = api.nvim_buf_get_extmark_by_id(curBufNr, cursorNS, cursorExtmark, {})
        api.nvim_win_set_cursor(curWinID, {cursorResExtmark[1] + 1, cursorResExtmark[2]})
        api.nvim_buf_clear_namespace(curBufNr, cursorNS, 0, -1)
    else
        api.nvim_win_set_cursor(curWinID, cursorPos)
    end
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
            cmd [[normal! V]]
            api.nvim_win_set_cursor(curWinID, {selectStart[1], cursor[2]})
        else
            api.nvim_win_set_cursor(curWinID, selectEnd)
            cmd [[normal! v]]
            api.nvim_win_set_cursor(curWinID, selectStart)
        end
    else
        if linewise then
            api.nvim_win_set_cursor(curWinID, selectStart)
            cmd [[normal! V]]
            api.nvim_win_set_cursor(curWinID, {selectEnd[1], cursor[2]})
        else
            api.nvim_win_set_cursor(curWinID, selectStart)
            cmd [[normal! v]]
            api.nvim_win_set_cursor(curWinID, selectEnd)
        end
    end

    return 0
end -- }}}

-- TODO replace with register

function M.convertPut(pasteCMD, opts) --  {{{
    opts = opts or {hlGroup="Search", timeout=500}
    local curBufNr = api.nvim_get_current_buf()
    local curWinID = api.nvim_get_current_win()
    local cursorPos   = api.nvim_win_get_cursor(curWinID)
    local regType = fn.getregtype()
    local saveRegContent = fn.getreg(vim.v.register)
    local curLine = api.nvim_get_current_line()
    local cursorNS      = api.nvim_create_namespace("inplacePutCursor")
    local cursorExtmark = api.nvim_buf_set_extmark(curBufNr, cursorNS, cursorPos[1] - 1, cursorPos[2], {})

    -- Convert register content
    if regType == "v" or regType == "c" then
        fn.setreg(vim.v.register, saveRegContent, "V")
    elseif regType == "V" or regType == "l" then
        fn.setreg(vim.v.register, saveRegContent:match("^%s*(.-)%s*$"), "v")
    else
        return
    end

    -- Execute EX command
    if vim.v.count ~= 0 then
        for _=0, vim.v.count do
            cmd("normal! \"" .. vim.v.register .. pasteCMD)
        end
    else
        cmd("normal! \"" .. vim.v.register .. pasteCMD)
    end

    -- Position of new created content
    local pos1 = api.nvim_buf_get_mark(curBufNr, "[")
    local pos2 = api.nvim_buf_get_mark(curBufNr, "]")
    -- Change to 0-based for extmark creation
    pos1 = {pos1[1] - 1, pos1[2]}
    pos2 = {pos2[1] - 1, pos2[2]}

    -- Format new created content when possible {{{
    -- Create extmark to track position of new content
    M.inplacePutNewContentNS      = api.nvim_create_namespace("inplacePutNewContent")
    M.inplacePutNewContentExtmark = api.nvim_buf_set_extmark(curBufNr, M.inplacePutNewContentNS,
                pos1[1], pos1[2], {end_line = pos2[1], end_col = pos2[2]})

    if regType == "v" or regType == "c" then
        api.nvim_win_set_cursor(curWinID, {pos1[1] + 1, pos1[2]})
        cmd "normal! V"
        api.nvim_win_set_cursor(curWinID, {pos2[1] + 1, pos2[2]})
        cmd "normal! ="
        M.lastPutLinewise = true
        -- Change to 0-based for extmark creation
    elseif regType == "V" or regType == "l" then
        -- Format current line if new paste content consists a single line
        local match = string.match(curLine, '%w')
        if not match then cmd [[normal! ==]] end
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
    fn.setreg(vim.v.register, saveRegContent, regType)
end --  }}}

return M

