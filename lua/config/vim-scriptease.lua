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
    map("n", [[<C-q>.]], [[<CMD>Messages<CR>]], {"silent"}, "Messages in quickfix")
    map("n", [[<C-q>,]], [[<CMD>Messages<CR>]], {"silent"}, "Messages in quickfix")
end

return M
