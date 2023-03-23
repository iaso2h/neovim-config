-- File: redir
-- Author: iaso2h
-- Description: Redir Vim Ex-command output into a new created scratch buffer
-- Version: 0.0.3
-- Last Modified: 2023-2-24
local api = vim.api
local M   = {}


local dump = function(newBufNr, funcArgTbl)
    local output = funcArgTbl[1]
    ---@diagnostic disable-next-line: param-type-mismatch
    local lines = vim.split(output, "\n", {trimempty = true})
    api.nvim_buf_set_lines(newBufNr, 0, -1, false, lines)
    api.nvim_put({output}, "l", false, false)
    api.nvim_put({" "}, "l", true, false)
    api.nvim_put({"--------------------------------------------------------------------------------"}, "l", true, false)
end


--- Redir Vim Ex-command output into a new created scratch buffer
--- @param CMD string Value of Vim Ex-command
function M.catch(CMD)
    local output = api.nvim_exec(string.format([[%s]], CMD), true)
    require("buf").newSplit(dump, {output}, "", false, true)
end


return M

