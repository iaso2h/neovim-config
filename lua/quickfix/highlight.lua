local M   = {}


--- Clear highlight in quickfix buffer
---@param qfBufNr? integer
M.generalClear = function(qfBufNr) -- {{{
    qfBufNr = qfBufNr or 0

    vim.api.nvim_buf_clear_namespace(qfBufNr, require("quickfix").ns, 0, -1)
end -- }}}
--- Highlight lines in quickfix window
---@param lineTbl table Contains 1-indexed line number
---@param hlGroup string Highlight group
---@param ns integer Namespace handler return by calling `vim.api.nvim_create_namespace()`
---@param bufNr? integer Optional buffer number
M.addLines = function(lineTbl, hlGroup, ns, bufNr) -- {{{
    bufNr = bufNr or vim.api.nvim_get_current_buf()

    for _, line in ipairs(lineTbl) do
        vim.api.nvim_buf_add_highlight(bufNr, ns, hlGroup, line - 1, 0, -1) -- (0, 0) indexed
    end
end -- }}}
--- Add missing highlight for warning, note, info in error column
---@param qfItems table Returned value of `vim.fn.getqflist()`
---@param qfBufNr integer The buffer number of quickfix
M.diagnosticsComplement = function(qfItems, qfBufNr) -- {{{
    -- Get existing namespace or create a new one
    local ns = vim.api.nvim_create_namespace("diagnosticsComplement")
    -- Clear the namespace highlight
    vim.api.nvim_buf_clear_namespace(qfBufNr, ns, 0, -1)

    local qfLines = vim.api.nvim_buf_get_lines(qfBufNr, 0, -1, false)
    for qfLineNr, item in ipairs(qfItems) do
        if item.type ~= "E" then
            local fileName = vim.fn.bufname(item.bufnr)
            local qfLine   = qfLines[qfLineNr]
            local vBarIdx  = string.find(qfLine, "|", fileName:len() + 2, true) -- 1 based index
            if vBarIdx then
                local errorText
                local errorStartIdx
                local diagnosticsHighlightGroup
                if item.type == "W" then
                    errorText = "warning"
                    diagnosticsHighlightGroup = "DiagnosticWarn"
                elseif item.type == "N" then
                    errorText = "note"
                    diagnosticsHighlightGroup = "DiagnosticHint"
                elseif item.type == "I" then
                    errorText = "info"
                    diagnosticsHighlightGroup = "DiagnosticInfo"
                end
                errorStartIdx = vBarIdx - errorText:len() -- 1 based index
                -- HACK: Can't put the new highlight on the stack of the "QuickFixLine" highlight group
                vim.api.nvim_buf_add_highlight(qfBufNr, ns,diagnosticsHighlightGroup, qfLineNr - 1, errorStartIdx - 1, vBarIdx - 1)
                -- vim.api.nvim_buf_set_extmark(qfBufNr, ns, qfLineNr - 1, errorStartIdx - 1, {
                --     end_row = qfLineNr - 1,
                --     end_col = vBarIdx - 1,
                --     hl_group = "Search",
                --     hl_mode = "replace",
                -- })
            end
        end
    end
end -- }}}
--- Refresh highligh in quickfix window
---@param qfBufNr integer Quickfix buffer number
---@param qfItems table Returned value of `vim.fn.getqflist()`
---@param qfTitle string Quickfix title
M.refreshHighlight = function(qfBufNr, qfItems, qfTitle) -- {{{
    if qfTitle == "Local Diagnostics" or qfTitle == "Workspace Diagnostics" then
        local diagnostics = require("quickfix.diagnostics")
        diagnostics.filteredChk = true
        -- Wrap it around the `dianostics.changedTick` value to avoid the
        -- quifix being updated from calling `require("quickfix.diagnostics").refresh()`
        diagnostics.changedTick = false
        M.diagnosticsComplement(qfItems, qfBufNr)
        diagnostics.changedTick = true
    elseif qfTitle == "Todo" then
        if package.loaded["todo-comments"] then
            local ns = require("todo-comments.config").ns
            if ns then
                vim.api.nvim_buf_clear_namespace(qfBufNr, ns, 0, -1)
            end
        end
    end

    M.generalClear(qfBufNr)
end -- }}}

return M
