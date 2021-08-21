local api = vim.api
api.nvim_buf_set_keymap(0, "n", [[gK]],         [[:lua nlua.keyword_program()<cr>]], {silent = true})
api.nvim_buf_set_keymap(0, "n", [[g==]],        [[<plug>(Luadev-RunLine]],           {})
api.nvim_buf_set_keymap(0, "v", [[g=]],         [[<plug>(Luadev-Run]],               {})
api.nvim_buf_set_keymap(0, "n", [[g=iw]],       [[<plug>(Luadev-RunWord]],           {})
api.nvim_buf_set_keymap(0, "i", [[<C-x><C-l>]], [[<plug>(Luadev-Complete]],          {})

api.nvim_buf_set_option(0, "textwidth", 78)

