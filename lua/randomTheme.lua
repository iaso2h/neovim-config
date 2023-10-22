-- File: randomTheme.lua
-- Author: iaso2h
-- Description: Randomize all highlight groups
-- Version: 0.0.1
-- Last Modified: 2023-10-20

local M = {

}

local dummy = { -- {{{
    "SpecialKey     xxx ctermfg=81 guifg=#d08770",
    "EndOfBuffer    xxx links to NonText",
    "TermCursor     xxx cterm=reverse gui=reverse",
    "                   links to Cursor",
    "TermCursorNC   xxx cleared",
    "NonText        xxx ctermfg=12 guifg=#4c566a",
    "Directory      xxx ctermfg=159 guifg=#8fbcbb",
    "ErrorMsg       xxx ctermfg=15 ctermbg=1 guifg=#d8dee9 guibg=#bf616a",
    "IncSearch      xxx cterm=reverse gui=bold guifg=#ffffff guibg=#ed427c",
    "Search         xxx ctermfg=0 ctermbg=11 gui=bold guifg=#ffffff guibg=#88c0d0",
    "CurSearch      xxx links to IncSearch",
    "MoreMsg        xxx ctermfg=121 gui=bold guifg=#88c0d0",
    "ModeMsg        xxx cterm=bold guifg=#d8dee9",
    "LineNr         xxx ctermfg=11 guifg=#4c566a",
    "LineNrAbove    xxx links to LineNr",
} -- }}}

local getHighlightGroup = function() -- {{{
    local cmdOutput = vim.api.nvim_exec2("hi", { output = true }).output
    local cmdRaw = vim.split(cmdOutput, "\n", { plain = true, trimempty = false })
    return cmdRaw
end -- }}}

local cmdParse = function(cmdRaw) -- {{{
    local result = string.match(cmdRaw, "^([^%s]+)%s+xxx.+$")
    if result then
        return result
    else
        return nil
    end
end -- }}}

M.getHighlightName = function () -- {{{
    local cmdRaw = getHighlightGroup()
    local names = vim.tbl_map(cmdParse, cmdRaw)
    return names
end -- }}}

M.hexes = {}
local randomHex = function() -- {{{
    local hex
    local randomNr

    repeat
        randomNr = math.random(0, 16777216)
        hex = string.format("#%x", randomNr)
        if randomNr < 1048576 then
            hex = "#" .. string.rep("0", (7 - #hex)) .. string.sub(hex, 2, -1)
        end

        -- TODO: a highly efficient way of checking duplicate
        -- if tbl_idx(M.hexes, hex, false) ~= -1 then
        --     table.insert(M.hexes, hex)
            return hex
        -- end
    until false
end -- }}}

M.apply = function () -- {{{
    local names = M.getHighlightName()

    for _, name in ipairs(names) do
        local guibg = randomHex()
        local guifg = randomHex()
        local cmd = string.format("highlight! %s guifg=%s guibg=%s", name, guifg, guibg)
        pcall(vim.api.nvim_command, cmd)
    end
end -- }}}

return M
