-- File: replace
-- Author: iaso2h
-- Description: Heavily inspired Ingo Karkat's work. Replace text with register
-- Version: 0.1.11
-- Last Modified: 2023-4-25
-- TODO: tests for softtab convert
-- NOTE: break change: Dot-repeat no longer support jump to mark motion now
-- because the new method of setting new line(or replace line) via
-- api.nvim_buf_set_lines and api.nvim_buf_set_text has been adopted, which
-- will clear the mark location after buffer being changed
local fn       = vim.fn
local api      = vim.api
local util     = require("util")
local register = require("register")
require("operator")

local M    = {
    regName              = nil,
    cursorPos            = nil, -- (1, 0) indexed
    count                = nil,
    motionDirection      = nil,
    restoreOption        = nil,

    lastReplaceNs       = api.nvim_create_namespace("inplaceReplace"),
    lastReplaceExtmark  = -1,
    lastReplaceLinewise = false,

    -- Options
    highlightChangeChk = false,
    placeCursor = true,
    suppressMessage = false,
    hlGroup = "Search",
    timeout = 550
}


----
-- Function: warnRead Warn when buffer is not modifiable
--
-- @return: return true when buffer is readonly
----
local warnRead = function()
    if not vim.o.modifiable or vim.o.readonly then
        vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
        return false
    end
    return true
end


---  https://github.com/tpope/vim-repeat/blob/master/autoload/repeat.vim
---  This function is used for preserving the vim.v.register value in case that
---  it's cleared during the file modification
M.saveCountReg = function()
    register.saveReg()
    M.regName = vim.v.register
    M.count   = vim.v.count1
end


----
-- Function: saveOption:Store vim options before perform any replacement----
----
local saveOption = function() -- {{{
    local saveClipboard
    local saveSelection

    -- BUG: somehow it will trigger xclipboard warning
    -- if api.nvim_get_option("clipboard") ~= "" then

        -- saveClipboard = vim.o.clipboard
        -- -- Avoid clobbering the selection and clipboard registers.
        -- vim.o.clipboard = ""
    -- end

    if api.nvim_get_option("selection") ~= "inclusive" then
        saveSelection = vim.o.clipboard
        -- Avoid clobbering the selection and clipboard registers.
        vim.opt.selection = "inclusive"
    end

    if saveClipboard or saveSelection then
        M.restoreOption = function()
            if saveSelection then vim.opt.selection = saveSelection end
            if saveClipboard then vim.opt.clipboard = saveClipboard end
        end
    else
        M.restoreOption = nil
    end
end -- }}}


--- Calculate how many spaces need to add or remove so that the indent of the
--- first line from both register and buffer matchup.
--- @param regContent string Value of register content
--- @param motionRegion table Contain start and end position of operator
--- movement. {1, 0} index
--- @param motionDirection number 1 indicate motionRegion like "j, w, f" is moving
--- forward -1 indicates motionRegion is moving backward
--- @param vimMode string Vim mode
--- @return string|nil Value of changed register content or nil if no
--- content changed
--- when reindentation is successful
local reindent = function(regContent, motionRegion, motionDirection, vimMode) -- {{{
    -- The value of bufferIndent is the first line where motionRegion starts or
    -- visual selection starts
    local bufferIndent
    if vimMode == "V" then
        -- In visual linewise mode, set the indentation value of starting
        -- position of region motionRegion to bufferIndent
        bufferIndent = fn.indent(motionRegion.Start[1])
    else
        if motionDirection == -1 then
            bufferIndent = fn.indent(motionRegion.End[1])
        else
            -- It's hard to detect the motionRegion direction for i[, a{, i<. etc in normal mode
            -- nil and 1 using the value of motionRegion.Start
            bufferIndent = fn.indent(motionRegion.Start[1])
        end
    end

    -- Get reindent count
    local count = bufferIndent - register.getIndent(regContent)

    -- Reindent the lines if counts do not match up
    if count ~= 0 then
        return register.reindent(count, regContent)
    else
        return nil
    end
end -- }}}


