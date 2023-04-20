-- File: jumplist
-- Author: iaso2h
-- Description: Enhance <C-i>/<C-o>
-- Version: 0.0.2
-- Last Modified: 2023-4-21
local jumpsDummy = { -- {{{
    "   1    55   15 Print(jumps)", '   2    54   36 local jumps = getJumps(isNewer, "local")',
    "   3     6   11 -- local filterJumps = function(jumps)", "   4    45    0 ",
    "   5    14   19 local getJumps = function(isNewer, filter)", "   6    56   15 if no t next(jumps) then",
    "   7    11   25 --perform a local jump or buffer jump",
    "   8    10    2 --- Get the filtered out jumplist so that is ready to filter out and decide to",
    '   9    54   23 local jumps = getJumps(isNewer, "local")', "  10    25   16 bre ak",
    "  12    39    0 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\plugin\\EnhancedJumps.vim",
    "  18   274   64 lua/core/mappings.lua", "  19   271   82 lua/core/mappings.lua",
    "  20   274    9 lua/core/mappings.lua", "  21    14    7 local getJu mps = function(isNewer, filter)",
    "  22    10   22 --- Get the filtered out jumplist so that is ready to filter out and decide to",
    "  23    14    2 local getJumps = function(isNewer, filter)",
    "  24    35    0 for i = currentIdx + 1, #jumpsTbl, 1 do", " 25   274    0 lua/core/mappings.lua",
    "  26    58    0 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps\\Common.vim",
    "  27    23    0 lua/buf/action/redir.lua",
    "  28    39    0 ~\\AppData\\Local\\nvim-data\\lazy\\vim-Enhance dJumps\\plugin\\EnhancedJumps.vim",
    "  29     5   26 lua/yankPut/init.lua", "  30     1    0 ", "  32   273   63 lua/core/mappings.lua",
    "  33   274   57 lua/core/mappings.lua", "  36    35   14 for i = currentIdx + 1, #jumpsTbl, 1 do",
    "  37    61    0 ", "  38     1    2 local M = {", "  39    49    2 end",
    "  40    14    7 local getJumps = function(isNewer, filter)", "  41    34    7 if isNewer then",
    "  42    14    7 local getJumps = function(isNewer, filter)", "  43    43    2 end",
    "  44     1    2 lo cal M = {", "  45    49    2 end",
    "  46    14    7 local getJumps = function(isNewer, filter)", "  47    34   16 if isNewer then",
    "  48   408   11 lua/yankPut/init.lua", "  49    34   16 if isNewer then", "  50   116   78 lua\\util\\init.lua",
    "  51    3 4   16 if isNewer then",
    "  52    47   10 -- let l:jumps = s:FilterJumps(EnhancedJumps#Common#SliceJumpsInDirection(EnhancedJumps#Common#GetJumps('jumps'), a:isNewer), a:filter, a:isNewer)",
    "  53    14    7 local getJumps = function(isNewer, filter)", " 54    40    9 for i = currentIdx - 1, 2, -1 do",
    "  55    34    9 if isNewer then", "  56    14    0 local getJumps = function(isNewer, filter)",
    "  57    43    0 end", "  58   408   11 lua/yankPut/init.lua", "  59    18   18 lua/yankPut/init.lua",
    "  60 39    0 -- Exclude the header, which is i == 1", "  61     5    0 lua\\config\\nvim-telescope.lua",
    "  62    43    6 end", "  63     1    7 local M = {", "  64    62    7 return M", "  65     1    7 local M = {",
    "  66    39    7 -- Exclude the header, w hich is i == 1", "  67    28    0 if currentIdx == 0 then",
    "  68     1    6 local M = {", "  69    62    6 return M", "  70     1    6 local M = {",
    "  71    30    6 return jumpsSliced",
    "  72    72    0 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJum ps\\autoload\\EnhancedJumps\\Common.vim",
    "  73    26    8 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps\\Common.vim",
    "  74    54   27 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps\\Common. vim",
    "  75    21   12 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps\\Common.vim",
    "  76    54   31 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps\\Common.vim",
    "  77    20   10 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps\\Common.vim",
    "  78    27    0 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps.vim",
    "  79     1    0 AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autol oad\\EnhancedJumps.vim",
    "  80   275   95 lua/core/mappings.lua", "  81   274   20 lua/core/mappings.lua",
    "  82   273   11 lua/core/mappings.lua", "  83     1   14 lua/core/mappings.lua",
    "  84   477   29 lua/core/mappings.lua", "  85   471   27 lua/core/ mappings.lua",
    "  86   470   27 lua/core/mappings.lua", "  87   375   23 lua/core/mappings.lua",
    "  88   374   23 lua/core/mappings.lua", "  89   373   23 lua/core/mappings.lua",
    "  90   372   23 lua/core/mappings.lua", "  91   362   32 lua/core/mappings.l ua",
    "  92   306    0 lua/core/mappings.lua", "  94   455    0 lua/core/plugins.lua",
    "  95    37    2 lua/exchange/init.lua"
} -- }}}


