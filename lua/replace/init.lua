-- File: init
-- Author: iaso2h
-- Description: Heavily inspired Ingo Karkat's work. Replace text with register
-- Version: 0.0.5
-- Last Modified: 2021-09-21
local fn   = vim.fn
local cmd  = vim.cmd
local api  = vim.api
local M    = {}
local util = require("util")
local restoreOption


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
    M.regType   = vim.v.register
    M.count     = vim.v.count1
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
        restoreOption = function()
            if saveSelection then vim.opt.selection = saveSelection end
            if saveClipboard then vim.opt.clipboard = saveClipboard end
        end
    end
end -- }}}

----
-- Function: matchRegtype: Match the motionType type with register type
--
-- @param motionType: String. Motion type by which how the operator perform.
--                    Can be "line", "char" or "block"
-- @param vimMode:    String. Vim mode. See: `:help mode()`
-- @param reg:        Table. Contain name, type, content of v:register
--                    Can be "line", "char" or "block"
-- @param pos:        Table. Contain start and end position of operator movement
-- @return:           Boolean. Return true when mataching successfully,
--                    otherwise return false
----
local matchRegType = function(motionType, vimMode, reg, pos) -- {{{
    -- NOTE:"\<C-v>" for vimMode in vimscript is evaluated as "\22" in lua, which represents blockwise motion
    -- NOTE:"\0261" in vimscript is evaluated as "\0221" in lua, which represents blockwise-vusal register
    -- TODO: match the same indent for grr with regtype is "V"
    if motionType == "block" and vimMode == "\22" then
        -- Adapt register for blockwise replace.
        local lines    = vim.split(reg.content, "\n", false)
        local linesCnt = #lines

        if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
            -- If the register contains just a single line, temporarily duplicate
            -- the line to match the height of the blockwise selection.
            local height = pos.startPos[1] - pos.endPos[1] + 1
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
    elseif reg.type == "v" and vimMode == "V" then
        -- Prepend indents to the char type register to match the same indent
        -- of the first visual selected line
        local indent = fn.indent(pos.startPos[1])
        if indent ~=0 then
            fn.setreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
        end
    elseif reg.type == "V" and string.match(reg.content, "\n$") then
        -- Our custom operator is characterwise, even in the
        -- ReplaceWithRegisterLine variant, in order to be able to replace less
        -- than entire lines (i.e. characterwise yanks).
        -- So there"s a mismatch when the replacement text is a linewise yank,
        -- and the replacement would put an additional newline to the end.
        -- To fix that, we temporarily remove the trailing newline character from
        -- the register contents and set the register type to characterwise yank.
        if motionType == "line" then
            -- TODO: Only support one line reindent, multiline support needed
            local lineCnt = str_count(reg.content, "\n")
            if lineCnt == 1 then
                local _, regIndent = string.find(reg.content, "^%s*")
                local bufferIndent = fn.indent(pos.startPos[1])
                local reindentCnt = bufferIndent - regIndent
                -- TODO: Need to test with real tab character indent, not soft tab indent
                if reindentCnt < 0 then
                    reg.content = string.gsub(reg.content, "^" .. string.rep(" ", math.abs(reindentCnt)), "")
                elseif reindentCnt > 0 then
                    reg.content = string.rep(" ", reindentCnt) .. reg.content
                end
            end
            fn.setreg(reg.name, string.sub(reg.content, 1, -2), "V")
        else
            fn.setreg(reg.name, vim.trim(reg.content), "v")
        end
        return true
    end

    return false
end -- }}}

