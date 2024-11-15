--- Checking validity of argument
---@param lhs  string|table    Left hand side of mapping
---@param rhs  string|function Right hand side of mapping
---@param arg  table           Argument table
---@return table|nil, string|nil
local argCheck = function (lhs, rhs, arg) -- {{{
    local opts
    local doc

    if next(arg) then
        if #arg == 1 then
            if type(arg[1]) == "string" then
                doc = arg[1]
            elseif type(arg[1]) == "table" then
                opts = arg[1]
            else
                vim.notify(
                    string.format([=[Error occurs while mapping [[%s]] for [[%s]]]=], lhs, rhs),
                    vim.log.levels.ERROR)
                vim.notify([=[Incorrect parameters passed]=], vim.log.levels.ERROR)
                return vim.notify(debug.traceback(), vim.log.levels.ERROR)
            end
        elseif #arg == 2 then
            opts = arg[1]
            doc  = arg[2]
            if type(opts) ~= "table" or type(doc) ~= "string" then
                vim.notify(
                    string.format([=[Error occurs while mapping [[%s]] for [[%s]]]=], lhs, rhs),
                    vim.log.levels.ERROR)
                vim.notify([=[Incorrect parameters passed]=], vim.log.levels.ERROR)
                return vim.notify(debug.traceback(), vim.log.levels.ERROR)
            end
        else
            if type(opts) ~= "table" or type(doc) ~= "string" then
                vim.notify(
                    string.format([=[Error occurs while mapping [[%s]] for [[%s]]]=], lhs, rhs),
                    vim.log.levels.ERROR)
                vim.notify([=[Incorrect parameters passed]=], vim.log.levels.ERROR)
                return vim.notify(debug.traceback(), vim.log.levels.ERROR)
            end
        end
    end

    -- Warn the lack of desc
    assert(type(rhs) == "function" or type(rhs) == "string", "rhs argument must be a function or a string")
    if type(rhs) == "string" and string.upper(rhs) ~= "<NOP>"  and not doc then
        vim.notify(
            string.format([=[Lack of desc in mapping: [[%s]] for [[%s]]]=], lhs, rhs),
            vim.log.levels.WARN)
    end

    return opts, doc
end -- }}}
--- Convert arguments to match up the specified ones in `vim.api.nvim_set_keymap()`
---@param mode string|table   Same as `vim.api.nvim_set_keymap()`
---@param lhs string          Same as `vim.api.nvim_set_keymap()`
---@param rhs string|function Same as `vim.api.nvim_set_keymap()`
---@param opts table Table value contain `h:map-arguments` strings that will be convert into table then passed into `vim.api.nvim_set_keymap`
---@param doc? string key mapping description
---@return table,table,string
local argConvert = function(mode, lhs, rhs, opts, doc) -- {{{
    local modeTbl
    -- Parameter "mode" can be either table value or string value, but convert
    -- it into table anyway
    if type(mode) == "string" then
        -- Convert "" into {"n", "x", "o"}. Do not use "" to map visual mode
        -- Inexplicitly, and to possibly apply mapping to select mode as well
        if mode == "" then
            modeTbl = {"n", "x", "o"}
        else
            modeTbl = {mode}
        end
    else
        modeTbl = mode
    end

    -- Do not use "v" to map select mode Inexplicitly
    for _, modeStr in ipairs(modeTbl) do
        if modeStr == "v" then
            vim.notify(
                string.format([=[Please use "x" to map [[%s]] for [[%s]] instead]=], lhs, rhs),
                vim.log.levels.WARN)
            vim.notify(debug.traceback(), lhs, rhs, vim.log.levels.WARN)
            table[modeStr] = nil
            table.insert(modeTbl, "x")
        end
    end

    -- Change string items in optsTbl into key-value pair table
    local optsKeyValTbl = {}
    local rhsStr
    -- Add description
    if doc and doc ~= "" then
        optsKeyValTbl.desc = doc
    end
    -- Handle RHS function
    if type(rhs) == "function" then
        optsKeyValTbl.callback = rhs
        rhsStr = ""
    else
        rhsStr = rhs
    end
    -- Complement the optsTbl
    if opts and next(opts) then
        for _, val in ipairs(opts) do
            if val ~= "vscode" then
                optsKeyValTbl[val] = true
            end
        end
    end

    return modeTbl, optsKeyValTbl, rhsStr
end -- }}}
--- Handy mapping func that wrap around the `vim.api.nvim_set_keymap()`
---@param mode string|table    Same as `vim.api.nvim_set_keymap()`
---@param lhs  string          Same as `vim.api.nvim_set_keymap()`
---@param rhs  string|function Same as `vim.api.nvim_set_keymap()`
---@vararg table|string    Optional table value contain `h:map-arguments` strings that will be convert into table then passed into vim.api.nvim_set_keymap. Optional key mapping description
_G.map = function(mode, lhs, rhs, ...) -- {{{
    -- Behavior difference between vim.keymap.set() and api.nvim_set_keymap()
    -- https://github.com/neovim/neovim/commit/6d41f65aa45f10a93ad476db01413abaac21f27d
    -- New api.nvim_set_keymap(): https://github.com/neovim/neovim/commit/b411f436d3e2e8a902dbf879d00fc5ed0fc436d3
    local opts, doc = argCheck(lhs, rhs, {...})
    if vim.g.vscode and not vim.list_contains(opts, "vscode") then
        return
    end

    local modeTbl, optsKeyValTbl, rhsStr = argConvert(mode, lhs, rhs, opts, doc)

    for _, m in ipairs(modeTbl) do
        local ok, msg = pcall(vim.api.nvim_set_keymap, m, lhs, rhsStr, optsKeyValTbl)
        if not ok then
            vim.notify(
                string.format([=[Error occurs while mapping [[%s]] for [[%s]]]=], lhs, rhsStr),
                vim.log.levels.ERROR)
            vim.notify(msg, vim.log.levels.ERROR)
            return vim.notify(debug.traceback(), vim.log.levels.ERROR)
        end
    end

    -- Always disable Select mode mapping when LHS mapping comes from: R,C,A,S,X
    -- when lhs is "". See: ":help map-table"
    if string.match(lhs, "[A-Z]") and modeTbl == "" then
        return vim.api.nvim_del_keymap("s", lhs)
    end
end -- }}}
--- Handy mapping func that wrap around the `vim.api.nvim_buf_set_keymap()`
---@param bufNr integer          Same as `vim.api.nvim_buf_set_keymap()`
---@param mode  string|table    Same as `vim.api.nvim_buf_set_keymap()`
---@param lhs   string          Same as `vim.api.nvim_buf_set_keymap()`
---@param rhs   string|function Same as `vim.api.nvim_buf_set_keymap()`
---@vararg table|string    Optional table value contain `h:map-arguments` strings -that will be convert into table then passed into vim.api.nvim_set_keymap. -Optional key mapping description
_G.bmap = function(bufNr, mode, lhs, rhs, ...) -- {{{
    assert(type(bufNr) == "number", "#1 argument is not a valid number")
    local opts, doc = argCheck(lhs, rhs, {...})
    if vim.g.vscode and not vim.list_contains(opts, "vscode") then
        return
    end

    local modeTbl, optsKeyValTbl, rhsStr = argConvert(mode, lhs, rhs, opts, doc)

    for _, m in ipairs(modeTbl) do
        local ok, msg = pcall(vim.api.nvim_buf_set_keymap, bufNr, m, lhs, rhsStr, optsKeyValTbl)
        if not ok then
            vim.notify(
                string.format([=[Error occurs while mapping [[%s]] for [[%s]]]=], lhs, rhsStr),
                vim.log.levels.ERROR)
            vim.notify(msg, vim.log.levels.ERROR)
            return vim.notify(debug.traceback(), vim.log.levels.ERROR)
        end
    end

    -- Always disable Select mode mapping when LHS mapping comes from: R,C,A,S,X
    -- when lhs is "". See: ":help map-table"
    if string.match(lhs, "[A-Z]") and modeTbl == "" then
        return vim.api.nvim_buf_del_keymap(bufNr, "s", lhs)
    end
end -- }}}
--- Replaces terminal codes and keycodes
---@param str string
---@return string
_G.t = function(str) -- {{{
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end -- }}}
--- Let you write rhs of mapping in a comafortable way

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
---@param str string
---@return string
_G.luaRHS = function(str) -- {{{
    assert(type(str) == "string", "Expected string value")

    local strTbl = vim.split(str, "\n", false)
    strTbl = vim.tbl_filter(function(i) return not i:match("^%s*$") end, strTbl)

    local concatStr = string.gsub(table.concat(strTbl, " "), "%s+", " ")

    return tostring(
        concatStr:sub(1, 1) == " " and
        concatStr:sub(2, -1) or concatStr)
end -- }}}
