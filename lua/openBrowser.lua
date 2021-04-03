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
            cmd [[mode]]
            return
        end
        local url = string.sub(curLine, urlStart + 1, urlEnd)
        -- Create highlight {{{
        local curPos = api.nvim_win_get_cursor(0)
        local curBufNr = api.nvim_get_current_buf()
        local opts = {hlGroup="Search", timeout=500}
        local urlNS = api.nvim_create_namespace('openUrl')
        api.nvim_buf_clear_namespace(curBufNr, urlNS, 0, -1)
        api.nvim_buf_add_highlight(curBufNr, urlNS, opts["hlGroup"], curPos[1] - 1, urlStart, urlEnd)
        -- }}} Create highlight

        vim.defer_fn(function()
            api.nvim_buf_clear_namespace(curBufNr, urlNS, 0, -1)
            if fn.has('win32') == 1 then
                fn.system("explorer " .. url)
            elseif fn.has('unix') == 1 then
                cmd("!open '" .. url .. "'")
            end
        end, opts["timeout"])
    else
        if fn.has('win32') == 1 then
            cmd("explorer " .. selectText)
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

