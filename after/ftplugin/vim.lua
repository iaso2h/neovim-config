-- Overwrite setting set by runtime/ftplugin/vim.vim
vim.opt.formatoptions = _G._format_option
if vim.g.loaded_scriptease then
    bmap(0, "n", [[<C-b>u]], [[<CMD>lua require("plugins.vim-scriptease").updateDebug]], {"silent"}, "Update vimscript")
    bmap(0, "n", [[<C-b>a]], [[<CMD>Breakadd<CR>]],   {"silent"}, "Add breakpoint at cursorline")
    bmap(0, "n", [[<C-b>d]], [[<CMD>Breakdel *<CR>]], {"silent"}, "Delete all breakpoints")
    bmap(0, "n", [[<C-b>l]], [[<CMD>breaklist<CR>]],  {"silent"}, "Display breakpoints")
end

vim.opt.textwidth = 78
