-- File: yankPut
-- Author: iaso2h
-- Description: VSCode like copy in visual, normal, input mode; inplace yank & put and convert put
-- Version: 0.1.12
-- Last Modified: 2022-01-24

local fn       = vim.fn
local cmd      = vim.cmd
local api      = vim.api
local util     = require("util")
local operator = require("operator")
local register = require("register")
local M = {
    lineMove = {
        lastMovePos = {
            bufNr = nil,
            lineNr = nil
        },
        timer    = nil,
        timeout  = 500,
        gitsignsOn     = package.loaded["gitsigns"] ~= nil,
        gitsignsLineHl = package.loaded["gitsigns"] ~= nil,
    },
    hlInterval = 250,
    hlGroup    = "Search"
}
-- TODO: test cases


function M.VSCodeLineMove(vimMode, direction) -- {{{
    if not vim.bo.modifiable then
        return vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
    end
    if fn.foldclosed('.') ~= -1 then return end

    -- Stop previous timer if this func is quick enough to be called again
    -- before the defered function is called and stop it
    if M.lineMove.timer then
        M.lineMove.timer:stop()
    end

    -- Disable Gitsign.nvim plugin to prevent frequently shrinking or
    -- expanding in sign column
    if M.lineMove.gitsignsOn and M.lineMove.gitsignsLineHl then
        cmd [[noautocmd Gitsigns toggle_signs]]
        M.lineMove.gitsignsLineHl = false
    end

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

    -- Get line info
    if vimMode == "n" then
        M.lineMove.lastMovePos.lineNr = {fn.getpos("'[")[2], fn.getpos("']")[2]}
    else
        M.lineMove.lastMovePos.lineNr = {fn.getpos("'<")[2], fn.getpos("'>")[2]}
    end
    M.lineMove.lastMovePos.bufNr  = api.nvim_get_current_buf()

    -- Set defered func. If the cursor is still at the same buffer and
    -- whithin the same line range, then perform a format action
    M.lineMove.timer = vim.defer_fn(function()
        local curBufNr = api.nvim_get_current_buf()
        local curlineNr = fn.getpos(".")[2]
        if curBufNr == M.lineMove.lastMovePos.bufNr and
            curlineNr <= M.lineMove.lastMovePos.lineNr[2] and
            curlineNr >= M.lineMove.lastMovePos.lineNr[1] and
            vim.o.equalprg == "" then

            cmd [[noautocmd normal! ==]]
        end
        cmd [[noautocmd Gitsigns toggle_signs]]
        M.lineMove.gitsignsLineHl = true
        M.lineMove.timer = nil
    end, M.lineMove.timeout)

end -- }}}


