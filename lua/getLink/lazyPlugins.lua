-- local getBuf = function()
--     local bufNrTbl = vim.api.nvim_list_bufs()
--     for _, bufNr in ipairs(bufNrTbl) do
--         local pluginFilePath = string.format("%s%slua%score%splugins.lua", _G._config_path, _G._sep, _G._sep, _G._sep)
--         if nvim_buf_get_name(bufNr) == pluginFilePath then
--             return bufNr
--         end
--     end

--     return -1
-- end


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

        table.insert(tbl.names,      require("util").getNodeText(bufNr, range, 1, 0))
        table.insert(tbl.tableCheck, tableCheck)
        table.insert(tbl.nodes,      node)
    end

    return tbl
end


return function(bufNr, cursorPos, fallback)
    -- Get buffer number from buffer list
    -- bufNr = getBuf()
    -- if bufNr == -1 then return end
    -- Need Tree-sitter support
    if not package.loaded["nvim-treesitter.parsers"] or
        not require("nvim-treesitter.parsers").has_parser() then
        return fallback(bufNr, cursorPos, vim.api.nvim_get_current_line())
    end

    local pluginRepo = [[
    (assignment_statement
      (variable_list
        (identifier) @the-name
          (#eq? @the-name "pluginArgs"))
        (expression_list
          (table_constructor
            (_)
              (field
                . (_) @the-first-child))))
    ]]
    local dependencyRepo = [[
    (assignment_statement
      (variable_list
        (identifier) @the-plugin-arg
        (#eq? @the-plugin-arg "pluginArgs"))
      (expression_list
        (table_constructor
          (_)
          (field
            (table_constructor
              (field
                (identifier) @dependencies
                (#eq? @dependencies "dependencies")
                (table_constructor
                  (field) @dependency)))))))
    ]]

    -- Get primary plugin node that contains the Github repository string
    local pluginRepoNodes = require("util").getRepoNodes(bufNr, pluginRepo, 2)
    if not next(pluginRepoNodes) then
        -- Use fallback when no tsNodes found
        return fallback(bufNr, cursorPos, vim.api.nvim_get_current_line())
    end

    -- Get the dependencies node that contains the Github repository string
    local dependencyRepoNodes = require("util").getRepoNodes(bufNr, dependencyRepo, 3)

    local pluginInfo = getPluginInfo(bufNr, pluginRepoNodes)

    -- Convert cursorPos into (0, 0) index
    local cursorIdx = {cursorPos[1] - 1 ,cursorPos[2]}
    local pluginIdx = 0
    -- Find which primary plugin table the cursor resides in
    for i, range in ipairs(pluginInfo.ranges) do
        if cursorIdx[1] >= range[1] and cursorIdx[1] <= range[3] then
            pluginIdx = i
            break
        end
    end

    -- Use fallback when cursor is not in any tsNode range
    if pluginIdx == 0 then
        return fallback(bufNr, cursorPos, vim.api.nvim_get_current_line())
    end

    -- Return url if the primary plugin spec for lazy.nvim isn't a table
    if not pluginInfo.tableCheck[pluginIdx] then
        -- Repository url link
        return "https://github.com/" .. pluginInfo.names[pluginIdx]
    end

    -- Plugin use a table specification for the configuration
    local pluginNode = pluginInfo.nodes[pluginIdx]
    local pluginNodeRange = {pluginNode:range()}
    local configRegex = vim.regex [[\(config\|init\).\{-}=.\{-}require[ (]\{-}\('\|"\)config\.\zs.*\ze\('\|"\)]]
    local pluginFieldLines = vim.api.nvim_buf_get_lines(bufNr, pluginNodeRange[1], pluginNodeRange[3] + 1, false)
    -- Loop form the end to check keyword in every line so that cursor can get
    -- snap to the closest available keyword even if it's not on the same line
    for i = #pluginFieldLines, 1, -1 do
        local lineText = pluginFieldLines[i]
        local lineIdx  = pluginNodeRange[3] - (#pluginFieldLines - i) -- 0 indexed
        -- Only check the fields just above the cursorline
        if lineIdx <= cursorIdx[1] then
            -- Try to open the file for the config/init field in path:
            -- <Neovim configuration path>/lua/config/<plugin name>.lua
            ---@diagnostic disable-next-line: need-check-nil
            local idx = {configRegex:match_str(lineText)}
            if next(idx) then
                local configName = lineText:sub(idx[1] + 1, idx[2])
                return string.format("e %s%slua%sconfig%s%s.lua",
                    _G._config_path, _G._sep, _G._sep, _G._sep, configName)
            end

            -- Secondly, check dependency fields
            for _, d in ipairs(dependencyRepoNodes) do
                -- TODO: support nested table dependency plugin specs
                if d:type() == "string" then
                    local dLineIdx = d:range()
                    if lineIdx == dLineIdx then
                        local dependencyRepoName = require("util").getNodeText(bufNr, {d:range()}, 1)
                        if string.find(dependencyRepoName, "/") then
                            return "https://github.com/" .. dependencyRepoName
                        end
                    elseif lineIdx < dLineIdx then
                        -- Only check the fields just above the n node
                        break
                    end
                end
            end
        end
    end

    -- Fall back to the plugin repository url
    return "https://github.com/" .. pluginInfo.names[pluginIdx]
end

