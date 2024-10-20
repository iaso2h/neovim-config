-- File: replace
-- Author: iaso2h
-- Description: Heavily inspired by Ingo Karkat's work. Replace text with register
-- Version: 0.1.16
-- Last Modified: 2024-10-19
-- TODO: tests for softtab convert
-- NOTE: break change: Dot-repeat no longer support jump to mark motion now
-- because the new method of setting new line(or replace line) via
-- api.nvim_buf_set_lines and api.nvim_buf_set_text has been adopted, which
-- will clear the mark location after buffer being changed
local util     = require("util")
local register = require("register")
local op       = require("operator")

local M = {
    regName         = nil,
    cursorPos       = nil, -- (1, 0) indexed
    currentLineChk  = false,
    plugMap         = "",
    count           = nil,
    motionDirection = nil,
    restoreOption   = nil,

    lastReplaceNs       = vim.api.nvim_create_namespace("inplaceReplace"),
    lastReplaceExtmark  = -1,
    lastReplaceLinewise = false,

    -- Options
    highlightChangeChk = false,
    placeCursor        = true,
    suppressMessage    = false,
    hlGroup            = "Search",
    timeout            = 550
}


--- Warn when buffer is not modifiable
---@return boolean Return true when buffer is readonly
local warnRead = function() -- {{{
    if not vim.o.modifiable or vim.o.readonly then
        vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
        return false
    end
    return true
end -- }}}


