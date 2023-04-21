-- File: jumplist
-- Author: iaso2h
-- Description: Enhance <C-i>/<C-o>
-- Version: 0.0.5
-- Last Modified: 2023-4-22

local defaultOpts  = {
    filterMethod = "lua_match",
    checkCursorRedundancy = true
}

local M = {
    opts = defaultOpts
}


-- local jumpsDummy = { -- {{{
--     "   1    55   15 Print(jumps)", '   2    54   36 local jumps = getJumps(isNewer, "local")',
--     "   3     6   11 -- local filterJumps = function(jumps)", "   4    45    0 ",
--     "   5    14   19 local getJumps = function(isNewer, filter)", "   6    56   15 if no t next(jumps) then",
--     "   7    11   25 --perform a local jump or buffer jump",
--     "   8    10    2 --- Get the filtered out jumplist so that is ready to filter out and decide to",
--     '   9    54   23 local jumps = getJumps(isNewer, "local")', "  10    25   16 bre ak",
--     "  12    39    0 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\plugin\\EnhancedJumps.vim",
--     "  18   274   64 lua/core/mappings.lua", "  19   271   82 lua/core/mappings.lua",
--     "  20   274    9 lua/core/mappings.lua", "  21    14    7 local getJu mps = function(isNewer, filter)",
--     "  22    10   22 --- Get the filtered out jumplist so that is ready to filter out and decide to",
--     "  23    14    2 local getJumps = function(isNewer, filter)",
--     "  24    35    0 for i = currentIdx + 1, #jumpsTbl, 1 do", " 25   274    0 lua/core/mappings.lua",
--     "  26    58    0 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps\\Common.vim",
--     "  27    23    0 lua/buf/action/redir.lua",
--     "  28    39    0 ~\\AppData\\Local\\nvim-data\\lazy\\vim-Enhance dJumps\\plugin\\EnhancedJumps.vim",
--     "  29     5   26 lua/yankPut/init.lua", "  30     1    0 ", "  32   273   63 lua/core/mappings.lua",
--     "  33   274   57 lua/core/mappings.lua", "  36    35   14 for i = currentIdx + 1, #jumpsTbl, 1 do",
--     "  37    61    0 ", "  38     1    2 local M = {", "  39    49    2 end",
--     "  40    14    7 local getJumps = function(isNewer, filter)", "  41    34    7 if isNewer then",
--     "  42    14    7 local getJumps = function(isNewer, filter)", "  43    43    2 end",
--     "  44     1    2 lo cal M = {", "  45    49    2 end",
--     "  46    14    7 local getJumps = function(isNewer, filter)", "  47    34   16 if isNewer then",
--     "  48   408   11 lua/yankPut/init.lua", "  49    34   16 if isNewer then", "  50   116   78 lua\\util\\init.lua",
--     "  51    3 4   16 if isNewer then",
--     "  52    47   10 -- let l:jumps = s:FilterJumps(EnhancedJumps#Common#SliceJumpsInDirection(EnhancedJumps#Common#GetJumps('jumps'), a:isNewer), a:filter, a:isNewer)",
--     "  53    14    7 local getJumps = function(isNewer, filter)", " 54    40    9 for i = currentIdx - 1, 2, -1 do",
--     "  55    34    9 if isNewer then", "  56    14    0 local getJumps = function(isNewer, filter)",
--     "  57    43    0 end", "  58   408   11 lua/yankPut/init.lua", "  59    18   18 lua/yankPut/init.lua",
--     "  60 39    0 -- Exclude the header, which is i == 1", "  61     5    0 lua\\config\\nvim-telescope.lua",
--     "  62    43    6 end", "  63     1    7 local M = {", "  64    62    7 return M", "  65     1    7 local M = {",
--     "  66    39    7 -- Exclude the header, w hich is i == 1", "  67    28    0 if currentIdx == 0 then",
--     "  68     1    6 local M = {", "  69    62    6 return M", "  70     1    6 local M = {",
--     "  71    30    6 return jumpsSliced",
--     "  72    72    0 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJum ps\\autoload\\EnhancedJumps\\Common.vim",
--     "  73    26    8 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps\\Common.vim",
--     "  74    54   27 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps\\Common. vim",
--     "  75    21   12 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps\\Common.vim",
--     "  76    54   31 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps\\Common.vim",
--     "  77    20   10 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps\\Common.vim",
--     "  78    27    0 ~\\AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autoload\\EnhancedJumps.vim",
--     "  79     1    0 AppData\\Local\\nvim-data\\lazy\\vim-EnhancedJumps\\autol oad\\EnhancedJumps.vim",
--     "  80   275   95 lua/core/mappings.lua", "  81   274   20 lua/core/mappings.lua",
--     "  82   273   11 lua/core/mappings.lua", "  83     1   14 lua/core/mappings.lua",
--     "  84   477   29 lua/core/mappings.lua", "  85   471   27 lua/core/ mappings.lua",
--     "  86   470   27 lua/core/mappings.lua", "  87   375   23 lua/core/mappings.lua",
--     "  88   374   23 lua/core/mappings.lua", "  89   373   23 lua/core/mappings.lua",
--     "  90   372   23 lua/core/mappings.lua", "  91   362   32 lua/core/mappings.l ua",
--     "  92   306    0 lua/core/mappings.lua", "  94   455    0 lua/core/plugins.lua",
--     "  95    37    2 lua/exchange/init.lua"
-- } -- }}}


