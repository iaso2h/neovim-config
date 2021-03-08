local vim = vim
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local M = {}

function M.openUrl(selectText)
    if not selectText then
        local regex = vim.regex [[[a-z]*:\/\/[^ >,;]*]]
        local urlStart
        local urlEnd
        local curLine = api.nvim_get_current_line()
        urlStart, urlEnd = regex:match_str(curLine)
        if not urlStart then
            cmd [[normal! \<C-l>]]
            return
        end
        local url = string.sub(curLine, urlStart + 1, urlEnd)
        if fn.has('win32') == 1 then
            fn.system("!explorer " .. url)
        elseif fn.has('unix') == 1 then
            cmd("!open '" .. url .. "'")
        end
    else
        if fn.has('win32') == 1 then
            cmd("!explorer " .. selectText)
        elseif fn.has('unix') == 1 then
            cmd("!open '" .. selectText .. "'")
        end
    end
end

function M.openInBrowser(str)
    if fn.has('win32') == 1 then
        cmd("!chrome \"? " .. str .. "\"")
    elseif fn.has('unix') == 1 then
        cmd("!open '" .. str .. "'")
    end
end

return M

