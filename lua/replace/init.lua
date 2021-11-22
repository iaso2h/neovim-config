-- File: init
-- Author: iaso2h
-- Description: Heavily inspired Ingo Karkat's work. Replace text with register
-- Version: 0.1.1
-- Last Modified: 2021-11-19
local fn   = vim.fn
local cmd  = vim.cmd
local api  = vim.api
local util = require("util")
local M    = {
    regName              = nil,
    cursorPos            = nil,
    count                = nil,
    devMode              = false,
    motionDirection      = nil,
    restoreNondefaultReg = nil,
    restoreOption        = nil
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
    util.saveReg()
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
--- @param reg             table Contain name, type, content of v:register Can be
---                        "line", "char" or "block"
--- @param regionMotion    table Contain start and end position of operator
---                        movement. {1, 0} indexedontains
--- @param motionDirection number 1 indicate motion like "j, w, f" is moving
---                        forward -1 indicates motion is moving backward
--- @return number
local reindent = function(reg, regionMotion, motionDirection)
    -- Motion direction detection for i[, a{, i<. etc
    if not motionDirection then return end

    local _, regIndent       = string.find(reg.content, "^%s*")
    local _, prefixLineBreak = string.find(reg.content, "^\n*")
    -- Minus the leading line breaks
    if prefixLineBreak then regIndent = regIndent - prefixLineBreak end

    local bufferIndent
    if motionDirection == 1 then
        bufferIndent = fn.indent(regionMotion.startPos[1])
    else
        bufferIndent = fn.indent(regionMotion.endPos[1])
    end

    local reindentCnt  = bufferIndent - regIndent

    -- Convert tab to spaces
    local tabCnt = 0
    repeat
        tabCnt = tabCnt + 1
        tabCnt = string.find(reg.content, "\t", tabCnt)
    until not tabCnt or tabCnt > regIndent
    if tabCnt then regIndent = regIndent + tabCnt * api.nvim_buf_get_option(0, "tabstop") end
    return reindentCnt
end


----
-- Function: matchRegtype: Match the motionType type with register type
--
-- @param motionType:      String. Motion type by which how the operator perform.
--                         Can be "line", "char" or "block"
-- @param vimMode:         String. Vim mode. See: `:help mode()`
-- @param reg:             Table. Contain name, type, content of v:register
--                         Can be "line", "char" or "block"
-- @param regionMotion:    Table. Contain start and end position of operator movement. {1, 0} indexed
-- @param motionDirection: Number. 1 indicate motion like "j, w, f" is moving
--                         forward, -1 indicates motion is moving backward
-- @return:                Boolean. Return true when mataching successfully,
--                         otherwise return false
----
local matchRegType = function(motionType, vimMode, reg, regionMotion, motionDirection) -- {{{
    -- NOTE:"\<C-v>" for vimMode in vimscript is evaluated as "\22" in lua, which represents blockwise motion
    -- NOTE:"\0261" in vimscript is evaluated as "\0221" in lua, which represents blockwise-vusal register
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

                fn.setreg(reg.name, table.concat(linesConcn, "\n"), "b")
                return true
            end
        elseif reg.type == "V" and linesCnt > 1 then
            -- If the register contains multiple lines, paste as blockwise. then
            fn.setreg(reg.name, "", "b")
            return true
        else
            -- No need to changed register when the register type is already blockwise
            return false
        end
    elseif vimMode == "V" and reg.type == "v" then
        -- Prepend indents to the char type register to match the same indent
        -- of the first visual selected line
        local indent = fn.indent(regionMotion.startPos[1])
        -- BUG: validate the spaces in register beforehand
        if indent ~= 0 then
            fn.setreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
        end
    elseif vimMode == "n" and motionType == "line" then
        -- TODO: might be able to merge with when vimMode == "V"
        if reg.type == "v" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))
                if reindentCnt < 0 then
                    reg.content = string.gsub(reg.content, "^" .. reindents, "")
                elseif reindentCnt > 0 then
                    reg.content = reindents .. reg.content
                end
            end
        else
            -- TODO:
        end

        fn.setreg(reg.name, reg.content, "v")

        return true
    elseif reg.type == "V" and string.match(reg.content, "\n$") then
        -- Our custom operator is characterwise, even in the
        -- ReplaceWithRegisterLine variant, in order to be able to replace less
        -- than entire lines (i.e. characterwise yanks).
        -- So there"s a mismatch when the replacement text is a linewise yank,
        -- and the replacement would put an additional newline to the end.
        -- To fix that, we temporarily remove the trailing newline character from
        -- the register contents and set the register type to characterwise yank.
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = stringCount(reg.content, "\n")

            -- Reindent the lines if counts do not match up
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))
                if reindentCnt < 0 then
                    reg.content = string.gsub(reg.content, "^" .. reindents, "")
                    if lineCnt ~= 1 then
                        reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    end
                elseif reindentCnt > 0 then
                    reg.content = reindents .. reg.content
                    if lineCnt ~= 1 then
                        reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                    end
                end
            end

            fn.setreg(reg.name, string.sub(reg.content, 1, -2), "V")
        elseif motionType == "char" then
            fn.setreg(reg.name, vim.trim(reg.content), "v")
        else
            -- TODO: blockwise parsing?
        end

        return true
    else
        -- TODO:?
    end

    return false
end -- }}}