---https://github.com/tpope/vim-repeat/blob/master/autoload/repeat.vim
--- This function is used for preserving the vim.v.register value in case that it's cleared during the file modification
M.saveCountReg = function() -- {{{
    register.saveReg()
    M.regName = vim.v.register
    M.count   = vim.v.count1
end -- }}}
--- Store vim options before perform any replacement
local saveOption = function() -- {{{
    local saveSelection

    if vim.api.nvim_get_option_value("selection", {scope = "global"}) ~= "inclusive" then
        saveSelection = vim.o.selection
        -- Avoid clobbering the selection and clipboard registers.
        vim.opt.selection = "inclusive"
    end

    if saveSelection then
        M.restoreOption = function()
            if saveSelection then vim.opt.selection = saveSelection end
        end
    else
        M.restoreOption = nil
    end
end -- }}}
--- Calculate how many spaces need to add or remove so that the indent of the first line from both register and buffer matchup.
---@param regContent string Value of register content
---@param motionRegion table Contain start and end position of operator
--movement. {1, 0} index
---@param motionDirection integer 1 indicate motionRegion like "j, w, f" is moving forward -1 indicates motionRegion is moving backward
---@param vimMode string Vim mode
---@return string|nil Value of changed register content or nil if no content changed
---when reindentation is successful
local reindent = function(regContent, motionRegion, motionDirection, vimMode) -- {{{
    -- The value of bufferIndent is the first line where motionRegion starts or
    -- visual selection starts
    local bufferIndent
    if vimMode == "V" then
        -- In visual linewise mode, set the indentation value of starting
        -- position of region motionRegion to bufferIndent
        bufferIndent = vim.fn.indent(motionRegion.Start[1])
    else
        if motionDirection == -1 then
            bufferIndent = vim.fn.indent(motionRegion.End[1])
        else
            -- It's hard to detect the motionRegion direction for i[, a{, i<. etc in normal mode
            -- nil and 1 using the value of motionRegion.Start
            bufferIndent = vim.fn.indent(motionRegion.Start[1])
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
---@param motionType string motionRegion type by which how the operator perform. "line" or "char"
---@param motionRegion table Contains start and end position of operator movement. {1, 0} indexed
---@param motionDirection integer 1 indicate motionRegion like "j, w, f" is moving
---@param vimMode string Vim mode. See: `:help mode()`
---@param reg RegisterInfo
---@return table reg The new reg table(might or might not have been modified) otherwise return false
local matchRegType = function(motionType, motionRegion, motionDirection, vimMode, reg) -- {{{
    -- NOTE:"\<C-v>" for vimMode in vimscript is evaluated as "\22" in lua, which represents blockwise motionRegion
    -- Vim mode
    --  ├── Normal mode
    --  │    ├── "char" motionRegion type(charwise)
    --  │    │     ├── "v"            register type
    --  │    │     ├── "V"            register type
    --  │    │     └── "<C-v>{width}" register type
    --  │    └── "line" motionRegion type(linewise)
    --  └── 3 Visual modes
    --       └── Motion type is the same as the visual mode type("visual", "char", "block").
    --           Defined in operator.lua. Kinda meaningless TBH.
    --            ├── "v"            register type
    --            ├── "V"            register type
    --            └── "<C-v>{width}" register type
    local regContentNew

    if vimMode == "n" then
        if motionType == "char" then
            if reg.type == "v" then
                -- Do nothing
            else
                -- Blockwise register type and linewise register type
                regContentNew = string.gsub(reg.content, "\n", " ")
                regContentNew = vim.trim(regContentNew)
            end
        else
        -- elseif motionType == "line" then
            if reg.type == "v" then
                regContentNew = reindent(reg.content, motionRegion, motionDirection, vimMode)
            else
                -- Blockwise register type and linewise register type

                regContentNew = reindent(reg.content, motionRegion, motionDirection, vimMode)
                -- Remove the additional newline in the end
                if regContentNew then
                    regContentNew = string.gsub(regContentNew, [[%s*$]], "")
                else
                    regContentNew = string.gsub(reg.content, [[%s*$]], "")
                end
            end
        end

        if regContentNew then
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg(reg.name, regContentNew, "v")
            reg.content = regContentNew
        end

        -- Always override the register type with character-wise
        reg.type = "v"
    elseif vimMode == "v" then
        -- No need to modify register
    elseif vimMode == "V" then
        regContentNew = reindent(reg.content, motionRegion, motionDirection, vimMode)
        -- Reindent register content when it's available
        if regContentNew then
            vim.fn.setreg(reg.name, regContentNew, reg.type)
            reg.content = regContentNew
        end
    else
        -- Block visual mode
        -- TODO: tests required

        local lines    = vim.split(reg.content, "\n", {plain = true, trimempty = true})
        local linesCnt = #lines

        if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
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
                vim.fn.setreg(reg.name, regContentNew, "b")
                reg.content = regContentNew
                reg.type    = "b"
            end
        elseif reg.type == "V" and linesCnt > 1 then
            -- If the register contains multiple lines, paste as blockwise. then
            -- TODO:
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg(reg.name, "", "b")
        else
            -- No need to changed register when the register type is already blockwise
        end
    end

    return reg
end -- }}}
--- Replace text by manipulating visual selection and put
---@param motionType string motionRegion type by which how the operator perform. Can be "line" or "char"
---@param motionRegion table Contains start and end position of operator movement. {1, 0} indexed
---@param vimMode string Vim mode. See: `:help mode()`
---@param reg RegisterInfo
---@param bufNr integer Buffer handler(number)
---@return table {repStart = {}, repEnd = {}}
local replace = function(motionType, motionRegion, vimMode, reg, bufNr) -- {{{
    -- With a put in visual mode, the previously selected text is put in the
    -- unnamed register, so we need to save and restore that.
    local regCMD = reg.name == [["]] and "" or ([["]] .. reg.name)
    -- Use extmark to track position of new content
    local repStart
    local repEnd

    if vimMode ~= "n" then
        vim.cmd(string.format("noa norm! gv%sp", regCMD))
        repStart = vim.api.nvim_buf_get_mark(0, "[")
        repEnd   = vim.api.nvim_buf_get_mark(0, "]")
        return {Start = repStart, End = repEnd}
    else
        if util.compareDist(motionRegion.Start, motionRegion.End) > 0 then
            -- This's a rare scenario where Start is fall behind End

            -- HACK: occurred when execute [[gr"agr$]]
            -- vim.notify("Start fall behind End", vim.log.levels.ERROR)
            vim.cmd(string.format("noa norm! %sP", regCMD))
            repStart = vim.api.nvim_buf_get_mark(0, "[")
            repEnd   = vim.api.nvim_buf_get_mark(0, "]")
            return {Start = repStart, End = repEnd}
        else
            if motionType == "char" then
                local Start = {motionRegion.Start[1] - 1, motionRegion.Start[2]}
                local End   = {motionRegion.End[1] - 1,   motionRegion.End[2]}
                if string.find(reg.content, "\n") then
                    vim.api.nvim_buf_set_text(
                        bufNr, Start[1], Start[2], End[1], End[2] + 1,
                        vim.split(reg.content, "\n", {plain = true}) )
                else
                    vim.api.nvim_buf_set_text(bufNr, Start[1], Start[2], End[1], End[2] + 1, {reg.content})
                end
            else
            -- elseif motionType == "line" then
                local Start = {motionRegion.Start[1] - 1, motionRegion.Start[2]}
                local End   = {motionRegion.End[1] - 1, motionRegion.End[2]}
                vim.api.nvim_buf_set_lines(bufNr, Start[1], End[1] + 1, false,
                vim.split(reg.content, "\n", {plain = true, trimempty = true}) )
            end

            return {}
        end
    end
end -- }}}
--- The replace operator
---@param opInfo GenericOperatorInfo
function M.operator(opInfo) -- {{{
    if not warnRead() then return end

    -- NOTE: see ":help g@" for details about motionType
    local bufNr = vim.api.nvim_get_current_buf()

    -- Get cursor position, motionRegion count, motionRegion region and register  {{{
    local motionRegion
    local motionDirection
    local endLine
    if opInfo.vimMode == "n" then
        -- For Replace operator exclusively

        -- Saving count and register. The part of saving cursor is done inside
        -- `expr()` but saving register in the `expr()` will be ignore when using dot repeat
        -- This is for normal mode. Because retrieving vim.v.count1 doesn't
        -- work in `M.expr()`. Other Replace mapping will do this saving part
        -- before calling operator().
        M.saveCountReg()

        -- Saving motionRegion region
        motionRegion = op.getMotionRegion(bufNr)
        endLine = vim.api.nvim_buf_get_lines(bufNr, motionRegion.End[1] - 1, motionRegion.End[1], false)[1]

        -- Motion region fix
        -- Avoid out of bound column index
        if motionRegion.End[2] > #endLine then
            motionRegion.End[2] = #endLine - 1
        end

        -- motionRegion fix
        -- Deal with multibyte character
        if vim.deep_equal(motionRegion.Start, motionRegion.End) then
            if string.len(endLine) ~= vim.fn.strchars(endLine) then

                local saveCursor = vim.api.nvim_win_get_cursor(0)
                vim.cmd[[noa norm! l]]
                local endCharByteIdx = vim.api.nvim_win_get_cursor(0)[2] - 1
                motionRegion.End[2] = endCharByteIdx
                vim.api.nvim_win_set_cursor(0, saveCursor)
            end
        end

        -- Saveing motionRegion direction
        if opInfo.motionType == "line" then
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
        if M.currentLineChk then
            -- For mapping of replacing current line

            M.cursorPos = vim.api.nvim_win_get_cursor(0)
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
            M.cursorPos = vim.api.nvim_buf_get_mark(bufNr, "`")
        end

        -- Saving motionRegion region
        motionRegion = {
            Start = vim.api.nvim_buf_get_mark(bufNr, "<"),
            End   = vim.api.nvim_buf_get_mark(bufNr, ">")
        }
        endLine = vim.api.nvim_buf_get_lines(bufNr, motionRegion.End[1] - 1, motionRegion.End[1], false)[1]
        -- Motion region fix
        -- Avoid out of bound column index
        if motionRegion.End[2] > #endLine then motionRegion.End[2] = #endLine - 1 end
    end


    -- Use extmark to track the motionRegion
    local repExtmark
    -- Always clear namespace before hand
    vim.api.nvim_buf_clear_namespace(bufNr, M.lastReplaceNs, 0, -1)
    local ok, msgOrVal = pcall(vim.api.nvim_buf_set_extmark, bufNr, M.lastReplaceNs,
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
    -- }}}

    -- Gather more register
    local reg
    if M.regName == "=" then
        -- TODO: tests required
        -- To get the expression result into the buffer, we use the unnamed
        -- register; this will be restored anyway.
        vim.fn.setreg('"', vim.g.ReplaceExpr)
        ---@type RegisterInfo
        reg = {
            name    = '"',
            type    = vim.fn.getregtype(M.regName),
            content = vim.g.ReplaceExpr
        }
    else
        ---@type RegisterInfo
        reg = {
            name    = M.regName,
            type    = vim.fn.getregtype(M.regName),
            content = vim.fn.getreg(M.regName, 1)
        }
    end


    -- Match the motionType type with register type
    ---@diagnostic disable-next-line: cast-local-type
    ok, msgOrVal = pcall(matchRegType, opInfo.motionType, motionRegion, motionDirection, opInfo.vimMode, reg)
    if not ok then
        ---@diagnostic disable-next-line: param-type-mismatch
        return vim.notify(msgOrVal, vim.log.levels.ERROR)
    else
        reg = msgOrVal
    end

    -- Replace with new content
    local rep
    ---@diagnostic disable-next-line: cast-local-type
    ok, msgOrVal = pcall(replace, opInfo.motionType, motionRegion, opInfo.vimMode, reg, bufNr)
    if not ok then
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.notify(msgOrVal, vim.log.levels.ERROR)
        -- TODO: clear rep extmark?
    else
        rep = msgOrVal
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    -- HACK: extmark covered by nvim_buf_set_lines and nvim_buf_set_text are
    -- always reversed?
    local repEndLine
    if not next(rep) then
        local repPos = vim.api.nvim_buf_get_extmark_by_id(bufNr, M.lastReplaceNs, repExtmark, {details = true})
        if opInfo.vimMode == "n" and opInfo.motionType == "line" and repPos[3].end_col == 0 and repPos[2] == 0 then
            if repPos[3].end_row < repPos[1] then
                -- NOTE: the END ROW has to subtract 1 offset
                repEndLine = vim.api.nvim_buf_get_lines(bufNr, repPos[1] - 1, repPos[1], false)[1]
                rep = {
                    Start = {repPos[3].end_row + 1, repPos[3].end_col},
                    End   = {repPos[1], #repEndLine - 1}
                }
            else
                repEndLine = vim.api.nvim_buf_get_lines(bufNr, repPos[3].end_row - 1, repPos[3].end_row, false)[1]
                rep = {
                    Start = {repPos[1] + 1, repPos[2]},
                    End   = {repPos[3].end_row, #repEndLine - 1}
                }
            end
        else
            if repPos[3].end_row < repPos[1] or (repPos[3].end_row == repPos[1] and repPos[3].end_col < repPos[2]) then
                -- NOTE: the END COLUMN has to subtract 1 offset
                repEndLine = vim.api.nvim_buf_get_lines(bufNr, repPos[1], repPos[1] + 1, false)[1]
                rep = {
                    Start = {repPos[3].end_row + 1, repPos[3].end_col},
                    End   = {repPos[1] + 1, repPos[2] - 1}
                }
            else
                repEndLine = vim.api.nvim_buf_get_lines(bufNr, repPos[3].end_row, repPos[3].end_row + 1, false)[1]
                rep = {
                    Start = {repPos[1] + 1, repPos[2]},
                    End   = {repPos[3].end_row + 1, repPos[3].end_col - 1}
                }
            end
        end
    end

    -- Create highlight
    -- Creates a new namespace or gets an existing one.
    if not (opInfo.vimMode == "n" and not M.highlightChangeChk) then
        local newContentExmark = util.nvimBufAddHl(
            bufNr,
            rep.Start,
            rep.End,
            reg.type,
            M.hlGroup,
            M.timeout,
            M.lastReplaceNs,
            true
        )
        if newContentExmark then
            M.lastReplaceExtmark = newContentExmark
        end
        if reg.type == "V" then
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
        if opInfo.vimMode == "n" then
            if not M.cursorPos then
                -- TODO: Supported cursor recall in dot-repeat mode
            else
                if util.compareDist(M.cursorPos, rep.End) <= 0 then
                    -- Replace content is bigger than the source, and cursor is
                    -- still in range of the replacement
                    local cursorLine = vim.api.nvim_buf_get_lines(bufNr,
                        M.cursorPos[1] - 1, M.cursorPos[1], false)[1]
                    cursorLine = #cursorLine == 0 and " " or cursorLine

                    if #cursorLine - 1 > M.cursorPos[2] then
                        vim.api.nvim_win_set_cursor(0, M.cursorPos)
                    else
                        vim.api.nvim_win_set_cursor(0, {M.cursorPos[1], #cursorLine - 1})
                    end
                else
                    if opInfo.motionType == "char" then
                        vim.api.nvim_win_set_cursor(0, rep.Start)
                    else
                    -- elseif motionType == "line" then
                        vim.cmd [[noa normal! ^]]
                    end
                end
            end
        elseif opInfo.vimMode == "v" then
            if reg.type == "V" then
                if M.cursorPos[1] == motionRegion.Start[1] and M.cursorPos[2] == motionRegion.Start[2] then
                    local startLine = vim.api.nvim_buf_get_lines(bufNr,
                        rep.Start[1] - 1, rep.Start[1], false)[1]
                    startLine = #startLine == 0 and " " or startLine
                    local _, indentEnd = string.find(startLine, "%s+")
                    if indentEnd then
                        vim.api.nvim_win_set_cursor(0, {rep.Start[1], indentEnd})
                    else
                        vim.api.nvim_win_set_cursor(0, rep.Start)
                    end
                else
                    vim.api.nvim_win_set_cursor(0, rep.End)
                end
            else
                if M.cursorPos[1] == motionRegion.Start[1] and M.cursorPos[2] == motionRegion.Start[2] then
                    vim.api.nvim_win_set_cursor(0, rep.Start)
                else
                    vim.api.nvim_win_set_cursor(0, rep.End)
                end
            end
        elseif opInfo.vimMode == "V" then
            if util.compareDist(M.cursorPos, rep.End) <= 0 then
                -- Avoid cursor out of scope
                local cursorLine = vim.api.nvim_buf_get_lines(bufNr,
                    M.cursorPos[1] - 1, M.cursorPos[1], false)[1]
                cursorLine = #cursorLine == 0 and " " or cursorLine

                if #cursorLine - 1 > M.cursorPos[2] then
                    vim.api.nvim_win_set_cursor(0, M.cursorPos)
                else
                    vim.api.nvim_win_set_cursor(0, {M.cursorPos[1], #cursorLine - 1})
                end
            else
                local startLine = vim.api.nvim_buf_get_lines(bufNr,
                    rep.Start[1] - 1, rep.Start[1], false)[1]
                startLine = #startLine == 0 and " " or startLine
                local _, indentEnd = string.find(startLine, "%s+")
                if indentEnd then
                    vim.api.nvim_win_set_cursor(0, {rep.Start[1], indentEnd})
                else
                    vim.api.nvim_win_set_cursor(0, rep.Start)
                end
            end
        else
            -- TODO: visual-block mode parse
        end
    end
    -- }}} Cursor

    -- Mapping repeating
    if opInfo.vimMode ~= "n" and vim.fn.exists("g:loaded_repeat") == 1 then
        vim.fn["repeat#setreg"](t(M.plugMap), M.regName);
        if M.currentLineChk then
            -- ReplaceCurLine
            vim.fn["repeat#set"](t(M.plugMap), M.count)
        elseif M.regName == "=" then
            vim.fn["repeat#set"](t"<Plug>ReplaceExpr")
        else
            -- VisualChar
            -- VisualLine
            vim.fn["repeat#set"](t(M.plugMap))
        end
    end
    -- Visual repeating
    if vim.fn.exists(vim.fn["visualrepeat#set"](t"<Plug>ReplaceVisual")) == 1 then
        vim.fn["visualrepeat#set"](t"<Plug>ReplaceVisual")
    end

    -- Reset
    M.cursorPos      = nil
    M.currentLineChk = false
    M.plugMap        = ""
end -- }}}
---Expression callback for replace operator
---@param restoreCursorChk boolean Whether to restore the cursor if possible
---@param highlightChangeChk boolean Whether to highlight the change. Only support turning off highlight changes in vim normal mode!
---@return string "g@"
function M.expr(restoreCursorChk, highlightChangeChk) -- {{{
    if not warnRead() then return "" end

    _G._opfunc = M.operator
    vim.o.opfunc = "LuaExprCallback"

    if restoreCursorChk then
        -- Preserving cursor position as its position will changed once the
        -- vim.o.opfunc() being called
        M.cursorPos = vim.api.nvim_win_get_cursor(0)
        M.placeCursor = true
    else
        M.cursorPos = nil
        M.placeCursor = false
    end

    M.highlightChangeChk = highlightChangeChk

    -- Evaluate the expression register outside of a function. Because
    -- unscoped variables do not refer to the global scope. Therefore,
    -- evaluation happened earlier in the mappings.
    return M.regName == "=" and [[:let g:ReplaceExpr = getreg("=")<CR>g@]] or "g@"
end -- }}}


return M
