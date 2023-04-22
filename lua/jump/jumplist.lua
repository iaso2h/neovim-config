-- File: jumplist
-- Author: iaso2h
-- Description: Enhance <C-i>/<C-o>
-- Version: 0.0.6
-- Last Modified: 2023-4-23

local defaultOpts  = {
    filterMethod = "lua_match",
    checkCursorRedundancy = true,
    returnFilterJumps = false
}

local M = {
    visualMode = "",
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
    local directionStr = isNewer and "newer" or "older"
    vim.notify(
        string.format("Cannot jump to any %s place in the %s jumplist",
            directionStr, filter), vim.log.levels.INFO)
end

local bufNameListed = {}

---@param line string
---@return string
local trimLeadingWhitespaces = function(line)
    local trimmedLine = string.gsub(line, "^%s+", "")
    return trimmedLine
end

---@param bufNr number
---@param jump table
---@param idxTbl table Indexes of all skeptical non-printable characters
---@return table All sub-strings. Captured via the position info provide by jump table and spitted by the non-printable
--characters
local getSubString = function(bufNr, jump, idxTbl)
    local subStrings = {}
    -- {        idx1,     idx2,     idx3,     idx4      }
    --      ↑          ↑         ↑         ↑         ↑
    -- {<headStr1>,<subStr2>,<subStr3>,<subStr4>,<tailStr5>}
    for i, idx in ipairs(idxTbl) do
        if i == 1 then
            if idx[1] ~= 1 then
                -- Skip adjacent empty text
                local headStr = vim.api.nvim_buf_get_text(bufNr, jump.lnum - 1, 0, jump.lnum - 1, idx[1] - 1,
                    {})[1]
                if #subStrings == 0 then
                    headStr = trimLeadingWhitespaces(headStr)
                end
                subStrings[#subStrings + 1] = headStr
            end
        end
        if i == #idxTbl then
            if idx[2] ~= #jump.text then
                -- Skip adjacent empty text
                local tailStr = vim.api.nvim_buf_get_text(bufNr, jump.lnum - 1, idx[2], jump.lnum - 1, -1,
                {})[1]
                if #subStrings == 0 then
                    tailStr = trimLeadingWhitespaces(tailStr)
                end
                subStrings[#subStrings + 1] = tailStr
            end
        end
        if i < #idxTbl then
            local nextIdx = idxTbl[i + 1]
            if idx[2] + 1 ~= nextIdx[1] then
                -- Skip adjacent empty text
                local midStr = vim.api.nvim_buf_get_text(bufNr, jump.lnum - 1, idx[2], jump.lnum - 1,
                    nextIdx[1] - 1, {})[1]
                if #subStrings == 0 then
                    midStr = trimLeadingWhitespaces(midStr)
                end
                subStrings[#subStrings + 1] = midStr
            end
        end
    end

    return subStrings
end


---@param bufNr number
---@param jump table
---@param filter string "local"|"buffer"
---@param cursorPos table (1, 0) based. If target and cursor are on the same line in local filter, that target jump will be discard. Set it to empty table to turn off this behavior
---@return boolean
local isLocal = function(bufNr, jump, filter, cursorPos)
    local line
    -- Special jump text
    if jump.text == "-invalid-" then
        return true
    elseif jump.text == "" then
        line = vim.api.nvim_buf_get_lines(bufNr, jump.lnum - 1, jump.lnum, false)[1]
        if line and line == "" then
            return true
        else
            return false
        end
    end

    -- Special position
    if filter == "local" and not next(cursorPos) and cursorPos[1] == jump.lnum then
        return false
    end

    -- Generic check
    if M.opts.filterMethod == "fs_stat" then
        -- NOTE: This is slow and will be deprecated
        if not next(bufNameListed) then
            local bufListed = vim.tbl_filter(function(b)
                return vim.api.nvim_buf_get_option(b, "buflisted")
            end, vim.api.nvim_list_bufs())
            bufNameListed = vim.tbl_map(function(b)
                return vim.fn.bufname(b)
            end, bufListed)
        end

        if string.sub(jump.text, 1, 1) == "~" then
            -- Expand the filename when the first character is ~
            if vim.loop.fs_stat(vim.fn.expand(jump.text)) then
                return false
            else
                return true
            end
        else
            -- Check whether jump text is contained in the :ls output
            if vim.tbl_contains(bufNameListed, jump.text) then
                return false
            end

            -- Concatenate the working directory string with the jump text and
            -- check if that file exist since the most files are under the
            -- same working directory
            local cwd = vim.loop.cwd()
            if vim.loop.fs_stat(string.format("%s/%s", cwd, jump.text)) then
                return false
            else
                if vim.loop.fs_stat(jump.text) then
                    return false
                else
                    return true
                end
            end
        end
    elseif M.opts.filterMethod == "lua_match" then
        line = vim.api.nvim_buf_get_lines(bufNr, jump.lnum - 1, jump.lnum, false)[1]
        if not line then
            return false
        else
            -- Non-empty line

            -- Always trim out the leading whitespaces as the jumplist
            -- text always do
            if jump.text == trimLeadingWhitespaces(line) then
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
                -- local j = {}
                -- j.lnum = 172
                -- j.text = foo -- }}} Tests
                -- Find all indexes of the skeptical non-printable words
                local cnt = 0
                local lastIdx = { 0 }
                local idxTbl = {}
                repeat
                    cnt = cnt + 1
                    lastIdx = { string.find(jump.text, "%^.", lastIdx[1] + 1, false) }
                    if next(lastIdx) then
                        idxTbl[#idxTbl + 1] = vim.deepcopy(lastIdx)
                    end
                    if cnt > 15 then break end
                until not next(lastIdx)

                if not next(idxTbl) then
                    -- No special character appears in the jump.text, and yet
                    -- it's not equal to line, so this's not a valid local jump
                    return false
                else
                    -- Get all the sub-strings slitted and separated by the
                    -- skeptical non-printable words, then loop through the
                    -- sub-strings table. Use the plain sub-string to match
                    -- against the jump text
                    for _, t in ipairs(getSubString(bufNr, jump, idxTbl)) do
                        if not string.find(jump.text, t, 1, true) then
                            return false
                        end
                    end
                    return true
                end
            end
        end
    elseif M.opts.filterMethod == "regex_match" then
        local regex
        jump.text = vim.fn.escape(jump.text, [[\]])
        regex = vim.regex([[\V]] .. vim.fn.substitute(jump.text, [[\^\%(\\\\\|\p\)]], [[\\%(\0\\|\\.\\)]], "g"))

        if not regex then
            vim.notify(string.format("Unable to parse regex for item[%d]", jump.count), vim.log.levels.ERROR)
            vim.print(jump)
            return true
        end

        line = vim.api.nvim_buf_get_lines(bufNr, jump.lnum - 1, jump.lnum, false)[1]
        if line and regex:match_str(line) then
            return true
        else
            return false
        end
    else
        return true
    end
end


---@param bufNr number
---@param jumps table
---@param filter string "local"|"buffer"
---@param cursorPos table (1, 0) based. If target and cursor are on the same line in local filter, that target jump will be discard. Set it to empty table to turn off this behavior
---@return table
local filterJumps = function(bufNr, jumps, filter, cursorPos)
    -- jumps = M.jumpsDummy
    local filterFunc
    if filter == "local" then
        filterFunc = isLocal
    else
        filterFunc = function(...)
            return not isLocal(...)
        end
    end

    local jumpsFiltered = {}
    for _, jumpLine in ipairs(jumps) do
        local parseResult = { string.match(jumpLine, "^>?%s*(%d+)%s+(%d+)%s+(%d+)%s+(.*)$") }
        local jumpParsed = {
            count = parseResult[1],
            lnum  = tonumber(parseResult[2]),
            col   = tonumber(parseResult[3]),
            text  = parseResult[4],
        }
        if filterFunc(bufNr, jumpParsed, filter, cursorPos) then
            jumpsFiltered[#jumpsFiltered+1] = jumpParsed
        end

        if #jumpsFiltered == vim.v.count1 + 1 then
            break
        end
    end
    if M.opts.filterMethod == "fs_stat" then
        bufNameListed = {}
    end

    return jumpsFiltered
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
    local jumpsSliced = getJumps(isNewer)
    if not next(jumpsSliced) then
        return exceedJump(isNewer, filter)
    end

    -- Get the parsed and filtered jumps table
    local jumpsFiltered = filterJumps(bufNr, jumpsSliced, filter, cursorPos)
    if not next(jumpsFiltered) then
        return exceedJump(isNewer, filter)
    end

    -- For tests
    if M.opts.returnFilterJumps then
        M.opts.returnFilterJumps = false
        return jumpsFiltered
    end

    -- Get the target jump, then execute the built-in command
    local targetJump = jumpsFiltered[vim.v.count1]
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
