local api = vim.api
local M   = {}


M.clear = function(qfBufNr)
    qfBufNr = qfBufNr or 0
    if package.loaded["todo-comments"] then
        local ns = require("todo-comments.config").ns
        if ns then
            api.nvim_buf_clear_namespace(qfBufNr, ns, 0, -1)
        end
        -- require("todo-comments.highlight").highlight_win(api.nvim_get_current_win(), true)
    end

    api.nvim_buf_clear_namespace(qfBufNr, require("quickfix").ns, 0, -1)
end


--- Highlight lines in quickfix window
---@param lineTbl table Contains 1-indexed line number
---@param hlGroup string Highlight group
---@param ns number Namespace handler return by calling
--vim.api.nvim_create_namespace()
---@param bufNr? number Optionial buffer number
M.addLines = function(lineTbl, hlGroup, ns, bufNr)
    bufNr = bufNr or api.nvim_get_current_buf()

    for _, line in ipairs(lineTbl) do
        api.nvim_buf_add_highlight(bufNr, ns, hlGroup, line - 1, 0, -1) -- (0, 0) indexed
    end
end


M.moreDiagnosticsHighlight = function(qfItems)
    local u = require("quickfix.util")
    if qfItems == nil then qfItems = u.getline() end
    local title = u.getlist{title = 0}.title
    if not string.find(title, "Diagnostics") then return end

    if vim.bo.buftype ~= "quickfix" then return end
    local qfBufnr = vim.api.nvim_get_current_buf()

    -- Clear namespace
    local ns = vim.api.nvim_create_namespace("myQuickfix")
    vim.api.nvim_buf_clear_namespace(qfBufnr, ns, 0, -1)

    local qfLines = vim.api.nvim_buf_get_lines(qfBufnr, 0, -1, false)
    for qfLineNr, item in ipairs(qfItems) do
        if item.type ~= "E" then
            local fileName = vim.fn.bufname(item.bufnr)
            local qfLine   = qfLines[qfLineNr]
            local vBarIdx  = string.find(qfLine, "|", fileName:len() + 2, true) -- 1 based index
            if not vBarIdx then
                return vim.notify("Unable to find vertical bar index", vim.log.levels.ERROR)
            end

            local errorText
            local errorStartIdx
            local errorHighlightGroup
            if item.type == "W" then
                errorText = "warning"
                errorHighlightGroup = "DiagnosticWarn"
            elseif item.type == "N" then
                errorText = "note"
                errorHighlightGroup = "DiagnosticHint"
            else
                return
            end
            errorStartIdx = vBarIdx - errorText:len() -- 1 based index
            vim.api.nvim_buf_add_highlight(qfBufnr, ns, errorHighlightGroup, qfLineNr - 1, errorStartIdx - 1, vBarIdx - 1)
        end
    end

end


return M
