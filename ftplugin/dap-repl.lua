vim.cmd[[noa lua require('dap.ext.autocompl').attach()<CR>]]
vim.api.nvim_buf_set_keymap(0, "n", [[<C-Space>]], [[<C-x><C-o>]], {noremap = true})