local exceedJump = function(isNewer, filter)
    local filterStr = filter .. "jumplist"
    if isNewer then
        vim.notify("At the newest of " .. filterStr, vim.log.levels.INFO)
    else
        vim.notify("At the oldest of " .. filterStr, vim.log.levels.INFO)
    end
end


---@param jumps table
---@param filter string "local" or "buffer"
local filterJumps = function(jumps, filter)
    -- jumps = M.jumpsDummy

    -- jumps = {"  95    37    2 [nvim-lua]"}
    local jumpsParsed = vim.tbl_map(function(j)
        local parseResult = {string.match(j, "^>?%s*(%d+)%s+(%d+)%s+(%d+)%s+(.*)$")}
        return {
            count = parseResult[1],
            lnum  = parseResult[2],
            col   = parseResult[3],
            text  = parseResult[4],
        }
    end, jumps)

    local bufListed = vim.tbl_filter(function(bufNr)
        return vim.api.nvim_buf_get_option(bufNr, "buflisted")
    end, vim.api.nvim_list_bufs())
    local bufNameListed = vim.tbl_map(function(bufNr)
        return vim.fn.bufname(bufNr)
    end, bufListed)

    local isLocal = function(j)
        -- TODO: use highlight group to check syntax?
        if j.text == "" then
            -- Check wether the current buffer text is empty
            local ok, valOrMsg = pcall(vim.api.nvim_buf_get_text, 0, j.lnum - 1, j.col- 1, j.lnum - 1, j.col, {})
            if not ok then
                return false -- empty buffer
            else
                if valOrMsg == "" then
                    return true -- empty line
                else
                    return false -- empty buffer
                end
            end
        elseif string.sub(j.text, 1, 1) == "~" then
            -- Expand the filename when the first character is ~
            if vim.loop.fs_stat(vim.fn.expand(j.text)) then
                return false
            else
                return true
            end
        else
            -- Check whether jump text is contained in the :ls output
            if vim.tbl_contains(bufNameListed, j.text) then
                return false
            end

            -- Concatenate the working directory string with the jump text and
            -- check if that file exist since the most files are under the
            -- same working directory
            local cwd = vim.loop.cwd()
            if vim.loop.fs_stat(string.format("%s/%s", cwd, j.text)) then
                return false
            else
                if vim.loop.fs_stat(j.text) then
                    return false
                else
                    return true
                end
            end
        end
    end
    if filter == "local" then
        return vim.tbl_filter(isLocal,jumpsParsed)
    elseif filter == "buffer" then
        return vim.tbl_filter(function(j) return not isLocal(j) end,jumpsParsed)
    end
   	-- return filter(a:jumps, 'EnhancedJumps#Common#IsJumpInCurrentBuffer(EnhancedJumps#Common#ParseJumpLine(v:val))')
end


--- Get the filtered out jumplist so that is ready to filter out and decide to
--perform a local jump or buffer jump
---@param isNewer boolean
local getJumps = function(isNewer)
    local jumpsStrOutput = vim.api.nvim_exec2(string.format([[%s]], "jumps"), {output = true}).output
    local jumpsTbl       = vim.split(jumpsStrOutput, "\n", {trimempty = true})
    local jumpsSliced    = {}

    -- Get current index in jumplist
    local currentIdx = 0
    for i = #jumpsTbl, 2, -1 do
        local jump = jumpsTbl[i]
        if string.sub(jump, 1, 1) == ">" then
            currentIdx = i
            break
        end
    end
    if currentIdx == 0 then
        vim.notify("Cannot find current index in jumplist", vim.log.levels.ERROR)
        return jumpsSliced
    end

    -- Get the sliced jumps
    if isNewer then
        for i = currentIdx + 1, #jumpsTbl, 1 do
            jumpsSliced[#jumpsSliced+1] = jumpsTbl[i]
        end
    else
        -- Exclude the header, which is i == 1
        for i = currentIdx - 1, 2, -1 do
            jumpsSliced[#jumpsSliced+1] = jumpsTbl[i]
        end
    end

    return jumpsSliced
end


return function(isNewer, filter)
    local jumpsSliced = getJumps(isNewer)
    if not next(jumpsSliced) then
        return exceedJump(isNewer, filter)
    end

    local jumpFilter  = filterJumps(jumpsSliced, filter)
    if not next(jumpFilter) then
        return exceedJump(isNewer, filter)
    end

    local count = vim.v.count1
    count = count > #jumpFilter and #jumpFilter or count
    local targetJump = jumpFilter[count]

    local exCMD = isNewer and t"<C-i>" or t"<C-o>"
    if filter == "local" then
        local cursorPos = vim.api.nvim_win_get_cursor(0)
        -- Avoid jumping in the same line
        if targetJump.lnum == cursorPos[1] then
            if vim.v.count1 < #jumpFilter then
                count = vim.v.count1 + 1
                targetJump = jumpFilter[count]
            else -- vim.v.count1 == #jumpFilter
                -- Do nothing
                return
            end
        end
    end
    vim.cmd("normal! " .. targetJump.count .. exCMD)
    -- TODO:echo the next jump
end
