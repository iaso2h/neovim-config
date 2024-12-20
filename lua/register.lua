-- File: trailingChar
-- Author: iaso2h
-- Description: Add character at the end of line
-- Version: 0.0.8
-- Last Modified: 2023-10-23
local M = {
    regAllWritable = [=[[-a-zA-Z0-9"_/]]=],
    regAll         = [=[[-a-zA-Z0-9":.%#=*+~/]]=]
}

-- TODO: Better register support detection
if _G._os_uname.machine ~= "aarch64" then
    M.regAllWritable = M.regAllWritable .. "+*"
end

--- Clear register
M.clear = function() -- {{{
    local regexWritable = vim.regex(M.regAllWritable)
    local char
    for i=34, 122 do
        char = string.char(i)
        if regexWritable:match_str(char) then
            vim.fn.setreg(char, "")
        end
    end
    vim.api.nvim_echo({{"Register cleared", "MoreMsg"}}, true, {})
end -- }}}
--- Prompt for inserting register
M.insertPrompt = function(vimMode) -- {{{
    local regexAll = vim.regex(M.regAll)
    local regName
    local regType
    local input

    -- Show the register hi and enter prompt
    vim.cmd [[noa reg]]
    repeat
        vim.cmd [[noa echohl Moremsg]]
        local ok, msg = pcall(vim.fn.input, "Register: ")
        vim.cmd [[noa echohl None]]
        if not ok then
            if string.find(msg, "Keyboard interrupt") then
                return
            else
                return vim.notify("\n" .. msg, vim.log.levels.ERROR)
            end
        else
            input = msg
        end

        -- Allow quick cancel by pressing return key only
        if input == "" then return end

        -- Allow more specific put command in normal mode
        if vimMode == "n" and #input == 2 then
            regName = input:sub(1, 1)
            local exCmd = input:sub(2, 2)
            ---@diagnostic disable-next-line: need-check-nil
            if regexAll:match_str(input:sub(1, 1)) then
                if exCmd:lower() == "p" then
                    -- Support pasting the register before/after
                    -- Use remap keybinding
                    return vim.api.nvim_feedkeys('"' .. input, "m", false)
                elseif exCmd:lower() == "e" then
                    -- Suport converting first, then pasting the register into buffer
                    regType = vim.fn.getregtype(regName)
                    if regType == "v" then
                        vim.api.nvim_feedkeys('"' .. regName .. "cpj", "m", false)
                        -- OPTIM: more options when invoking inplace putting
                        return vim.defer_fn(function()
                            vim.cmd([[s#^\s*##e]])
                            vim.cmd("noh")
                        end ,0)
                    else
                        vim.notify("\nRegister" .. regName .. " isn't a characterwise register for editing macro", vim.log.levels.WARN)
                    end
                elseif exCmd:lower() == "r" then
                    -- Suport replace target register(macro) content with the text of current line
                    local regexWritable = vim.regex(M.regAllWritable)
                    ---@diagnostic disable-next-line: need-check-nil
                    if regexWritable:match_str(regName) then
                        local curLine = vim.api.nvim_get_current_line()
                        if string.find(curLine, "^%s*$") then
                            vim.notify("\nCurrent line isn't a invalid register content", vim.log.levels.WARN)
                        else
                            ---@diagnostic disable-next-line: param-type-mismatch
                            vim.fn.setreg(regName, curLine, "c")
                            return vim.cmd([[norm! "_dd]])
                        end
                    else
                        vim.notify("\nRegister" .. regName .. " isn't a writable register", vim.log.levels.WARN)
                    end
                end
            end
        else
            if #input == 1 and regexAll:match_str(input) then
                regName = input
                regType = vim.fn.getregtype(regName)
                local regContent = vim.fn.getreg(regName, 0)

                if regType == "" then
                    return
                elseif regType == "V" or regType == "line" then
                    local lines = vim.split(regContent:sub(1, -2), "\n")
                    return vim.api.nvim_put(lines, "l", true, false)
                else
                    return vim.api.nvim_put({regContent}, "c", true, false)
                end
            else
                vim.notify("\nInvalid register name", vim.log.levels.WARN)
            end
        end
    until false -- Infinite loop with multiple break points nested
end -- }}}
--- Get the specific pattern occurrence count in a string
---@param str string In what string to look up
---@param pattern string What pattern to be looked up
local stringCount = function(str, pattern) -- {{{
    local count = 0
    local init = 0
    while true do
        init = string.find(str, pattern, init + 1)
        if not init then return count end
        count = count + 1
    end
end -- }}}
---Reindent the register content
---@param indentOffset integer Can be negative integer. How many indents the source register content going to be prefixed or trimmed
---@param srcContent string The content return by vim.fn.getreg()
---@return string Reindented register content
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
            newContent = string.gsub(newContent, "\n%s*$", "\n")
        end
    end

    return newContent
end -- }}}
---Get the correct indent count of a register content by its leading space number. It also converts leading tabs into corresponding spaces and takes that into account
---@param regContent string Value return by vim.fn.getreg()
---@return integer # Value of the corresponding leading spaces of a register
M.getIndent = function(regContent) -- {{{
    local _, regIndent = string.find(regContent, "^%s*")
    local _, prefixLineBreak = string.find(regContent, "^\n*")

    -- Minus the leading line breaks
    if prefixLineBreak then regIndent = regIndent - prefixLineBreak end

    -- Convert leading tabs to spaces, then update reindent count
    local tabIdx = 0
    local tabCnt = 0
    repeat
        tabIdx = tabIdx + 1
        tabIdx = string.find(regContent, "\t", tabIdx)
        if tabIdx then tabCnt = tabCnt + 1 end
    until not tabIdx or tabIdx > regIndent

    if tabIdx then regIndent = regIndent + tabCnt * vim.api.nvim_get_option_value("tabstop", {buf = 0}) end

    return regIndent
end -- }}}

---@class RegisterInfo
---@field name string
---@field content string
---@field type string "v" for character-wise, "V" for line-wise, "\022<width>" for block-wise

local regUnnamed = {}
local regZero    = {}
local regStar    = {}
local regPlus    = {}
local regOther   = {}

--- Get register information
---@param name string
---@return RegisterInfo
local getReg = function(name)
    local content = vim.fn.getreg(name, 1)
    local type = vim.fn.getregtype(name)
    return {
        name = name,
        content = content,
        type = type
    }
    -- local regInfo = vim.fn.getreginfo(name)
    -- return {
    --     name = name,
    --     content = regInfo.regcontents,
    --     type = regInfo.regtype
    -- }
end
--- Set register information
---@param reg RegisterInfo
local setReg = function(reg)
    vim.fn.setreg(reg.name, reg.content, reg.type)
end
--- Save the star registers, plus and unnamed registers - independently, restoreReg can be accessed after saveReg is called
function M.saveReg() -- {{{
    local profile = require("profile")
    regUnnamed = getReg('"')
    regZero    = getReg("0")
    if _G._os_uname.machine == "aarch64" then
        regStar = {}
        regPlus = {}
    else
        if _G._os_uname.sysname == "Windows_NT" then
            regStar = getReg("*")
        else
            regStar = getReg("*")
            regPlus = getReg("+")
        end
    end

    if not vim.list_contains({'"', "*", "+", "0"}, vim.v.register) then
        regOther = getReg(vim.v.register)
    else
        regOther = {}
    end
end -- }}}

M.restoreReg = function() -- {{{
    if next(regOther) then
        setReg(regOther)
        regOther = {}
    end

    if next(regStar) then
        setReg(regStar)
        regStar = {}
    end

    if next(regPlus) then
        setReg(regPlus)
        regPlus = {}
    end

    if next(regUnnamed) then
        setReg(regUnnamed) -- setting unnamed register will set zero as well
        setReg(regZero)
        regUnnamed = {}
        regZero = {}
    end
end -- }}}

--- Copy indent of specific line number in current buffer
---@param lineNr integer (1, 0) indexed
---@return string # Corresponding line indent
M.indentCopy = function(lineNr) -- {{{
    return string.rep(" ", vim.fn.indent(lineNr))
end -- }}}


return M

