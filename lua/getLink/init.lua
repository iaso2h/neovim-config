-- File: getLink module
-- Author: iaso2h
-- Description: Get url link in browser
-- Version: 0.0.16
-- Last Modified: 2024-06-02
local opts = {
    ns = vim.api.nvim_create_namespace('getLink'),
    highlightTimout = 500,
    highlightGroup = "Search",
}

--- Open the url link
---@param url string
---@param timeout integer
---@param bufNr integer
local function openUrl(url, timeout, bufNr) -- {{{
    timeout = timeout or 0

    ---@diagnostic disable-next-line: param-type-mismatch
    vim.defer_fn(function()
        if timeout ~= 0 and bufNr then
            vim.api.nvim_buf_clear_namespace(bufNr, opts.ns, 0, -1)
        end
        if vim.fn.has('win32') == 1 then
            vim.fn.system{"explorer", url}
        elseif vim.fn.has('unix') == 1 then
            vim.fn.system{"xdg-open", url}
        end
    end, timeout)
end -- }}}
--- Highlight area in current line
---@param bufNr integer
---@param lnum integer
---@param colStart integer
---@param colEnd integer
local function highlight(bufNr, lnum, colStart, colEnd) -- {{{
    vim.api.nvim_buf_clear_namespace(bufNr, opts.ns, 0, -1)
    vim.api.nvim_buf_add_highlight(bufNr, opts.ns, opts.highlightGroup, lnum - 1, colStart, colEnd)
end -- }}}
--- Get the url link
---@param bufNr integer
---@param cursorPos table (1, 0) based
---@param curLine string Current line
---@return string # Return empty string if failed to retrieve one at the cursor location
local getUrl = function(bufNr, cursorPos, curLine) -- {{{
    local urlStart, urlEnd = vim.regex[=[[a-z]*:\/\/[^ >,;]*]=]:match_str(curLine)
    if urlStart then
        local url = string.sub(curLine, urlStart + 1, urlEnd)
        highlight(bufNr, cursorPos[1], urlStart, urlEnd)
        return url
    end
    return ""
end -- }}}
---@param url string The url string
return function(url) -- {{{
    local commentStr
    local ok, msg = pcall(string.gsub, vim.bo.commentstring, "%s*%%s$", "")
    if not ok then
        return vim.notify(msg, vim.log.levels.ERROR)
    else
        commentStr = msg
    end
    local luaRunPrefixStr = [[^%s*]] .. commentStr .. [[+%s*LUARUN:]]
    local vimRunPrefixStr = [[^%s*]] .. commentStr .. [[+%s*VIMRUN:]]

    if not url then
        -- Normal mode with no selected text provided
        local curBufNr  = vim.api.nvim_get_current_buf()
        local cursorPos = vim.api.nvim_win_get_cursor(0)
        local curLine   = vim.api.nvim_get_current_line()

        local filePath = vim.fn.expand("%:p")

        if filePath == (_G._config_path .. pathStr "/lua/plugins/init.lua") then
            url = require("getLink.lazyPlugins")(curBufNr, cursorPos, getUrl)
            if type(url) == "string" and url ~= "" then
                if string.find(url, "http") then
                    openUrl(url, opts.highlightTimout, curBufNr)
                else
                    vim.cmd(url)
                end
            end
        elseif string.match(curLine, luaRunPrefixStr) then
            local idx = {string.find(curLine, luaRunPrefixStr)}
            vim.cmd("lua " .. curLine:sub(idx[2] + 1, -1))
        elseif string.match(curLine, vimRunPrefixStr) then
            local idx = {string.find(curLine, vimRunPrefixStr)}
            vim.cmd(curLine:sub(idx[2] + 1, -1))
        else
            -- Support for opening normal http[s] link
            url = getUrl(curBufNr, cursorPos, curLine)
            if url ~= "" then openUrl(url, opts.highlightTimout, curBufNr) end
        end
    else
        -- Visual mode with selected text provided
        if _G._os_uname.sysname == "Windows_NT" then
            vim.fn.system{"explorer", url}
        elseif _G._os_uname.sysname == "Linux" then
            if vim.fn.expand("%:p") == vim.fn.stdpath("config") .. "/lua/plugins/init.lua" then
                url = "https://github.com/" .. url
            end
                vim.fn.system{"xdg-open", url}
        end
    end
end -- }}}
