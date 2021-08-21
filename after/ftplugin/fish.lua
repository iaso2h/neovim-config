local api = vim.api
local cmd = vim.cmd
cmd [[compiler fish]]
api.nvim_buf_set_option(0, "textwidth", 78)
api.nvim_buf_set_option(0, "foldmethod", "expr")
api.nvim_buf_set_option(0, "foldexpr", "EnhanceFoldExpr")

