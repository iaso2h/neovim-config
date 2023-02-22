-- File: replace
-- Author: iaso2h
-- Description: Heavily inspired Ingo Karkat's work. Replace text with register
-- Version: 0.1.5
-- Last Modified: 2022-01-27
-- TODO: tests for softtab convert
local fn       = vim.fn
local cmd      = vim.cmd
local api      = vim.api
local util     = require("util")
local register = require("register")
require("operator")
local M    = {
    regName              = nil,
    cursorPos            = nil, -- (1, 0) indexed
    count                = nil,
    motionDirection      = nil,
    restoreNondefaultReg = nil,
    restoreOption        = nil,
    suppressMessage      = nil
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
M.replaceSave = function()
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

    -- BUG: somehow it will triger xclipboard warning
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
--- @param regionMotion table Contain start and end position of operator
--- movement. {1, 0} indexedontains
--- @param motionDirection number 1 indicate motion like "j, w, f" is moving
--- forward -1 indicates motion is moving backward
--- @param vimMode string Vim mode
--- @return string/boolean Value of changed register content or false if no
--- content changed
--- when reindentation is successful
local reindent = function(regContent, regionMotion, motionDirection, vimMode)
    -- The value of bufferIndent is the first line where motion starts or
    -- visual selection starts
    local bufferIndent
    if vimMode == "V" then
        -- In visual linewise mode, set the indentation value of starting
        -- position of region motion to bufferIndent
        bufferIndent = fn.indent(regionMotion.startPos[1])
    else
        if motionDirection == -1 then
            bufferIndent = fn.indent(regionMotion.endPos[1])
        -- elseif motionDirection == 1 then
            -- bufferIndent = fn.indent(regionMotion.startPos[1])
        else
            -- It's hard to detect the motion direction for i[, a{, i<. etc in normal mode
            -- nil and 1 using the value of regionMotion.startPos
            bufferIndent = fn.indent(regionMotion.startPos[1])
            -- return false
        end
    end

    -- Get reindent count
    local reindent = bufferIndent - register.getIndent(regContent)

    -- Reindent the lines if counts do not match up
    if reindent ~= 0 then
        return register.reindent(reindent, regContent)
    else
        return false
    end
end


----
-- Function: matchRegtype: Match the motionType type with register type
--
-- @param motionType: String. Motion type by which how the operator perform.
-- Can be "line", "char" or "block"
-- @param vimMode: String. Vim mode. See: `:help mode()`
-- @param reg: Table. Contain name, type, content of v:register
-- Can be "line", "char" or "block"
-- @param regionMotion: Table. Contain start and end position of operator movement. {1, 0} indexed
-- @param motionDirection: Number. 1 indicate motion like "j, w, f" is moving
-- forward, -1 indicates motion is moving backward
-- @return: Boolean. Return true when mataching successfully,
-- otherwise return false
----
local matchRegType = function(motionType, vimMode, reg, regionMotion, motionDirection) -- {{{
    -- NOTE:"\<C-v>" for vimMode in vimscript is evaluated as "\22" in lua, which represents blockwise motion
    -- NOTE:"\0261" in vimscript is evaluated as "\0221" in lua, which represents blockwise-vusal register
    -- Vim mode
    --  ├── block mode
    --  │    └── ...
    --  ├── normal mode
    --  │    ├── "v" register type
    --  │    │     ├── "char" motion type(charwise)
    --  │    │     ├── "line" motion type(linewise)
    --  │    │     └── "block" motion type(blockwise-visual)
    --  │    ├── "V" register type
    --  │    │     └── ...
    --  │    └── "<C-v>" register type
    --  │          └── ...
    --  └── visual mode
    --       └── ...
    if vimMode == "\22" and motionType == "block" then
        -- Adapt register for blockwise replace.
        local lines    = vim.split(reg.content, "\n", false)
        local linesCnt = #lines

        if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
            -- If the register contains just a single line, temporarily duplicate
            -- the line to match the height of the blockwise selection.
            local height = regionMotion.startPos[1] - regionMotion.endPos[1] + 1
            if height > 1 then
                local linesConcn = {}
                for _ = 1, height, 1 do
                    linesConcn = tbl_merge(linesConcn, lines)
                end

                local regContentNew = table.concat(linesConcn, "\n")
                fn.setreg(reg.name, regContentNew, "b")
                reg.content = regContentNew
            end
        elseif reg.type == "V" and linesCnt > 1 then
            -- If the register contains multiple lines, paste as blockwise. then
            -- TODO:
            fn.setreg(reg.name, "", "b")
        else
            -- No need to changed register when the register type is already blockwise
        end
    elseif vimMode == "n" then
        if reg.type == "v" then
            if motionType == "line" then
                local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
                -- Reindent register content when it's available
                if regContentNew then
                    fn.setreg(reg.name, regContentNew, "v")
                    reg.content = regContentNew
                end
            else
                -- No need to modify register
            end
        elseif reg.type == "V" then
            -- Our custom operator is characterwise, even in the
            -- ReplaceWithRegisterLine variant, in order to be able to replace less
            -- than entire lines (i.e. characterwise yanks).
            -- So there"s a mismatch when the replacement text is a linewise yank,
            -- and the replacement would put an additional newline to the end.
            -- To fix that, we temporarily remove the trailing newline character from
            -- the register contents and set the register type to characterwise yank.
            if motionType == "line" then
                local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
                -- Reindent register content when it's available
                if regContentNew then
                    if vim.endswith(regContentNew, "\n") then
                        regContentNew = string.sub(regContentNew, 1, -2)
                    end
                    fn.setreg(reg.name, regContentNew, "v")
                else
                    if vim.endswith(reg.content, "\n") then
                        regContentNew = string.sub(reg.content, 1, -2)
                    end
                    fn.setreg(reg.name, regContentNew, "v")
                end

                reg.content = regContentNew
            elseif motionType == "char" then
                local regContentNew = vim.trim(reg.content)
                fn.setreg(reg.name, regContentNew, "v")
                reg.content = regContentNew
            else
                -- TODO: blockwise-visual motionType parsing?
            end
        else
            -- TODO: block type register parsing?
        end
    elseif vimMode == "v" then
        -- No need to modify register
    elseif vimMode == "V" then
        local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
        -- Reindent register content when it's available
        if regContentNew then
            fn.setreg(reg.name, regContentNew, reg.type)
            reg.content = regContentNew
        end

    else
        -- TODO: more vimMode and tests
    end
end -- }}}


--- Replace text by manipulating visual selection and put
--- @param motionType string Motion type by which how the operator
--- perform. Can be "line", "char" or "block"
--- @param vimMode string Vim mode. See: `:help mode()`
--- @param reg table Contain name, type, content of v:register Can be "line",
--- "char" or "block"
--- @param regionMotion table Contain start and end position of operator movement. {1, 0} indexed
--- @param curBufNr integer Buffer handler(number)
--- @param opts table Options about highlighting
--- @return table {repStart = {}, repEnd = {}}
local replace = function(motionType, vimMode, reg, regionMotion, curBufNr, opts) -- {{{
    -- With a put in visual mode, the previously selected text is put in the
    -- unnamed register, so we need to save and restore that.
    local regCMD = reg.name == [["]] and "" or ([["]] .. reg.name)

    if vimMode ~= "n" then
        cmd(string.format("noa norm! gv%sp", regCMD))
    else
        if util.compareDist(regionMotion.startPos, regionMotion.endPos) > 0 then
            -- This's a rare scenario where startpos is fall behind endpos
            vim.notify("Startpos fall behind endpos", vim.log.levels.ERROR)
            cmd(string.format("noa norm! %sP", regCMD))
        else
            local visualCMD = motionType == "line" and "V" or "v"

            api.nvim_win_set_cursor(0, regionMotion.endPos)
            cmd("noa norm! " .. visualCMD)
            api.nvim_win_set_cursor(0, regionMotion.startPos)
            cmd("noa norm!" .. regCMD .. "p")
        end
    end

    -- Create extmark to track position of new content
    local repStart = api.nvim_buf_get_mark(0, "[")
    local repEnd   = api.nvim_buf_get_mark(0, "]")

    -- Create highlight {{{
    -- Creates a new namespace or gets an existing one.
    require("yankPut").inplacePutNewContentNS = api.nvim_create_namespace("inplacePutNewContent")
    local newContentExmark = util.nvimBufAddHl(curBufNr, repStart, repEnd,
            reg.type, opts.hlGroup, opts.timeout, require("yankPut").inplacePutNewContentNS)
    if newContentExmark then require("yankPut").inplacePutNewContentExtmark = newContentExmark end
    -- }}} Create highlight

    -- Report change in Neovim statusbar
    if not M.suppressMessage then
        local srcLinesCnt = regionMotion.endPos[1] - regionMotion.startPos[1] + 1
        local repLineCnt  = repEnd[1] - repStart[1] + 1
        if srcLinesCnt >= vim.o.report or repLineCnt >= vim.o.report then
            local srcReport = string.format("Replaced %d line%s", srcLinesCnt, srcLinesCnt == 1 and "" or "s")
            local repReport = srcLinesCnt == repLineCnt and '' or
                string.format(" with %d line%s", repLineCnt, repLineCnt == 1 and "" or "s")

            api.nvim_echo({{srcReport .. repReport, "Normal"}}, false, {})
            -- TODO: Make new message start at another new line
        end
    end

    return {startPos = repStart, endPos = repEnd}
end -- }}}


