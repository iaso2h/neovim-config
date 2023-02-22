-- File: trailingChar
-- Author: iaso2h
-- Description: Add character at the end of line
-- Version: 0.0.4
-- Last Modified: 2023-2-22
local api = vim.api
local ts  = vim.treesitter
local M   = {}

--- Find if a comment node exist in a line
---@param commentStr string The trimed version of vim.bo.commentstring
---@param char string The character to be added
---@param line string The value of current line
local trailingMarkerFallback = function(commentStr, char, line)
    if char == "{" then
        api.nvim_set_current_line(line .. " " .. commentStr .. " {{{")
    elseif char == "}" then
        api.nvim_set_current_line(line .. " " .. commentStr .. " }}}")
    end
end


--- Find if a comment node exist in a line
---@param cursorPos table (0, 0) based. Row(Line) and column.
---@param lastNode object The treesitter object retrieved by calling
---ts.get_node_at_post(0, <linenum>, 0)
---@param lineLen number The length of current cursor
---@return boolean Whether comment node is found
local function findCommentNode(cursorPos, lastNode, lineLen)
    local commentTick = false
    local cnt = 0
    local i = 1
    repeat
        local node = ts.get_node_at_pos(0, cursorPos[1], i)
        if not node then
            vim.notify("Failed to get treesitter node", vim.log.levels.WARN)
            return commentTick
        end

        local range = {node:range()}

        if range[1] == cursorPos[1] and node:id() == lastNode:id() then
            i = range[4]
        else
            i = i + 1
            lastNode = node
        end

        if node:type() == "comment" then
            commentTick = true
            break
        end

        cnt = cnt + 1
        if cnt > 50 then
            break
        end
    until i > lineLen

    return commentTick
end


--- Find if a comment node exist in a line
---@param cursorPos table (0, 0) based. Row(Line) and column.
---@param line string The value of current line
---@param char string The character to be added
local trailingMarker = function (cursorPos, line, char)
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
    cursorPos = {cursorPos[1] - 1, cursorPos[2]}


    -- Use treesitter to find comment node
    -- Get node across line
    local lastNode = ts.get_node_at_pos(0, cursorPos[1], 0)

    if not lastNode then
        vim.notify("Failed to get treesitter node. Using fallback func", vim.log.levels.WARN)
        return trailingMarkerFallback(commentStr, char, line)
    end
    if lastNode:has_error() then
        return vim.notify("Fix the syntax error first", vim.log.levels.WARN)
    end


    -- Call ts.get_node_at_pos() at every row until eol
    if not findCommentNode(cursorPos, lastNode, lineLen) then
        trailingMarkerFallback(commentStr, char, line)
    else
        local newLine
        if char == "{" then
            newLine = line .. " {{{"
        else
            local commentStrIdx = {string.find(line, commentStr, 1, true)}
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


--- Add trailing character
---@param char string
function M.main(char) -- {{{
    local cursorPos = api.nvim_win_get_cursor(0)
    local line = api.nvim_buf_get_lines(0, cursorPos[1] - 1,cursorPos[1], false)[1]
    if char == "{" or char == "}" then
        trailingMarker(cursorPos, line, char)
    else
        -- local curLine = api.nvim_get_current_line()
        -- if string.sub(curLine, #curLine) ~= trailingChar then
            vim.cmd("noa normal! A" .. char)
            api.nvim_win_set_cursor(0, cursorPos)
        -- end
    end
end -- }}}

return M