----
-- Replace text by manipulating visual selection and put
--
-- @param motionType:   String. Motion type by which how the operator perform.
--                      Can be "line", "char" or "block"
-- @param vimMode:      String. Vim mode. See: `:help mode()`
-- @param reg:          Table. Contain name, type, content of v:register
--                      Can be "line", "char" or "block"
-- @param regionMotion: Table. Contain start and end position of operator movement. {1, 0} indexed
-- @param curBufNr:     Ineger. Buffer handler(number)
----
local replace = function(motionType, vimMode, reg, regionMotion, curBufNr) -- {{{
    -- With a put in visual mode, the previously selected text is put in the
    -- unnamed register, so we need to save and restore that.
    reg.name = reg.name == [["]] and "" or [["]] .. reg.name

    if vimMode ~= "n" then
        cmd(string.format("noa norm! gv%sp", reg.name))
    else
        -- TODO: tests needed
        if util.compareDist(regionMotion.startPos, regionMotion.endPos) > 0 then
            -- This's the scenario where startpos is fall behind endpos
            cmd(string.format("noa norm! %sP", reg.name))
        else
            -- This's the most common case
            local visualCMD = motionType == "line" and "V" or "v"

            api.nvim_win_set_cursor(0, regionMotion.endPos)
            cmd("noa norm! " .. visualCMD)
            api.nvim_win_set_cursor(0, regionMotion.startPos)
            cmd("noa norm!" .. reg.name .. "p")
        end

    end

    -- Create extmark to track position of new content
    local repStart = api.nvim_buf_get_mark(0, "[")
    local repEnd   = api.nvim_buf_get_mark(0, "]")

    -- Inplace-replaced new can be retieved from 'gp' mapping, same as the inplace-put
    require("yankPut").inplacePutNewContentNS      = api.nvim_create_namespace("inplacePutNewContent")
    require("yankPut").inplacePutNewContentExtmark = api.nvim_buf_set_extmark(curBufNr,
        require("yankPut").inplacePutNewContentNS,
        repStart[1] - 1, repStart[2],
        {end_line = repEnd[1] - 1, end_col = repEnd[2]})

    -- Report change in Neovim statusbar
    local srcLinesCnt = regionMotion.endPos[1] - regionMotion.startPos[1] + 1
    local repLineCnt  = repEnd[1] - repStart[1] + 1
    if srcLinesCnt >= vim.o.report or repLineCnt >= vim.o.report then
        local srcReport = string.format("Replaced %d line%s", srcLinesCnt, srcLinesCnt == 1 and "" or "s")
        local repReport = srcLinesCnt == repLineCnt and '' or
            string.format(" with %d line%s", repLineCnt, repLineCnt == 1 and "" or "s")

        api.nvim_echo({{srcReport .. repReport, "Normal"}}, false, {})
    end

    return {startPos = repStart, endPos = repEnd}
end -- }}}


