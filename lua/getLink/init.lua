-- File: o
-- Author: iaso2h
-- Description: Open url link in browser
-- Version: 0.0.10
-- Last Modified: 2023-3-15
local fn  = vim.fn
local api = vim.api
local M   = {
    ns = api.nvim_create_namespace('getLink'),
    highlighTimout = 500,
    highlightGroup = "Search",
}


local function openUrl(url, timeout, bufNr)
    timeout = timeout or 0

    vim.defer_fn(function()
        if timeout ~= 0 and bufNr then
            api.nvim_buf_clear_namespace(bufNr, M.ns, 0, -1)
        end
        if fn.has('win32') == 1 then
            fn.system("explorer " .. url)
        elseif fn.has('unix') == 1 then
            fn.system("xdg-open '" .. url .. "'")
        end
    end, timeout)
end



--- Highligh area in current line
---@param bufNr number
---@param lnum number
---@param colStart number
---@param colEnd number
local function highlight(bufNr, lnum, colStart, colEnd)
    api.nvim_buf_clear_namespace(bufNr, M.ns, 0, -1)
    api.nvim_buf_add_highlight(bufNr, M.ns, M.highlightGroup, lnum - 1, colStart, colEnd)
end


function M.main(selectText)
    -- Normal mode with no selected text provided
    if not selectText then
        local url
        local urlStart
        local urlEnd
        local curBufNr = api.nvim_get_current_buf()

        local filePath = fn.expand("%:p")

        if filePath == string.format("%s%slua%score%splugins.lua", _G._configPath, _G._sep, _G._sep, _G._sep) then
            -- TODO: support repo link in requires
            url = require("getLink.path.pluginConfig")()
            if url then
                return openUrl(url)
            end
        elseif vim.bo.filetype == "packer" then
            -- Support for jumping to related github commit in packer buffer
            local cursorPos = api.nvim_win_get_cursor(0)
            local lines = api.nvim_buf_get_lines(0, fn.line("w0"), cursorPos[1], false)
            local lnum
            local commitStr
            local commitIdx
            local urlIdx
            for i = #lines, 1, -1 do
                local line = lines[i]

                -- Find commit string
                if not commitStr then
                    local regex = vim.regex([[^\s\+\zs\w\{7}\ze ]])
                    commitIdx = {regex:match_str(line)}
                    if next(commitIdx) then
                        commitStr = string.sub(line, commitIdx[1] + 1, commitIdx[2])
                        urlStart, urlEnd = unpack(commitIdx)

                        -- Highlight the commit string
                        if M.highlighTimout ~= 0 then
                            lnum = cursorPos[1] - (#lines - i)
                            highlight(curBufNr, lnum, urlStart, urlEnd)
                        end
                    end
                end

                -- FInd github repository url
                urlIdx = {string.find(line, "https://.*$")}
                if next(urlIdx) then
                    urlStart, urlEnd = unpack(urlIdx)
                    url = string.sub(line, urlStart, urlEnd)

                    if not commitStr then
                        -- Highlight the repo url
                        if M.highlighTimout ~= 0 then
                            lnum = cursorPos[1] - (#lines - i)
                            highlight(curBufNr, lnum, urlStart - 1, urlEnd)
                        end
                    else
                        url = url .. "/commit/" .. commitStr
                    end

                    return openUrl(url, M.highlighTimout, curBufNr)
                end
            end
        else
            -- Support for opening normal http[s] link
            local cursorLine = api.nvim_get_current_line()
            local cursorPos = api.nvim_win_get_cursor(0)
            urlStart, urlEnd = vim.regex([=[[a-z]*:\/\/[^ >,;]*]=]):match_str(cursorLine)

            if urlStart then
                url = string.sub(cursorLine, urlStart + 1, urlEnd)
                highlight(curBufNr, cursorPos[1], urlStart, urlEnd)
                return openUrl(url, M.highlighTimout, curBufNr)
            end
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
