-- File: extraction
-- Author: iaso2h
-- Description: Extract selected content into new variable or new file
-- Version: 0.0.5
-- Last Modified: 2021-04-05
-- TODO: change the other var in the same scope
-- BUG: Visual character mode will remove one extra space
local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}
local util = require("util")
local langAmid = {
    go = " := "
}
local langSuffix = {
    c          = {";", "\\"},
    cpp        = {";", "\\"},
    java       = {";"},
    javascript = {";"},
}

----
-- Function: getPrefix : return different prefix of variable assignment based on language type
--
-- @param lang: string value of code language
-- @param lhs:  string value of LHS
-- @return: string value of prefix
----
local getPrefix = function(lang, lhs)
    if lang == "vim" then
        return "let "
    elseif lang == "lua" then
        if string.sub(lhs, 1, 1) == string.sub(lhs, 1, 1):lower() then
            return "local "
        else
            return ""
        end
    else
        return ""
    end
end


----
-- Function: joinRHS join string table based on language
--
-- @param lang: Coding language
-- @param rhs:  String value contain RHS content
-- @return:     Concatenated string
----
local joinRHS = function(lang, rhs)
    local lines = vim.split(rhs, "\n", true)
    lines = util.trimWhiteSpaces(lines, false, true)
    -- TODO remove line suffix like ";" in c, cpp language when concatenate the line
    return table.concat(lines, " ")
end


----
-- Function: getSrcContent :Get the source content from visual selection
--
-- @param lang:     String value of coding language.
-- @param vimMode:  String value of Vim mode.
-- @param curBufNr: Integer number of current buffer.
-- @param curBufNr: Integer number of window ID.
-- @return: For "v" mode, return string value of source content value, and the
-- namespace together with the extmark to track the position information; For
-- "V" mode return string value of source content value for "V" mode only.
----
local getSrcContent = function(lang, vimMode, curBufNr, curWinID) -- {{{
    local pos1
    local pos2
    local srcContent
    local linebreakSelectCheck = false

    if vimMode == "n" then
        pos1 = api.nvim_buf_get_mark(curBufNr, "[")
        pos2 = api.nvim_buf_get_mark(curBufNr, "]")
        api.nvim_win_set_cursor(curWinID, pos1)
        cmd("normal! v")
        api.nvim_win_set_cursor(curWinID, pos2)
        cmd("normal! v")
    elseif vimMode:lower() == "v" then
        pos1 = api.nvim_buf_get_mark(curBufNr, "<")
        pos2 = api.nvim_buf_get_mark(curBufNr, ">")
        -- Abort when selection is invalid
        if pos1[1] == pos2[1] and pos1[2] == pos2[2] then return false end
    end

    -- Cut content into register and retrieve it as RHS content
    util.saveReg()
    if vimMode == "v" or vimMode == "n" then
        -- Avoid delete "\n" line break character in the end of line
        local pos2LineLen = #api.nvim_buf_get_lines(curBufNr, pos2[1] - 1, pos2[1], false)[1]
        if vimMode == "v" then
            if pos2[2] == pos2LineLen then
                linebreakSelectCheck = true
                pos2 = {pos2[1], pos2[2] - 1}
            end
        else
            if pos2[2] == pos2LineLen - 1 then
                linebreakSelectCheck = true
            end
        end

        -- Create extmark to track position of new content
        local extra2VarNS      = api.nvim_create_namespace("extra2Var")
        local extra2VarExtmark = api.nvim_buf_set_extmark(curBufNr, extra2VarNS,
                                    pos1[1] - 1, pos1[2],
                                    {end_line = pos2[1] - 1, end_col = pos2[2]})

        -- Cut source content into register
        api.nvim_win_set_cursor(curWinID, pos1)
        cmd "normal! v"
        api.nvim_win_set_cursor(curWinID, pos2)
        cmd "normal! d"
        srcContent = fn.getreg("\"", 1)

        -- Join source content for multiple line visual characterwise selection
        srcContent = joinRHS(lang, srcContent)

        -- util.restoreReg()
        return srcContent, extra2VarNS, extra2VarExtmark, linebreakSelectCheck
    elseif vimMode == "V" then
        cmd [[normal! gvd]]
        srcContent = fn.getreg("\"", 1)

        util.restoreReg()
        return srcContent
    end
end -- }}}


