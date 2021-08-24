vim.api.nvim_buf_set_keymap(0, "n", [[gK]],         [[:lua nlua.keyword_program()<cr>]], {silent = true})
vim.api.nvim_buf_set_keymap(0, "n", [[g==]],        [[<plug>(Luadev-RunLine)]],          {})
vim.api.nvim_buf_set_keymap(0, "v", [[g=]],         [[<plug>(Luadev-Run)]],              {})
vim.api.nvim_buf_set_keymap(0, "n", [[g=iw]],       [[<plug>(Luadev-RunWord)]],          {})
vim.api.nvim_buf_set_keymap(0, "i", [[<C-x><C-l>]], [[<plug>(Luadev-Complete)]],         {})

vim.api.nvim_buf_set_option(0, "textwidth", 78)

