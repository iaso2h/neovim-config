-- Overwrite setting set by runtime/ftplugin/lua.vim
vim.opt.formatoptions = "cr/qn2mM1jpl"

bmap(0, "n", [[gK]],         [[<CMD>lua nlua.keyword_program()<cr>]], {"silent"}, "Lookup in Neovim help")
bmap(0, "n", [[g==]],        [[<plug>(Luadev-RunLine)]],  "Luadev run line")
bmap(0, "v", [[g=]],         [[<plug>(Luadev-Run)]],      "Luadev runline")
bmap(0, "n", [[g=iw]],       [[<plug>(Luadev-RunWord)]],  "Luadev run word")
bmap(0, "i", [[<C-x><C-l>]], [[<plug>(Luadev-Complete)]], "Luadev complete")

vim.opt.textwidth = 80