----
-- Function: newVar :Create new variable
--
-- @param lang:                 String value of coding language
-- @param curWinID:             Integer value of current window ID
-- @param curBufNr:             Integer value of current buffer number
-- @param lhs:                  String value of the LHS
-- @param rhs:                  String value of the RHS
-- @param extra2VarNS:          Integer value of the namespace handler
-- @param extra2VarExtmark:     Integer value of the extmark ID
-- @param linebreakSelectCheck: Boolean
----
local newVar = function(lang, curWinID, curBufNr, lhs, rhs, extra2VarNS, extra2VarExtmark, linebreakSelectCheck) -- {{{
    local prefix
    local suffix = langSuffix[lang] or ""
    suffix = suffix ~= "" and langSuffix[1] or ""
    local amid   = langAmid[lang]   or " = "
    -- Retrieve RHS source location
    local rhsSrcResExtmark = api.nvim_buf_get_extmark_by_id(curBufNr,
                                                            extra2VarNS,
                                                            extra2VarExtmark,
                                                            {details = true})
    local rhsSrcResStart = {rhsSrcResExtmark[1], rhsSrcResExtmark[2]}
    local rhsSrcResEnd   = {rhsSrcResExtmark[3]["end_row"], rhsSrcResExtmark[3]["end_col"]}

    -- Put new content {{{
    local indentWidth = fn.indent(rhsSrcResStart[1] + 1)
    prefix = getPrefix(lang, lhs)
    local newLine = string.format("%s%s%s%s%s%s", string.rep(" ", indentWidth),
        prefix, lhs, amid, rhs, suffix)
    api.nvim_put({newLine}, "l", false, false)
    api.nvim_win_set_cursor(curWinID, {rhsSrcResEnd[1] + 2, rhsSrcResEnd[2]})
    -- Create record in jumplist
    cmd [[normal! mz`z]]

    -- Put lhs value after when linebreak character is selected
    if not linebreakSelectCheck then
        api.nvim_put({lhs}, "c", false, false)
    else
        api.nvim_put({lhs}, "c", true, false)
    end
    local lhsNewStart = {rhsSrcResStart[1] + 1, indentWidth + #prefix}
    api.nvim_win_set_cursor(curWinID, lhsNewStart)
    -- }}} Put new content

    -- Create highlight {{{
    -- api.nvim_buf_clear_namespace(curBufNr, extra2VarNS, 0, -1)
    -- api.nvim_buf_add_highlight(curBufNr, extra2VarNS, opts["hlGroup"], lhsNewStart[1] - 1, lhsNewStart[2], lhsNewStart[2] + #lhs)
    -- vim.defer_fn(function()
    -- api.nvim_buf_clear_namespace(curBufNr, extra2VarNS, 0, -1)
    -- end, opts["timeout"])
    -- }}} Create highlight
end -- }}}


----
-- Function: newFile :Create new file at given path
--
-- @param newFilePath: String value contain new file path
-- @param srcContent:  String value of source content of the new file
-- @param CWD:         String value of current working directory
----
local newFile = function(newFilePath, srcContent, CWD) -- {{{
    -- Find slash
    local byteSlashIndex = util.matchAll(newFilePath, "/")
    local filePath

    if not next(byteSlashIndex) then byteSlashIndex = util.matchAll(newFilePath, "\\") end

    if next(byteSlashIndex) then -- Slash exist
        if byteSlashIndex == #newFilePath - 1 then
            api.nvim_echo({{"Invalid file path", "WarningMsg"}}, false, {})
            return
        end
        -- Refine file path
        if newFilePath[1] == "/" or newFilePath[1] == '\\' then
            filePath = CWD .. newFilePath
        elseif string.sub(newFilePath, 1, 2) == './' then
            filePath = CWD .. string.sub(newFilePath, 2)
        else
            filePath = CWD .. "/" .. newFilePath
        end
        -- Make sure folder created before file creation
        local absFolder = string.sub(filePath, 1, byteSlashIndex[#byteSlashIndex] + #CWD + 1)
        fn.mkdir(absFolder, "p")
    else -- Slash does not exist
        filePath = newFilePath
    end

    local f = io.open(filePath, "w")
    if not f then
        api.nvim_echo({{"Unable to create file: " .. filePath, "ErrorMsg"}}, false, {})
        return
    end
    f:write(srcContent)
    f:close()
    api.nvim_echo({{"File created: " .. filePath, "false"}}, true, {})
    -- Delete selection code
    util.saveReg()
    cmd [[normal! gvd]]
    util.restoreReg()
    local openFileAnswer = fn.confirm("Open and edit new file?", "&Yes\n&No", 1)
    if openFileAnswer == 1 then cmd("e " .. filePath) end
end -- }}}


----
-- Function: M.main :Main function to start the extraction for creating either
-- new variable or new file
--
-- @param argTbl: argTbl[1] is the string value of motionwise, which is return
-- when g@ is called
-- @return: 0
----
function M.main(argTbl) -- {{{
    local motionwise = argTbl[1]
    -- Visual block mode is not supported
    if motionwise == "block" then return end

    -- opts = opts or {hlGroup="Search", timeout=500}
    local vimMode  = argTbl[2] or "n"
    local lang     = vim.bo.filetype
    local CWD      = fn.getcwd()
    local curWinID = api.nvim_get_current_win()
    local curBufNr = api.nvim_get_current_buf()
    local newID
    local srcContent
    local extra2VarNS
    local extra2VarExtmark
    local linebreakSelectCheck

    -- Get new identifier for new LHS or new file {{{
    if vimMode == "v" or vimMode == "n" then
        cmd [[echohl Moremsg]]
        newID = fn.input("Variable Name: ")
        cmd [[echohl None]]
        if newID == "" then return end -- Sanity check
    elseif vimMode == "V" then
        -- Check CWD {{{
        if fn.has('win32') == 1 then
            -- Check file cwd
            local newCWD = fn.expand("%:p:h")
            if CWD ~= newCWD then
                local answerCD = fn.confirm("Change CWD to \"" .. newCWD .. "\"?", "&Yes\n&No")
                if answerCD == 1 then
                    cmd("cd " .. newCWD)
                    CWD = newCWD
                elseif answerCD == 0 then
                    return
                end
            end
        end
        api.nvim_echo({{"CWD: " .. CWD, "Moremsg"}}, false, {})
        -- }}} Check CWD
        newID = fn.input("Enter new file path: ")
        -- Check valid input
        if newID == "" then return end
    end
    -- }}} Get new identifier for new LHS or new file

    -- Get source content {{{
    srcContent, extra2VarNS, extra2VarExtmark, linebreakSelectCheck = getSrcContent(lang, vimMode, curBufNr, curWinID)
    if not srcContent then return end -- Sanity check
    -- }}} Get source content

    -- Create new variable or new file {{{
    if vimMode == "v" or vimMode == "n" then
        return newVar(lang, curWinID, curBufNr, newID, srcContent, extra2VarNS, extra2VarExtmark, linebreakSelectCheck)
    elseif vimMode == "V" then
        return newFile(newID, srcContent, CWD)
    end
    -- }}} Create new variable or new file
end -- }}}

return M

