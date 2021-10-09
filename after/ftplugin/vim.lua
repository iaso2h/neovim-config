vim.opt.formatoptions = "nmM12pcjlq"
if vim.g.loaded_scriptease then
    local bufNr = vim.api.nvim_get_current_buf()

    bmap(bufNr, "n", [[<C-b>u]], [[:lua require("config.vim-scriptease").updateDebug]], {"silent"}, "Update vimscript")
    bmap(bufNr, "n", [[<C-b>a]], [[:<C-u>Breakadd<CR>]],   {"silent"}, "Add breakpoint at cursorline")
    bmap(bufNr, "n", [[<C-b>d]], [[:<C-u>Breakdel *<CR>]], {"silent"}, "Delete all breakpoints")
    bmap(bufNr, "n", [[<C-b>l]], [[:<C-u>breaklist<CR>]], {"silent"}, "Display breakpoints")
end
