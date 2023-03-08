-- File: openBrowser
-- Author: iaso2h
-- Description: Open url link in browser
-- Version: 0.0.8
-- Last Modified: 2023-3-7
local fn  = vim.fn
local api = vim.api
local M   = {}
local dev = true



local function openUrl(url, timeout)
    timeout = timeout or 0

    vim.defer_fn(function()
        if fn.has('win32') == 1 then
            fn.system("explorer " .. url)
        elseif fn.has('unix') == 1 then
            fn.system("xdg-open '" .. url .. "'")
        end
    end, timeout)
end



local function highlight(urlStart, urlEnd)
    local curPos   = api.nvim_win_get_cursor(0)
    local curBufNr = api.nvim_get_current_buf()
    local urlNS    = api.nvim_create_namespace('openLink')
    api.nvim_buf_clear_namespace(curBufNr, urlNS, 0, -1)
    api.nvim_buf_add_highlight(curBufNr, urlNS, "Search", curPos[1] - 1, urlStart, urlEnd)
end


function M.main(selectText)
    -- Normal mode with no selected text provided
    if not selectText then
        local url
        local urlStart
        local urlEnd
        local curLine


        local sep = string.find(_G._os_uname.sysname, "Windows_NT") and "\\" or "/"
        local filePath = fn.expand("%:p")
        local configPath = fn.stdpath("config")
        if 0 > 1 then
            map("n", [[gh]], [[<CMD>lua require("openLink").main()<CR>]], "which_key_ignore")
        end


        if dev or filePath == string.format("%s%slua%score%splugins.lua", configPath, sep, sep, sep) then
            url = require("openLink.path.pluginConfig")(configPath, sep)
            if url then
                return openUrl(url)
            end
        elseif vim.bo.filetype == "packer" then
            -- Support for jumping to related github commit in packer buffer
            curLine = api.nvim_get_current_line()
            urlStart, urlEnd = vim.regex [=[Updated \zs.\{-}\/.\{-}\ze:]=]:match_str(curLine)

            if not urlStart then return end

            url = "https://github.com/" .. string.sub(curLine, urlStart + 1, urlEnd)

            local commitStart, commitEnd = vim.regex [=[\.\.\zs.\{7}$]=]:match_str(curLine)

            if not urlStart then return vim.notify("Capturing commit string failed", vim.log.levels.ERROR) end

            url = url .. string.format([[/commit/%s]], string.sub(curLine, commitStart + 1, commitEnd))

            urlEnd = commitEnd

            highlight(urlStart, urlEnd)
            return openUrl(url, 500)
        else
            -- Support for opening normal http[s] link
            curLine = api.nvim_get_current_line()
            urlStart, urlEnd = vim.regex [=[[a-z]*:\/\/[^ >,;]*]=]:match_str(curLine)

            if not urlStart then return end

            url = string.sub(curLine, urlStart + 1, urlEnd)

            highlight(urlStart, urlEnd)
            return openUrl(url, 500)
        end

    -- Visual mode with selected text provided
    else
        if _G._os_uname.sysname == "Windows_NT" then
            fn.system("explorer " .. selectText)
        elseif _G._os_uname.sysname == "Linux" then
            if fn.expand("%:p") == fn.stdpath("config") .. "/lua/core/plugins.lua" then
                selectText = "https://github.com/" .. selectText
            end
                fn.system("xdg-open '" .. selectText .. "'")
        end
    end
end

return M
