-- Overwrite setting set by runtime/ftplugin/vim.vim
vim.opt.formatoptions = "cr/qn2mM1jpl"
if vim.g.loaded_scriptease then
    bmap(0, "n", [[<C-b>u]], [[:lua require("config.vim-scriptease").updateDebug]], {"silent"}, "Update vimscript")
    bmap(0, "n", [[<C-b>a]], [[:<C-u>Breakadd<CR>]],   {"silent"}, "Add breakpoint at cursorline")
    bmap(0, "n", [[<C-b>d]], [[:<C-u>Breakdel *<CR>]], {"silent"}, "Delete all breakpoints")
    bmap(0, "n", [[<C-b>l]], [[:<C-u>breaklist<CR>]],  {"silent"}, "Display breakpoints")
end

vim.opt.textwidth = 80