--- This function will be called when g@ is evaluated by Neovim
--- @param args table of argument: {motionType, vimMode, plugMap}
---        motionType: String. Motion type by which how the operator perform.
---                    Can be "line", "char" or "block"
---        vimMode:    String. Vim mode. See: `:help mode()`
---        plugMap:    String. eg: <Plug>myplug
function M.operator(args) -- {{{
    if not warnRead() then return end

    local motionType = args[1]
    local vimMode    = args[2]
    local plugMap    = args[3]
    local opts = {hlGroup = "Search", timeout = 250}

    local curBufNr = api.nvim_get_current_buf()
    local regionMotion
    local reg
    local motionDirection

    -- Saving {{{
    if vimMode == "n" then
        -- For Replace operator inclusively

        regionMotion = {
            startPos = api.nvim_buf_get_mark(curBufNr, "["),
            endPos   = api.nvim_buf_get_mark(curBufNr, "]")
        }
        -- This is for M.expr() only. Other type of replace will do the saving
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
        -- For all replace modes other than replace operator

        regionMotion = {
            startPos = api.nvim_buf_get_mark(curBufNr, "<"),
            endPos   = api.nvim_buf_get_mark(curBufNr, ">")
        }
        -- Save cusor position
        if vimMode == "V"  then
            if #args ~= 4 then
                -- Because Visual Line Mode the cursor will place at the first column once
                -- entering commandline mode. Therefor "gv" is exectued here to retrieve it.
                -- Somehow the below command sequence cannot produce the effect of retrieving:
                -- vim.cmd[[:lua vim.cmd([[norm! gv]] .. t"<Esc>"); Print(vim.api.nvim_win_get_cursor(0))]]
                cmd([[noa norm! gvm`]] .. t"<Esc>")
                M.cursorPos = api.nvim_buf_get_mark(curBufNr, "`")
            else
                M.cursorPos = api.nvim_win_get_cursor(0)
                vim.cmd("noa norm! V" .. vim.v.count1 .. "_" .. t"<Esc>");
            end
        else
            M.cursorPos = api.nvim_win_get_cursor(0)
        end
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
            content = fn.getreg(vim.v.register, 1)
        }
    end


    -- Match the motionType type with register type
    local ok, regChanged = pcall(matchRegType, motionType, vimMode, reg, regionMotion, motionDirection)
    if not ok then vim.notify(regChanged, vim.log.levels.ERROR) end

    -- Replace with new content
    local ok, regionReplace = pcall(replace, motionType, vimMode, reg, regionMotion, curBufNr)
    if not ok then vim.notify(regionReplace, vim.log.levels.ERROR) end

    -- Create highlight {{{
    local repHLNS = api.nvim_create_namespace("inplaceReplaceHL")
    api.nvim_buf_clear_namespace(curBufNr, repHLNS, 0, -1)

    local region = vim.region(curBufNr,
        {regionReplace.startPos[1] - 1, regionReplace.startPos[2]},
        {regionReplace.endPos[1] - 1,   regionReplace.endPos[2]},
        reg.type, true)

    for lineNr, cols in pairs(region) do
        api.nvim_buf_add_highlight(curBufNr, repHLNS, opts["hlGroup"], lineNr, cols[1], cols[2])
    end

    vim.defer_fn(function()
        -- In case of buffer being deleted
        if api.nvim_buf_is_valid(curBufNr) then
            pcall(api.nvim_buf_clear_namespace, curBufNr, repHLNS, 0, -1)
        end
    end, opts["timeout"])
    -- }}} Create highlight
    -- Restoration {{{

    -- Register
    util.restoreReg()
    -- Options
    if vim.is_callable(M.restoreOption) then M.restoreOption() end

    -- Cursor
    if vimMode == "n" then
        if not M.cursorPos then
            -- TODO: Dot repeat not supported
        else
            if require("util").compareDist(M.cursorPos, regionReplace.endPos) <= 0 then
                -- Avoid curosr out of scope
                local cursorLine = api.nvim_buf_get_lines(curBufNr,
                    M.cursorPos[1] - 1, M.cursorPos[1], false)[1]
                cursorLine = #cursorLine == 0 and 1 or cursorLine

                if #cursorLine - 1 > M.cursorPos[2] then
                    api.nvim_win_set_cursor(0, M.cursorPos)
                else
                    api.nvim_win_set_cursor(0, {M.cursorPos[1], #cursorLine - 1})
                end
            else
                if motionType == "char" then -- {{{
                    api.nvim_win_set_cursor(0, regionReplace.startPos)
                elseif motionType == "line" then
                    -- Cursor should be able to locate itself at the no-blank
                    -- beginning of the replacement
                else
                    -- TODO: blockwise parse
                end
            end

            -- Always clear M.cursorPos after restoration
            if not M.devMode then
                M.cursorPos = nil
            end
        end
    else
        local firstNewLine = api.nvim_get_current_line()
        local newCol = #firstNewLine == 0 and 1 or #firstNewLine
        -- In cases the text length of new text content is shorter
        -- than the one of origin text
        if M.cursorPos[2] + 1 >= newCol then
            api.nvim_win_set_cursor(0, {regionReplace.startPos[1], newCol - 1})
        else
            api.nvim_win_set_cursor(0, {regionReplace.startPos[1], M.cursorPos[2]})
        end
    end
    -- }}} Restoration

    -- Mapping repeating {{{
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

    -- }}} visualrepeat visualrepeat1
end -- }}}


--- Expression callback for replace operator
--- @return string "g@"
function M.expr() -- {{{
    -- TODO: Detect virutal edit
    if not warnRead() then return "" end

    Opfunc = M.operator
    vim.o.opfunc = "LuaExprCallback"
    require("operator")

    -- Preserving cursor position as its position will changed once the
    -- vim.o.opfunc() being called
    M.cursorPos = api.nvim_win_get_cursor(0)

    -- Evaluate the expression register outside of a function. Because
    -- unscoped variables do not refer to the global scope. Therefore,
    -- evaluation happened earlier in the mappings.
    return M.regName == "=" and [[:let g:ReplaceExpr = getreg("=")<CR>g@]] or "g@"
end -- }}}


return M

