local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

--- Echo search pattern and result index at the commandline
M.info = function()
    local searchDict = fn.searchcount()
    local result = string.format("[%s/%s]", searchDict.current, searchDict.total)
    local searchPat = fn.histget("search")
    local str = string.format('%s %s', searchPat, result)

    if searchDict.current == 1 or
            math.abs(searchDict.current - searchDict.total) == 0 then
        api.nvim_echo({{str, "CmpItemAbbrMatch"}}, false, {})
    else
        api.nvim_echo({{str}}, false, {})
    end
end



-- if not ok then vim.notify(msg, vim.log.levels.ERROR) end
-- if vim.startswith(msg, "E5108") then
    -- return
-- else
    -- success(ok, err)
-- end
M.cycleSearch = function(exCMD)
    local ok, msg = pcall(cmd, "noa norm! " .. exCMD)
    if not ok then
        if string.match(msg, "E486") then
            api.nvim_echo({{"Pattern not found: " .. fn.histget("search")}}, false, {})
            return
        else
            return vim.notify(msg, vim.log.levels.ERROR)
        end
    end

    cmd("norm! " .. "zv")
    -- cmd("norm! " .. "zzzv")
    M.info()
end


M.start = function(exCMD)
    local placeholder
    if exCMD == "/" then
        placeholder = "/\\v"
    elseif exCMD == "?" then
        placeholder = "?\\v"
    end

    local ok, input, msg
    ok, input = pcall(fn.input, "", placeholder)
    if not ok then
        msg = input
        if msg == "Keyboard interrupt" then
            return
        else
            vim.notify(msg, vim.log.levels.ERROR)
        end
    end

    ok, msg = pcall(cmd, input)
    if not ok then
        if vim.startswith(msg, "Vim:E486") then
            api.nvim_echo({{"Pattern not found: " .. input}}, false, {})
        else
            vim.notify(msg, vim.log.levels.ERROR)
        end
    else
        local searchDict = fn.searchcount()
        if searchDict.total ~= 0 and searchDict.current == 0 then
            cmd("norm! n")
        end
        cmd("norm! zv:" .. t[[<C-\>e<Esc>]])
        M.info()
    end
end

return M
