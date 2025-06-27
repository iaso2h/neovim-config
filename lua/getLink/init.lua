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
---@param url string The URL to open.
---@param timeout integer? The delay in milliseconds before opening the URL. Defaults to 0.
---@param bufNr integer? The buffer number where the URL is located. If provided, clears the highlight after `timeout`.
---@return nil
local function openUrl(url, timeout, bufNr) -- {{{
    timeout = timeout or 0

    ---@diagnostic disable-next-line: param-type-mismatch
    vim.defer_fn(function()
        if timeout ~= 0 and bufNr then
            vim.api.nvim_buf_clear_namespace(bufNr, opts.ns, 0, -1)
        end
        vim.ui.open(url)
    end, timeout)
end -- }}}
--- Highlight a specific area in the current line.
---@param bufNr integer The buffer number where the highlight should be applied.
---@param lnum integer The line number (1-based) to highlight.
---@param colStart integer The starting column (0-based) of the highlight.
---@param colEnd integer The ending column (0-based) of the highlight.
---@return nil
local function highlight(bufNr, lnum, colStart, colEnd) -- {{{
    vim.api.nvim_buf_clear_namespace(bufNr, opts.ns, 0, -1)
    vim.hl.range(bufNr, opts.ns, opts.highlightGroup, {lnum - 1, colStart}, {lnum - 1, colEnd+1})
end -- }}}
--- Get the URL link from the current line at the cursor position.
---@param bufNr integer The buffer number where the URL is located.
---@param cursorPos table The cursor position (1-based line, 0-based column).
---@param curLine string The current line content.
---@return string The extracted URL, or an empty string if no URL is found.
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
        return vim.api.nvim_echo( { { msg} }, true, {err = true} )
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
            vim.system({"explorer", url}, {}, function() end)
        elseif _G._os_uname.sysname == "Linux" then
            if vim.fn.expand("%:p") == vim.fn.stdpath("config") .. "/lua/plugins/init.lua" then
                url = "https://github.com/" .. url
            end
                vim.system({"xdg-open", url}, {}, function() end)
        end
    end
end -- }}}
