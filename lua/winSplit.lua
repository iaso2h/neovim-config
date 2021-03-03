local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}
function M.smartSplit(bufType)
    if vim.bo.buftype == bufType then
        local gui = api.nvim_list_uis()[1]
        if not gui.width then return end
        if 232 == gui["width"] then
            cmd [[wincmd L]]
        else
            cmd [[wincmd J]]
        end
    end
end

return M

