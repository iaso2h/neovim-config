-- Location list detection
if next(vim.fn.getloclist(0, {items = 0}).items) then
    vim.b._is_local = true
end
if vim.b._is_local then
    bmap(0, "n", [[<C-f>]], [[:Lfilter ]],          {"nowait"}, "Filter in quickfix")
    bmap(0, "n", [[%]],     [[<CMD>Lfilter %<CR>]], {"silent"}, "Filter other buffer in quickfix")
    bmap(0, "n", [[#]],     [[<CMD>Cfilter #<CR>]], {"silent"}, "Filter other buffer in quickfix")
else
    bmap(0, "n", [[<C-f>]], [[:Cfilter ]],          {"nowait"}, "Filter in quickfix")
    bmap(0, "n", [[%]],     [[<CMD>Cfilter %<CR>]], {"silent"}, "Filter other buffer in quickfix")
    bmap(0, "n", [[#]],     [[<CMD>Cfilter #<CR>]], {"silent"}, "Filter other buffer in quickfix")
end

-- bmap(0, "n", [[q]], [[<CMD>lua require("quickfix.highlight").clear();vim.cmd"q"<CR>]], {"silent"}, "Close quickfix")
-- bmap(0, "n", [[Q]], [[<CMD>lua require("quickfix.highlight").clear();vim.cmd"q"<CR>]], {"silent"}, "Close quickfix")
bmap(0, "n", [[q]], [[<CMD>wincmd p | cclose<CR>]], {"silent"}, "Close quickfix")
bmap(0, "n", [[Q]], [[<CMD>wincmd p | cclose<CR>]], {"silent"}, "Close quickfix")
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
bmap(0, "x", [[d]],  [[:lua require("quickfix.modification").delete("v")<CR>]],     {"silent"}, "Delete selected quickfix items")
bmap(0, "n", [[dd]], [[<CMD>lua require("quickfix.modification").delete("n")<CR>]], {"silent"}, "Delete quickfix item under cursor")
bmap(0, "n", [[u]],  [[<CMD>lua require("quickfix.modification").recovery()<CR>]],  {"silent"}, "Recovery quickfix items")
bmap(0, "n", [[r]],  [[<CMD>lua require("quickfix.modification").refresh()<CR>]],   {"silent"}, "Refresh quickfix items")
vim.api.nvim_set_option_value("number", true, {win = 0})
vim.api.nvim_set_option_value("relativenumber", false, {win = 0})
vim.api.nvim_set_option_value("signcolumn", "no", {win = 0})
vim.api.nvim_set_option_value("cursorline", false, {win = 0})
vim.api.nvim_set_option_value("wrap", true, {win = 0})
vim.api.nvim_set_option_value("foldcolumn", "0", {win = 0})
vim.api.nvim_set_option_value("buflisted", false, {buf = 0})

vim.cmd [[setlocal winhighlight=Normal:PanelBackground,SignColumn:PanelBackground]]
if vim.api.nvim_list_uis()[1].height > 42 and _G._os_uname.machine ~= "aarch64" then
    vim.cmd [[resize 21]]
end
-- In case of cmdheight being changed
if vim.o.cmdheight ~= 2 then
    vim.o.cmdheight = 2
end

