local fn  = vim.fn
local cmd = vim.cmd
local M   = {}

M.main = function(listName, direction)
    if listName == "changelist" then
        if direction == 1 then
            pcall(cmd, [[norm! mz`zg,]])
        elseif direction == -1 then
            pcall(cmd, [[norm! mz`zg;]])
        end
    elseif listName == "jumplist" then
        if direction == 1 then
            pcall(cmd, [[norm! <C-i>]])
        elseif direction == -1 then
            pcall(cmd, [[norm! <C-o>]])
        end
    end

    -- Prevent hop on a fold-closed line
    if fn.foldclosed('.') ~= -1 then
        cmd [[norm! zAzz]]
    else
        cmd [[norm! zz]]
    end
end

return M

