local operator = require "operator"
-- ReplaceWithRegister.vim: Replace text with the contents of a register.
--
-- DEPENDENCIE
--   - ingo-library.vim plugin (optional)
--   - repeat.vim (vimscript #2136) plugin (optional)
--   - visualrepeat.vim (vimscript #3848) plugin (optional)
--
-- Copyrighvim.t. (C) 2011-2020 Ingo Karkat
--   The VIM LICENSE applies to this script; see ':help copyright'.
--
-- Maintainer:	Ingo Karkat <ingo@karkat.de>
local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local preFunc
local posFunc
local cursorPos
local M   = {}

-- Note: Could use ingo#pos#IsOnOrAfter(), but avoid dependency to ingo-library
-- for now.
local function correctRegtype(motionwise, register, regType ,replacement)
    if motionwise == "block" then
        -- Adaptations for blockwise replace.
        local pasteTextTbl = vim.split(replacement["text"], "\n", false)
        local pasteLineNr  = #pasteTextTbl
        if regType == 'v' or (regType == 'V' and pasteLineNr == 1) then
            -- If the register contains just a single line, temporarily duplicate
            -- the line to match the height of the blockwise selection.
            local height = replacement["startPos"][1] - replacement["endPos"][1] + 1
            if height > 1 then
                local convertReg = vim.split(replacement["text"], "\n", false)
                for _=1, height - 1 do
                    local copyReg = convertReg
                    convertReg = vim.list_extend(convertReg, copyReg)
                end
                fn.retreg(register, table.concat(convertReg, "\n"))
                return 1
            end
        elseif regType == 'V' and pasteLineNr > 1 then
            -- If the register contains multiple lines, paste as blockwise. then
            fn.retreg(register, '', [[a\<C-v>]])
            return 1
        end
    elseif regType == 'V' and string.match(replacement["text"], "\n$") then
        -- Our custom operator is characterwise, even in the
        -- ReplaceWithRegisterLine variant, in order to be able to replace less
        -- than entire lines (i.e. characterwise yanks).
        -- So there's a mismatch when the replacement text is a linewise yank,
        -- and the replacement would put an additional newline to the end.
        -- To fix that, we temporarily remove the trailing newline character from
        -- the register contents and set the register type to characterwise yank.
        fn.setreg(register, replacement["text"]:sub(1, #replacement["text"] - 1), 'v')
        return 1
    end

    return 0
end

local function replace(motionwise, register, replacement, curBufNr)
    -- With a put in visual mode, the selected text will be replaced with the
    -- contents of the register. This works better than first deleting the
    -- selection into the black-hole register and then doing the insert; as
    -- "d" + "i/a" has issues at the end-of-the line (especially with blockwise
    -- selections, where "v_o" can put the cursor at either end), and the "c"
    -- commands has issues with multiple insertion on blockwise selection and
    -- autoindenting.
    -- With a put in visual mode, the previously selected text is put in the
    -- unnamed register, so we need to save and restore that.

    -- Note: Must not use ""p; this somehow replaces the selection with itself?!
    replacement["register"] = register == '"' and '' or '"' .. register

    -- if register == '=' then
        -- -- Cannot evaluate the expression register within a function; unscoped
        -- -- variables do not refer to the global scope. Therefore, evaluation
        -- -- happened earlier in the mappings.
        -- -- To get the expression result into the buffer, we use the unnamed
        -- -- register; this will be restored, anyway.
        -- fn.setreg('"', vim.g.ReplaceWithRegisterExpr)
        -- -- TODO
        -- correctForRegtype(motionwise, '"', fn.getregtype('"'), vim.g.ReplaceWithRegisterExpr)
        -- -- Must not clean up the global temp variable to allow command
        -- -- repetition.
        -- -- local pasteRegister = ''
    -- end

    local newContentStart
    local newContentEnd
    if motionwise == 'visual' then
        cmd("silent normal! gv" .. replacement["register"] .. "p")
        newContentStart  = api.nvim_buf_get_mark(0, "[")
        newContentEnd    = api.nvim_buf_get_mark(0, "]")
        -- Create extmark to track position of new content
        require("yankPut").inplacePutNewContentNS      = api.nvim_create_namespace("inplacePutNewContent")
        require("yankPut").inplacePutNewContentExtmark = api.nvim_buf_set_extmark(curBufNr,
                                                    require("yankPut").inplacePutNewContentNS,
                                                    newContentStart[1] - 1,
                                                    newContentStart[2],
                                                    {end_line = newContentEnd[1] - 1,
                                                        end_col = newContentEnd[2]})
        api.nvim_win_set_cursor(0, api.nvim_buf_get_mark(0, "["))
        cmd("normal! v")
        api.nvim_win_set_cursor(0, api.nvim_buf_get_mark(0, "]"))
        cmd("normal! =")
    else
        -- TODO
        -- replacement["mode"]     = fn.visualmode()

        api.nvim_win_set_cursor(0, replacement["startPos"])
        local visualCMD
        if motionwise == "line" then
            visualCMD = "V"
        else
            visualCMD = "v"
        end
        cmd("normal! " .. visualCMD)
        api.nvim_win_set_cursor(0, replacement["endPos"])
        cmd('normal!' .. replacement["register"] .. "p")
        newContentStart  = api.nvim_buf_get_mark(0, "[")
        newContentEnd    = api.nvim_buf_get_mark(0, "]")
        -- Create extmark to track position of new content
        require("yankPut").inplacePutNewContentNS      = api.nvim_create_namespace("inplacePutNewContent")
        require("yankPut").inplacePutNewContentExtmark = api.nvim_buf_set_extmark(curBufNr,
                                                    require("yankPut").inplacePutNewContentNS,
                                                    newContentStart[1] - 1,
                                                    newContentStart[2],
                                                    {end_line = newContentEnd[1] - 1,
                                                        end_col = newContentEnd[2]})

        -- TODO
        -- silent! call('ingo#selection#Set', l:save_visualarea)
    end

    -- Report change in Neovim statusbar
    local srcLineCount = replacement["endPos"][1] - replacement["startPos"][1] + 1
    local repLineCount = newContentEnd[1] - newContentStart[1] + 1
    if srcLineCount >= vim.o.report or repLineCount >= vim.o.report then
        local srcReport = string.format("Replaced %d line%s", srcLineCount, srcLineCount == 1 and "" or "s")
        local repReport = srcLineCount == repLineCount and '' or
            string.format(" with %d line%s", repLineCount, repLineCount == 1 and "" or "s")
        api.nvim_echo({{srcReport .. repReport, "MoreMsg"}}, false, {})
    end

end

function ReplaceOperator(argTbl)
    -- TODO
    local opts = {hlGroup = "Search", timeout = 500}
    local curBufNr      = api.nvim_get_current_buf()
    local motionwise      = argTbl[1]
    local register      = vim.v.register
    local regType       = fn.getregtype(register)
    local saveClipboard = vim.o.clipboard
    vim.o.clipboard     = "" -- Avoid clobbering the selection and clipboard registers.
    local replacement   = {}
    replacement["text"] = fn.getreg(register, 1) -- Expression evaluation inside function context may cause errors, therefore get unevaluated expression when register == '='.
    -- DEBUG:
    -- Print(argTbl)

    -- DEBUG:

    if motionwise == "visual" then
        cursorPos = api.nvim_win_get_cursor(0)
        replacement["startPos"]  = api.nvim_buf_get_mark(0, "<")
        replacement["endPos"]    = api.nvim_buf_get_mark(0, ">")
        -- Not sure this has any relationship with modifiable
        -- api.nvim_buf_set_lines(0, cursorPos[1] - 1, cursorPos[1], false, {api.nvim_get_current_line()})
    else
        -- Execute preceding functoin when modifiable is off
        if preFunc then
            preFunc()
            preFunc = nil
        end
        replacement["startPos"] = api.nvim_buf_get_mark(0, "[")
        replacement["endPos"]   = api.nvim_buf_get_mark(0, "]")
    end

    -- Save registers
    require("util").saveReg()

    local isCorrected = correctRegtype(motionwise, register, regType, replacement)

    replace(motionwise, register, replacement, curBufNr)

    -- Add hightlight
    -- Restoration
    vim.o.clipboard = saveClipboard
    if isCorrected then
        -- Undo the temporary change of the register.
        -- Note: This doesn't cause trouble for the read-only registers :, .,
        -- %, # and =, because their regtype is always 'v'.
        fn.setreg(register, replacement["text"], regType)
    else
        require("util").restoreReg()
    end

    -- Create highlight {{{
    local replaceHLNS = api.nvim_create_namespace("inplaceReplaceHL")
    api.nvim_buf_clear_namespace(curBufNr, replaceHLNS, 0, -1)

    local newContentResExtmark = api.nvim_buf_get_extmark_by_id(curBufNr,
                                    require("yankPut").inplacePutNewContentNS,
                                    require("yankPut").inplacePutNewContentExtmark,
                                    {details = true})
    local newContentResStart = {newContentResExtmark[1], newContentResExtmark[2]}
    local newContentResEnd   = {newContentResExtmark[3]["end_row"], newContentResExtmark[3]["end_col"]}

    local region = vim.region(curBufNr, newContentResStart, newContentResEnd,
    regType, vim.o.selection == "inclusive" and true or false)
    for lineNr, cols in pairs(region) do
        api.nvim_buf_add_highlight(curBufNr, replaceHLNS, opts["hlGroup"], lineNr, cols[1], cols[2])
    end

    vim.defer_fn(function()
        api.nvim_buf_clear_namespace(curBufNr, replaceHLNS, 0, -1)
    end, opts["timeout"])
    -- }}} Create highlight

    -- Restore cursor {{{
    -- Use extmark to track the new position of newContentStart after executing_
    -- formaprg in some cases
    -- Skip when it's called from repeat key
    if motionwise ~= "visual" then
        if cursorPos then
            if cursorPos[2] > newContentResEnd[2] then
                -- In cases where then size of the new text content is less than the
                -- size of the origin text content
                api.nvim_win_set_cursor(0, {cursorPos[1], newContentResStart[2]})
            else
                api.nvim_win_set_cursor(0, cursorPos)
            end

            cursorPos = nil
        else
            api.nvim_win_set_cursor(0, {newContentResStart[1] + 1, newContentResStart[2]})
        end
    else
        -- newContentStart directly
        -- TODO: Retrieve cursor at starting position

        -- Place cursor at non-blank position
        local newContentFirstLine = api.nvim_buf_get_lines(0, newContentResStart[1], newContentResStart[1] + 1, false)[1]
        api.nvim_win_set_cursor(0, {newContentResStart[1] + 1, newContentResStart[2]})
        if string.sub(newContentFirstLine, 1, 1) == " " then cmd "normal! w" end
    end
    -- }}} Restore cursor

    M.argTbl = argTbl
    -- if argTbl[1] == "visual" then
        -- cmd [[call repeat#set("\<plug>InplaceReplaceLine", v:count)]]
    -- end

    if #argTbl >= 2 then
        -- Store as Global value for call luaeval() in Vimscript
        M.argTbl = argTbl

        if argTbl[2] == "InplaceReplaceLine" then
            cmd [[call repeat#set("\<lt>plug>InplaceReplaceLine", v:count)]]
        elseif argTbl[2] == "InplaceReplaceVisual" then
            cmd [[call repeat#set("\<lt>plug>InplaceReplaceVisual")]]
            cmd [[call visualrepeat#set("\<lt>plug>InplaceReplaceVisual")]]
        end
    end
end

function M.expression()
    -- Note: Could use
    -- ingo#mapmaker#OpfuncExpression('ReplaceWithRegister#Operator'), but avoid
    -- dependency to ingo-library for now.
    Opfunc = ReplaceOperator
    vim.o.opfunc = "LuaExprCallback"

    if not vim.o.modifiable or vim.o.readonly then
        -- Probe for "Cannot make changes" error and readonly warning via a no-op
        -- dummy modification. then
        -- In the case of a nomodifiable buffer, Vim will abort the normal mode then
        -- command chain, discard the g@, and thus not invoke the operatorfunc.
        preFunc = function ()
            api.nvim_buf_set_lines(0, cursorPos[1] - 1, cursorPos[1], false, {api.nvim_get_current_line()})
        end
    end

    cursorPos = api.nvim_win_get_cursor(0)


    -- TODO
    -- if vim.v.register == '=' then
        -- -- Must evaluate the expression register outside of a function.
        -- keys = [[:let g:ReplaceWithRegisterExpr = getreg('=')\<CR>]] .. keys
    -- end

    return "g@"
end

function ReplaceVisualMode()
    vim.g.repeat_count = vim.g.repeat_count or ''
    local vimcmd = api.nvim_exec([[call visualrepeat#reapply#VisualMode(0)]], true)
    if vimcmd ~= "" then
        cmd([[normal!]] .. vimcmd)
    end
    ReplaceOperator({"visual", "InplaceReplaceVisual"})
end

return M

-- vim: set ts=4 sts=4 sw=4 expandtab

