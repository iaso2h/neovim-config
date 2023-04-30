-- TODO: bundle the quifix into a plugins?

-- Location list detection
if next(vim.fn.getloclist(0, {items = 0}).items) then
    vim.b._is_loc = true
end
if vim.b._is_loc then
    bmap(0, "n", [[<C-f>]], [[:Lfilter ]],          {"nowait"}, "Filter in quickfix")
    bmap(0, "n", [[%]],     [[<CMD>Lfilter %<CR>]], {"silent"}, "Filter other buffer in quickfix")
    bmap(0, "n", [[#]],     [[<CMD>Cfilter #<CR>]], {"silent"}, "Filter other buffer in quickfix")
else
    bmap(0, "n", [[<C-f>]], [[:Cfilter ]],          {"nowait"}, "Filter in quickfix")
    bmap(0, "n", [[%]],     [[<CMD>Cfilter %<CR>]], {"silent"}, "Filter other buffer in quickfix")
    bmap(0, "n", [[#]],     [[<CMD>Cfilter #<CR>]], {"silent"}, "Filter other buffer in quickfix")
end

bmap(0, "n", [[q]], [[<CMD>lua require("quickfix.highlight").clear();vim.cmd"q"<CR>]], {"silent"}, "Close quickfix")
bmap(0, "n", [[Q]], [[<CMD>lua require("quickfix.highlight").clear();vim.cmd"q"<CR>]], {"silent"}, "Close quickfix")
bmap(0, "n", [[<leader>H]], [[<CMD>lua require("quickfix.highlight").clear()<CR>]], {"silent"}, "Clear known quickfix highlight")

-- _G._qf_fallback_open is setup at '<stdpath("config")>/init.lua'
bmap(0, "n", [[<CR>]], [[:lua require("quickfix.cc")(false, 0)<CR>]], {"silent"}, "Preview current item in quickfix")
bmap(0, "n", [[o]],    [[:lua require("quickfix.cc")(true, 0)<CR>]],  {"silent"}, "Open current item in quickfix")
bmap(0, "n", [[<C-n>]], [[<CMD>lua require("quickfix.cc")(false, 1)<CR>]], {"noremap", "silent"}, "Next item on quickfix")
bmap(0, "n", [[<C-p>]], [[<CMD>lua require("quickfix.cc")(false, -1)<CR>]], {"noremap", "silent"}, "Previous item on quickfix")
-- Showing floating info
bmap(0, "n", [[gK]], [[<CMD>lua require("quickfix.info").hover(true)<CR>]],  {"silent"}, "Show quickfix item info")
bmap(0, "n", [[K]],  [[<CMD>lua require("quickfix.info").hover(false)<CR>]], {"silent"}, "Show quickfix item info")

bmap(0, "n", [[d]],  [[<Nop>]],                                             "which_key_ignore")
bmap(0, "x", [[d]],  [[:lua require("quickfix.undo").delete("v")<CR>]],     {"silent"}, "Delete selected quickfix items")
bmap(0, "n", [[dd]], [[<CMD>lua require("quickfix.undo").delete("n")<CR>]], {"silent"}, "Delete quickfix item under cursor")
bmap(0, "n", [[u]],  [[<CMD>lua require("quickfix.undo").recovery()<CR>]],  {"silent"}, "Recovery quickfix items")
bmap(0, "n", [[r]],  [[<CMD>lua require("quickfix.refresh").main()<CR>]],   {"silent"}, "Refresh quickfix items")
vim.api.nvim_win_set_option(0, "number", true)
vim.api.nvim_win_set_option(0, "relativenumber", false)
vim.api.nvim_win_set_option(0, "signcolumn", "no")
vim.api.nvim_win_set_option(0, "wrap", true)
vim.api.nvim_win_set_option(0, "foldcolumn", "0")
vim.api.nvim_buf_set_option(0, "buflisted", false)

vim.cmd [[setlocal winhighlight=Normal:PanelBackground,SignColumn:PanelBackground]]
vim.cmd [[resize 21]]
-- In case of cmdheight being changed
if vim.o.cmdheight ~= 2 then
    vim.o.cmdheight = 2
end

