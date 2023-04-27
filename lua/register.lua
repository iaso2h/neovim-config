-- File: trailingChar
-- Author: iaso2h
-- Description: Add character at the end of line
-- Version: 0.0.5
-- Last Modified: 2023-3-16
local fn  = vim.fn
local api = vim.api
local M = {
    writable = [=[[-a-zA-Z0-9"*+_/]]=],
         all = [=[[-a-zA-Z0-9":.%#=*+~/]]=]
}

--- Clear register
M.clear = function() -- {{{
    local regexWritable = vim.regex(M.writable)
    local char
    for i=34, 122 do
        char = string.char(i)
        if regexWritable:match_str(char) then
            fn.setreg(char, "")
        end
    end
    vim.api.nvim_echo({{"Register cleared", "MoreMsg"}}, true, {})
end -- }}}


--- Prompt for inserting register
M.insertPrompt = function(vimMode) -- {{{
    local regexAll = vim.regex(M.all)
    local reg
    vim.cmd [[noa reg]]
    vim.cmd [[noa echohl Moremsg]]
    repeat
        local ok, msg = pcall(fn.input, "Register: ")
        if not ok then
            if string.find(msg, "Keyboard interrupt") then
                return
            else
                return vim.notify(msg, vim.log.levels.ERROR)
            end
        else
            reg = msg
        end

        -- Allow quick cancel by pressing return key only
        if reg == "" then return end

        -- Allow more specific put command in normal mode
        if vimMode == "n" and #reg == 2 then
            local exCMD = reg:sub(2, 2)
            if exCMD:lower() == "p" and regexAll:match_str(reg:sub(1, 1)) then
                -- Use remap keybinding
                return api.nvim_feedkeys('"' .. reg, "m", false)
            end
        end
    until (#reg == 1 and regexAll:match_str(reg)) or vim.notify("    Invalid register name", vim.log.levels.WARN)
    vim.cmd [[noa echohl None]]

    -- local regContent = reg == "=" and fn.getreg(reg, 1) or fn.getreg(reg, 0)
    local regType    = fn.getregtype(reg)
    local regContent = fn.getreg(reg, 0)


    if regType == "" then
        return
    elseif regType == "V" or regType == "line" then
        local lines = vim.split(regContent:sub(1, -2), "\n")
        api.nvim_put(lines, "l", true, false)
    else
        api.nvim_put({regContent}, "c", true, false)
    end
end -- }}}




local stringCount = function(str, pattern)
    local count = 0
    local init = 0
    while true do
        init = string.find(str, pattern, init + 1)
        if not init then return count end
        count = count + 1
    end
end


--- Reindent the register content
--- @param indentOffset integer Can be negative integer. How many indents
--- the source register content going to be prefixed or trimmed
--- @param srcContent string The content return by vim.fn.getreg()
--- @return string Reindented register content
M.reindent = function(indentOffset, srcContent) -- {{{
    if indentOffset == 0 then return srcContent end

    local newContent
    local srcLineCnt = stringCount(srcContent, "\n")
    if vim.endswith(srcContent, "\n") then srcLineCnt = srcLineCnt - 1 end
    local indentCntAbs = string.rep(" ", math.abs(indentOffset))

    if indentOffset < 0 then
        newContent = string.gsub(srcContent, "^" .. indentCntAbs, "")
        if srcLineCnt > 0 then
            newContent = string.gsub(newContent, "\n" .. indentCntAbs, "\n")
        end
    elseif indentOffset > 0 then
        newContent = indentCntAbs .. srcContent
        if srcLineCnt > 0 then
            newContent = string.gsub(newContent, "\n", "\n" .. indentCntAbs)
            -- Minus the extra spaces in the end of regConetent. e.g ".....\n    "
            newContent = string.gsub(newContent, "\n%s*$", "")
        end
    end

    return newContent
end -- }}}


--- Get the correct indent count of a register content by its leading space
--- number. It also converts leading tabs into corresponding spaces and takes
--- that into account
--- @param regContent string Value return by vim.fn.getreg()
--- @return integer Value of the corresponding leading spaces of a register
M.getIndent = function(regContent) -- {{{
    local _, regIndent = string.find(regContent, "^%s*")
    local _, prefixLineBreak = string.find(regContent, "^\n*")

    -- Minus the leading line breaks
    if prefixLineBreak then regIndent = regIndent - prefixLineBreak end

    -- Convert tab to spaces, then update reindent count
    local tabIdx = 0
    local tabCnt = 0
    repeat
        tabIdx = tabIdx + 1
        tabIdx = string.find(regContent, "\t", tabIdx)
        if tabIdx then tabCnt = tabCnt + 1 end
    until not tabIdx or tabIdx > regIndent

    if tabIdx then regIndent = regIndent + tabCnt * api.nvim_buf_get_option(0, "tabstop") end

    return regIndent
end -- }}}


--- Save the star registers, plus and unnamed registers - independently,
--- restoreReg can be accessed after saveReg is called
function M.saveReg() -- {{{
    local unnamedContent = vim.fn.getreg('"', 1)
    local unnamedType    = vim.fn.getregtype('"')
    local starContent    = vim.fn.getreg('*', 1)
    local starType       = vim.fn.getregtype('*')
    local plusContent    = vim.fn.getreg('+', 1)
    local plusType       = vim.fn.getregtype('+')
    local nonDefaultName = vim.v.register
    local nonDefaultContent
    local nonDefaultType
    if not vim.tbl_contains({'"', "*", "+"}, nonDefaultName) then
        nonDefaultContent = vim.fn.getreg(nonDefaultName, 1)
        nonDefaultType    = vim.fn.getregtype(nonDefaultName)
    end
    M.restoreReg = function()
        if nonDefaultContent and nonDefaultContent ~= "" then
            vim.fn.setreg(nonDefaultName, nonDefaultContent, nonDefaultType)
        end

        if starContent ~= "" then
            vim.fn.setreg('*', starContent,    starType)
        end
        if plusContent ~= "" then
            vim.fn.setreg('+', plusContent,    plusType)
        end
        if unnamedContent ~= "" then
            vim.fn.setreg('"', unnamedContent, unnamedType)
        end

        vim.defer_fn(function() M.restoreReg = nil end, 1000)
    end
end -- }}}


--- Copy indent of specific line number in current buffer
---@param lineNr number (1, 0) indexed
---@return string Corresponding line indent
M.indentCopy = function(lineNr)
    return string.rep(" ", vim.fn.indent(lineNr))
end


return M