--- Match the motionType type with register type
--- @param motionType string motionRegion type by which how the operator perform.
--- Can be "line", "char" or "block"
--- @param motionRegion table Contains start and end position of operator movement. {1, 0} indexed
--- @param motionDirection number 1 indicate motionRegion like "j, w, f" is moving
--- @param vimMode string Vim mode. See: `:help mode()`
--- @param reg table Contain name, type, content of v:register
--- Can be "line", "char" or "block"
--- forward, -1 indicates motionRegion is moving backward
--- @return table reg The new reg table(might or might not have been modified)
--- otherwise return false
local matchRegType = function(motionType, motionRegion, motionDirection, vimMode, reg) -- {{{
    -- NOTE:"\<C-v>" for vimMode in vimscript is evaluated as "\22" in lua, which represents blockwise motionRegion
    -- NOTE:"\0261" in vimscript is evaluated as "\0221" in lua, which represents blockwise-visual register
    -- Vim mode
    --  ├── Normal mode
    --  │    ├── "char" motionRegion type(charwise)
    --  │    │     ├── "v"     register type
    --  │    │     ├── "V"     register type
    --  │    │     └── "<C-v>" register type
    --  │    └── "line" motionRegion type(linewise)
    --  └── 3 Visual modes
    --       └── Motion type is the same as the visual mode type("visual", "char", "block").
    --           Defined in operator.lua. Kinda meaningless TBH.
    --            ├── "v"     register type
    --            ├── "V"     register type
    --            └── "<C-v>" register type
    local regContentNew

    if vimMode == "n" then
        if motionType == "char" then
            if reg.type == "v" or reg.type == "c" then
            elseif reg.type == "V" or reg.type == "l" then
                if not string.find(reg.content, "\n", 1, true) then
                    regContentNew = vim.trim(reg.content)
                else
                    -- TODO: reindent the new Content when there's newline
                    -- character in reg.content
                end
            else
                -- Blockwise register type
                regContentNew = string.gsub(reg.content, "\n", " ")
            end
        elseif motionType == "line" then
            if reg.type == "v" or reg.type == "c" then
                regContentNew = reindent(reg.content, motionRegion, motionDirection, vimMode)
            else
                -- Blockwise register type and linewise register type

                regContentNew = reindent(reg.content, motionRegion, motionDirection, vimMode)
                -- Remove the additional newline in the end
                if regContentNew then
                    if vim.endswith(regContentNew, "\n") then
                        regContentNew = string.sub(regContentNew, 1, -2)
                    end
                else
                    if vim.endswith(reg.content, "\n") then
                        regContentNew = string.sub(reg.content, 1, -2)
                    end
                end
            end
        end

        if regContentNew then
            ---@diagnostic disable-next-line: param-type-mismatch
            fn.setreg(reg.name, regContentNew, "v")
            reg.content = regContentNew
            reg.type    = "c"
        end
    elseif vimMode == "v" then
        -- No need to modify register
    elseif vimMode == "V" then
        regContentNew = reindent(reg.content, motionRegion, motionDirection, vimMode)
        -- Reindent register content when it's available
        if regContentNew then
            fn.setreg(reg.name, regContentNew, reg.type)
            reg.content = regContentNew
        end
    else
        -- Block visual mode
        -- TODO: tests required

        local lines    = vim.split(reg.content, "\n", {trimempty = true})
        local linesCnt = #lines

        if reg.type == "v" or
                reg.type == "c" or
                (reg.type == "V" and linesCnt == 1) or
                (reg.type == "l" and linesCnt == 1) then
            -- If the register contains just a single line, temporarily duplicate
            -- the line to match the height of the blockwise selection.
            local height = motionRegion.Start[1] - motionRegion.End[1] + 1
            if height > 1 then
                local linesConcat = {}
                for _ = 1, height, 1 do
                    linesConcat = vim.list_extend(linesConcat, lines)
                end

                regContentNew = table.concat(linesConcat, "\n")
                ---@diagnostic disable-next-line: param-type-mismatch
                fn.setreg(reg.name, regContentNew, "b")
                reg.content = regContentNew
                reg.type    = "b"
            end
        elseif (reg.type == "V" and linesCnt > 1) or
                (reg.type == "l" and linesCnt > 1) then
            -- If the register contains multiple lines, paste as blockwise. then
            -- TODO:
            ---@diagnostic disable-next-line: param-type-mismatch
            fn.setreg(reg.name, "", "b")
        else
            -- No need to changed register when the register type is already blockwise
        end
    end

    return reg
end -- }}}


