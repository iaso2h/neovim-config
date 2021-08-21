local map  = require("util").map
local promptBufNr
local tbl = vim.tbl_keys(TelescopeGlobalState)
if tbl[1] == "number" then
    promptBufNr = tbl[1]
else
    promptBufNr = tbl[2]
end

vim.api.nvim_buf_set_keymap(promptBufNr, "n", [[<A-e>]], string.format([[:lua require("telescope.actions").preview_scrolling_up(%s)<cr>]],   promptBufNr), {})
vim.api.nvim_buf_set_keymap(promptBufNr, "n", [[<A-d>]], string.format([[:lua require("telescope.actions").preview_scrolling_down(%s)<cr>]], promptBufNr), {})
vim.api.nvim_buf_set_keymap(promptBufNr, "i", [[<A-e>]], string.format([[:lua require("telescope.actions").preview_scrolling_up(%s)<cr>]],   promptBufNr), {})
vim.api.nvim_buf_set_keymap(promptBufNr, "i", [[<A-d>]], string.format([[:lua require("telescope.actions").preview_scrolling_down(%s)<cr>]], promptBufNr), {})

vim.api.nvim_buf_set_keymap(promptBufNr, "n", [[<C-s>]], string.format([[:lua require("telescope.actions").select_horizontal(%s)<cr>]], promptBufNr), {})
vim.api.nvim_buf_set_keymap(promptBufNr, "i", [[<C-s>]], string.format([[:lua require("telescope.actions").select_horizontal(%s)<cr>]], promptBufNr), {})


vim.api.nvim_buf_set_keymap(promptBufNr, "n", [[g]], string.format([[:lua require("telescope.actions").move_to_top(%s)<cr>]],    promptBufNr), {})
vim.api.nvim_buf_set_keymap(promptBufNr, "n", [[z]], string.format([[:lua require("telescope.actions").move_to_middle(%s)<cr>]], promptBufNr), {})
vim.api.nvim_buf_set_keymap(promptBufNr, "n", [[G]], string.format([[:lua require("telescope.actions").move_to_bottom(%s)<cr>]], promptBufNr), {})

vim.api.nvim_buf_set_keymap(promptBufNr, "i", [[<C-l>]], string.format([[:lua require("telescope.actions").complete_tag(%s)<cr>]], promptBufNr), {})

vim.api.nvim_buf_set_keymap(promptBufNr, "i", [[<C-l>]], string.format([[:lua require("telescope.actions").complete_tag(%s)<cr>]], promptBufNr), {})

