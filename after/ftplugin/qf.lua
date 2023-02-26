local api = vim.api


bmap(0, "n", [[<cr>]],  [[:lua require("quickfix").cc(false, true)<CR>]], {"silent"}, "Preview current item in quickfix")
bmap(0, "n", [[o]],     [[:lua require("quickfix").cc(true, true)<CR>]],  {"silent"}, "Open current item in quickfix")
bmap(0, "n", [[<C-n>]], [[j<CMD>lua require("quickfix").cc(false, true)<CR>]],  {"noremap", "silent"}, "Next item on quickfix")
bmap(0, "n", [[<C-p>]], [[k<CMD>lua require("quickfix").cc(false, true)<CR>]],  {"noremap", "silent"}, "Previous item on quickfix")

bmap(0, "n", [[<C-f>]], [[:Cfilter ]],                               {"nowait"}, "Filter in quickfix")
bmap(0, "n", [[%]],     [[<CMD>Cfilter %<CR>]],                      {"silent"}, "Filter other buffer in quickfix")
bmap(0, "n", [[#]],     [[<CMD>Cfilter #<CR>]],                      {"silent"}, "Filter other buffer in quickfix")

bmap(0, "n", [[q]],     [[<CMD>cclose<CR>]],                         {"silent"}, "Close quickfix")
bmap(0, "n", [[Q]],     [[<CMD>cclose<CR>]],                         {"silent"}, "Close quickfix")

bmap(0, "n", [[d]], [[<Nop>]], "which_key_ignore")
bmap(0, "x", [[d]],  [[:lua require("quickfix").delete("v")<CR>]],    {"silent"}, "Delete selected quickfix items")
bmap(0, "n", [[dd]], [[:lua require("quickfix").delete("n")<CR>]],    {"silent"}, "Delete quickfix item")
bmap(0, "n", [[u]],  [[<CMD>lua require("quickfix").recovery()<CR>]], {"silent"}, "Recovery quickfix items")

bmap(0, "n", [[K]],  [[<CMD>lua require("quickfix").info()<CR>]],   {"silent"}, "Show quickfix item info")

api.nvim_win_set_option(0, "number", true)
api.nvim_win_set_option(0, "relativenumber", false)
api.nvim_win_set_option(0, "signcolumn", "no")
api.nvim_win_set_option(0, "foldcolumn", "0")
-- api.nvim_buf_set_option(0, "buflisted", false)

api.nvim_create_autocmd({
    "CursorMoved",
    "CmdwinEnter",
    "CmdlineLeave",
    -- Neovim will enter relative buffer temporarily, so "BufLeave" will allways
    -- trigger then destroy the brand new float window and buffer within
    "WinLeave",
    "TabLeave",
    "ModeChanged",
}, {
    buffer = vim.api.nvim_get_current_buf(),
    desc = "Close floating win inside quickfix when cursor moves",
    callback = require("quickfix").closeFloatWin,
})

vim.cmd [[setlocal winhighlight=Normal:PanelBackground,SignColumn:PanelBackground]]
vim.cmd [[resize 21]]
