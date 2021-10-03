local api = vim.api
local cmd = vim.cmd

api.nvim_buf_set_keymap(0, "n", [[<cr>]],  [[:<C-u>.cc | exe "norm! zzzv" | copen<cr>]], {silent = true})
api.nvim_buf_set_keymap(0, "n", [[<C-f>]], [[:<C-u>Cfilter]], {nowait = true})
api.nvim_buf_set_keymap(0, "n", [[%]],     [[:<C-u>Cfilter %<CR>]], {})

api.nvim_win_set_option(0, "number", true)
api.nvim_win_set_option(0, "relativenumber", false)
api.nvim_buf_set_option(0, "buflisted", false)
cmd [[resize 21]]

