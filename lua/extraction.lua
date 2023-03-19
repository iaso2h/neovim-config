-- File: extraction
-- Author: iaso2h
-- Description: Extract selected content into new variable or new file
-- Version: 0.0.8
-- Last Modified: 2023-3-4
-- NOTE: Deprecated: Please use refactor.nvim instead for visual line mode
require("operator")
local fn   = vim.fn
local api  = vim.api
local util = require("util")
local M = {}
local reset = function ()
    M.data = {
        cwd        = nil,
        vimMode    = nil,
        motionMode = nil
    }
end

reset()


local langAssignOperator = {
    go = " := "
}
local langSuffix = {
    c          = ";",
    cpp        = ";",
    java       = ";",
    javascript = ";",
}


--- Return different prefix of variable assignment based on language type
--- @param lang string Value of code language
--- @param lhs  string Value of LHS
--- @return string value of prefix
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


--- Join string table based on language
--- @param rhs string RHS of language expression
--- @return string
local joinRHS = function(rhs)
    local lines = vim.split(rhs, "\n", true)
    lines = util.trimSpaces(lines, false, true)
    -- TODO remove line suffix like ";" in c, cpp language when concatenate the line
    return table.concat(lines, " ")
end


--- Get the source content from visual selection
--- @return table For "v" mode, return string value of source content value, and the
--- namespace together with the extmark to track the position information; For
--- "V" mode return string value of source content value for "V" mode only.
local getSrcContent = function() -- {{{
    local startPos
    local endPos

    if M.vimMode == "n" then
        startPos = api.nvim_buf_get_mark(0, "[")
        endPos   = api.nvim_buf_get_mark(0, "]")

    elseif M.vimMode:lower() == "v" then
        startPos = api.nvim_buf_get_mark(0, "<")
        endPos   = api.nvim_buf_get_mark(0, ">")

        -- Abort when selection is invalid
        if startPos[1] == endPos[1] and startPos[2] == endPos[2] then
            vim.notify("Too small selection", vim.log.levels.ERROR)
            return {}
        end
    end

    -- Save register
    util.saveReg()

    -- Cut content into register and retrieve it as RHS content
    local linebreakChk = false
    local srcContent
    if M.vimMode == "v" or M.vimMode == "n" then
        -- Avoid delete "\n" line break character in the end of line
        local endLineLen = #api.nvim_buf_get_lines(0, endPos[1] - 1, endPos[1], false)[1]
        if M.vimMode == "v" then
            if endPos[2] == endLineLen then
                linebreakChk = true
                endPos = {endPos[1], endPos[2] - 1}
            end
        else
            if endPos[2] == endLineLen - 1 then
                linebreakChk = true
            end
        end

        -- Create extmark to track position of new content
        local namespace = api.nvim_create_namespace("extractToVar")
        -- (0, 0) indexed
        local extmark   = api.nvim_buf_set_extmark(0, namespace,
                                    startPos[1] - 1,           startPos[2],
                                    {end_line = endPos[1] - 1, end_col = endPos[2]})

        -- Cut source content into register
        api.nvim_win_set_cursor(0, startPos)
        vim.cmd "noa normal! v"
        api.nvim_win_set_cursor(0, endPos)
        vim.cmd "noa normal! d"
        srcContent = fn.getreg("\"", 1)

        -- Join source content for multiple line visual characterwise selection
        srcContent = joinRHS(srcContent)

        -- util.restoreReg()
        return {srcContent, namespace, extmark, linebreakChk}
    else
        -- Visual line mode

        vim.cmd [[noa normal! gvd]]
        srcContent = fn.getreg("\"", 1)

        util.restoreReg()
        return {srcContent}
    end
end -- }}}


