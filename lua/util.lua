local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M = {whichKeyDocs = {}}

function Print(...)
    local objects = {}
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        table.insert(objects, vim.inspect(v))
    end

    print(table.concat(objects, '\n'))
    return ...
end

function _G.t(str)
    return api.nvim_replace_termcodes(str, true, true, true)
end

function _G.ex(exec) return fn.executable(exec) == 1 end


----
-- Function: Vim2Lua___
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

----
-- Function: Reload: Reload lua module path
--
-- @param module: string value of module name, use current lua file name when nil is provided
----
function Reload(module) -- {{{
    local configPath = fn.stdpath("config")
    if not string.match(fn.expand("%:p"), configPath) then return end

    if vim.bo.filetype == "lua" then
        -- Lua {{{
        local luaModule
        if not module then
            module = vim.fn.expand("%:p")
            -- TODO: reload module
            local luaModulePath = configPath .. "/lua"
            -- Configuration module for packer.nvim
            if string.match(module, luaModulePath) then
                local sep
                if fn.has("win32") == 1 then
                    sep = "\\"
                else
                    sep = "/"
                end

                luaModule = ((string.gsub(string.sub(string.gsub(fn.expand("%:p:r"),
                                luaModulePath, ""), 2), sep, ".")))

                -- In case where module are not loaded
                if package.loaded[luaModule] == nil then return end

                package.loaded[luaModule] = nil
                api.nvim_echo({{"Reload: " .. module, "Normal"}}, true, {})
                local fallback = require(luaModule)

                -- Call the config func
                if type(fallback) == "function" then
                    fallback()
                elseif type(fallback) == "table" then
                    for _, funcName in ipairs{"config", "setup"} do
                        if vim.tbl_contains(vim.tbl_keys(fallback), funcName) then
                            local literalFunc = string.format([[require("%s").%s()]], luaModule, funcName)
                            loadstring(literalFunc)()
                        end
                    end
                else
                end
                -- Recompile packages for lua/core/plugins.lua
                if module == configPath .. "/lua/core/plugins.lua" then
                    local answerCD = fn.confirm("Recompile packages?", "&Yes\n&No")
                    if answerCD == 1 then
                        cmd [[PackerSync]]
                    end
                end
            end
        else
            if package.loaded[module] then
                package.loaded[module] = nil
                api.nvim_echo({{"Reload: " .. module, "Normal"}}, true, {})
                require(module)

            end
        end
        -- }}} Lua
    else
        -- Vim {{{
        module = fn.expand("%:p")
        if module == configPath .. "/init.vim" then
            cmd("source " .. module)
            cmd "redraw!"
            cmd "AirlineRefresh"
            api.nvim_echo({{"Reload: " .. module, "Normal"}}, true, {})
        elseif fn.expand("%:p:h") == configPath .. "/plugins" then
            cmd("source " .. module)
            api.nvim_echo({{"Reload: " .. module, "Normal"}}, true, {})
        elseif string.match(fn.expand("%:p:h"), configPath .. "/colors") then
            local colorscheme = fn.expand("%:t:r")
            cmd("colorscheme " .. colorscheme)
            api.nvim_echo({{"Colorscheme: " .. colorscheme, "Normal"}}, true, {})
        end
        -- }}} Vim
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
        cmd [[normal! mz`z]]
        if reservedCount then
            local saveCount = vim.v.count
            if saveCount ~= 0 then
                for _ = 1, saveCount do cmd("normal! " .. action) end
            else
                cmd("normal! " .. action)
            end
        else
            cmd("normal! " .. action)
        end
    elseif type(action) == "function" then
        if not funArg then return end
        cmd [[normal! mz`z]]
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
        -- BUG: Execute ls! will incur Neovim built-in LSP complain
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
    optsTbl = optsTbl or {}
    if vim.g.vscode and vim.tbl_contains(optsTbl, "novscode") then
        return
    end
    if type(optsTbl) == "string" then
        doc = optsTbl
        optsTbl = {}
    end
    -- Disable whichkey temporarily
    -- Register key documentation
    -- if doc then
        -- if not WhichKeyDocRegistered then
            -- M.whichKeyDocs[lhs] = doc
        -- else
            -- require("which-key").register{lhs = doc}
        -- end
    -- end

    if not next(optsTbl) then
        api.nvim_set_keymap(mode, lhs, rhs, optsTbl)
    else
        local optsKeywordTbl = {}
        for _, val in ipairs(optsTbl) do
            if val ~= "novscode" then
                optsKeywordTbl[val] = true
            end
        end
        api.nvim_set_keymap(mode, lhs, rhs, optsKeywordTbl)
    end
end -- }}}
----
-- Function: _G.vmap wrap around the nvim_set_keymap. This is for VS Code only!
--
-- @param mode:    Same as vim.api.nvim_set_keymap()
-- @param lhs:     Same as vim.api.nvim_set_keymap()
-- @param rhs:     Same as vim.api.nvim_set_keymap()
----
function _G.vmap(mode, lhs, rhs) -- {{{
    if vim.g.vscode then
        api.nvim_set_keymap(mode, lhs, rhs, {silent = true})
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
    if not next(optsTbl) then
        api.nvim_buf_set_keymap(bufNr, mode, lhs, rhs, optsTbl)
    else
        local optKeywordTbl = {}
        for _, val in ipairs(optsTbl) do
            optKeywordTbl[val] = true
        end
        api.nvim_buf_set_keymap(bufNr, mode, lhs, rhs, optKeywordTbl)
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
    if api.nvim_buf_get_lines(0, -2, -1, false)[1] ~= "" then
        local saveView = fn.winsaveview()
        cmd('keepjumps normal! Go')
        fn.winrestview(saveView)
    end
end -- }}}

