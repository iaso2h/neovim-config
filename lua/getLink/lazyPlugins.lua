--- Retrieve plugin repository infos via treesitter
---@class nodeInfo
---@field names string[] Node names
---@field specRanges table Node ranges
---@field tableCheck boolean[] Whether the node at different index is a table node
---@field nodes userdata[] Tressitter nodes
---@param bufNr integer Buffer number
---@param nodes userdata Tressitter node
---@return nodeInfo
local function getPluginInfo(bufNr, nodes) -- {{{
    local tbl = {
        names = {},
        specRanges = {},
        tableCheck = {},
        nodes = {}
    }
    for _, node in ipairs(nodes) do
        local nodeType = node:type()
        local tableCheck = false
        local specRange = {node:range()}
        local repoRange

        if nodeType == "table_constructor" then
            tableCheck = true
            local stringNode = node:named_child(0):named_child(0)
            if not stringNode then
                vim.notify("Plugin specs doesn't follow the correct structure: https://github.com/folke/lazy.nvim#-plugin-spec", vim.log.levels.ERROR)
                vim.notify(string.format("Error node index: (%d, %d)", specRange[1], specRange[2]))
                return {}
            end
            repoRange = { stringNode:range() }
        else
            repoRange = specRange
        end

        table.insert(tbl.specRanges, specRange)
        table.insert(tbl.names,      require("util").getNodeText(bufNr, repoRange, 1, 0))
        table.insert(tbl.tableCheck, tableCheck)
        table.insert(tbl.nodes,      node)
    end

    return tbl
end -- }}} 
--- Get the Github repository url link near cursor or open the configration file
---@param bufNr integer Buffer number
---@param cursorPos table (1, 0) based
---@param fallback function the fallback function to handle the link at the `cursorPos`
---@return string # The url string
return function(bufNr, cursorPos, fallback) -- {{{
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
    local pluginRepoNodes = require("util").getQueryNodes(bufNr, pluginRepo, 2)
    if not next(pluginRepoNodes) then
        -- Use fallback when no tsNodes found
        return fallback(bufNr, cursorPos, vim.api.nvim_get_current_line())
    end

    -- Get the dependencies node that contains the Github repository string
    local dependencyRepoNodes = require("util").getQueryNodes(bufNr, dependencyRepo, 3)

    -- pluginsInfo = {specRanges, names, tableCheck, nodes}
    local pluginInfos = getPluginInfo(bufNr, pluginRepoNodes)
    if not next(pluginInfos) then return "" end

    -- Convert cursorPos into (0, 0) index
    local cursorIdx = {cursorPos[1] - 1 ,cursorPos[2]}
    local pluginIdx = 0

    -- Figure out which plugin specification table the cursor resides in
    for i, range in ipairs(pluginInfos.specRanges) do
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
    if not pluginInfos.tableCheck[pluginIdx] then
        -- Repository url link
        return "https://github.com/" .. pluginInfos.names[pluginIdx]
    end

    -- Plugin use a table specification for the configuration
    local pluginSpecRange = pluginInfos.specRanges[pluginIdx]
    local configRegex = vim.regex [[\(config\|init\).\{-}=.\{-}require[ (]\{-}\('\|"\)plugins\.\zs.*\ze\('\|"\)]]
    local pluginSpecLines = vim.api.nvim_buf_get_lines(bufNr, pluginSpecRange[1], pluginSpecRange[3] + 1, false)
    -- Loop form the end to check keyword in every line so that cursor can get
    -- snap to the closest available keyword even if it's not on the same line
    for i = #pluginSpecLines, 1, -1 do
        local lineText = pluginSpecLines[i]
        local lineIdx  = pluginSpecRange[3] - (#pluginSpecLines - i) -- 0 indexed
        -- Only check the fields just above the cursorline
        if lineIdx <= cursorIdx[1] then
            -- Try to open the file for the plugins/init field in path:
            -- <Neovim configuration path>/lua/config/<plugin name>.lua
            ---@diagnostic disable-next-line: need-check-nil
            local idx = {configRegex:match_str(lineText)}
            if next(idx) then
                local configName = lineText:sub(idx[1] + 1, idx[2])
                return string.format("e %s/lua/plugins/%s.lua", _G._config_path, configName)
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
    return "https://github.com/" .. pluginInfos.names[pluginIdx]
end -- }}} 
