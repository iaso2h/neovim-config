local api = vim.api
local cmd = vim.cmd
api.nvim_buf_set_keymap(0, "n", [[<cr>]], [[:.cc | copen<cr>]], {silent = true})
-- map <buffer> <silent> <cr> :.cc<cr>:copen<cr>

api.nvim_win_set_option(0, "number", true)
api.nvim_win_set_option(0, "relativenumber", false)
api.nvim_buf_set_option(0, "buflisted", false)
cmd [[resize 15]]

