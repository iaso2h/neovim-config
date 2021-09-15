-- File: redir
-- Author: iaso2h
-- Description: Redir Vim Ex-command output into a new created scratch buffer
-- Version: 0.0.2
-- Last Modified: 2021/03/29
local api = vim.api
local M   = {}

----
-- Function: M.redirCatch : Redir Vim Ex-command output into a new created scratch buffer
--
-- @param CMD: String value of Vim Ex-command
----
function M.catch(CMD)
    local output = api.nvim_exec(string.format([[%s]], CMD), true)
    require("util").newSplit(M.dump, {output}, "", false, true)
end

function M.dump(newBufNr, funcArgTbl)
    local output = funcArgTbl[1]
    local lines = vim.split(output, "\n", true)
    local collapsedLines = string.format([["%s"\n--------------------------------------------------------------------------------]], output)
    api.nvim_buf_set_lines(newBufNr, 0, -1, false, lines)
    api.nvim_put({collapsedLines}, "l", false, false)
end

return M

