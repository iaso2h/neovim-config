-- File: trailingChar
-- Author: iaso2h
-- Description: Add character at the end of line
-- Version: 0.0.8
-- Last Modified: 2024-01-31
local ts  = vim.treesitter

--- Find if a comment node exist in a line
---@param commentStr string The trimmed version of vim.bo.commentstring
---@param char string The character to be added
---@param line string The value of current line
local trailingMarkerFallback = function(commentStr, char, line)
    if char == "{" then
        vim.api.nvim_set_current_line(line .. " " .. commentStr .. " {{{")
    elseif char == "}" then
        vim.api.nvim_set_current_line(line .. " " .. commentStr .. " }}}")
    end
end


--- Find if a comment node exist in a line, start at col 2
---@param cursorPos table (0, 0) indexed. Row(Line) and column.
---@param cursorNode TSNode The treesitter object can be retrieved by calling `ts.get_node_at_post(0, <lineNum>, 0)`. The row and column value is (0, 0) indexing
---@param cursorLineLen integer The length of current line
---@return integer # Whether comment node is found
local function findCommentNode(cursorPos, cursorNode, cursorLineLen) -- {{{
    local cnt = 0
    local i = 1 -- 1 indexing
    repeat
        -- Break condition 1
        if i > cursorLineLen then
            i = i - 1
            return -1
        end

        -- Break condition 2
        local node = ts.get_node {0, cursorPos[1], i}
        if not node then
            vim.notify("Failed to get treesitter node", vim.log.levels.WARN)
            return -1
        end

        -- Break condition 3
        if node:type() == "comment" or
            node:type() == "comment_content" or
            node:type () == "TSComment" then

            return i
        end

        local range = { node:range() }
        if node:id() == cursorNode:id() then
            -- Next loop start at the end column of the same node
            i = range[4] + 1
        else
            i = i + 1
            cursorNode = node
        end

        -- Break condition 4
        cnt = cnt + 1
        if cnt > 20 then
            vim.notify("Loop too many times", vim.log.levels.WARN)
            return -1
        end
    until false
end -- }}}


--- Find if a comment node exist in a line
---@param cursorPos table (1, 0) based. Row(Line) and column.
---@param line string The value of current line
---@param char string The character to be added
local trailingMarker = function(cursorPos, line, char)
    local commentStr
    local ok, msg = pcall(string.gsub, vim.bo.commentstring, "%s+%%s$", "")
    if not ok then
        vim.notify("Failed at retrieving comment string", vim.log.levels.ERROR)
        return vim.notify(msg, vim.log.levels.ERROR)
    else
        commentStr = msg
    end

    local lineLen = #line
    if lineLen == 0 then
        trailingMarkerFallback(commentStr, char, line)
    end
    -- Convert to (0, 0) based
    local cursorIdx = { cursorPos[1] - 1, cursorPos[2] }

    -- Use treesitter to find comment node
    local cursorNode = ts.get_node {0, cursorIdx[1], 1}
    if not cursorNode then
        vim.notify("Failed to get treesitter node. Using fallback func", vim.log.levels.WARN)
        return trailingMarkerFallback(commentStr, char, line)
    end
    if cursorNode:has_error() then
        return vim.notify("Fix the syntax error first", vim.log.levels.WARN)
    end

    local commentNodeStartColumn = findCommentNode(cursorIdx, cursorNode, lineLen)
    if commentNodeStartColumn == -1 then
        trailingMarkerFallback(commentStr, char, line)
    else
        local newLine
        if char == "{" then
            newLine = line .. " {{{"
        else
            local commentStrIdx = { string.find(line, commentStr, commentNodeStartColumn, true) }
            if not next(commentStrIdx) then
                return vim.notify("Failed to index comment string in: " .. line, vim.log.levels.ERROR)
            end

            if commentStrIdx[1] == 1 then
                newLine = commentStr .. " }}}" .. string.sub(line, commentStrIdx[2] + 1, -1)
            else
                newLine = string.sub(line, 1, commentStrIdx[2]) ..
                    " }}}" .. string.sub(line, commentStrIdx[2] + 1, -1)
            end
        end


        vim.api.nvim_set_current_line(newLine)
    end
end


local function findEmptyLine(line)
    return string.find(line, "^$")
end


--- Add trailing character in current line
---@param vimMode string
---@param char string
return function(vimMode, char) -- {{{
    local cursorPos = vim.api.nvim_win_get_cursor(0)
    local lines
    if vimMode == "n" then
        lines = vim.api.nvim_buf_get_lines(0, cursorPos[1] - 1, cursorPos[1], false)[1]

        if char == "{" or char == "}" then
            trailingMarker(cursorPos, lines, char)
        else
            vim.api.nvim_set_current_line(lines .. char)
        end
    else
        local startPos = vim.api.nvim_buf_get_mark(0, "<")
        local endPos   = vim.api.nvim_buf_get_mark(0, ">")
        lines = vim.api.nvim_buf_get_lines(0, startPos[1] - 1, endPos[1], false)

        if char == "{" or char == "}" then
            local commentStr
            local ok, msg = pcall(string.gsub, vim.bo.commentstring, "%s+%%s$", "")
            if not ok then
                vim.notify("Failed at retrieving comment string", vim.log.levels.ERROR)
                return vim.notify(msg, vim.log.levels.ERROR)
            else
                commentStr = msg
            end

            -- Get user note
            local note
            vim.cmd [[noa echohl Moremsg]]
            ok, msg = pcall(vim.fn.input, "Comment for fold marker: ")
            vim.cmd [[noa echohl None]]
            if not ok then
                if string.find(msg, "Keyboard interrupt") then
                    note = ""
                else
                    return vim.notify(msg, vim.log.levels.ERROR)
                end
            else
                note = msg
            end

            -- Decide fold marker type
            local topEmpty = findEmptyLine(lines[1])
            local botEmpty = findEmptyLine(lines[#lines])
            local newLine
            -- Whole line fold marker
            if topEmpty or botEmpty then
                -- Always put empty line at the very end of visual selection
                if topEmpty then
                    newLine = require("register").indentCopy(startPos[1] + 1) .. commentStr .. " " .. note .. " {{{"
                    table.insert(lines, 2, newLine)
                else
                    newLine = require("register").indentCopy(startPos[1]) .. commentStr .. " " .. note .. " {{{"
                    table.insert(lines, 1, newLine)
                end

                if botEmpty then
                    newLine = require("register").indentCopy(endPos[1] - 1) .. commentStr .. " }}}"
                    table.insert(lines, #lines, newLine)
                else
                    newLine = require("register").indentCopy(endPos[1]) .. commentStr .. " }}}"
                    lines[#lines + 1] = newLine
                end
            else
                -- Inline fold marker
                if note == "" then
                    newLine = " " .. commentStr .. note .. " {{{"
                else
                    newLine = " " .. commentStr .. " " .. note .. " {{{"
                end
                lines[1] = lines[1] .. newLine

                newLine = " " .. commentStr .. " }}}"
                lines[#lines] = lines[#lines] .. newLine
            end
        else
            for i, line in ipairs(lines) do
                -- Skip blank line
                if not findEmptyLine(line) then
                    lines[i] = line .. char
                end
            end
        end

        -- Replace lines
        vim.api.nvim_buf_set_lines(0, startPos[1] - 1, endPos[1], false, lines)
    end
end -- }}}
