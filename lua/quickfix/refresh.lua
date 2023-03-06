local fn  = vim.fn
local api = vim.api
local M   = {}


M.main = function ()
-- {
  -- bufnr = 0,
  -- col = 0,
  -- end_col = 0,
  -- end_lnum = 0,
  -- lnum = 0,
  -- module = "",
  -- nr = 0,
  -- pattern = "",
  -- text = "    no file 'C:\\tools\\neovim\\nvim-win64\\bin\\lua\\e.lua'",
  -- type = "",
  -- valid = 0,
  -- vcol = 0
-- }
-- {
  -- bufnr = 36,
  -- col = 4,
  -- end_col = 0,
  -- end_lnum = 0,
  -- lnum = 59,
  -- module = "",
  -- nr = 0,
  -- pattern = "",
  -- text = "NOTE: http://olivinelabs.com/busted/",
  -- type = "",
  -- valid = 1,
  -- vcol = 0
-- }

    local qfItems = fn.getqflist()
    for idx, item in ipairs(qfItems) do
        if item.valid ~= 0 and item.bufnr ~= 0 and
            api.nvim_buf_is_valid(item.bufnr) and
            api.nvim_buf_get_option(item.bufnr, "buflisted")
            then
            -- Only update listed buffer because otherwise
            -- vim.api.nvim_buf_get_lines can't get content from unlisted buffer
            qfItems[idx].text = api.nvim_buf_get_lines(item.bufnr, item.lnum - 1, item.lnum, false)[1]
        end
    end
    fn.setqflist({}, " ", {items = qfItems})
end

return M
