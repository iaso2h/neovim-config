-- local getBuf = function()
--     local bufNrTbl = vim.api.nvim_list_bufs()
--     for _, bufNr in ipairs(bufNrTbl) do
--         local pluginFilePath = string.format("%s%slua%score%splugins.lua", _G._configPath, _G._sep, _G._sep, _G._sep)
--         if vim.api.nvim_buf_get_name(bufNr) == pluginFilePath then
--             return bufNr
--         end
--     end

--     return -1
-- end


--- Get node text at given range
---@param bufNr number
---@param range table Captured indices return by calling tsnode:range() . All
---values are 0 index
---@param xOffset? number Negative number to expand the same unit from column
---start and column end, and positive number to shrink. Default 0
---@param yOffset? number Negative number to expand the same unit from row
---start and column end, and positive number to shrink. Default 0
---@param concatChar? string What character will be used as the separator to
---concatenate table elements. Default ""
local getNodeText = function(bufNr, range, xOffset, yOffset, concatChar)
    xOffset = xOffset or 0
    yOffset = yOffset or 0
    concatChar = concatChar or ""
    local text = vim.api.nvim_buf_get_text(
        bufNr,
        range[1] + yOffset,
        range[2] + xOffset,
        range[3] - yOffset,
        range[4] - xOffset,
        {})
    return table.concat(text, concatChar)
end


local getArgFieldNodes = function(bufNr)
    local tsParser = vim.treesitter.get_parser(bufNr, "lua")
    local tsTree = tsParser:parse()[1]
    local root = tsTree:root()
    local myQuery = [[
    (assignment_statement
      (variable_list
        (identifier) @the-name
        (#eq? @the-name "pluginArgs"))
      (expression_list
        (table_constructor
          (_)(field
               . (_) @the-first-child))))
    ]]
    local argsQuery = require("vim.treesitter.query").parse_query("lua", myQuery)
    local lastLine = vim.api.nvim_buf_call(bufNr, function()
        ---@diagnostic disable-next-line: redundant-return-value
        return vim.fn.line("$")
    end)

    local nodeTbl = {}
    local index = 0
    for _, node, _ in argsQuery:iter_captures(root, bufNr, 1, lastLine) do
        index = index + 1
        if node:type() ~= "identifier" then
            nodeTbl[#nodeTbl+1] = node
        end
    end

    return nodeTbl
end


local function getPluginInfo(bufNr, nodes)
    local tbl = {
        names = {},
        ranges = {},
        tableCheck = {},
        nodes = {}
    }
    for _, node in ipairs(nodes) do
        local nodeType = node:type()
        local tableCheck = false
        local range = {node:range()}
        table.insert(tbl.ranges, range)

        if nodeType == "table_constructor" then
            tableCheck = true
            local stringNode = node:named_child(0):named_child(0)
            -- Override the range value with the real string field for plug-in
            -- spec table by calling the named_child(0)method twice
            range = {stringNode:range()}
        end

        table.insert(tbl.names,      getNodeText(bufNr, range, 1, 0))
        table.insert(tbl.tableCheck, tableCheck)
        table.insert(tbl.nodes,      node)
    end

    return tbl
end


return function(bufNr, cursorPos, fallback)
    -- Get buffer number from buffer list
    -- bufNr = getBuf()
    if bufNr == -1 then return end

    local fieldNodes = getArgFieldNodes(bufNr)
    if not next(fieldNodes) then
        -- Use fallback when no tsNodes found
        return fallback(bufNr, cursorPos)
    end

    local pluginInfo = getPluginInfo(bufNr, fieldNodes)

    -- Convert cursorPos into (0, 0) index
    local cursor = {cursorPos[1] - 1 ,cursorPos[2]}
    local cursorRange = {}
    local pluginIdx = 0
    for i, range in ipairs(pluginInfo.ranges) do
        if cursor[1] >= range[1] and cursor[1] <= range[3] then
            cursorRange = range
            pluginIdx   = i
            break
        end
    end
    -- Use fallback when cursor is not in any tsNode range
    if pluginIdx == 0 then
        return fallback(bufNr, cursorPos)
    end

    if not pluginInfo.tableCheck[pluginIdx] then
        -- Repository url link
        return "https://github.com/" .. pluginInfo.names[pluginIdx]
    end

    -- Plugin configuration use table specification
    local node = pluginInfo.nodes[pluginIdx]
    local configPat = vim.regex [[\(config\|init\).\{-}=.\{-}conf[ (]\{-}\zs\('\|"\).*\('\|"\)]]
    local configPath = ""
    for n in node:iter_children() do
        if n:named() and n:type() == "field" then
            local range = {n:range()}
            if range[1] < cursorPos[1] then
                local text = getNodeText(bufNr, range, 0, 0, "")
                local idx = {configPat:match_str(text)}
                if next(idx) then
                    local configName = text:sub(idx[1] + 2, idx[2] - 1)
                    configPath = string.format("e %s%slua%sconfig%s%s.lua",
                        _G._configPath, _G._sep, _G._sep, _G._sep, configName)
                    return configPath
                end
            end
        end
    end

    return "https://github.com/" .. pluginInfo.names[pluginIdx]
end