----
-- Function: replace___: Replace text by manipulating visual selection and put
--
-- @param motionType: String. Motion type by which how the operator perform.
--                    Can be "line", "char" or "block"
-- @param vimMode:    String. Vim mode. See: `:help mode()`
-- @param reg:        Table. Contain name, type, content of v:register
--                    Can be "line", "char" or "block"
-- @param pos:        Table. Contain start and end position of operator movement
-- @param curBufNr:   Ineger. Buffer handler(number)
----
local replace = function(motionType, vimMode, reg, pos, curBufNr) -- {{{
    -- With a put in visual mode, the previously selected text is put in the
    -- unnamed register, so we need to save and restore that.
    reg.name = reg.name == [["]] and "" or [["]] .. reg.name

    if vimMode ~= "n" then
        cmd(string.format("noa norm! gv%sp", reg.name))
    else
        -- TODO: tests needed
        if util.compareDist(pos.startPos, pos.endPos) > 0 then
            -- This's the scenario where startpos is fall behind endpos
            cmd(string.format("noa norm! %sP", reg.name))
        else
            -- This's the most common case
            local visualCMD = motionType == "line" and "V" or "v"

            api.nvim_win_set_cursor(0, pos.startPos)
            cmd("noa norm! " .. visualCMD)
            api.nvim_win_set_cursor(0, pos.endPos)
            cmd("noa norm!" .. reg.name .. "p")
        end

    end

    -- Create extmark to track position of new content
    local repStart   = api.nvim_buf_get_mark(0, "[")
    local repEnd     = api.nvim_buf_get_mark(0, "]")
    local repNS      = api.nvim_create_namespace("inplacePutNewContent")
    local repExtmark = api.nvim_buf_set_extmark(curBufNr, repNS,
                                                repStart[1] - 1, repStart[2],
                                                {
                                                    end_line = repEnd[1] - 1,
                                                    end_col  = repEnd[2]
                                                })
    -- Inplace-replaced new can be retieved from 'gp' mapping, same as the inplace-put
    require("yankPut").inplacePutNewContentNS      = repNS
    require("yankPut").inplacePutNewContentExtmark = repExtmark
    -- Report change in Neovim statusbar
    local srcLinesCnt = pos.endPos[1] - pos.startPos[1] + 1
    local repLineCnt  = repEnd[1] - repStart[1] + 1
    if srcLinesCnt >= vim.o.report or repLineCnt >= vim.o.report then
        local srcReport = string.format("Replaced %d line%s", srcLinesCnt, srcLinesCnt == 1 and "" or "s")
        local repReport = srcLinesCnt == repLineCnt and '' or
            string.format(" with %d line%s", repLineCnt, repLineCnt == 1 and "" or "s")

        api.nvim_echo({{srcReport .. repReport, "Normal"}}, false, {})
    end

    return {
        namespace = repNS,
        extmark   = repExtmark
    }
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
    local pos
    local reg
    -- Saving {{{
    -- Save registers and vim options
    util.saveReg()
    saveOption()

    -- Save cusor position
    if vimMode ~= "n" then
        if vimMode == "V"  then
            if #args ~= 4 then
                -- Because Visual Line Mode the cursor will place at the first column once
                -- entering commandline mode. Therefor "gv" is exectued here to retrieve it.
                -- Somehow the below command sequence cannot produce the effect of retrieving:
                -- vim.cmd[[:lua vim.cmd([[norm! gv]] .. t"<Esc>"); Print(vim.api.nvim_win_get_cursor(0))]]
                cmd([[noa norm! gvmz]] .. t"<Esc>")
                M.cursorPos = api.nvim_buf_get_mark(curBufNr, "z")
            else
                M.cursorPos = api.nvim_win_get_cursor(0)
                vim.cmd("noa norm! V" .. vim.v.count1 .. "_" .. t"<Esc>");
            end
        elseif vimMode ~= "V" then
            M.cursorPos = api.nvim_win_get_cursor(0)
        end
    end
    -- }}} Saving

    if M.regType == "=" then
        -- To get the expression result into the buffer, we use the unnamed
        -- register; this will be restored, anyway.
        fn.setreg('"', vim.g.ReplaceExpr)
        reg = {
            name    = '"',
            type    = fn.getregtype(M.regType),
            content = vim.g.ReplaceExpr
        }
    else
        reg = {
            name    = M.regType,
            type    = fn.getregtype(M.regType),
            content = fn.getreg(vim.v.register, 1)
        }
    end

    if vimMode ~= "n" then
        pos = {
            startPos = api.nvim_buf_get_mark(curBufNr, "<"),
            endPos   = api.nvim_buf_get_mark(curBufNr, ">")
        }
    else
        pos = {
            startPos = api.nvim_buf_get_mark(curBufNr, "["),
            endPos   = api.nvim_buf_get_mark(curBufNr, "]")
        }
    end

    -- Match the motionType type with register type
    local ok, regChanged = pcall(matchRegType, motionType, vimMode, reg, pos)
    if not ok then vim.notify(regChanged, vim.log.levels.ERROR) end


    -- Replace with new content
    local ok, replaced = pcall(replace, motionType, vimMode, reg, pos, curBufNr)
    if not ok then vim.notify(replaced, vim.log.levels.ERROR) end

    -- Create highlight {{{
    local repHLNS = api.nvim_create_namespace("inplaceReplaceHL")
    api.nvim_buf_clear_namespace(curBufNr, repHLNS, 0, -1)

    local repExtmark = api.nvim_buf_get_extmark_by_id(curBufNr,
                                    replaced.namespace,
                                    replaced.extmark,
                                    {details = true})
    local repStart = {repExtmark[1], repExtmark[2]}
    local repEnd   = {repExtmark[3]["end_row"], repExtmark[3]["end_col"]}

    local region = vim.region(curBufNr, repStart, repEnd, reg.type, true)
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
    util.restoreReg()
    fn.setreg(reg.name, reg.content, reg.type)

    -- Options restoration
    if vim.is_callable(restoreOption) then restoreOption(); restoreOption = nil end

    -- Cursor restoration
    if vimMode == "n" then
        if util.withinRegion(M.cursorPos, pos.startPos, pos.endPos) then
            -- In cases the text length of new text content is shorter
            -- than the one of origin text
            if M.cursorPos[2] > repEnd[2] then
                api.nvim_win_set_cursor(0, {repStart[1] + 1, repEnd[2]})
            else
                api.nvim_win_set_cursor(0, {repStart[1] + 1, M.cursorPos[2]})
            end
        else
        end
    else
        local firstNewLine = api.nvim_get_current_line()
        local newCol = #firstNewLine == 0 and 1 or #firstNewLine
        -- In cases the text length of new text content is shorter
        -- than the one of origin text
        if M.cursorPos[2] + 1 >= newCol then
            api.nvim_win_set_cursor(0, {repStart[1] + 1, newCol - 1})
        else
            api.nvim_win_set_cursor(0, {repStart[1] + 1, M.cursorPos[2]})
        end
        -- If the preserved cursor position is at the white space position of
        -- the new content line, move one word foreward
        -- TODO: check situation that executing a "w" command might get cursor
        -- into next line
        -- if string.match(newPosthen, "%s") then
            -- cmd "noa norm! w"
        -- end
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
    elseif M.regType == "=" then
        fn["repeat#set"](t"<Plug>ReplaceExpr")
    end
    -- Visual repeating
    fn["visualrepeat#set"](t"<Plug>ReplaceVisual")

    -- }}} visualrepeat visualrepeat1
end -- }}}


function M.expr() -- {{{
    -- TODO: Detect virutal edit
    if not warnRead() then return "" end

    M.replaceSave()

    Opfunc = M.operator
    vim.o.opfunc = "LuaExprCallback"
    require("operator")

    -- Preserving cursor position as its position will changed once the
    -- vim.o.opfunc() being called
    M.cursorPos = api.nvim_win_get_cursor(0)

    -- Evaluate the expression register outside of a function. Because
    -- unscoped variables do not refer to the global scope. Therefore,
    -- evaluation happened earlier in the mappings.
    return M.regType == "=" and [[:let g:ReplaceExpr = getreg("=")<CR>g@]] or "g@"
end -- }}}


return M