-- VSCode yank line {{{
function M.VSCodeLineYank(vimMode, direction)
    if not vim.bo.modifiable then
        return vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
    end
    -- if fn.foldclosed('.') ~= -1 then return end
    local saveClipboard = api.nvim_get_option("clipboard")
    -- Set clipboard to "" temporarily to avoid xclip warning
    vim.opt.clipboard = ""


    register.saveReg()

    -- Duplication {{{
    if vimMode ~= "n" then
        cmd [[noautocmd normal! gv]]
        -- Visual mode {{{
        local cursor      = api.nvim_win_get_cursor(0)
        local selectStart = api.nvim_buf_get_mark(0, "<")
        local selectEnd   = api.nvim_buf_get_mark(0, ">")
        cmd(string.format("silent! noautocmd %d,%dyank", selectStart[1], selectEnd[1]))
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
    else
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

    register.restoreReg()
    vim.opt.clipboard = saveClipboard
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
    local opts = {hlGroup=M.hlGroup, timeout=M.hlInterval}
    local motionType = args[1]
    local vimMode    = args[2]
    local plugMap    = operator.plugMap
    local curWinID = api.nvim_get_current_win()
    local curBufNr = api.nvim_get_current_buf()
    local posStart = api.nvim_buf_get_mark(0, "[")
    local posEnd   = api.nvim_buf_get_mark(0, "]")
    local regName  = vim.v.register == "+" and "" or '"' .. vim.v.register

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
    local yankHLNS = api.nvim_create_namespace('inplaceYankHL')
    api.nvim_buf_clear_namespace(curBufNr, yankHLNS, 0, -1)

    local region = vim.region(curBufNr, posStart, posEnd, fn.getregtype(),
        vim.o.selection == "inclusive" and true or false)
    for lineNr, cols in pairs(region) do
        api.nvim_buf_add_highlight(curBufNr, yankHLNS, opts["hlGroup"], lineNr, cols[1], cols[2])
    end

    -- Restor cursor position
    if operator.cursorPos then
        api.nvim_win_set_cursor(curWinID, operator.cursorPos)
        -- Always clear M.cursorPos after restoration to avoid restoring
        -- cursor in after repeat command is performed
        operator.cursorPos = nil
    end

    vim.defer_fn(function()
        -- In case of buffer being deleted
        if api.nvim_buf_is_valid(curBufNr) then
            pcall(api.nvim_buf_clear_namespace, curBufNr, yankHLNS, 0, -1)
        end
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


-- TODO: doc
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

    local regTypeSave   = fn.getregtype()
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
            M.lastPutLinewise = true

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
            regContentNew = string.gsub(regContentSave, "\n%s+", " ")
            regContentNew = string.gsub(regContentNew, "\n", "")
            regContentNew = string.gsub(regContentNew, "^%s+", "")
        end

        fn.setreg(vim.v.register, regContentNew, "V")
    else
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

    -- Record the register type for the lastYankPut()
    if regTypeSave == "V" or regTypeSave == "l" then
        M.lastPutLinewise = true
    else
        M.lastPutLinewise = false
    end

    inplacePutExCmd(pasteCMD, vimMode)


    -- Highlight new content {{{
    -- Position of new created content
    local posStart = api.nvim_buf_get_mark(curBufNr, "[")
    local posEnd = api.nvim_buf_get_mark(curBufNr, "]")
    -- Change to 0-based for extmark creation
    posStart = {posStart[1] - 1, posStart[2]}
    posEnd = {posEnd[1] - 1, posEnd[2]}

    -- Create extmark to track position of new content
    local saveNS = M.inplacePutNewContentNS
    M.inplacePutNewContentNS = api.nvim_create_namespace("inplacePutNewContent")
    -- HACK: can be out of scope
    local ok, msg = pcall(api.nvim_buf_set_extmark, curBufNr, M.inplacePutNewContentNS,
                    posStart[1], posStart[2], {end_line = posEnd[1], end_col = posEnd[2]})
    if not ok then
        M.inplacePutNewContentNS = saveNS
        vim.notify(msg, vim.log.levels.WARN)
    else
        M.inplacePutNewContentExtmark = msg
    end
    -- }}} Highlight new content

    -- Use equalprg for the new single-line content {{{
    if convertPut then
        if regTypeSave == "v" and vim.o.equalprg == "" then
            local match = string.match(api.nvim_get_current_line(), '^%w')
            if not match then cmd [[noautocmd normal! ==]] end
        end
    else
        if (regTypeSave == "V" or regTypeSave == "l") and vim.o.equalprg == "" then
            local match = string.match(api.nvim_get_current_line(), '^%w')
            if not match then cmd [[noautocmd normal! ==]] end
        end
    end
    -- }}} Use equalprg for the new single-line content

    -- Create highlight {{{
    local putHLNS = api.nvim_create_namespace('inplacePutHL')
    api.nvim_buf_clear_namespace(curBufNr, putHLNS, 0, -1)

    local newContentResExtmark = api.nvim_buf_get_extmark_by_id(curBufNr,
                                            M.inplacePutNewContentNS,
                                            M.inplacePutNewContentExtmark,
                                            {details = true})
    local newContentResStart = {newContentResExtmark[1],
                                newContentResExtmark[2]}
    local newContentResEnd   = {newContentResExtmark[3]["end_row"],
                                newContentResExtmark[3]["end_col"]}
    local region = vim.region(curBufNr, newContentResStart,
                            newContentResEnd, regTypeSave,
                            vim.o.selection == "inclusive" and true or false)
    for lineNr, cols in pairs(region) do
        api.nvim_buf_add_highlight(curBufNr, putHLNS, opts["hlGroup"],
                                    lineNr, cols[1], cols[2])
    end

    vim.defer_fn(function()
        -- In case of buffer being deleted
        if api.nvim_buf_is_valid(curBufNr) then
            pcall(api.nvim_buf_clear_namespace, curBufNr, putHLNS, 0, -1)
        end
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
    -- Restore register
    if convertPut then
        register.restoreReg()
    end
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

