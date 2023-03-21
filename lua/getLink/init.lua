-- File: o
-- Author: iaso2h
-- Description: Open url link in browser
-- Version: 0.0.11
-- Last Modified: 2023-3-19
local fn  = vim.fn
local api = vim.api
local M   = {
    ns = api.nvim_create_namespace('getLink'),
    highlightTimout = 500,
    highlightGroup = "Search",
}


local function openUrl(url, timeout, bufNr)
    timeout = timeout or 0

    ---@diagnostic disable-next-line: param-type-mismatch
    vim.defer_fn(function()
        if timeout ~= 0 and bufNr then
            api.nvim_buf_clear_namespace(bufNr, M.ns, 0, -1)
        end
        if fn.has('win32') == 1 then
            fn.system{"explorer", url}
        elseif fn.has('unix') == 1 then
            fn.system{"xdg-open", url}
        end
    end, timeout)
end


--- Highlight area in current line
---@param bufNr number
---@param lnum number
---@param colStart number
---@param colEnd number
local function highlight(bufNr, lnum, colStart, colEnd)
    api.nvim_buf_clear_namespace(bufNr, M.ns, 0, -1)
    api.nvim_buf_add_highlight(bufNr, M.ns, M.highlightGroup, lnum - 1, colStart, colEnd)
end


local getUrl = function(bufNr, cursorPos)
    local cursorLine = api.nvim_get_current_line()
    local urlStart, urlEnd = vim.regex[=[[a-z]*:\/\/[^ >,;]*]=]:match_str(cursorLine)
    if urlStart then
        local url = string.sub(cursorLine, urlStart + 1, urlEnd)
        highlight(bufNr, cursorPos[1], urlStart, urlEnd - 1)
        return url
    end
    return ""
end


function M.main(selectText)
    if not selectText then
        -- Normal mode with no selected text provided
        local url
        local curBufNr = api.nvim_get_current_buf()
        local cursorPos = api.nvim_win_get_cursor(0)

        local filePath = fn.expand("%:p")

        if filePath == string.format("%s%slua%score%splugins.lua", _G._configPath, _G._sep, _G._sep, _G._sep) then
            url = require("getLink.lazyPlugins")(curBufNr, cursorPos, getUrl)
            if type(url) == "string" and url ~= "" then
                if string.find(url, "http") then
                    openUrl(url, M.highlightTimout, curBufNr)
                else
                    vim.cmd(url)
                end
            end
        else
            -- Support for opening normal http[s] link
            url = getUrl(curBufNr, cursorPos)
            if url ~= "" then openUrl(url, M.highlightTimout, curBufNr) end
        end
    else
        -- Visual mode with selected text provided
        if _G._os_uname.sysname == "Windows_NT" then
            fn.system{"explorer", selectText}
        elseif _G._os_uname.sysname == "Linux" then
            if fn.expand("%:p") == fn.stdpath("config") .. "/lua/core/plugins.lua" then
                selectText = "https://github.com/" .. selectText
            end
                fn.system{"xdg-open", selectText}
        end
    end
end

return M
