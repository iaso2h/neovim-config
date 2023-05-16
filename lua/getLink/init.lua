-- File: getLink module
-- Author: iaso2h
-- Description: Get url link in browser
-- Version: 0.0.15
-- Last Modified: 2023-4-26
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


local getUrl = function(bufNr, cursorPos, curLine)
    local urlStart, urlEnd = vim.regex[=[[a-z]*:\/\/[^ >,;]*]=]:match_str(curLine)
    if urlStart then
        local url = string.sub(curLine, urlStart + 1, urlEnd)
        highlight(bufNr, cursorPos[1], urlStart, urlEnd)
        return url
    end
    return ""
end


function M.main(selectText)
    if not selectText then
        -- Normal mode with no selected text provided
        local url
        local curBufNr  = api.nvim_get_current_buf()
        local cursorPos = api.nvim_win_get_cursor(0)
        local curLine   = api.nvim_get_current_line()

        local filePath = fn.expand("%:p")

        if filePath == (_G._config_path .. pathStr "/lua/plugins/init.lua") then
            url = require("getLink.lazyPlugins")(curBufNr, cursorPos, getUrl)
            if type(url) == "string" and url ~= "" then
                if string.find(url, "http") then
                    openUrl(url, M.highlightTimout, curBufNr)
                else
                    vim.cmd(url)
                end
            end
        elseif string.match(curLine, [[^%s*--%s*LUARUN:]]) then
            local idx = {string.find(curLine, [[^%s*--%s*LUARUN:]])}
            vim.cmd("lua " .. curLine:sub(idx[2] + 1, -1))
        else
            -- Support for opening normal http[s] link
            url = getUrl(curBufNr, cursorPos, curLine)
            if url ~= "" then openUrl(url, M.highlightTimout, curBufNr) end
        end
    else
        -- Visual mode with selected text provided
        if _G._os_uname.sysname == "Windows_NT" then
            fn.system{"explorer", selectText}
        elseif _G._os_uname.sysname == "Linux" then
            if fn.expand("%:p") == fn.stdpath("config") .. "/lua/plugins/init.lua" then
                selectText = "https://github.com/" .. selectText
            end
                fn.system{"xdg-open", selectText}
        end
    end
end

return M