--- Create new variable
--- @param lhs          string Value of the LHS
--- @param rhs          string Value of the RHS
--- @param namespace    number Value of the namespace handler
--- @param extmark      number Value of the extmark ID
--- @param linebreakChk boolean
local newVar = function(lhs, rhs, namespace, extmark, linebreakChk) -- {{{
    local lang = vim.bo.filetype
    local prefix = getPrefix(lang, lhs)
    local suffix = langSuffix[lang] or ""
    suffix = suffix and suffix or ""
    local assignOperator = langAssignOperator[lang]
    assignOperator = assignOperator and assignOperator or " = "
    -- Retrieve RHS source location
    -- (0, 0) indexed
    local rhsExtmark = api.nvim_buf_get_extmark_by_id(0, namespace, extmark, {details = true})
    local rhsStart = {rhsExtmark[1], rhsExtmark[2]}
    local rhsEnd   = {rhsExtmark[3]["end_row"], rhsExtmark[3]["end_col"]}

    -- Put new content {{{

    local indentWidth = fn.indent(rhsStart[1] + 1)
    local newLine = string.format("%s%s%s%s%s%s",
        string.rep(" ", indentWidth),
        prefix, lhs, assignOperator, rhs, suffix)
    api.nvim_put({newLine}, "l", false, false)

    -- Set location in jump list
    vim.cmd [[noa norm! m`]]

    -- Put lhs value
    api.nvim_win_set_cursor(0, {rhsEnd[1] + 2, rhsEnd[2]})
    if not linebreakChk then
        api.nvim_put({lhs}, "c", false, false)
    else
        api.nvim_put({lhs}, "c", true, false)
    end

    -- Place cursor at the declaration of new var
    local newLineStart = {rhsStart[1] + 1, indentWidth + #prefix}
    api.nvim_win_set_cursor(0, newLineStart)
    -- }}} Put new content
end -- }}}


--- Create new file at given path
--- @param filePath string value contain new file path
M.newFile = function(filePath) -- {{{
    -- Find index of last slash
    -- local newFilePath = [[C:/user/test\test123\test321.lua]]
    -- local newFilePath = [[C:/user/test/test123/test321.lua]]
    -- local newFilePath = [[C:\user/test\new.lua]]
    -- local newFilePath = [[C:\user\test/new.lua]]
    local lastFSlash = string.find(string.reverse(filePath), "/")
    local lastBSlash = string.find(string.reverse(filePath), "\\")
    local lastSlash

    if not lastFSlash and lastBSlash then
        lastSlash = #filePath - lastBSlash + 1
    elseif not lastBSlash and lastFSlash then
        lastSlash = #filePath - lastFSlash + 1
    elseif lastFSlash and lastBSlash then
        lastSlash = lastFSlash < lastBSlash and
            #filePath - lastFSlash + 1 or
            #filePath - lastBSlash + 1
    else
        -- Skip creating folder
    end

    -- Creating folder
    local folderPath
    if lastSlash then
        folderPath = string.sub(filePath, 1, lastSlash - 1)
        -- Make sure folder created before file creation, even if it exists
        fn.mkdir(folderPath, "p")
    end

    -- Writing file
    local f, err = io.open(filePath, "w")
    if not f then
        vim.notify("Unable to create file: " .. filePath, vim.log.levels.ERROR)
        vim.notify(err, vim.log.levels.ERROR)
        return
    end

    f:write(unpack(getSrcContent()))
    f:close()

    vim.notify("File created: " .. filePath, vim.log.levels.INFO)

    -- Delete selection code
    util.saveReg()
    vim.cmd [[noa normal! gvd]]
    util.restoreReg()
    local openFileAnswer = fn.confirm("Load the new file into buffer?", "&Yes\n&No", 1)
    if openFileAnswer == 1 then vim.cmd("e " .. filePath) end
end -- }}}


M.newIdentifier = function(newID)
    ---@diagnostic disable-next-line: deprecated
    local unpack = unpack and unpack or table.unpack
    -- Get source content
    local src, namespace, extmark, linebreakChk = unpack(getSrcContent())
    if not src then return end -- Sanity check

    -- Create new variable or new file
    if M.vimMode == "v" or M.vimMode == "n" then
        return newVar(newID, src, namespace, extmark, linebreakChk)
    elseif M.vimMode == "V" then
        return M.newFile(newID)
    end
end


--- Main function to start the extraction for creating either
--- new variable or new file
--- @param args table {motionType, vimMode, plugMap}
---        motionType string Motion type by which how the operator perform.
---                    Can be "line", "char" or "block"
---        vimMode    string Vim mode. See `help mode()`
---        plugMap    string eg <Plug>myPlug
---        vimMode     string Vim mode. See `help mode()`
function M.main(args) -- {{{
    M.vimMode    = args[2]
    M.motionType = args[1]
    if not vim.o.modifiable or vim.o.readonly then
        reset()
        return vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
    end
    if M.vimMode == "\22" then
        reset()
        return vim.notify("Visual block mode is not supported", vim.log.levels.WARN)
    end

    -- opts = opts or {hlGroup="Search", timeout=500}
    M.cwd  = fn.getcwd()

    -- Get new identifier for new LHS or new file {{{
    if M.vimMode == "v" or M.vimMode == "n" then
        vim.ui.input({prompt = "Variable name: "}, function(input)
            if input and input ~= "" then
                require("extraction").newIdentifier(input)
            end
        end)
    elseif M.vimMode == "V" then
        vim.ui.input({
            prompt = "Enter new file path: ",
            default = fn.getcwd(),
        }, function(input)
            if input and input ~= "" then
                require("extraction").newFile(input)
            end
        end)
    else
        return vim.notify("Not support in current mode", vim.log.levels.WARN)
    end

    reset()
    -- }}} Get new identifier for new LHS or new file
end -- }}}

return M

