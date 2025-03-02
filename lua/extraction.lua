-- File: extraction
-- Author: iaso2h
-- Description: Extract selected content into new variable or new file
-- Version: 0.0.12
-- Last Modified: 2025-03-02
-- TODO: Deprecated: Please use refactor.nvim instead for visual line mode
local op       = require("operator")
local util     = require("util")
local register = require("register")
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
---@param lang string Value of code language
---@param lhs  string Value of LHS
---@return string value of prefix
local getPrefix = function(lang, lhs) -- {{{
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
end -- }}}
--- Join string table based on language
---@param rhs string RHS of language expression
---@return string
local joinRHS = function(rhs) -- {{{
    local lines = vim.split(rhs, "\n", {plain = true})
    lines = util.trimSpaces(lines, false, true)
    -- TODO remove line suffix like ";" in c, cpp language when concatenate the line
    return table.concat(lines, " ")
end -- }}}
--- Get the source content from visual selection
---@return table # For "v" mode, return string value of source content value, and the namespace together with the extmark to track the position information; For "V" mode return string value of source content value for "V" mode only.
local getSrcContent = function() -- {{{
    local posStart
    local posEnd

    if M.vimMode == "n" then
        local motionRegion = op.getMotionRegion(M.vimMode)
        posStart = motionRegion.Start
        posEnd   = motionRegion.End
        posStart = vim.api.nvim_buf_get_mark(0, "[")
        posEnd   = vim.api.nvim_buf_get_mark(0, "]")
    elseif M.vimMode:lower() == "v" then
        posStart = vim.api.nvim_buf_get_mark(0, "<")
        posEnd   = vim.api.nvim_buf_get_mark(0, ">")

        -- Abort when selection is invalid
        if posStart[1] == posEnd[1] and posStart[2] == posEnd[2] then
            vim.notify("Too small selection", vim.log.levels.ERROR)
            return {}
        end
    end

    -- Save register
    register.saveReg()

    -- Cut content into register and retrieve it as RHS content
    local linebreakChk = false
    local srcContent
    if M.vimMode == "v" or M.vimMode == "n" then
        -- Avoid delete "\n" line break character in the end of line
        local endLineLen = #vim.api.nvim_buf_get_lines(0, posEnd[1] - 1, posEnd[1], false)[1]
        if M.vimMode == "v" then
            if posEnd[2] == endLineLen then
                linebreakChk = true
                posEnd = {posEnd[1], posEnd[2] - 1}
            end
        else
            if posEnd[2] == endLineLen - 1 then
                linebreakChk = true
            end
        end

        -- Create extmark to track position of new content
        local namespace = vim.api.nvim_create_namespace("extractToVar")
        -- (0, 0) indexed
        local extmark   = vim.api.nvim_buf_set_extmark(0, namespace,
                                    posStart[1] - 1,           posStart[2],
                                    {end_line = posEnd[1] - 1, end_col = posEnd[2]})

        -- Cut source content into register
        vim.api.nvim_win_set_cursor(0, posStart)
        vim.cmd "noa normal! v"
        vim.api.nvim_win_set_cursor(0, posEnd)
        vim.cmd "noa normal! d"
        srcContent = vim.fn.getreg("\"", 1)

        -- Join source content for multiple line visual characterwise selection
        srcContent = joinRHS(srcContent)

        return {srcContent, namespace, extmark, linebreakChk}
    else
        -- Visual line mode
        vim.cmd [[noa normal! gvd]]
        srcContent = vim.fn.getreg("\"", 1)

        register.restoreReg()
        return {srcContent}
    end
end -- }}}
--- Create new variable
---@param lhs          string Value of the LHS
---@param rhs          string Value of the RHS
---@param namespace    integer Value of the namespace handler
---@param extmark      integer Value of the extmark ID
---@param linebreakChk boolean
local newVar = function(lhs, rhs, namespace, extmark, linebreakChk) -- {{{
    local lang = vim.bo.filetype
    local prefix = getPrefix(lang, lhs)
    local suffix = langSuffix[lang] or ""
    suffix = suffix and suffix or ""
    local assignOperator = langAssignOperator[lang]
    assignOperator = assignOperator and assignOperator or " = "
    -- Retrieve RHS source location
    -- (0, 0) indexed
    local rhsExtmark = vim.api.nvim_buf_get_extmark_by_id(0, namespace, extmark, {details = true})
    local rhsStart = {rhsExtmark[1], rhsExtmark[2]}
    local rhsEnd   = {rhsExtmark[3]["end_row"], rhsExtmark[3]["end_col"]}

    -- Put new content {{{

    local indentWidth = vim.fn.indent(rhsStart[1] + 1)
    local newLine = string.format("%s%s%s%s%s%s",
        string.rep(" ", indentWidth),
        prefix, lhs, assignOperator, rhs, suffix)
    vim.api.nvim_put({newLine}, "l", false, false)

    -- Set location in jump list
    vim.cmd [[noa norm! m`]]

    -- Put lhs value
    vim.api.nvim_win_set_cursor(0, {rhsEnd[1] + 2, rhsEnd[2]})
    if not linebreakChk then
        vim.api.nvim_put({lhs}, "c", false, false)
    else
        vim.api.nvim_put({lhs}, "c", true, false)
    end

    -- Place cursor at the declaration of new var
    local newLineStart = {rhsStart[1] + 1, indentWidth + #prefix}
    vim.api.nvim_win_set_cursor(0, newLineStart)
    -- }}} Put new content
end -- }}}
--- Create new file at given path
---@param filePath string value contain new file path
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
        vim.fn.mkdir(folderPath, "p")
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
    register.saveReg()
    vim.cmd [[noa normal! gvd]]
    register.restoreReg()
    local openFileAnswer = vim.fn.confirm("Load the new file into buffer?", "&Yes\n&No", 1)
    if openFileAnswer == 1 then vim.cmd("e " .. filePath) end
end -- }}}
--- Get the new identifier for statements block of file
---@param newId integer The new window ID
M.newIdentifier = function(newId) -- {{{
    -- Get source content
    local src, namespace, extmark, linebreakChk = unpack(getSrcContent())
    if not src then return end -- Sanity check

    -- Create new variable or new file
    if M.vimMode == "v" or M.vimMode == "n" then
        return newVar(newId, src, namespace, extmark, linebreakChk)
    elseif M.vimMode == "V" then
        return M.newFile(newId)
    end
end -- }}}
--- Operator to extract for creating either a new variable or a new file
---@param opInfo GenericOperatorInfo
function M.operator(opInfo) -- {{{
    M.vimMode = opInfo.vimMode
    M.argPath = opInfo.path
    if not vim.o.modifiable or vim.o.readonly then
        reset()
        return vim.notify("E21: Cannot make changes, 'modifiable' is off", vim.log.levels.ERROR)
    end
    if M.vimMode == "\22" then
        reset()
        return vim.notify("Visual block mode is not supported", vim.log.levels.WARN)
    end

    -- opts = opts or {hlGroup="Search", timeout=500}
    M.cwd  = vim.fn.getcwd()

    -- Get new identifier for new LHS or new file {{{
    if M.vimMode == "v" or M.vimMode == "n" then
        vim.ui.input({prompt = "Variable name: "}, function(input)
            if input and input ~= "" then
                require("extraction").newIdentifier(input)
            end
        end)
    elseif M.vimMode == "V" then
        if M.argPath == "" then
            vim.ui.input({
                prompt = "Enter new file path: ",
                default = vim.fn.getcwd(),
            }, function(input)
                if input and input ~= "" then
                    require("extraction").newFile(input)
                end
            end)
        else
            M.newFile(M.argPath)
        end
    else
        return vim.notify("Not support in current mode", vim.log.levels.WARN)
    end

    reset()
    -- }}} Get new identifier for new LHS or new file
end -- }}}


return M