----
-- Function: TrimWhiteSpaces Trim all trailing white spaces in the current
-- buffer or in the given string table
--
-- @param silent: non-zero value will show trimming result when complete
----
----
-- Function: M.trimWhiteSpaces :Trim all trailing white spaces in current buffer
--
-- @param strTbl: Lua table of source string need to be trimmed
-- @param silent: Non-zero value will show trimming result when complete
-- @param trimSuffix: set to true to trim the suffix as well
-- @return:       return table of trimmed string, otherwise return 0
----
function M.trimWhiteSpaces(strTbl, silent, trimSuffix) -- {{{
    if vim.bo.modified == false then return end

    if not strTbl then
        local saveView = fn.winsaveview()
        silent = silent or 1
        if silent == 1 then
            cmd [[keeppatterns %s#\s\+$##e]]
        else
            cmd [[keeppatterns %s#\s\+$##e]]
            local result = fn.execute [[g#\s\+$#p]]
            local count = #M.matchAll(result, [[\n]])
            cmd [[keeppatterns %s#\s\+$##e]]
            api.nvim_echo({{count .. " line[s] trimmed", "Moremsg"}}, false, {})
        end
        fn.winrestview(saveView)
    elseif next(strTbl) then
        if trimSuffix then
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
-- Function: M.saveReg will save the quote registers and unnamed registers
-- independantly, restoreReg can be accessed after saveReg is called
----
function M.saveReg() -- {{{
    local unnamed     = fn.getreg('"', 1)
    local unnamedType = fn.getregtype('"')
    local quote       = fn.getreg('*', 1)
    local quoteType   = fn.getregtype('*')
    M.restoreReg = function()
        fn.setreg('"', unnamed, unnamedType)
        fn.setreg('*', quote, quoteType)
        vim.defer_fn(function() M.restoreReg = nil end, 1000)
    end
end -- }}}

function M.visualSelection(returnType) -- {{{
    -- Not support blockwise visual mode
    local mode = fn.visualmode()
    if mode == "\22" then return end
    -- Return (1,0)-indexed line,col info
    local selectStart = api.nvim_buf_get_mark(0, "<")
    local selectEnd = api.nvim_buf_get_mark(0, ">")
    local lines = api.nvim_buf_get_lines(0, selectStart[1] - 1, selectEnd[1],
                                         false)
    if #lines == 0 then
        print("0");
        return {""}
    end
    -- Needed to remove the last character to make it match the visual selction
    if vim.o.selection == "exclusive" then selectEnd[2] = selectEnd[2] - 1 end
    if mode == "v" then
        lines[#lines] = lines[#lines]:sub(1, selectEnd[2] + 1)
        lines[1] = lines[1]:sub(selectStart[2] + 1)
    end

    if returnType == "list" then
        return lines
    elseif returnType == "string" then
        return table.concat(lines, "\n")
    end
end -- }}}

----
-- Function: M.posDist Caculate the distance from pos1 to pos2
--
-- @param pos1:    {line, col} like table value contain {1, 0} based number
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
    -- UbuntuMono
    local width2height   = 0.1978
    local height2width   = 5.0566

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
            return newWin(func, funcArgList, bufListed, scratchBuf, "col", height2width, width2height)
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
    if not winID then
        return api.nvim_win_get_config(0).relative ~= ""
    else
        return api.nvim_win_get_config(winID).relative ~= ""
    end
end

-- dummy
function _G.whichKeyDoc(docs)
    return
end

return M

