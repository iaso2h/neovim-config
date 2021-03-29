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
    c          = ";",
    cpp        = ";",
    java       = ";",
    javascript = ";",
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
-- @return: For "v" mode, return string value of source content value, and the
-- namespace together with the extmark to track the position information; For
-- "V" mode return string value of source content value for "V" mode only.
----
local getSrcContent = function(lang, vimMode, curBufNr) -- {{{
    local pos1
    local pos2
    local srcContent

    if vimMode == "n" then
        pos1 = api.nvim_buf_get_mark(0, "[")
        pos2 = api.nvim_buf_get_mark(0, "]")
    elseif vimMode:lower() == "v" then
        pos1 = api.nvim_buf_get_mark(0, "<")
        pos2 = api.nvim_buf_get_mark(0, ">")
    end

    -- Create extmark to track position of new content
    local extra2VarNS      = api.nvim_create_namespace("extra2Var")
    local extra2VarExtmark = api.nvim_buf_set_extmark(curBufNr, extra2VarNS,
        pos1[1] - 1, pos1[2],
        {end_line = pos2[1] - 1, end_col = pos2[2]})

    -- Abort when selection is invalid
    if pos1[1] == pos2[1] and pos1[2] == pos2[2] then return false end

    -- Cut content into register and retrieve it as RHS content
    util.saveReg()
    cmd [[normal! gvd]]
    if vimMode == "v" then
        srcContent = fn.getreg("\"", 1)

        -- Join RHS content for multiple line selection in visual mode
        if vimMode == "v" and pos1[1] ~= pos2[2] then
            srcContent = joinRHS(lang, srcContent)
        end

        util.restoreReg()

        return srcContent, extra2VarNS, extra2VarExtmark
    elseif vimMode == "V" then
        return srcContent
    end
end -- }}}


----
-- Function: newVar :Create new variable
--
-- @param lang:             String value of coding language
-- @param curWinID:         Integer value of current window ID
-- @param curBufNr:         Integer value of current buffer number
-- @param lhs:              String value of the LHS
-- @param rhs:              String value of the RHS
-- @param extra2VarNS:      Integer value of the namespace handler
-- @param extra2VarExtmark: Integer value of the extmark ID
----
local newVar = function(lang, curWinID, curBufNr, lhs, rhs, extra2VarNS, extra2VarExtmark) -- {{{
    local prefix
    local suffix = langSuffix[lang] or ""
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
    api.nvim_put({lhs}, "c", false, false)
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
-- @param newFilePath: string value contain new file path
-- @param srcContent:  source content of the new file
----
local newFile = function(newFilePath, srcContent) -- {{{
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
-- @param operType: String value of operator type generated when g@ is called
-- @param vimMode:  Vim mode
-- @param ...:
-- @return: 0
----
function M.main(operType, vimMode, ...) -- {{{
    -- Dosn't support block mode
    if operType == "block" then return end

    -- opts = opts or {hlGroup="Search", timeout=500}
    local lang   = vim.bo.filetype
    local newID
    local srcContent
    local curWinID = api.nvim_get_current_win()
    local curBufNr = api.nvim_get_current_buf()
    local extra2VarNS
    local extra2VarExtmark

    -- Get new identifier for new LHS or new file {{{
    if vimMode == "v" then
        cmd [[echohl Moremsg]]
        newID = fn.input("Variable Name: ")
        cmd [[echohl None]]
        if newID == "" then return end -- Sanity check
    elseif vimMode == "V" then
        -- Check CWD {{{
        if fn.has('win32') == 1 then
            -- Check file cwd"
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
    srcContent, extra2VarNS, extra2VarExtmark = getSrcContent(lang, vimMode, curBufNr)
    if not srcContent then return end -- Sanity check
    -- }}} Get source content

    -- Create new variable or new file {{{
    if vimMode == "v" then
        return newVar(lang, curWinID, curBufNr, newID, srcContent, extra2VarNS, extra2VarExtmark)
    elseif vimMode == "V" then
        return newFile(newID, srcContent)
    end
    -- }}} Create new variable or new file
end -- }}}

return M