--- This function will be called when g@ is evaluated by Neovim
--- @param args table of argument: {motionType, vimMode, plugMap}
--- motionType: String. Motion type by which how the operator perform.
--- Can be "line", "char" or "block"
--- vimMode:    String. Vim mode. See: `:help mode()`
--- plugMap:    String. eg: <Plug>myplug
function M.operator(args) -- {{{
    if not warnRead() then return end

    -- NOTE: see ":help g@" for details about motionType
    local motionType = args[1]
    local vimMode    = args[2]
    local plugMap    = args[3]
    local opts = {hlGroup = "Search", timeout = 250}

    local curBufNr = api.nvim_get_current_buf()
    local regionMotion
    local reg
    local motionDirection

    -- Saving {{{
    -- In addition to the M.replaceSave(), some generic savings are implemented here
    if vimMode == "n" then
        -- For Replace operator exclusively

        regionMotion = {
            startPos = api.nvim_buf_get_mark(curBufNr, "["),
            endPos   = api.nvim_buf_get_mark(curBufNr, "]")
        }
        -- This is for M.expr() only. Other Replace mapping will do the saving
        -- part before calling operator(). Saving register in the expr() will
        -- be ignore when using dot repeat
        M.replaceSave()

        if motionType == "line" then
            if M.cursorPos then
                if M.cursorPos[1] == regionMotion.endPos[1] then
                    -- Motion direction detection for k
                    motionDirection = -1
                elseif M.cursorPos[1] == regionMotion.startPos[1] then
                    -- Motion direction detection for j
                    motionDirection = 1
                else
                    -- Motion direction detection for i[, a{, i<. etc
                end

                -- Store for dot reeat
                M.motionDirection = motionDirection
            else
                -- Dot repeat
                -- Motion direction detection. Perform in dot repeat, use the existing value in M.motionDirection
                motionDirection = M.motionDirection
            end
        else
            -- TODO: charwise and blockwise motion parsing?
            M.motionDirection = nil
        end

    else
        -- For all replace modes other than the replace operator

        -- The value of vim.v.count1 will be changed whenever the
        -- vim.cmd("norm! <normal command>") is executed, so the preservation
        -- of register and count have to be done in advanced. Due to the
        -- mapping of replacing current line is parsed in "V" vim mode, and
        -- the preservation of register in other visual vim mode is
        -- implemented in the key mapping stage Save cusor position, therefore
        -- the replaceSave() is called in the key mapping stage to achieve
        -- a consistent mapping layout
        if vimMode == "V" and #args == 4 then
            -- For mapping of replacing current line
            M.cursorPos = api.nvim_win_get_cursor(0)
            -- Override the position of mark "<" and ">"
            vim.cmd("noa norm! V" .. M.count .. "_" .. t"<Esc>");
        else
            -- Because in visual mode, the cursor will place at the first
            -- column once entering commandline mode. Therefor cursor is
            -- retrieved by execting the "gv" command. But Somehow the below
            -- command sequence cannot produce the effect of retrieving the
            -- correct cursor:

            -- In the end, a workaround is use by retrieving the mark position
            -- which is set in the cursor potion
            cmd([[noa norm! gvm`]] .. t"<Esc>")
            M.cursorPos = api.nvim_buf_get_mark(curBufNr, "`")
        end

        regionMotion = {
            startPos = api.nvim_buf_get_mark(curBufNr, "<"),
            endPos   = api.nvim_buf_get_mark(curBufNr, ">")
        }
    end

    -- Save vim options
    saveOption()
    -- }}} Saving

    -- Gather register info
    if M.regName == "=" then
        -- To get the expression result into the buffer, we use the unnamed
        -- register; this will be restored, anyway.
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
    local ok, msg = pcall(matchRegType, motionType, vimMode, reg, regionMotion, motionDirection)
    if not ok then vim.notify(msg, vim.log.levels.ERROR) end

    -- Replace with new content
    local regionReplace
    ok, msg = pcall(replace, motionType, vimMode, reg, regionMotion, curBufNr, opts)
    if not ok then
        vim.notify(msg, vim.log.levels.ERROR)
    else
        regionReplace = msg
    end

    -- Restoration {{{
    -- Register
    register.restoreReg()
    -- Options
    if vim.is_callable(M.restoreOption) then M.restoreOption() end

    -- Curosr {{{
    if vimMode == "n" then
        if not M.cursorPos then
            -- TODO: Supported in repeat mode?
        else
            if util.compareDist(M.cursorPos, regionReplace.endPos) <= 0 then
                -- Avoid curosr out of scope
                local cursorLine = api.nvim_buf_get_lines(curBufNr,
                    M.cursorPos[1] - 1, M.cursorPos[1], false)[1]
                cursorLine = #cursorLine == 0 and " " or cursorLine

                if #cursorLine - 1 > M.cursorPos[2] then
                    api.nvim_win_set_cursor(0, M.cursorPos)
                else
                    api.nvim_win_set_cursor(0, {M.cursorPos[1], #cursorLine - 1})
                end
            else
                if motionType == "char" then
                    api.nvim_win_set_cursor(0, regionReplace.startPos)
                elseif motionType == "line" then
                    -- Cursor should be able to locate itself at the no-blank
                    -- beginning of the replacement
                else
                    -- TODO: blockwise parse
                end
            end

            -- Always clear M.cursorPos after restoration
            M.cursorPos = nil
        end
    elseif vimMode == "v" then
        if reg.type == "V" or reg.type == "l" then
            if M.cursorPos[1] == regionMotion.startPos[1] and M.cursorPos[2] == regionMotion.startPos[2] then
                local startLine = api.nvim_buf_get_lines(curBufNr,
                    regionReplace.startPos[1] - 1, regionReplace.startPos[1], false)[1]
                startLine = #startLine == 0 and " " or startLine
                local _, indentEnd = string.find(startLine, "%s+")
                if indentEnd then
                    api.nvim_win_set_cursor(0, {regionReplace.startPos[1], indentEnd})
                else
                    api.nvim_win_set_cursor(0, regionReplace.startPos)
                end
            else
                api.nvim_win_set_cursor(0, regionReplace.endPos)
            end
        else
            if M.cursorPos[1] == regionMotion.startPos[1] and M.cursorPos[2] == regionMotion.startPos[2] then
                api.nvim_win_set_cursor(0, regionReplace.startPos)
            else
                api.nvim_win_set_cursor(0, regionReplace.endPos)
            end
        end

    elseif vimMode == "V" then
        if util.compareDist(M.cursorPos, regionReplace.endPos) <= 0 then
            -- Avoid curosr out of scope
            local cursorLine = api.nvim_buf_get_lines(curBufNr,
                M.cursorPos[1] - 1, M.cursorPos[1], false)[1]
            cursorLine = #cursorLine == 0 and " " or cursorLine

            if #cursorLine - 1 > M.cursorPos[2] then
                api.nvim_win_set_cursor(0, M.cursorPos)
            else
                api.nvim_win_set_cursor(0, {M.cursorPos[1], #cursorLine - 1})
            end
        else
            local startLine = api.nvim_buf_get_lines(curBufNr,
                regionReplace.startPos[1] - 1, regionReplace.startPos[1], false)[1]
            startLine = #startLine == 0 and " " or startLine
            local _, indentEnd = string.find(startLine, "%s+")
            if indentEnd then
                api.nvim_win_set_cursor(0, {regionReplace.startPos[1], indentEnd})
            else
                api.nvim_win_set_cursor(0, regionReplace.startPos)
            end
        end
    else
        -- TODO: visual-blcok mode parse
    end
    -- }}} Curosr
    -- }}} Restoration

    -- Mapping repeating {{{
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

    -- }}} Mapping repeating
end -- }}}


--- Expression callback for replace operator
--- @param restoreCursorChk boolean Whether to restore the cursor if possible
--- @return string "g@"
function M.expr(restoreCursorChk) -- {{{
    -- TODO: Detect virutal edit
    if not warnRead() then return "" end

    Opfunc = M.operator
    vim.o.opfunc = "LuaExprCallback"

    if restoreCursorChk then
        -- Preserving cursor position as its position will changed once the
        -- vim.o.opfunc() being called
        M.cursorPos = api.nvim_win_get_cursor(0)
    else
        M.cursorPos = nil
    end

    -- Evaluate the expression register outside of a function. Because
    -- unscoped variables do not refer to the global scope. Therefore,
    -- evaluation happened earlier in the mappings.
    return M.regName == "=" and [[:let g:ReplaceExpr = getreg("=")<CR>g@]] or "g@"
end -- }}}


return M

