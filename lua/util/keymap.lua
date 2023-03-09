local api = vim.api


--- Checking validity of arguement
---@param lhs  string|table    Left hand side of mapping
---@param rhs  string|function Right hand side of mapping
---@param arg  table           Arguemnt table
---@return table|nil, string|nil
local argCheck = function (lhs, rhs, arg)
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
    if type(rhs) == "string" and string.upper(rhs) ~= "<NOP>"  and not doc then
        vim.notify(
            string.format([=[Lack of desc in mapping: [[%s]] for [[%s]]]=], lhs, rhs),
            vim.log.levels.WARN)
    end

    return opts, doc
end


--- Convert arguments to match up the specified ones in vim.api.nvim_set_keymap()
---@param mode string|table Same as vim.api.nvim_set_keymap()
---@param lhs string Same as vim.api.nvim_set_keymap()
---@param rhs string|function Same as vim.api.nvim_set_keymap()
---@param opts table|nil Table value contain `h:map-arguments` strings
-- that will be convert into table then passed into vim.api.nvim_set_keymap
---@param doc string|nil key mapping description
---@return table, table, string
local argConvert = function(mode, lhs, rhs, opts, doc)
    local modeTbl
    -- Parameter "mode" can be either table value or string value, but convert
    -- it as table anyway
    if type(mode) == "string" then
        -- Convert "" into {"n", "x", "o"}. Do not use "" to map visual mode
        -- inexplicitly, and possibly apply mapping to select mode as well
        if mode == "" then
            modeTbl = {"n", "x", "o"}
        else
            modeTbl = {mode}
        end
    else
        modeTbl = mode
    end

    -- Do not use "v" to map select mode inexplicitly
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
    -- Cycle through optsTbl
    if opts and next(opts) then
        for _, val in ipairs(opts) do
            optsKeyValTbl[val] = true
        end
    end

    return modeTbl, optsKeyValTbl, rhsStr
end


--- Handy mapping func that wrap around the vim.api.nvim_set_keymap()
---@param mode string|table    Same as vim.api.nvim_set_keymap()
---@param lhs  string          Same as vim.api.nvim_set_keymap()
---@param rhs  string|function Same as vim.api.nvim_set_keymap()
---@vararg ... table|string    Optional table value contain `h:map-arguments` strings
--- that will be convert into table then passed into vim.api.nvim_set_keymap.
--- Optional key mapping description
function _G.map(mode, lhs, rhs, ...) -- {{{
    -- Behavior difference between vim.keymap.set() and api.nvim_set_keymap()
    -- https://github.com/neovim/neovim/commit/6d41f65aa45f10a93ad476db01413abaac21f27d
    -- New api.nvim_set_keymap(): https://github.com/neovim/neovim/commit/b411f436d3e2e8a902dbf879d00fc5ed0fc436d3
    local opts, doc = argCheck(lhs, rhs, {...})

    local modeTbl, optsKeyValTbl, rhsStr = argConvert(mode, lhs, rhs, opts, doc)

    for _, m in ipairs(modeTbl) do
        local ok, msg = pcall(api.nvim_set_keymap, m, lhs, rhsStr, optsKeyValTbl)
        if not ok then
            vim.notify(
                string.format([=[Error occurs while mapping [[%s]] for [[%s]]]=], lhs, rhsStr),
                vim.log.levels.ERROR)
            vim.notify(msg, vim.log.levels.ERROR)
            return vim.notify(debug.traceback(), vim.log.levels.ERROR)
        end
    end

    -- Always disable Select mode mapping for key mapping like: R,C,A,S,X
    -- when lhs is "". See: ":help map-table"
    if string.match(lhs, "[A-Z]") and modeTbl == "" then
        return api.nvim_del_keymap("s", lhs)
    end

    if CoreMappigsStart then
        if modeTbl[1] == "" then modeTbl[1] = "all" end
        for _, m in ipairs(modeTbl) do
            -- Initiation
            _G.CoreMappings = _G.CoreMappings or {}
            CoreMappings[m] = CoreMappings[m] or {}

            CoreMappings[m][#CoreMappings[m]+1] = lhs
        end
    end
end -- }}}


--- Handy mapping func that wrap around the vim.api.nvim_set_keymap()
---@param bufNr number          Same as vim.api.nvim_set_keymap()
---@param mode  string|table    Same as vim.api.nvim_set_keymap()
---@param lhs   string          Same as vim.api.nvim_set_keymap()
---@param rhs   string|function Same as vim.api.nvim_set_keymap()
---@vararg ...  table|string     Optional table value contain `h:map-arguments` strings
--- that will be convert into table then passed into vim.api.nvim_set_keymap.
--- Optional key mapping description
function _G.bmap(bufNr, mode, lhs, rhs, ...) -- {{{
    assert(type(bufNr) == "number", "#1 argument is not a valid number")
    local opts, doc = argCheck(lhs, rhs, {...})

    local modeTbl, optsKeyValTbl, rhsStr = argConvert(mode, lhs, rhs, opts, doc)

    for _, m in ipairs(modeTbl) do
        local ok, msg = pcall(api.nvim_buf_set_keymap, bufNr, m, lhs, rhsStr, optsKeyValTbl)
        if not ok then
            vim.notify(
                string.format([=[Error occurs while mapping [[%s]] for [[%s]]]=], lhs, rhsStr),
                vim.log.levels.ERROR)
            vim.notify(msg, vim.log.levels.ERROR)
            return vim.notify(debug.traceback(), vim.log.levels.ERROR)
        end
    end

    -- Always disable Select modemapping for key mapping like: R,C,A,S,X
    -- when lhs is "". See: ":help map-table"
    if string.match(lhs, "[A-Z]") and modeTbl == "" then
        return api.nvim_buf_del_keymap(bufNr, "s", lhs)
    end
end -- }}}
