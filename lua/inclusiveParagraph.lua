-- File: inclusiveParagraph
-- Author: iaso2h
-- Description: Jump to the very start or end of a paragraph(inclusively)
-- Version: 0.0.1
-- Last Modified: 2021/02/23
local vim = vim
local cmd = vim.cmd
local api = vim.api
local M = {}

function M.main(direction)
  local curLine = api.nvim_get_current_line()
  if direction == "up" then
    if curLine == "" then
      cmd "normal! {j"
    else
      local curLineNr = api.nvim_win_get_cursor(0)[1]
      if api.nvim_buf_get_lines(0, curLineNr - 2, curLineNr - 1, false) == "" then
        cmd "normal! k{j"
      else
        cmd "normal! {j"
      end
    end
  elseif direction == "down" then
    if curLine == "" then
      cmd "normal! }k"
    else
      local curLineNr = api.nvim_win_get_cursor(0)[1]
      if api.nvim_buf_get_lines(0, curLineNr, curLineNr + 1, false) == "" then
        cmd "normal! j}k"
      else
        cmd "normal! }k"
      end
    end
  end
end

return M

