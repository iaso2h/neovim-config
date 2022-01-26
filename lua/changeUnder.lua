local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {
    pat = nil,
}


--- Change the whole word under cursor, highlight it with search highlight
--- @param ncmd string The command to be performed in normal mode(no remap mode)
--- @param direction integer 1 indicates searching forward, 0 indicates searching
--- backward
--- @param plugMap string The plug mapping to be binded when press dot-repeat key
M.init = function(ncmd, direction, plugMap)
    -- local cycleCMD = direction == 1 and "n" or "N"
    local cycleCMD = "n"
    local searchCMD = direction == 1 and "g*" or "g#"
    if vim.v.hlsearch == 1 then
        local curLine = api.nvim_get_current_line()
        if #curLine == 0 then
            return cmd(string.format("norm! %s%s", cycleCMD, ncmd))
        end
        -- col and result are both 0-indexed
        local col = api.nvim_win_get_cursor(0)[2]
        local result = require("util").matchAllStrPos(curLine, M.pat)
        if not next(result) then
            cmd(string.format("norm %s%s", cycleCMD, ncmd))
        else
            local insideChk = false
            for _, t in ipairs(result) do
                if col >= t[2] and col < t[3] then
                    insideChk = true
                    break
                end
            end
            if insideChk then
                cmd(string.format("norm %s", ncmd))
            else
                cmd(string.format("norm %s%s", cycleCMD, ncmd))
            end
        end
    else
        M.pat = fn.histget("search")
        cmd(string.format("norm %s%s", searchCMD, ncmd))
    end

    fn["repeat#set"](t(plugMap))
end

return M
