local api = vim.api


local getClosestTopNonFoldLine = function(topline, cursorline)
    local nonFoldRegions = require("snapToFold").getAllNonFoldRegion(topline, cursorline)
    if next(nonFoldRegions) then
        return nonFoldRegions[#nonFoldRegions][1]
    else
        return nil
    end
end


local findTsNode = function(roughResult)
    -- Find parent node at the same line as the initNode is
    local ts = require("vim.treesitter")
    local initNode = ts.get_node{ bufNr = 0, pos = {roughResult.row - 1, roughResult.col - 1} }
    if not initNode then return end
    local initLine = initNode:range() -- (0, 0) indexed
    local parentNode
    local parentNodeLine
    if initNode:type() == roughResult.nodeType then
        return initNode
    else
        local node = initNode
        repeat
            parentNode = node:parent()
            parentNodeLine = parentNode:range() -- (0, 0) indexed
            if parentNode:type() == roughResult.nodeType then
                return parentNode
            end

            node = parentNode
        until parentNodeLine ~= initLine
    end

    return nil
end


local regexMatch = function(cursorPos, roughResult, funcNode)
    -- Pass the function line along with the correspoding offet lines to find the
    -- keyword
    local funcNodeLineIdx = #roughResult.lines - (cursorPos[1] - (funcNode:range() + 1))
    local endLineIdx = funcNodeLineIdx + roughResult.lineOffset
    -- Make sure the endLineIdx does not get out of scope
    endLineIdx = endLineIdx > #roughResult.lines and #roughResult.lines or endLineIdx
    local funcLines = {}
    for i = endLineIdx, funcNodeLineIdx, -1 do
        funcLines[#funcLines+1] = roughResult.lines[i]
    end
    -- Find the keyword string precisely
    for _, line in ipairs(funcLines) do
        local urlStart, urlEnd = vim.regex(roughResult.precisePat):match_str(line)
        if urlStart then
            if roughResult.githubRepo then
                local url = "https://github.com/" .. string.sub(line, urlStart + 2, urlEnd - 1)
                return url
            elseif roughResult.configFile then
                local configName = string.sub(line, urlStart + 2, urlEnd - 1)
                local cmdStr = string.format("e %s%slua%sconfig%s%s.lua",
                    _G._configPath, _G._sep, _G._sep, _G._sep, configName)
                vim.cmd(cmdStr)
                return
            end
        end
    end
end


return function()
    local fn = vim.fn
    local cursorPos  = api.nvim_win_get_cursor(0)

    -- Avoid parsing through too many lines when there are folded lines above the cursor
    local topline = getClosestTopNonFoldLine(fn.line("w0"), cursorPos[1])
    local halfWinTopline = cursorPos[1] - math.floor(api.nvim_win_get_height(0) / 2)
    halfWinTopline = halfWinTopline < 1 and 1 or halfWinTopline
    if not topline or halfWinTopline > topline then
        topline = halfWinTopline
    else
        topline = topline
    end
    local lines = api.nvim_buf_get_lines(0, topline, cursorPos[1], false)

    -- Find the keyword string roughly upward from cursorline
    local useIdx
    local confIdx
    local requireIdx
    for i = #lines, 1, -1 do
        local line = lines[i]

        -- Support for capturing a Github repository string after a use()
        -- function call or a requires attribute, then opening up the URL
        -- address
        useIdx     = string.find(line, "use%W")
        requireIdx = string.find(line, "requires%W")
        -- Support for opening the neovim plugin configuration file after a
        -- setup or a config attribute
        confIdx    = string.find(line, "conf%W")

        if useIdx or confIdx or requireIdx then

            -- whatever appears first will decide the the precise pattern to match against
            local roughResult = {
                lines = lines,
                lineOffset = 0,
                row = cursorPos[1] - (#lines - i)
            }

            if useIdx or requireIdx then
                roughResult.col = requireIdx or useIdx
                -- Take the next line adjacent to "use() / requires = " into account
                -- eg:
                -- line 187: use/requires = {
                -- line 188: 'phaazon/hop.nvim',
                -- line 189: ..
                -- line 190: }
                roughResult.lineOffset = 1
                -- Precise pattern is use for regex pattern matching after a ts
                -- node is found
                roughResult.nodeType   = requireIdx and "field" or "function_call"
                roughResult.precisePat = [[^\s*\(use\|requires\)\?\s*\zs\('\|"\)\w.\{-}\/.\{-}\('\|"\)]]
                roughResult.githubRepo = true
            elseif confIdx then
                roughResult.col = confIdx

                roughResult.nodeType   = "function_call"
                roughResult.precisePat = [[\(config\|setup\).\{-}=.\{-}conf[ (]\{-}\zs\('\|"\).*\('\|"\)]]
                roughResult.configFile = true
            end

            -- Confirm that the rough result is the identifier of a function call
            local funcNode = findTsNode(roughResult)
            if funcNode then
                -- Use the regex to match against the keyword and compose a url
                -- string to return
                return regexMatch(cursorPos, roughResult, funcNode)
            else
                -- Entering the next iteration of for loop
            end
        else
            -- Entering the next iteration of for loop
        end
    end
end
