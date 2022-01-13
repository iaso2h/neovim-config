local fn   = vim.fn
local cmd  = vim.cmd
local api  = vim.api
local M = {whichKeyDocs = {}}

function Print(...)
    local objects = {}
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        table.insert(objects, vim.inspect(v))
    end
    if #objects == 1 and type(objects[1]) == "table" then
        require("pprint").pprint(objects[1])
    else
        print(table.concat(objects, '\n'))
    end

    return ...
end

function _G.t(str)
    return api.nvim_replace_termcodes(str, true, true, true)
end

function _G.ex(exec) return fn.executable(exec) == 1 end


----
-- Function: Vim2Lua
--
-- @param mode:    string value. "syntax" or "map" mode
-- @param verbose: boolean value, when set true, all opts keyword will be output in "map" mode
-- @return: 0
----
function Vim2Lua(mode) -- {{{
    if mode == "syntax" then
        -- Change vim script syntax into lua {{{
        local curPos = api.nvim_win_get_cursor(0)
        local range = curPos[1] .. ",$"
        local t = {
            [range .. "s#^\\(\\s*\\)'\\(.\\{-}\\)':#\1\2 =#e"] = true,
            [range .. "s#^\\(\\s*\\)\"\\(.\\{-}\\)\":#\1\2 =#e"] = true,
            [range .. "s#function\\(!\\)\\?\\(.*\\) abort#function\\2#e"] = true,
            [range .. "s#endfunction#end#e"] = true,
            [range .. "s#endif#end#e"] = true,
            [range .. "s#endwhile#end#e"] = true,
            [range .. "s#endfor#end#e"] = true,
            [range .. "s/!=[?#]\\?/~=/e"] = true,
            [range .. "s/==[?#]\\?/==/e"] = true,
            [range .. "s#||#or#e"] = true,
            [range .. "s#&&#and#e"] = true,
            [range .. "s#\\([^ ]\\) !\\(\\w\\)#\\1 not \\1#e"] = true,
            [range .. "s#|# #e"] = true,
            [range .. "s#a:##e"] = true,
            [range .. "s#b:#vim.b.#e"] = true,
            [range .. "s#w:#vim.w.#e"] = true,
            [range .. "s#t:#vim.t.#e"] = true,
            [range .. "s#v:#vim.v.#e"] = true,
            [range .. "s#\\(let \\)\\?g:#vim.g.#e"] = true,
            [range .. "s#&buftype#vim.bo.buftype#e"] = true,
            [range .. "s#&filetype#vim.bo.filetype#e"] = true,
            [range .. "s#&modified#vim.bo.modified#e"] = true,
            [range .. "s#&diff#vim.bo.diff#e"] = true,
            [range .. "s#&\\(\\w\\+\\)#vim.o.\1#e"] = true,
            [range .. "s#expand(#fn.expand(#e"] = true,
            [range .. "s#has(#fn.has(#e"] = true
        }
        local functionSCallRep    = string.format(range .. [=[s#call <sid>#lua require("%s").#e]=], fn.expand("%:t:r"))
        local functionSIdRep      = range .. [=[s#^\(\s*\)function\(!\)\? s:\(\w\)#\1function M\.\3#e]=]
        local functionGIdRep      = range .. [=[s#^\(\s*\)function\(!\)\? \(\u.\)\(.*\)#\1function M\.\l\3\4#e]=]
        local functionCallRep     = range .. [=[s#^\(\s*\)call \(.*\)#\1\2#e]=]
        local optionSetRep        = range .. [=[s#^\(\s*\)set \(.*\)#\1\2#e]=]
        local strConcanationRep   = range .. [=[s# \. # \.\. #e]=]
        local continueLineRep     = range .. [=[s#^\(\s\+\)\\#\1#e]=]
        local termStartRep        = range .. [=[s#^\(\s\+\)!\(.\+\)#\1cmd [[\2]]#e]=]
        local listLenRep          = range .. [=[s/\(str\)len(/#/e]=]
        local normalRep           = range .. [=[s#\(^\s*\)\(normal!.*\)#\1cmd [[\2]]#e]=]
        local executeRep          = range .. [=[s#\(\s\+\)execute#\1cmd#e]=]
        local commentStartRep     = range .. [=[s#^\(\s\{-}\)"#\1--#e]=]
        local commentStartMarkRep = range .. [=[s#" {{{#-- {{{#e]=]
        local commentEndMarkRep   = range .. [=[s#" }}}#-- }}}#e]=]
        local defaultInitRep1     = range .. [=[s#get(g:, "\(.\{-}\)", \(.\{-}\))#vim.g.\1 or \2#e]=]
        local defaultInitRep2     = range .. [=[s#get(g:, '\(.\{-}\)', \(.\{-}\))#vim.g.\1 or \2#e]=]
        local commandRep          = range .. [=[s#command!.*#cmd [[&]]#e]=]
        local userCommandStartRep = range .. [=[s#^\(\s\+\)\(\u.\+\)#\1cmd [[\2]]#e]=]
        t[strConcanationRep]   = true
        t[continueLineRep]     = true
        t[termStartRep]        = true
        t[listLenRep]          = true
        t[functionSCallRep]    = true
        t[functionSIdRep]      = true
        t[functionGIdRep]      = true
        t[functionCallRep]    = true
        t[optionSetRep]        = true
        t[normalRep]           = true
        t[executeRep]          = true
        t[commentStartRep]     = true
        t[commentStartMarkRep] = true
        t[commentEndMarkRep]   = true
        t[defaultInitRep1]     = false
        t[defaultInitRep2]     = false
        t[commandRep]          = true
        t[userCommandStartRep] = true

        for str, bool in pairs(t) do if bool then cmd(str) end end
        api.nvim_win_set_cursor(0, curPos)
        -- }}} Change vim script syntax into lua
    elseif mode == "map" then
        -- Change vim mapping syntax into lua mapping syntax {{{
        local curLine = api.nvim_get_current_line()
        local optKeyword = {}
        local mapKeyword = fn.matchstr(curLine, "^\\w\\{-}map!\\?")
        if mapKeyword == "" then do return end end
        if string.match(curLine, "<silent>") ~= nil then optKeyword["silent"] = true end
        if string.match(curLine, "<expr>") ~= nil then optKeyword["expr"] = true end
        if string.match(curLine, "<nowait>") ~= nil then optKeyword["nowait"] = true end

        local mapMode
        if #mapKeyword == 3 then
            mapMode = ""
        elseif #mapKeyword == 4 then
            mapMode = string.match(mapKeyword, "map!")
            if not mapMode then
                mapMode = string.sub(mapKeyword, 1, 1)
            end
        elseif #mapKeyword == 7 then
            optKeyword["noremap"] = true
            mapMode = ""
        elseif #mapKeyword == 8 then
            optKeyword["noremap"] = true
            mapMode = string.sub(mapKeyword, 1, 1)
            if mapMode == "m" then mapMode = "!" end
        else
            do return end
        end
        local mapping = fn.matchstr(curLine,
                                    [[^[nvicxto]\?\(nore\)\?map!\? \(<expr>\)\? \?\(<silent>\)\? \?\(<expr>\)\? \?\(nowait\)\? \?\zs.*]])
        if mapping == "" then do return end end
        local LHS = fn.matchstr(mapping, [[^.\{-}\ze .*$]])
        local RHS = fn.matchstr(mapping, [[^.\{-} \zs.*]])

        local optString = ""
        local luaMapping
        if next(optKeyword) then
            for optName, val in pairs(optKeyword) do
                if val then
                    optString = optString .. '"' .. optName .. '", '
                end
            end
            optString = string.sub(optString, 1, -3)
            luaMapping = string.format([=[map("%s", [[%s]], [[%s]], {%s})]=],
                                    mapMode, LHS, RHS, optString)
        else
            luaMapping = string.format([=[map("%s", [[%s]], [[%s]])]=],
                                    mapMode, LHS, RHS)
        end

        local cursor = api.nvim_win_get_cursor(0)
        api.nvim_buf_set_lines(0, cursor[1] - 1, cursor[1], {false},
                               {luaMapping})
        cmd "noh"
        -- setKey("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", {noremap = true, silent = true})
        -- setKey('n', 'j', "v:count == 0 ? 'gj' : 'j'", {noremap= true, expr = true, silent = true})
        -- setKey(0, 'i', '<C-Space>','pumvisible() ? "<C-e>" : "<Plug>(completion_trigger)"', {expr=true})
        -- }}} Change vim mapping syntax into lua mapping syntax
    end
end -- }}}


-- Function: M.addJump: Add jump location in jumplist before execute specified key
--
-- @param action:        Keystroke string or function
-- @param reservedCount: Boolean value. Number count will be considered when true is provided
-- @param funArg:        Optional funArg
----
function M.addJump(action, reservedCount, funArg) -- {{{
    if type(action) == "string" then
        if reservedCount then
            local saveCount = vim.v.count
            if saveCount ~= 0 then
                cmd [[normal! m`]]
                for _ = 1, saveCount do cmd("normal! " .. action) end
            else
                cmd("normal! " .. action)
            end
        else
            cmd("normal! " .. action)
        end
    elseif type(action) == "function" then
        if not funArg then return end
        cmd [[normal! m`]]
        action(funArg)
    end
end -- }}}

----
-- Function: M.tblLoaded return all loaded buffer listed in the :ls command in a table
--
-- @param termInclude: boolean value to determine whether contains terminal or not
-- @return: table
----
function M.tblLoaded(termInclude) -- {{{
    local bufTbl
    if not termInclude then
        bufTbl = vim.tbl_filter(function(buf) return string.match(buf, "term://") == nil end,
            vim.split(fn.execute("ls"), '\n', false))
        table.remove(bufTbl, 1)
    else
        -- NOTE: Execute ls! will incur Neovim built-in LSP complain
        bufTbl = vim.split(fn.execute("ls"), '\n', false)
        table.remove(bufTbl, 1)
    end
    return bufTbl
end -- }}}


----
-- Function: _G.map wrap around the nvim_set_keymap, and accept the fouth argument as table
--
-- @param mode:    Same as vim.api.nvim_set_keymap()
-- @param lhs:     Same as vim.api.nvim_set_keymap()
-- @param rhs:     Same as vim.api.nvim_set_keymap()
-- @param optsTbl: Table value contain string elements that will be pass into_
-- the fourth argument of nvim_set_keymap as the key name of value pairs, and
-- the value is true
-- @param doc:     String. Key documentation
--
----
function _G.map(mode, lhs, rhs, optsTbl, doc) -- {{{
    -- Behavior difference between vim.keymap.set() and api.nvim_set_keymap()
    -- https://github.com/neovim/neovim/commit/6d41f65aa45f10a93ad476db01413abaac21f27d
    -- New api.nvim_set_keymap(): https://github.com/neovim/neovim/commit/b411f436d3e2e8a902dbf879d00fc5ed0fc436d3

    optsTbl = optsTbl or {}
    doc = doc or ""

    -- Parameter "mode" can be either table value or string value
    mode = type(mode) == "string" and {mode} or mode

    -- Parameter "optsTbl" can be string value, which will be parsed as doc/description
    if type(optsTbl) == "string" then
        doc = optsTbl
        optsTbl = {}
    end

    -- Change string items in optsTbl into key-value pair table
    local optsKeyValTbl = {}
    if next(optsTbl) then
        for _, val in ipairs(optsTbl) do
            optsKeyValTbl[val] = true
        end
    end

    -- Handel RHS
    if type(rhs) == "function" then
        optsKeyValTbl.callback = rhs
        rhs = ""
    end

    -- Add description
    if doc ~= "" then optsKeyValTbl.desc = doc end

    -- Disable whichkey temporarily
    -- Register key documentation
    -- if doc then
        -- if not WhichKeyDocRegistered then
            -- M.whichKeyDocs[lhs] = doc
        -- else
            -- require("which-key").register{lhs = doc}
        -- end
    -- end

    -- Do not use "v" to map select mode inplicit
    if mode == "v" then
        vim.notify(
            string.format([=[Please use "x" to map [[%s]] for [[%s]] instead]=], lhs, rhs),
            vim.log.levels.WARN)
        mode = "x"
    end


    for _, m in ipairs(mode) do
        local ok, msg = pcall(api.nvim_set_keymap, m, lhs, rhs, optsKeyValTbl)
        if not ok then
            vim.notify(
                string.format([=[Error occurs while mapping [[%s]] for [[%s]]]=], lhs, rhs),
                vim.log.levels.ERROR)
            return vim.notify(msg, vim.log.levels.ERROR)
        end
    end

    -- Always disable Select mode mapping for key mapping like: R,C,A,S,X
    -- when lhs is "". See: ":help map-table"
    if string.match(lhs, "[A-Z]") and mode == "" then
        return api.nvim_del_keymap("s", lhs)
    end

    if CoreMappigsStart then
        if mode[1] == "" then mode[1] = "all" end
        for _, m in ipairs(mode) do
            -- Initiation
            _G.CoreMappings = _G.CoreMappings or {}
            CoreMappings[m] = CoreMappings[m] or {}

            CoreMappings[m][#CoreMappings[m]+1] = lhs
        end
    end
end -- }}}


----
-- Function: _G.bmap wrap around the nvim_set_keymap, and accept the fouth argument as table
--
-- @param bufNr:   Same as vim.api.nvim_buf_set_keymap()
-- @param mode:    Same as vim.api.nvim_buf_set_keymap()
-- @param lhs:     Same as vim.api.nvim_buf_set_keymap()
-- @param rhs:     Same as vim.api.nvim_buf_set_keymap()
-- @param optsTbl: Table value contain string elements that will be pass into_
-- the fourth argument of nvim_set_keymap as the key name of value pairs, and
-- the value is true
-- @param doc:     String. Key documentation
----
function _G.bmap(bufNr, mode, lhs, rhs, optsTbl, doc) -- {{{
    optsTbl = optsTbl or {}
    doc = doc or ""

    -- Parameter "mode" can be either table value or string value
    mode = type(mode) == "string" and {mode} or mode

    -- Parameter "optsTbl" can be string value, which will be parsed as doc/description
    if type(optsTbl) == "string" then
        doc = optsTbl
        optsTbl = {}
    end


    -- Register key documentation
    if doc then
        if not WhichKeyDocRegistered then
            M.whichKeyDocs[lhs] = doc
        else
            require("which-key").register{lhs = doc}
        end
    end

    -- Change string items in optsTbl into key-value pair table
    local optsKeyValTbl = {}
    if next(optsTbl) then
        for _, val in ipairs(optsTbl) do
            optsKeyValTbl[val] = true
        end
    end

    -- Handel RHS
    if type(rhs) == "function" then
        optsKeyValTbl.callback = rhs
        rhs = ""
    end


    -- Add description
    if doc ~= "" then optsKeyValTbl.desc = doc end

    if mode == "v" then
        vim.notify(
            string.format([=[Please use "x" to map [[%s]] for [[%s]] instead]=], lhs, rhs),
            vim.log.levels.WARN)
        mode = "x"
    end


    for _, m in ipairs(mode) do
        local ok, msg = pcall(api.nvim_buf_set_keymap, bufNr, m, lhs, rhs, optsKeyValTbl)
        if not ok then
            vim.notify(
                string.format([=[Error occurs while mapping [[%s]] for [[%s]]]=], lhs, rhs),
                vim.log.levels.ERROR)
            return vim.notify(msg, vim.log.levels.ERROR)
        end
    end

    -- Always disable Select mode mapping for key mapping like: R,C,A,S,X
    -- when lhs is "". See: ":help map-table"
    if string.match(lhs, "[A-Z]") and mode == "" then
        return api.nvim_buf_del_keymap(bufNr, "s", lhs)
    end
end -- }}}


function M.convertMap(mode, lhs, rhs, optsTbl)
    local specArg = ""
    local noremap = ""
    local mapString

    if optsTbl then
        for _, val in ipairs(optsTbl) do
            if val ~= "noremap" then
                specArg = specArg .. " <" .. val .. ">"
            end
        end
        if vim.tbl_contains(optsTbl, "noremap") then
            noremap = "nore"
        end
        specArg = specArg:sub(2)
    end

    mode = mode .. noremap .. "map"
    if specArg ~= "" then
        mapString = string.format("%s %s %s\n",mode, lhs, rhs)
    else
        mapString = string.format("%s %s %s %s\n",mode, specArg, lhs, rhs)
    end
    return mapString
end

function M.readInitLua()
    local targetF = io.open("C:/users/hashub/desktop/convertedmap1.vim", "w")
    local srcF = io.open("C:/Users/Hashub/AppData/Local/nvim/lua/init.lua", "r")
    local keymapcheck = false
    while true do
        local text = srcF:read()
        if not text then break end
        repeat
            if not keymapcheck then
                if vim.startswith(text, "-- Key mapping") then
                    keymapcheck = true
                    targetF:write([[" ]] .. text:sub(3) .. "\n")
                end
                break
            end

            if vim.startswith(text, "--") then
                targetF:write([[" ]] .. text:sub(3) .. "\n")
                break
            end
            if vim.startswith(text, "map(") then
                local convertMap = fn.luaeval([[require("util").convertMap]] .. text:sub(4))
                targetF:write(convertMap)
                break
            end
            targetF:write("\n")
            break
        until true
    end
    targetF:close()
    srcF:close()
end


-- Match enhance {{{
function M.matchAll(expr, pat)
    -- Based on VimL match(), Always return a list
    local t = {}
    local idx = -1
    while 1 do
        idx = fn.match(expr, pat, idx + 1)
        if idx == -1 then return t end
        table.insert(t, idx)
    end
end

function M.matchAllStrPos(expr, pat)
    -- Based on VimL matchstrpos(), Always return a list
    local t = {}
    local posList = {0, 0, 0}
    while 1 do
        posList = fn.matchstrpos(expr, pat, posList[3])
        if posList[1] == "" then return t end
        table.insert(t, posList)
    end
end
-- }}} Match enhance


function M.trailingEmptyLine() -- {{{
    if vim.bo.modified == false then return end

    if type(TrailEmptyLineChk) == "nil" then
        TrailEmptyLineChk = TrailEmptyLineChk or false
    end
    if not TrailEmptyLineChk then return end

    if api.nvim_buf_get_lines(0, -2, -1, false)[1] ~= "" then
        local saveView = fn.winsaveview()
        cmd('keepjumps normal! G')
        api.nvim_put({""}, "l", true, false)
        fn.winrestview(saveView)
    end
end -- }}}

----
-- Function: M.trimSpaces :Trim all trailing white spaces in current buffer
--
-- @param strTbl: Table of source string need to be trimmed. If no table
--        provided, the whole buffer will be trimmed instead.
-- @param silent: Boolean, default is true. Set this to true to not show trimming result
-- @param prefix: set to true to trim the suffix as well
-- @return:       return table of trimmed string, otherwise return 0
----
function M.trimSpaces(strTbl, silent, prefix) -- {{{
    if type(TrimSpacesChk) == "nil" then
        TrimSpacesChk = TrimSpacesChk or true
    end
    if not TrimSpacesChk then return end

    if vim.bo.modified == false then return end

    if not strTbl then
        local saveView = fn.winsaveview()
        silent = silent or true
        if silent then
            cmd [[noa keeppatterns %s#\s\+$##e]]
        else
            cmd [[noa keeppatterns %s#\s\+$##e]]
            local result = fn.execute [[g#\s\+$#p]]
            local count = #M.matchAll(result, [[\n]])
            cmd [[noa keeppatterns %s#\s\+$##e]]
            api.nvim_echo({{count .. " line[s] trimmed", "Moremsg"}}, false, {})
        end
        fn.winrestview(saveView)
    elseif next(strTbl) then
        if prefix then
            strTbl = vim.tbl_map(function(str)
                return fn.substitute(str, "^\\s\\+", "", "")
            end, strTbl)
        end
        return vim.tbl_map(function(str)
            return fn.substitute(str, "\\s\\+$", "", "")
        end, strTbl)
    end
end -- }}}

----
-- Function: M.saveReg will save the star registers, plus and unnamed registers
-- independantly, restoreReg can be accessed after saveReg is called
----
function M.saveReg() -- {{{
    local unnamedContent = fn.getreg('"', 1)
    local unnamedType    = fn.getregtype('"')
    local starContent    = fn.getreg('*', 1)
    local starType       = fn.getregtype('*')
    local plusContent    = fn.getreg('+', 1)
    local plusType       = fn.getregtype('+')
    local nonDefaultName = vim.v.register
    local nonDefaultContent
    local nonDefaultType
    if not vim.tbl_contains({'"', "*", "+"}, nonDefaultName) then
        nonDefaultContent = fn.getreg(nonDefaultName, 1)
        nonDefaultType    = fn.getregtype(nonDefaultName)
    end
    M.restoreReg = function()
        if nonDefaultContent and nonDefaultContent ~= "" then
            fn.setreg(nonDefaultName, nonDefaultContent, nonDefaultType)
        end

        if starContent ~= "" then
            fn.setreg('*', starContent,    starType)
        end
        if plusContent ~= "" then
            fn.setreg('+', plusContent,    plusType)
        end
        if unnamedContent ~= "" then
            fn.setreg('"', unnamedContent, unnamedType)
        end

        vim.defer_fn(function() M.restoreReg = nil end, 1000)
    end
end -- }}}


function M.visualSelection(returnType, returnNormal) -- {{{
    -- Not support blockwise visual mode
    local mode = fn.visualmode()
    if mode == "\22" then return end
    -- Return (1,0)-indexed line,col info
    local selectStart = api.nvim_buf_get_mark(0, "<")
    local selectEnd = api.nvim_buf_get_mark(0, ">")
    local lines = api.nvim_buf_get_lines(0, selectStart[1] - 1, selectEnd[1],
                                         false)

    if #lines == 0 then
        return {""}
    end
    -- Needed to remove the last character to make it match the visual selction
    if vim.o.selection == "exclusive" then selectEnd[2] = selectEnd[2] - 1 end
    if mode == "v" then
        lines[#lines] = lines[#lines]:sub(1, selectEnd[2] + 1)
        lines[1]      = lines[1]:sub(selectStart[2] + 1)
    end

    if returnNormal then cmd("norm! " .. t"<Esc>") end
    if returnType == "list" then
        return lines
    elseif returnType == "string" then
        return table.concat(lines, "\n")
    end
end -- }}}


----
-- Function: M.posDist Caculate the distance from pos1 to pos2
--
-- @param pos1:    {line, col} like table value contain {1, 0} based number.
--                 Can be retrieved by calling vim.api.nvim_buf_get_mark()
-- @param pos2:    Same as pos1
-- @param bias:    Bias number. Default value: 1
-- @param baisIdx: Bias index, possible value: 1 or 2. Default value: 1
-- @return: integer value of distance from pos1 to pos2
----
function M.posDist(pos1, pos2, bias, baisIdx)
    bias    = bias or 1
    baisIdx = baisIdx or 1
    local lineDist
    local colDist
    if baisIdx == 1 then
        lineDist = (pos1[1] - pos2[1])^2 * bias
        colDist  = (pos1[2] - pos2[2])^2
    else
        lineDist = (pos1[1] - pos2[1])^2
        colDist  = (pos1[2] - pos2[2])^2 * bias
    end
    return lineDist + colDist
end


--- Compare the distance from a to b by subtracting them
--- @param a table list-liked table
--- @param b table list-liked table
--- @return number
function M.compareDist(a, b)
    for idx, val in ipairs({a, b}) do
        assert(vim.tbl_islist(val), string.format("Argument %s expects list-liked table", idx))
    end
    return a[1] == b[1] and a[2] - b[2] or a[1] - b[1]
end


--- Check if pos is whithin a defined region
--- @param pos table
--- @param regionStart table
--- @param regionEnd table
--- @return boolean
function M.withinRegion(pos, regionStart, regionEnd)
    if M.compareDist(pos, regionStart) < 0 or M.compareDist(regionEnd, pos) < 0 then
        return false
    else
        return true
    end
end


-- Convert UTF-8 hex code to character
function M.u2char(code)
    if type(code) == 'string' then code = tonumber('0x' .. code) end
    local c = string.char
    if code <= 0x7f then return c(code) end
    local t = {}
    if code <= 0x07ff then
        t[1] = c(bit.bor(0xc0, bit.rshift(code, 6)))
        t[2] = c(bit.bor(0x80, bit.band(code, 0x3f)))
    elseif code <= 0xffff then
        t[1] = c(bit.bor(0xe0, bit.rshift(code, 12)))
        t[2] = c(bit.bor(0x80, bit.band(bit.rshift(code, 6), 0x3f)))
        t[3] = c(bit.bor(0x80, bit.band(code, 0x3f)))
    else
        t[1] = c(bit.bor(0xf0, bit.rshift(code, 18)))
        t[2] = c(bit.bor(0x80, bit.band(bit.rshift(code, 12), 0x3f)))
        t[3] = c(bit.bor(0x80, bit.band(bit.rshift(code, 6), 0x3f)))
        t[4] = c(bit.bor(0x80, bit.band(code, 0x3f)))
    end
    return table.concat(t)
end


function M.splitExist()
    local winCount  = fn.winnr("$")
    local ui        = api.nvim_list_uis()[1]
    -- Based on vim.o.guifont = "更纱黑体 Mono SC Nerd:h13"
    if fn.has("win32") == 1 then
        if winCount == 2 and 232/2 < ui["width"] then cmd [[noautocmd wincmd L]] end
    elseif fn.has("unix") == 1 then
        if winCount == 2 and 284/2 < ui["width"] then cmd [[noautocmd wincmd L]] end
    end
end


local function newWin(func, funcArgList, bufListed, scratchBuf, layoutStyle, height2width, width2height)
    local newBufNr = api.nvim_create_buf(bufListed, scratchBuf)
    if layoutStyle == "col" then
        cmd [[wincmd v]]
        api.nvim_win_set_buf(0, newBufNr)
        cmd("vertical resize " .. (api.nvim_win_get_width(0) - math.floor(api.nvim_win_get_height(0) * 0.618 * height2width)))
    else
        cmd [[wincmd s]]
        api.nvim_win_set_buf(0, newBufNr)
        cmd("resize " .. (api.nvim_win_get_height(0) - math.floor(api.nvim_win_get_width(0) * 0.618 * width2height)))
    end
    if func then
        if next(funcArgList) then
            func(newBufNr, funcArgList)
        else
            func(newBufNr)
        end
    end
end

----
-- Function: M.newSplit :Create a new split window based on the window layout
--
-- @param func:        function object to be executed after new window is
-- create. This function must accept the buffer number of the new buffer as the first argument
-- @param funcArgList: function argument table, can be empty
-- @param bufnamePat:  Shift focus to window if any window contains the buffer that match the given pattern, can be an empty string
-- @param bufListed:   Determine whether the new create buffer listed when calling api.nvim_create_buf(), expected boolean
-- @param scratchBuf:  Create a "throwaway" scratch-buffer when calling api.nvim_create_buf(), expected boolean
-- @return: 0
----
function M.newSplit(func, funcArgList, bufnamePat, bufListed, scratchBuf) -- {{{
    local winIDTbl            = api.nvim_list_wins()
    local winIDNonRelativeTbl = vim.tbl_filter(function(winID) return vim.api.nvim_win_get_config(winID).relative == "" end, winIDTbl)
    local nonSplitFileTypeTbl = {"coc-explorer", "qf", "NvimTree"}

    local curWinID  = api.nvim_get_current_win()
    local winInfo   = fn.getwininfo()
    local winLayout = fn.winlayout()
    -- -- UbuntuMono
    -- local width2height   = 0.1978
    -- local height2width   = 5.0566
    -- Delugia
    local width2height   = 0.4798
    local height2width   = 2.5523

    local ui             = api.nvim_list_uis()[1]
    local screenWidth    = ui.width
    local screenHeight   = ui.height

    -- Store windows ID for position restoration
    M.newSplitLastBufNr = curWinID

    -- If bufnamePat is provided and vim find the buffer that match the
    -- pattern, Shift focus to that buffer in current window instead
    if bufnamePat ~= "" then -- {{{
        local matchResult
        for _, tbl in ipairs(winInfo) do
            matchResult = string.match(api.nvim_buf_get_name(api.nvim_win_get_buf(tbl["winid"])), bufnamePat)
            if matchResult then
                cmd(string.format("%dwincmd w", tbl["winnr"]))
                return
            end
        end
    end -- }}}

    if #winIDNonRelativeTbl == 1 then
        if screenWidth <= screenHeight * height2width then
            return newWin(func, funcArgList, bufListed, scratchBuf, "row", height2width, width2height)
        else
            return newWin(func, funcArgList, bufListed, scratchBuf, "col", height2width - 1., width2height)
        end
    else -- {{{

        local newSplitChk = false

        -- Do not split on special window
        if vim.tbl_contains(nonSplitFileTypeTbl, vim.bo.filetype) then
            winLayout[1] = winLayout[1] == "row" and "col" or "row"
            cmd "noautocmd wincmd W"
        end

        repeat
            cmd "noautocmd wincmd W"
            if not vim.tbl_contains(nonSplitFileTypeTbl, vim.bo.filetype) and
                vim.tbl_contains(winIDNonRelativeTbl, api.nvim_get_current_win()) then

                newWin(func, funcArgList, bufListed, scratchBuf, winLayout[1], height2width, width2height)
                newSplitChk = true
            end
        until api.nvim_get_current_win() ~= curWinID

        -- In case of new win never had been created
        if not newSplitChk then
            cmd "noautocmd wincmd W"
            cmd "noautocmd wincmd W"
            return newWin(func, funcArgList, bufListed, scratchBuf, winLayout[1], height2width, width2height)
        end
    end -- }}}
end -- }}}


function _G.isFloatWin(winID)
    return api.nvim_win_get_config(winID and winID or 0).relative ~= ""
end


----
-- Function: _G.tbl_remove: Remove value from list-liked lua table
--
-- @param tbl:          List-liked table
-- @param srcVal:       Srouce value to be look up and removed
-- @param removeAllChk: Boolean value, default is true. Whether to remove the
--                      all values or not
-- @param cnt:          Integer value, default is 1. Determine how many value
--                      o be removed when firstOnlyChk is false
-- @return: Integer, table or nil. idx of the value. idx of table will be return when there are more
--          than one idx to be return. nil will be return when no idx found
----
 _G.tbl_remove = function(tbl, srcVal, removeAllChk, cnt)
    assert(next(tbl), "Empty table is not allowed")
    assert(vim.tbl_islist(tbl), "Expect list-liked table")

    removeAllChk = removeAllChk or false
    cnt = cnt or 1
    if not removeAllChk then
        for idx, val in ipairs(tbl) do
            if val == srcVal then
                tbl[idx] = nil
                return idx
            end
        end

    else
        local removeCount = 0
        local idxTbl = {}
        for idx, val in ipairs(tbl) do
            if val == srcVal then
                tbl[idx] = nil
                removeCount = removeCount + 1
                idxTbl[#idxTbl+1] = idx
            end
            if removeCount == cnt then return idxTbl end
        end

    end

    -- return nil when not idx found
    return nil
end


----
-- Function: _G.tbl_replace: Replace value1 inside list-liked table with value2
--
-- @param tbl:       List-liked table of which value to be replaced
-- @param repVal:    Value to replace with
-- @param srcVal:    Source value to be replaced
-- @param repAllChk: Boolean value, default is true. Whether to replace all value or not
-- @param cnt:       Integer value, default is 1. Determine how many srcVal
--                   will be replaced
-- @param alertOnFail: Boolean value, default is false. Whether to alert when
-- replace failed
-- @return: nil
----
_G.tbl_replace = function(tbl, repVal, srcVal, repAllChk, cnt, alertOnFail)
    repAllChk = repAllChk or true
    cnt = cnt or 1
    alertOnFail = alertOnFail or false

    local idx = tbl_remove(tbl, srcVal, repAllChk, cnt)
    if not idx then
        if alertOnFail then
            return vim.notify("Source value instance not found", vim.log.levels.WARN)
        else
            return
        end
    end
    local repCnt = 0
    if type(idx) == "table" then
        for _, index in ipairs(idx) do
            tbl[index] = repVal
            if repAllChk then
                repCnt = repCnt + 1
                if repCnt == cnt then return end
            end
        end
    else
        -- Bacause when table with one element have its very only element
        -- set to nil, the table will also became nil
        if idx == 1 then
            tbl = {repVal}
        else
            tbl[idx] = repVal
        end
    end

end


----
-- Function: _G.tbl_merge: Concanate two or more list like table
--
-- @param ...: Table
----
_G.tbl_merge = function(...)
    local tblConcanated = {}
    for i = 1, select('#', ...) do
        local tbl = select(i, ...)
        assert(vim.tbl_islist(tbl), "Only list-liked table allowed")
        if next(tbl) then
            for _, value in ipairs(tbl) do
                tblConcanated[#tblConcanated+1] = value
            end
        end
    end
    return tblConcanated
end


--- Return the index of specific item in a list-liked table. Only support
--- number and string for now
--- @param tbl table list-liked table
--- @param item number or string
--- @param idxAll boolean whether to return all the indexes as a table
--- @return number or table return table when idxAll is true
_G.tbl_idx = function(tbl, item, idxAll)
    assert(vim.tbl_islist(tbl), "Expect list-liked table")
    assert(type(item) == "string" or type(item) == "number", "Only support indexing string or number")
    local idxTbl = {}
    for idx, i in ipairs(tbl) do
        if i == item then
            if not idxAll then
                return idx
            else
                idxTbl[#idxTbl+1] = idx
            end
        end
    end

    if not idxAll then
        return nil
    else
        return idxTbl
    end
end


----
-- Function: _G.luaRHS: Let you write rhs of mapping in a comafortable way

-- Before:
            -- map("n", [[<Plug>ReplaceCurLine]], [[:lua vim.fn["repeat#setreg"](t"<Plug>ReplaceCurLine", vim.v.register); require("replace").replaceSave(); if require("replace").regType == "=" then vim.g.ReplaceExpr = vim.fn.getreg("=") end; vim.cmd("norm! V" .. vim.v.count1 .. "_" .. "<lt>Esc>"); require("replace").operator({"line", "V", "<Plug>ReplaceCurLine", true})<CR>]], {"silent"})

-- After:
            -- map("n", [[<Plug>ReplaceCurLine]],
                -- luaRHS[[
                -- :lua vim.fn["repeat#setreg"](t"<Plug>ReplaceCurLine", vim.v.register);

                -- require("replace").replaceSave();
                -- if require("replace").regType == "=" then
                    -- vim.g.ReplaceExpr = vim.fn.getreg("=")
                -- end;

                -- vim.cmd("norm! V" .. vim.v.count1 .. "_" .. "<lt>Esc>");

                -- require("replace").operator({"line", "V", "<Plug>ReplaceCurLine", true})<CR>
                -- ]],
                -- {"silent"})
--
-- @param str: RHS mapping
-- @return: nil
----
_G.luaRHS = function(str)
    assert(type(str) == "string", "Expected string value")

    local strTbl = vim.split(str, "\n", false)
    strTbl = vim.tbl_filter(function(i) return not i:match("^%s*$") end, strTbl)
        local concnStr = string.gsub(table.concat(strTbl, " "), "%s+", " ")

    return tostring(
        concnStr:sub(1, 1) == " " and
        concnStr:sub(2, -1) or concnStr:sub(1, -1))
end


_G.vimRHS = function(str)
    assert(type(str) == "string", "Expected string value")

    local strTbl = vim.split(str, "\n", false)
    strTbl = vim.tbl_filter(function(i) return not i:match("^%s*$") end, strTbl)
        local concnStr = string.gsub(table.concat(strTbl, "<Bar> "), "%s+", " ")

    return tostring(
        concnStr:sub(1, 1) == " " and
        concnStr:sub(2, -1) or concnStr:sub(1, -1))
end


_G.stringCount = function(str, pattern)
    local count = 0
    local init = 0
    while true do
        init = string.find(str, pattern, init + 1)
        if not init then return count end
        count = count + 1
    end
end

-- dummy
_G.whichKeyDoc = function(docs)
    return
end


return M
