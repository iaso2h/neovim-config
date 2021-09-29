local M = {}
M.updateDebug = function()
    if vim.bo.filetype ~= "vim" then return end

    local cmd = vim.cmd

    cmd [[noa up]]
    cmd [[noa Runtime]]
    cmd [[noa breakdel *]]
    vim.notify("Script update")
end

M.config = function()
    map("n", [[g>]], [[:<C-u>Messages<CR>]], {"silent", "novscode"}, "Messages in quickfix")
    whichKeyDoc({"gS", "Show syntax highlighting groups"})
    whichKeyDoc({"g=", "Eval operator"})
    whichKeyDoc({"g==", "Eval current line"})
end

return M
