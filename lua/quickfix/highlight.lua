local M   = {}


--- Clear highlight in quickfix buffer
---@param qfBufNr integer
M.clear = function(qfBufNr) -- {{{
    qfBufNr = qfBufNr or 0
    if package.loaded["todo-comments"] then
        local ns = require("todo-comments.config").ns
        if ns then
            vim.api.nvim_buf_clear_namespace(qfBufNr, ns, 0, -1)
        end
        -- require("todo-comments.highlight").highlight_win(api.nvim_get_current_win(), true)
    end

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


return M