local exceedJump = function(isNewer, filter)
    local filterStr = filter .. "jumplist"
    if isNewer then
        vim.notify("At the newest of " .. filterStr, vim.log.levels.INFO)
    else
        vim.notify("At the oldest of " .. filterStr, vim.log.levels.INFO)
    end
end


---@param bufNr number
---@param jumps table
---@param filter string "local"|"buffer"
---@param cursorPos table (1, 0) based. If target and cursor are on the same line in local filter, that target jump will be discard. Set it to empty table to turn off this behavior
local filterJumps = function(bufNr, jumps, filter, cursorPos)
    -- jumps = M.jumpsDummy

    local jumpsParsed = vim.tbl_map(function(j)
        local parseResult = {string.match(j, "^>?%s*(%d+)%s+(%d+)%s+(%d+)%s+(.*)$")}
        return {
            count = parseResult[1],
            lnum  = tonumber(parseResult[2]),
            col   = tonumber(parseResult[3]),
            text  = parseResult[4],
        }
    end, jumps)

    local isLocal
    if M.opts.filterMethod == "fs_stat" then
        -- NOTE: This is slow and will be deprecated
        local bufListed = vim.tbl_filter(function(b)
            return vim.api.nvim_buf_get_option(b, "buflisted")
        end, vim.api.nvim_list_bufs())
        local bufNameListed = vim.tbl_map(function(b)
            return vim.fn.bufname(b)
        end, bufListed)

        isLocal = function(j)
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
            elseif j.text == "-invalid-" then
                return true
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
    elseif M.opts.filterMethod == "lua_match" then
        isLocal = function(j)
            local line
            if j.text == "" then
                line = vim.api.nvim_buf_get_lines(bufNr, j.lnum - 1, j.lnum, false)[1]
                if line and line == "" then
                    return true
                else
                    return false
                end
            elseif j.text == "-invalid-" then
                return true
            else
                line = vim.api.nvim_buf_get_lines(bufNr, j.lnum - 1, j.lnum, false)[1]
                if not line then
                    -- Non-empty line
                    return false
                else
                    -- Meaning full line content

                    -- Trim the leading whitespaces
                    line = string.gsub(line, "^%s+", "")
                    -- Check redundant jumps
                    if filter == "local" and not next(cursorPos) and cursorPos[1] == j.lnum then
                        return false
                    end

                    if j.text == line then
                        return true
                    else
                        -- local bufNr = 0 -- Tests {{{

 --                        local foo = [[
 -- Lorem ^Xipsum dolor sit a^Xmet, qui minim labor^Xe adipisic^Xing minim ^Xsint cillum sin^Xt consec^Xtetur cu^Xpidatat.]]
 --                        local foo = [[
 -- Lorem ^Xipsum]]
 --                        local foo = [[
 -- Lorem ^Xipsu^Xm do^X^Xlor]]
--                         local foo = [[
-- ^X^X Lorem ^Xipsum dolor^X^X]]
                        -- local j = {}
                        -- j.lnum = 172
                        -- j.text = foo -- }}} Tests
                        -- Find all indexes of the skeptical non-printable words
                        local cnt = 0
                        local lastIdx = {0}
                        local idxTbl = {}
                        repeat
                            cnt = cnt + 1
                            lastIdx = {string.find(j.text, "%^.", lastIdx[1] + 1, false)}
                            if next(lastIdx) then
                                idxTbl[#idxTbl+1] = vim.deepcopy(lastIdx)
                            end
                            if cnt > 15 then break end
                        until not next(lastIdx)

                        if not next(idxTbl) then
                            -- Not special character
                            return false
                        else
                            -- Get all substrings
                            local substrings = {}
                            for i, idx in ipairs(idxTbl) do
                                if i == 1 and idx[1] ~= 1 then
                                    local headStr = vim.api.nvim_buf_get_text(bufNr, j.lnum - 1, 0, j.lnum - 1, idx[1] - 1, {})[1]
                                    if #substrings == 0 then
                                        headStr = string.gsub(headStr, "^%s+", "")
                                    end
                                    substrings[#substrings+1] = headStr
                                end
                                if i == #idxTbl and idx[2] ~= #j.text then
                                    local tailText = vim.api.nvim_buf_get_text(bufNr, j.lnum - 1, idx[2], j.lnum - 1, -1, {})[1]
                                    if #substrings == 0 then
                                        tailText = string.gsub(tailText, "^%s+", "")
                                    end
                                    substrings[#substrings+1] = tailText
                                end
                                if i < #idxTbl then
                                    local nextIdx = idxTbl[i + 1]
                                    if idx[2] + 1 ~= nextIdx[1] then
                                        -- Skip adjacent empty text
                                        local midStr = vim.api.nvim_buf_get_text(bufNr, j.lnum - 1, idx[2], j.lnum - 1, nextIdx[1] - 1, {})[1]
                                        if #substrings == 0 then
                                            midStr = string.gsub(midStr, "^%s+", "")
                                        end
                                        substrings[#substrings+1] = midStr
                                    end
                                end
                            end
                            -- Use the plain string to match against the jump text
                            for _, t in ipairs(substrings) do
                                if not string.find(j.text, t, 1, true) then
                                    return false
                                end
                            end
                            return true
                        end
                    end
                end
            end
        end
    elseif M.opts.filterMethod == "regex_match" then
        isLocal = function(j)
            local regex
            if j.text == "-invalid-" then
                return true
            elseif j.text ~= "" then
                j.text = vim.fn.escape(j.text, [[\]])
                regex = vim.regex([[\V]] .. vim.fn.substitute(j.text, [[\^\%(\\\\\|\p\)]], [[\\%(\0\\|\\.\\)]], "g"))
            else
                regex = vim.regex("^$")
            end

            if not regex then
                vim.notify(string.format("Unable to parse regex for item[%d]", j.count), vim.log.levels.ERROR)
                vim.print(j)
                return false
            end

            local line = vim.api.nvim_buf_get_lines(bufNr, j.lnum - 1, j.lnum, false)[1]
            if line and regex:match_str(line) then
                return true
            else
                return false
            end
        end
    else
        return {}
    end

    -- Filter out the parsed jumps
    if filter == "local" then
        return vim.tbl_filter(isLocal, jumpsParsed)
    elseif filter == "buffer" then
        return vim.tbl_filter(function(j) return not isLocal(j) end,jumpsParsed)
    end
end


--- Get the filtered out jumplist so that is ready to filter out and decide to perform a local jump or buffer jump
---@param isNewer boolean
local getJumps = function(isNewer)
    local jumpsStrOutput = vim.api.nvim_exec2(string.format([[%s]], "jumps"), {output = true}).output
    local jumpsTbl       = vim.split(jumpsStrOutput, "\n")
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


M.go = function(vimMode, isNewer, filter)

    local bufNr       = vim.api.nvim_get_current_buf()
    local winId       = vim.api.nvim_get_current_win()
    local cursorPos   = M.opts.checkCursorRedundancy and vim.api.nvim_win_get_cursor(winId) or {}

    -- Get the jumps table and reordered them
    -- OPTIM:
    local jumpsSliced = getJumps(isNewer)
    if not next(jumpsSliced) then
        return exceedJump(isNewer, filter)
    end

    -- Get the parsed and filtered jumps table
    local jumpsFilter = filterJumps(bufNr, jumpsSliced, filter, cursorPos)
    if not next(jumpsFilter) then
        return exceedJump(isNewer, filter)
    end
    do return jumpsFilter end

    -- Get the target jump, then execute the built-in command
    local count = vim.v.count1
    count = count > #jumpsFilter and #jumpsFilter or count
    local targetJump = jumpsFilter[count]
    local exCMD = isNewer and t"<C-i>" or t"<C-o>"
    -- TODO: Since local jump is expected to happen in the same buffer,
    -- it's possible to turn it into a proper motion?
    if vimMode ~= "n" then
        local visualCMD = "v" ~= string.lower(vimMode) and t"<C-q>" or vimMode
        vim.cmd(string.format("norm! %s%s%s", visualCMD, targetJump.count, exCMD))
    else
        vim.cmd(string.format("norm! %s%s", targetJump.count, exCMD))
    end

    -- Post processing
    if filter == "local" then
        local posBufNr = vim.api.nvim_get_current_buf()
        if posBufNr ~= bufNr then
            vim.notify("Failed to perform a correct local jump", vim.log.levels.ERROR)
            vim.print(targetJump)
        end
    end

    -- TODO:echo the next jump?
end


M.setup = function(opts)
    opts = opts or defaultOpts
    M.opts = vim.tbl_deep_extend("keep", opts, defaultOpts)
end

return M