--- Replace text by manipulating visual selection and put
--- @param motionType string motionRegion type by which how the operator
--- perform. Can be "line", "char" or "block"
--- @param motionRegion table Contains start and end position of operator movement. {1, 0} indexed
--- @param vimMode string Vim mode. See: `:help mode()`
--- @param reg table Contain name, type, content of v:register Can be "line",
--- "char" or "block"
--- @param bufNr integer Buffer handler(number)
--- @return table {repStart = {}, repEnd = {}}
local replace = function(motionType, motionRegion, vimMode, reg, bufNr) -- {{{
    -- With a put in visual mode, the previously selected text is put in the
    -- unnamed register, so we need to save and restore that.
    local regCMD = reg.name == [["]] and "" or ([["]] .. reg.name)
    -- Use extmark to track position of new content
    local repStart
    local repEnd

    if vimMode ~= "n" then
        vim.cmd(string.format("noa norm! gv%sp", regCMD))
        repStart = api.nvim_buf_get_mark(0, "[")
        repEnd   = api.nvim_buf_get_mark(0, "]")
        return {Start = repStart, End = repEnd}
    else
        if util.compareDist(motionRegion.Start, motionRegion.End) > 0 then
        -- This's a rare scenario where Start is fall behind End

        -- HACK: occurred when execute [[gr"agr$]]
        -- vim.notify("Start fall behind End", vim.log.levels.ERROR)
        vim.cmd(string.format("noa norm! %sP", regCMD))
        repStart = api.nvim_buf_get_mark(0, "[")
        repEnd   = api.nvim_buf_get_mark(0, "]")
        return {Start = repStart, End = repEnd}
    else
        if motionType == "char" then
            local Start = {motionRegion.Start[1] - 1, motionRegion.Start[2]}
            local End   = {motionRegion.End[1] - 1, motionRegion.End[2]}
            if string.find(reg.content, "\n") then
                api.nvim_buf_set_text(
                    bufNr, Start[1], Start[2], End[1], End[2] + 1,
                    vim.split(reg.content, "\n", {plain = true}) )
            else
                api.nvim_buf_set_text(bufNr, Start[1], Start[2], End[1], End[2] + 1, {reg.content})
            end
        elseif motionType == "line" then
            local Start = {motionRegion.Start[1] - 1, motionRegion.Start[2]}
            local End   = {motionRegion.End[1] - 1, motionRegion.End[2]}
            api.nvim_buf_set_lines(bufNr, Start[1], End[1] + 1, false,
            vim.split(reg.content, "\n", {plain = true, trimempty = true}) )
        end
        return {}
    end
end
end -- }}}


--- This function will be called when g@ is evaluated by Neovim
--- @param args table {motionType, vimMode, plugMap}
--- motionType     string  motionRegion type by which how the operator perform.
--- Can be "line", "char" or "block"
--- vimMode        string  Vim mode. See: `:help mode()`
--- plugMap        string  eg: <Plug>myPlug
--- replaceLineChk boolean
function M.operator(args) -- {{{
    if not warnRead() then return end

    -- NOTE: see ":help g@" for details about motionType
    local motionType = args[1]
    local vimMode    = args[2]
    -- if vimMode == "n", plugMap will be nil
    local plugMap    = args[3]
    local bufNr = api.nvim_get_current_buf()

    -- Saving cursor position, motionRegion count, motionRegion region and register  {{{
    local motionRegion
    local motionDirection
    if vimMode == "n" then
        -- For Replace operator exclusively

        -- Saving cursor part is done inside expr()
        -- Saving motionRegion region
        motionRegion = {
            Start = api.nvim_buf_get_mark(bufNr, "["),
            End   = api.nvim_buf_get_mark(bufNr, "]")
        }

        -- Saveing motionRegion direction
        if motionType == "line" then
            if M.cursorPos then
                if M.cursorPos[1] == motionRegion.End[1] then
                    -- motionRegion direction detection for k
                    motionDirection = -1
                elseif M.cursorPos[1] == motionRegion.Start[1] then
                    -- motionRegion direction detection for j
                    motionDirection = 1
                else
                    -- motionRegion direction detection for i[, a{, i<. etc
                end

                -- Store for dot repeat
                M.motionDirection = motionDirection
            else
                -- Dot repeat
                -- motionRegion direction detection. Perform in dot repeat, use the
                -- existing value in M.motionDirection
                motionDirection = M.motionDirection
            end
        else
            -- TODO: charwise and blockwise motionRegion parsing?
            M.motionDirection = nil
        end

        -- Saving count and register.
        -- This is for vimMode. Because retrieving vim.v.count1 failed at
        -- M.expr() before "g@" get evaluted only. Other Replace mapping will
        -- do this saving part before calling operator(). In addition, Saving
        -- register in the expr() will be ignore when using dot repeat
        M.saveCountReg()
    else
        -- For all replace modes other than the replace operator

        -- The value of vim.v.count1 will be changed whenever the
        -- vim.cmd("norm! <normal command>") is executed, so the preservation
        -- of register and count have to be done in advanced, before the
        -- operator() func is called.
        -- Because the mapping of replacing current line is parsed in "V" vim
        -- mode, the saveCountReg() is always called in the key mapping stage
        -- to achieve a consistent mapping layout just like the other visual
        -- modes
        if vimMode == "V" and args[4] then
            -- For mapping of replacing current line

            M.cursorPos = api.nvim_win_get_cursor(0)
            -- Override the position of mark "<" and ">"
            vim.cmd("noa norm! V" .. M.count .. "_" .. t"<Esc>");
        else
            -- In visual mode, the cursor will place at the first column once
            -- entering commandline mode. Therefore cursor info is retrieved
            -- by execting the "gv" command. But Somehow the below command
            -- sequence cannot produce the effect of retrieving the correct
            -- cursor:

            -- In the end, a workaround comes in by retrieving the mark
            -- position which is set in the cursor position
            vim.cmd([[noa norm! gvm`]] .. t"<Esc>")
            M.cursorPos = api.nvim_buf_get_mark(bufNr, "`")
        end

        -- Saving motionRegion region
        motionRegion = {
            Start = api.nvim_buf_get_mark(bufNr, "<"),
            End   = api.nvim_buf_get_mark(bufNr, ">")
        }
    end

    -- Avoid out of bound column index
    local endLine = api.nvim_buf_get_lines(bufNr, motionRegion.End[1] - 1, motionRegion.End[1], false)[1]
    if motionRegion.End[2] > #endLine then motionRegion.End[2] = #endLine - 1 end

    -- Use extmark to track the motionRegion
    local repExtmark
    -- Always clear namespace before hand
    api.nvim_buf_clear_namespace(bufNr, M.lastReplaceNs, 0, -1)
    local ok, msgOrVal = pcall(api.nvim_buf_set_extmark, bufNr, M.lastReplaceNs,
        motionRegion.Start[1] - 1, motionRegion.Start[2],
        {end_line = motionRegion.End[1] - 1, end_col = motionRegion.End[2]})
    -- End function calling if extmark is out of scope
    if not ok then
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.notify(msgOrVal, vim.log.levels.WARN)
        return vim.notify(debug.traceback(), vim.log.levels.ERROR)
    else
        repExtmark = msgOrVal
    end

    -- Save vim options
    saveOption()
    -- }}} Saving cursor position, motionRegion count, motionRegion region and register

    -- Gather more register
    local reg
    if M.regName == "=" then
        -- TODO: tests required
        -- To get the expression result into the buffer, we use the unnamed
        -- register; this will be restored anyway.
        fn.setreg('"', vim.g.ReplaceExpr)
        reg = {
            name    = '"',
            type    = fn.getregtype(M.regName),
            content = vim.g.ReplaceExpr
        }
    else
        reg = {
            name    = M.regName,
            type    = fn.getregtype(M.regName),
            content = fn.getreg(M.regName, 1)
        }
    end


    -- Match the motionType type with register type
    ---@diagnostic disable-next-line: cast-local-type
    ok, msgOrVal = pcall(matchRegType, motionType, motionRegion, motionDirection, vimMode, reg)
    if not ok then
        ---@diagnostic disable-next-line: param-type-mismatch
        return vim.notify(msgOrVal, vim.log.levels.ERROR)
    else
        reg = msgOrVal
    end

    -- Replace with new content
    local rep
    ---@diagnostic disable-next-line: cast-local-type
    ok, msgOrVal = pcall(replace, motionType, motionRegion, vimMode, reg, bufNr)
    if not ok then
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.notify(msgOrVal, vim.log.levels.ERROR)
        -- TODO: clear rep extmark?
    else
        rep = msgOrVal
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    -- HACK: extmark changed by nvim_buf_set_lines and nvim_buf_set_text are
    -- always reversed?
    local repEndLine
    if not next(rep) then
        local repPos = api.nvim_buf_get_extmark_by_id(bufNr, M.lastReplaceNs, repExtmark, {details = true})
        if vimMode == "n" and motionType == "line" and repPos[3].end_col == 0 and repPos[2] == 0 then
            if repPos[3].end_row < repPos[1] then
                -- NOTE: the END ROW has to subtract 1 offset
                repEndLine = api.nvim_buf_get_lines(bufNr, repPos[1] - 1, repPos[1], false)[1]
                rep = {
                    Start = {repPos[3].end_row + 1, repPos[3].end_col},
                    End   = {repPos[1], #repEndLine - 1}
                }
            else
                repEndLine = api.nvim_buf_get_lines(bufNr, repPos[3].end_row - 1, repPos[3].end_row, false)[1]
                rep = {
                    Start = {repPos[1] + 1, repPos[2]},
                    End   = {repPos[3].end_row, #repEndLine - 1}
                }
            end
        else
            if repPos[3].end_row < repPos[1] or (repPos[3].end_row == repPos[1] and repPos[3].end_col < repPos[2]) then
                -- NOTE: the END COLUMN has to subtract 1 offset
                repEndLine = api.nvim_buf_get_lines(bufNr, repPos[1], repPos[1] + 1, false)[1]
                rep = {
                    Start = {repPos[3].end_row + 1, repPos[3].end_col},
                    End   = {repPos[1] + 1, repPos[2] - 1}
                }
            else
                repEndLine = api.nvim_buf_get_lines(bufNr, repPos[3].end_row, repPos[3].end_row + 1, false)[1]
                rep = {
                    Start = {repPos[1] + 1, repPos[2]},
                    End   = {repPos[3].end_row + 1, repPos[3].end_col - 1}
                }
            end
        end
    end

    -- Create highlight
    -- Creates a new namespace or gets an existing one.
    if not (vimMode == "n" and not M.highlightChangeChk) then
        local newContentExmark = util.nvimBufAddHl(bufNr, rep.Start, rep.End,
                reg.type, M.hlGroup, M.timeout, M.lastReplaceNs)
        if newContentExmark then
            M.lastReplaceExtmark = newContentExmark
        end
        if reg.type == "l" or reg.type == "V" then
            M.lastReplaceLinewise = true
        else
            M.lastReplaceLinewise = false
        end
    end

    -- Report change in Neovim cmdline
    if not M.suppressMessage then
        local srcLinesCnt = motionRegion.End[1] - motionRegion.Start[1] + 1
        local repLineCnt  = rep.End[1] - rep.Start[1] + 1
        if srcLinesCnt >= vim.o.report or repLineCnt >= vim.o.report then
            local srcReport = string.format("Replaced %d line%s", srcLinesCnt, srcLinesCnt == 1 and "" or "s")
            local repReport = srcLinesCnt == repLineCnt and '' or
                string.format(" with %d line%s", repLineCnt, repLineCnt == 1 and "" or "s")

            vim.notify(srcReport .. repReport, vim.log.levels.INFO)
        end
    end

    -- Restoration
    -- Register
    register.restoreReg()
    -- Options
    if vim.is_callable(M.restoreOption) then M.restoreOption() end

    -- Cursor {{{
    if M.placeCursor and M.cursorPos then
        if vimMode == "n" then
            if not M.cursorPos then
                -- TODO: Supported cursor recall in dot-repeat mode
            else
                if util.compareDist(M.cursorPos, rep.End) <= 0 then
                    -- Replace content is bigger than the source, and cursor is
                    -- still in range of the replacement
                    local cursorLine = api.nvim_buf_get_lines(bufNr,
                        M.cursorPos[1] - 1, M.cursorPos[1], false)[1]
                    cursorLine = #cursorLine == 0 and " " or cursorLine

                    if #cursorLine - 1 > M.cursorPos[2] then
                        api.nvim_win_set_cursor(0, M.cursorPos)
                    else
                        api.nvim_win_set_cursor(0, {M.cursorPos[1], #cursorLine - 1})
                    end
                else
                    if motionType == "char" then
                        api.nvim_win_set_cursor(0, rep.Start)
                    elseif motionType == "line" then
                        vim.cmd [[noa normal! ^]]
                    end
                end

                -- Always clear M.cursorPos after restoration
                M.cursorPos = nil
            end
        elseif vimMode == "v" then
            if reg.type == "V" or reg.type == "l" then
                if M.cursorPos[1] == motionRegion.Start[1] and M.cursorPos[2] == motionRegion.Start[2] then
                    local startLine = api.nvim_buf_get_lines(bufNr,
                        rep.Start[1] - 1, rep.Start[1], false)[1]
                    startLine = #startLine == 0 and " " or startLine
                    local _, indentEnd = string.find(startLine, "%s+")
                    if indentEnd then
                        api.nvim_win_set_cursor(0, {rep.Start[1], indentEnd})
                    else
                        api.nvim_win_set_cursor(0, rep.Start)
                    end
                else
                    api.nvim_win_set_cursor(0, rep.End)
                end
            else
                if M.cursorPos[1] == motionRegion.Start[1] and M.cursorPos[2] == motionRegion.Start[2] then
                    api.nvim_win_set_cursor(0, rep.Start)
                else
                    api.nvim_win_set_cursor(0, rep.End)
                end
            end

        elseif vimMode == "V" then
            if util.compareDist(M.cursorPos, rep.End) <= 0 then
                -- Avoid cursor out of scope
                local cursorLine = api.nvim_buf_get_lines(bufNr,
                    M.cursorPos[1] - 1, M.cursorPos[1], false)[1]
                cursorLine = #cursorLine == 0 and " " or cursorLine

                if #cursorLine - 1 > M.cursorPos[2] then
                    api.nvim_win_set_cursor(0, M.cursorPos)
                else
                    api.nvim_win_set_cursor(0, {M.cursorPos[1], #cursorLine - 1})
                end
            else
                local startLine = api.nvim_buf_get_lines(bufNr,
                    rep.Start[1] - 1, rep.Start[1], false)[1]
                startLine = #startLine == 0 and " " or startLine
                local _, indentEnd = string.find(startLine, "%s+")
                if indentEnd then
                    api.nvim_win_set_cursor(0, {rep.Start[1], indentEnd})
                else
                    api.nvim_win_set_cursor(0, rep.Start)
                end
            end
        else
            -- TODO: visual-block mode parse
        end
    end
    -- }}} Cursor

    -- Mapping repeating
    if vimMode ~= "n" then
        vim.fn["repeat#setreg"](t(plugMap), M.regName);
    end

    if #args > 2 then
        if #args == 4 then
            -- ReplaceCurLine
            fn["repeat#set"](t(plugMap), M.count)
        else
            -- VisualChar
            -- VisualLine
            fn["repeat#set"](t(plugMap))
        end
    elseif M.regName == "=" then
        fn["repeat#set"](t"<Plug>ReplaceExpr")
    end
    -- Visual repeating
    fn["visualrepeat#set"](t"<Plug>ReplaceVisual")
end -- }}}


---Expression callback for replace operator
---@param restoreCursorChk boolean Whether to restore the cursor if possible
---@param highlightChangeChk boolean Whether to highlight the change. Only
--support turning off highlight changes in vim normal mode!
---@return string "g@"
function M.expr(restoreCursorChk, highlightChangeChk) -- {{{
    if not warnRead() then return "" end

    _G._opfunc = M.operator
    vim.o.opfunc = "LuaExprCallback"

    if restoreCursorChk then
        -- Preserving cursor position as its position will changed once the
        -- vim.o.opfunc() being called
        M.cursorPos = api.nvim_win_get_cursor(0)
    else
        M.cursorPos = nil
    end

    M.highlightChangeChk = highlightChangeChk

    -- Evaluate the expression register outside of a function. Because
    -- unscoped variables do not refer to the global scope. Therefore,
    -- evaluation happened earlier in the mappings.
    return M.regName == "=" and [[:let g:ReplaceExpr = getreg("=")<CR>g@]] or "g@"
end -- }}}


return M
