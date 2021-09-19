-- File: openBrowser
-- Author: iaso2h
-- Description: Open url link in browser
-- Version: 0.0.5
-- Last Modified: 2021-09-17
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

function M.main(selectText)
    -- Normal mode with no selected text provided
    if not selectText then
        local url
        local urlStart
        local urlEnd
        local curLine

        if fn.expand("%:p") == fn.stdpath("config") .. "/lua/core/plugins.lua" then
            -- Support for jumping to neovim plugin in github.com
            local curPos  = api.nvim_win_get_cursor(0)
            local lines   = api.nvim_buf_get_lines(0, curPos[1] - 2, curPos[1], false)
            local prevLine = lines[1]
            curLine = lines[2]

            if string.match(prevLine, "use%s+{") then
                -- match: "userName/repository"
                urlStart, urlEnd = vim.regex [['.\{-}']]:match_str(curLine)
                url = "https://github.com/" .. string.sub(curLine, urlStart + 2, urlEnd - 1)
            elseif string.match(curLine, [[use%s+['"]%w]]) then
                -- match: use "userName/repository"
                urlStart, urlEnd = vim.regex [[use \zs'.\{-}']]:match_str(curLine)
                url = "https://github.com/" .. string.sub(curLine, urlStart + 2, urlEnd - 1)
            elseif string.match(curLine, [[config%s+=%s+conf]]) then
                -- match: config = conf "moduleName"
                urlStart, urlEnd = vim.regex [=[config.\{-}conf.\{-}\zs".\{-}"]=]:match_str(curLine)

                -- End parsing
                if not urlStart then return end

                return cmd(string.format("e %s/lua/config/%s.lua",
                    fn.stdpath("config"),
                    string.sub(curLine, urlStart + 2, urlEnd - 1)
                ))
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
        else
            -- Support for opening normal http[s] link
            curLine = api.nvim_get_current_line()
            urlStart, urlEnd = vim.regex [=[[a-z]*:\/\/[^ >,;]*]=]:match_str(curLine)

            if not urlStart then return end

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
        if jit.os == "Windows" then
            fn.system("explorer " .. selectText)
        elseif jit.os == "Linux" then
            if fn.expand("%:p") == fn.stdpath("config") .. "/lua/core/plugins.lua" then
                selectText = "https://github.com/" .. selectText
            end
                fn.system("xdg-open '" .. selectText .. "'")
        end
    end
end

return M

