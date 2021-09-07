-- File: openBrowser
-- Author: iaso2h
-- Description: Open url link in browser
-- Version: 0.0.4
-- Last Modified: 2021-08-24
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

function M.openUrl(selectText)
    -- Normal mode with no selected text provided
    if not selectText then
        local regex
        if fn.expand("%:p") == fn.stdpath("config") .. "/lua/core/plugins.lua" then
            regex = vim.regex [[use \zs'.\{-}\/.\{-}']]
        else
            regex = vim.regex [=[[a-z]*:\/\/[^ >,;]*]=]
        end

        local urlStart
        local urlEnd
        local curLine = api.nvim_get_current_line()
        urlStart, urlEnd = regex:match_str(curLine)

        if not urlStart then return end

        local url
        if fn.expand("%:p") == fn.stdpath("config") .. "/lua/core/plugins.lua" then
            url = "https://github.com/" .. string.sub(curLine, urlStart + 2, urlEnd - 1)
        else
            url = string.sub(curLine, urlStart + 1, urlEnd)
        end

        -- Create highlight {{{
        local curPos   = api.nvim_win_get_cursor(0)
        local curBufNr = api.nvim_get_current_buf()
        local opts     = {hlGroup = "Search", timeout = 500}
        local urlNS    = api.nvim_create_namespace('openUrl')
        api.nvim_buf_clear_namespace(curBufNr, urlNS, 0, -1)
        api.nvim_buf_add_highlight(curBufNr, urlNS, opts["hlGroup"], curPos[1] - 1, urlStart, urlEnd)
        -- }}} Create highlight

        vim.defer_fn(function()
            api.nvim_buf_clear_namespace(curBufNr, urlNS, 0, -1)
            if fn.has('win32') == 1 then
                fn.system("explorer " .. url)
            elseif fn.has('unix') == 1 then
                fn.system("xdg-open '" .. url .. "'")
            end
        end, opts["timeout"])
    -- Visual mode with selected text provided
    else
        if fn.has('win32') == 1 then
            fn.system("explorer " .. selectText)
        elseif fn.has('unix') == 1 then
            if fn.expand("%:p") == fn.stdpath("config") .. "/lua/core/plugins.lua" then
                selectText = "https://github.com/" .. selectText
            end
                fn.system("xdg-open '" .. selectText .. "'")
        end
    end
end

function M.openInBrowser(str)
    if fn.has('win32') == 1 then
        fn.system("explorer \"? " .. str .. "\"")
    elseif fn.has('unix') == 1 then
        fn.system("xdg-open '" .. str .. "'")
    end
end

return M

