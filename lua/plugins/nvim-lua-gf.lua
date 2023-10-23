-- File: nvim-lua-gf.lua
-- Author: iaso2h
-- Description: Go to file on identifier
-- Version: 0.0.2
-- Last Modified: 2023-10-23

local u = require "nvim-treesitter.ts_utils"
local preWinId
local preBufNr
local preCursor
local cursorMovedChk = false


--- Fallback method of opening file
local fallback = function()
    if cursorMovedChk then
        vim.api.nvim_win_set_cursor(preWinId, preCursor)
    end
    vim.cmd [[norm! gf]]
end

local query = {
    lua = [[
(assignment_statement
  (_)
  (expression_list
    (function_call
      (identifier) @the-function-indentifier
      (#any-of? @the-function-indentifier "require" "dofile" "loadfile")
      (arguments
        (string
          (string_content) @the-string-content))))) @the-whole-assignment
]]
}

local handler = function(tbl) -- {{{
    if not tbl then return end

    -- TODO: maybe support cross file jumping for gf command?
    if (#tbl.items == 1 and vim.fn.bufnr(tbl.items[1].filename) == preBufNr) or
        (#tbl.items == 2 and tbl.items[1].filename == tbl.items[2].filename and vim.fn.bufnr(tbl.items[1].filename) == preBufNr) then

        -- Leave track at the jump history
        vim.cmd [[norm! m```]]

        local i = tbl.items[1]
        vim.api.nvim_win_set_cursor(preWinId, {i.lnum, i.col - 1})
        cursorMovedChk = true

        local util = require("util")
        local nodes = util.getQueryNodes(preBufNr, query.lua)
        local assignmentNodeIdx = -1
        for idx, node in ipairs(nodes) do
            if idx % 3 == 1 then
                local range = {node:range()} -- (0, 0) indexd
                if i.lnum - 1 >= range[1] and i.lnum - 1 <= range[3] then
                    assignmentNodeIdx = idx
                    break
                end
            end
        end
        if assignmentNodeIdx == -1 then return fallback() end

        local stringNode = nodes[assignmentNodeIdx + 2]
        u.goto_node(stringNode, false, true)
        vim.cmd [[norm! gf]]
    else
        fallback()
    end
end -- }}}


return function()
    -- Initialization
    preBufNr  = vim.api.nvim_get_current_buf()
    preWinId  = vim.api.nvim_get_current_win()
    preCursor = vim.api.nvim_win_get_cursor(preWinId)
    cursorMovedChk = false

    if not vim.bo.filetype == "lua" or
        not require("vim.treesitter.highlighter").active[preBufNr] then
        -- Doesn't support treesitter

        return fallback()
    end

    local node = u.get_node_at_cursor(preWinId)
    if not node then return fallback() end

    if node:type() == "identifier" then
        vim.lsp.buf.definition { on_list = handler }
    else
        return fallback()
    end
end
