local api = vim.api
local cmd = vim.cmd

api.nvim_buf_set_keymap(0, "n", [[<cr>]], [[:<C-u>.cc | exe "norm! zzzv" | copen<CR>]], {silent = true})
api.nvim_buf_set_keymap(0, "n", [[o]],    [[:<C-u>.cc | exe "norm! zzzv"<CR>]],         {silent = true})
api.nvim_buf_set_keymap(0, "n", [[<C-f>]], [[:<C-u>Cfilter ]],      {nowait = true})
api.nvim_buf_set_keymap(0, "n", [[%]],     [[:<C-u>Cfilter %<CR>]], {silent = true})
api.nvim_buf_set_keymap(0, "n", [[#]],     [[:<C-u>Cfilter #<CR>]], {silent = true})
api.nvim_buf_set_keymap(0, "n", [[<C-n>]], [[:cnext<CR>zzzv:lua require("buffer").quickfixToggle()<CR>]],     {silent = true})
api.nvim_buf_set_keymap(0, "n", [[<C-p>]], [[:cprevious<CR>zzzv:lua require("buffer").quickfixToggle()<CR>]], {silent = true})
api.nvim_win_set_option(0, "number", true)
api.nvim_win_set_option(0, "relativenumber", false)
api.nvim_buf_set_option(0, "buflisted", false)
cmd [[setlocal winhighlight=Normal:PanelBackground,SignColumn:PanelBackground]]
cmd [[resize 21]]
if QuickfixSwitchWinID then
    vim.api.nvim_set_current_win(QuickfixSwitchWinID)
    QuickfixSwitchWinID = nil
end

