local u = require "nvim-treesitter.ts_utils"
local preWinId
local preBufNr
local preCursor


local fallback = function()
    vim.api.nvim_win_set_cursor(preWinId, preCursor)
    vim.cmd [[norm! gf]]
end


local handler = function(tbl) -- {{{
    if not tbl then return end

    local i = tbl.items[1]
    -- TODO: maybe support cross file jumping for gf command?
    if (#tbl.items == 1 and vim.fn.bufnr(i.filename) == preBufNr) or
        (#tbl.items == 2 and vim.fn.bufnr(i.filename) == preBufNr and
        i.filename == tbl.items[2].filename) then

        vim.cmd [[norm! m```]]
        vim.api.nvim_win_set_cursor(preWinId, {i.lnum, i.col - 1})
        local node = u.get_node_at_cursor(preWinId)
        local nodeLineNr = node:range()

        local lastNode = node
        local parentNode
        local matchFoundTick = false
        repeat
            parentNode = lastNode:parent()
            if parentNode then
                if parentNode:range() ~= nodeLineNr then
                    -- Not at the same line
                    break
                end
                if parentNode:type() == "variable_list" then
                    matchFoundTick = true
                    break
                end

                -- Before entering next iteration
                lastNode = parentNode
            end
        until not parentNode
        if not matchFoundTick then return fallback() end
        local siblingNode = parentNode:next_named_sibling()
        if not siblingNode then return fallback() end
        if siblingNode:type() ~= "expression_list" then return fallback() end

        local getStringNode = function()
            return siblingNode:child():child():next_named_sibling():child()
        end
        local ok, msgOrVal = pcall(getStringNode)
        if ok then
            local stringNode = msgOrVal
            if not stringNode or stringNode:type() ~= "string" then return fallback() end
            u.goto_node(stringNode, false, true)
            vim.cmd [[norm! gf]]
            -- HACK: not working
            -- vim.defer_fn(function()
            --     vim.api.nvim_buf_call(preBufNr, function()
            --             vim.cmd [[norm! ``]]
            --         end)
            -- end, 0)
        else
            fallback()
        end
    end
end -- }}}


return function ()
    if not vim.bo.filetype == "lua" or
        not package.loaded["nvim-treesitter.parsers"] or
        not require("nvim-treesitter.parsers").has_parser() then

        return vim.cmd [[norm! gf]]
    end

    preWinId  = vim.api.nvim_get_current_win()
    preBufNr  = vim.api.nvim_get_current_buf()
    preCursor = vim.api.nvim_win_get_cursor(preWinId)
    local node = u.get_node_at_cursor(vim.api.nvim_get_current_win())
    if node:type() == "identifier" then
        vim.lsp.buf.definition { on_list = handler }
    end
end
