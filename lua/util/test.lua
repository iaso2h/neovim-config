local api = vim.api


--- Find cursor location, visual selected region in buffer lines
---@param lines table
---@param cursorIndicatorChar string
---@param visualRegionChk? boolean
---@return table, table
_G.lineFilterCursor = function(lines, cursorIndicatorChar, visualRegionChk)
    -- Init cursor startup position if cursor indicator exist
    local filterLines  = {}
    local visualRegion = {}
    -- Default location
    local cursorPos = {1, 0}

    -- Find cursor position
    for idx, line in ipairs(lines) do
        if not visualRegionChk then
            local col = string.find(line, cursorIndicatorChar, 1, true)
            if col then
                -- {1, 0} index based, ready for api.nvim_win_set_cursor()
                cursorPos = {idx - 1, col - 1}
            else
                filterLines[#filterLines+1] = line
            end
        else
            -- Find cursor indicator character in every line
            local col = 1
            local cursorFound = false
            repeat
                col = string.find(line, cursorIndicatorChar, col, true)
                if col then
                    -- {1, 0} index based, ready for api.nvim_win_set_cursor()
                    if #lines == 0 then
                        -- Position of the visual start
                        visualRegion[#visualRegion+1] = {idx - 1, col - 1}
                    else
                        -- Position of the visual end
                        visualRegion[#visualRegion+1] = {#lines, col - 1}
                    end
                    cursorFound = true

                    -- Entering next iteration from the next colmun
                    col = col + 1
                end
            until not col

            -- Skip the current for loop iteration
            if not cursorFound then
                lines[#lines+1] = line
            end
        end
    end

    if not visualRegionChk then
        return filterLines, cursorPos
    else
        assert.are.same(2, #visualRegion)
        return filterLines, visualRegion
    end
end


---
---@param lines table
---@param filetype string
---@param cursorIndicatorChar string
---@param visualCMD? string Noremap version of ex command to start a visual selection
---@param visualRegionChk? boolean Whether to setup to visual selection
--area. Following can revisit it by invoking "gv"
---@param cursorAtEnd? boolean Whether to place cursor at the end of visual
--selection area or the beginning
_G.initLinesCursor = function(lines, filetype, cursorIndicatorChar, visualCMD, visualRegionChk, cursorAtEnd)
    local bufNr = api.nvim_create_buf(false, true)
    local cursorPos
    lines, cursorPos = lineFilterCursor(lines, cursorIndicatorChar, visualRegionChk)

    -- Setting up buffer lines
    api.nvim_buf_set_option(bufNr, 'filetype', filetype)
    api.nvim_win_set_buf(0, bufNr)
    api.nvim_buf_set_lines(bufNr, 0, -1, true, lines)

    -- Setting up cursor position
    if not visualRegionChk then
        api.nvim_win_set_cursor(0, cursorPos)
    else
        if visualRegionChk and cursorAtEnd then
            api.nvim_win_set_cursor(0, cursorPos[1])
            vim.cmd([[noa norm! ]] .. visualCMD)
            api.nvim_win_set_cursor(0, cursorPos[2])
            vim.cmd([[noa norm! ]] .. t"<Esc>")
        else
            api.nvim_win_set_cursor(0, cursorPos[2])
            vim.cmd([[noa norm! ]] .. visualCMD)
            api.nvim_win_set_cursor(0, cursorPos[1])
            vim.cmd([[noa norm! ]] .. t"<Esc>")
        end
    end
end


--- Run command and then assert the output with expected
--- @param feedkeys string Commands to execute in Neovim
_G.feedkeysOutput = function(feedkeys) -- {{{
    api.nvim_feedkeys(api.nvim_replace_termcodes(feedkeys, true, true, true),
                        "x", false)
    local outputLines = api.nvim_buf_get_lines(0, 0, -1, false)
    local outputCursorPos = api.nvim_win_get_cursor(0)
    return outputLines, outputCursorPos
end -- }}}
