-- Overwrite setting set by runtime/ftplugin/lua.vim
vim.opt.formatoptions = _G._Myformatoptions

bmap(0, "n", [[gK]],         [[<CMD>lua require("luaKeywordHelp")()<cr>]], {"silent"}, "Lookup in Neovim help")
bmap(0, "n", [[g==]],        [[<plug>(Luadev-RunLine)]],  "Luadev run line")
bmap(0, "x", [[g=]],         [[<plug>(Luadev-Run)]],      "Luadev runline")
bmap(0, "n", [[g=iw]],       [[<plug>(Luadev-RunWord)]],  "Luadev run word")
bmap(0, "i", [[<C-x><C-l>]], [[<plug>(Luadev-Complete)]], "Luadev complete")

---@diagnostic disable: assign-type-mismatch
vim.opt_local.suffixesadd:prepend ".lua"
vim.opt_local.suffixesadd:prepend "init.lua"
for _, path in pairs(vim.api.nvim_list_runtime_paths()) do
    vim.opt_local.path:append(path .. "/lua")
end
vim.opt.textwidth = 80
