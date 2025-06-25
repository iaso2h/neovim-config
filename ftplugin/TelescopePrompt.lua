 -- TODO: supoort multiple actions

local promptBufNr
local tbl = vim.tbl_keys(TelescopeGlobalState)

if type(tbl[1]) == "number" then
    promptBufNr = tbl[1]
else
    promptBufNr = tbl[2]
end

if not vim.api.nvim_buf_is_valid(promptBufNr) then return end

-- TODO: Open in floating win or newtab
vim.api.nvim_buf_set_keymap(
    promptBufNr,
    "n",
    [[?]],
    [[:<C-u>Redir lua Print(require("telescope.actions.state").get_selected_entry())<CR>]],
    {silent = true, noremap = true}
)
