-- File: search
-- Author: iaso2h
-- Description: Jump & Search utilities
-- Version: 0.0.8
-- Last Modified: 2023-4-27
local M = {}

--- Echo search pattern and result index at the commandline
local echo = function() -- {{{
    local searchDict = vim.fn.searchcount()
    local result = string.format("[%s/%s]", searchDict.current, searchDict.total)
    local searchPat = vim.fn.histget("search")
    local echoStr = string.format('%s %s', searchPat, result)

    if searchDict.current == 1 or
            math.abs(searchDict.current - searchDict.total) == 0 then
        -- When search reaches the end
        vim.api.nvim_echo({{echoStr, "TelescopePromptCounter"}}, false, {})
    else
        vim.api.nvim_echo({{echoStr, "Normal"}}, false, {})
    end
end -- }}}
--- Search func wraps around the native n/N exCmd
---@param exCmd string "n" or "N"
M.cycle = function(exCmd) -- {{{
    local ok, msg = pcall(vim.api.nvim_command, "noa norm! " .. exCmd)
    if not ok then
        ---@diagnostic disable-next-line: param-type-mismatch
        if string.match(msg, "E486") then
            vim.api.nvim_echo({{"Pattern not found: " .. vim.fn.histget("search")}}, false, {})
            return
        else
            return vim.api.nvim_echo({{msg,}}, true, {err=true})
        end
    end

    vim.cmd("norm! " .. "zv")
    echo()
end -- }}}
--- Search func wraps around the native //? exCmd in Visual mode
---@param exCmd string "/" or "?"
-- Similar project: https://github.com/bronson/vim-visual-star-search
M.searchSelected = function(exCmd) -- {{{
    local cursorPos = vim.api.nvim_win_get_cursor(0)
    local selectedStr = vim.fn.escape(
        require("selection").get("string", true),
        [=[\$^.*~[]=]  -- Escape special character in magic mode(Neovim default)
    )
    selectedStr = exCmd .. selectedStr
    vim.cmd(selectedStr)
    vim.api.nvim_echo({{selectedStr}}, false, {})
    vim.api.nvim_win_set_cursor(0, cursorPos)
end -- }}}
--- Search the word under cursor
---@param exCmd string The non-recursive key mapping for searching. "*" or "#"
---@param ignoreWordBoundary boolean Whether to ignore the word boundary by surround the word with `\<` and `\>`
M.cword = function(exCmd, ignoreWordBoundary) -- {{{
    exCmd = ignoreWordBoundary and "g" .. exCmd or exCmd
    local util = require("util")

    util.saveViewCursor()
    vim.cmd("norm! " .. exCmd .. "``")
    if vim.is_callable(util.restoreViewCursor) then
        util.restoreViewCursor(vim.fn.winheight(0))
    end
    echo()
end -- }}}


return M
