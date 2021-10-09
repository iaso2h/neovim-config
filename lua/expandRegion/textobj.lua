local fn     = vim.fn
local cmd    = vim.cmd
local api    = vim.api
local ts     = require("expandRegion.treesitter")
local util   = require("util")
local M    = {}


--- Get the start position and end position of the visual selected area
--- @param curBufNr number current buffer number
--- @return table
M.getVisualStartEnd = function(curBufNr)
    return api.nvim_buf_get_mark(curBufNr, "<"), api.nvim_buf_get_mark(curBufNr, ">")
end


--- Compare the selected text object region with treesitter node
--- @param selection table a text object region table
--- @param tsNode object treesitter node
--- @return boolean whether both the region infos provided by parameter is the same
M.compareWithNode = function(selection, tsNode)
    local tsNodeRange
    if tsNode:type() == "string" then
        tsNodeRange = ts.getNodeRange(tsNode, true)
    else
        tsNodeRange = ts.getNodeRange(tsNode)
    end
    return util.compareDist(selection.posStart, tsNodeRange.posStart) == 0
        and util.compareDist(selection.posEnd, tsNodeRange.posEnd) == 0
end


--- Generate a region table contain different types of text object, might
--- contain duplicated items
--- @param textObjTbl table list-liked text object table
--- @param curBufNr number current buffer number
--- @param tsNode object treesitter node
--- @return table region table
M.getTextObjSelection = function(textObjTbl, curBufNr, tsNode)
    local saveView
    local selectionTbl = {}
    for _, textObj in ipairs(textObjTbl) do
        saveView = fn.winsaveview()
        cmd([[noa norm v]] .. textObj .. t"<Esc>")

        -- Store selection info in a table. e.g.
        -- {textObj = ..., length = ..., content = ..., posStart = ..., posEnd = ...}
        local selection = {textObj = textObj, type = "textObj"}
        selection.posStart, selection.posEnd = M.getVisualStartEnd(curBufNr)
        if util.compareDist(selection.posStart, selection.posEnd) == 0 then
            selection.content = ""
            selection.length  = 0
        else
            selection.content = require("selection").getSelect("string", true)
            selection.length  = #selection.content
        end

        -- Need to correct the i,w and iB text objects due to some malfunctions
        if selection.textObj == "i,w" then
            -- TODO: improve ,w textobj
            local line = api.nvim_buf_get_lines(0, selection.posStart[1] - 1,
                                            selection.posStart[1], false)[1]
            local selectChars
            if selection.posStart[1] == selection.posEnd[1] then
                selectChars = string.sub(line, selection.posStart[2] + 1,
                                                selection.posEnd[2] + 1)

                local nonWordIdx  = string.find(selectChars, "%W")
                -- HACK:make ,w not select the non-word character
                if nonWordIdx then
                    selection.content = string.sub(selection.content, 1, nonWordIdx - 1)
                    selection.posEnd  = {selection.posStart[1],
                                        selection.posStart[2] + nonWordIdx - 2}
                    selection.length  = nonWordIdx - 1
                end
            else
                selectChars = string.sub(line, selection.posStart[2] + 1, #line)
                selection.content = selectChars
                selection.posEnd  = {selection.posStart[1],
                                    selection.posStart[2] + #selectChars - 1}
                selection.length  = #selectChars
            end
        elseif selection.textObj == "iB" then
            local line = api.nvim_buf_get_lines(0, selection.posEnd[1] - 1,
                                            selection.posEnd[1], false)[1]
            if #line == selection.posEnd[2] then
                selection.content = string.sub(selection.content,
                                            1, #selection.content - 1)
                selection.posEnd  = {selection.posEnd[1], selection.posEnd[2] - 1}
                selection.length  = selection.length - 1
            end
        end


        fn.winrestview(saveView)
        selectionTbl[#selectionTbl+1] = selection

        -- Stop parsing text objects when found a treesitter node has the same
        -- selection region
        if tsNode and M.compareWithNode(selection, tsNode) then
            -- Delete the last text object since it has the same region of the
            -- treesitter node. Use treesitter instead. Except for string node,
            -- because region of string node will wrap around the ""(quotation
            -- mark), and "inside" method text object cannot produce this
            -- effect yet.
            if tsNode:type() ~= "string" then
                selectionTbl[#selectionTbl] = nil
            end

            break
        end
    end

    return selectionTbl
end


--- Remove the items with the same length and same position of column and row
--- @param tbl table position table. e.g. {pos}
--         {textObj = ..., length = ..., content = ..., posStart = ..., posEnd = ...}
--- @return table with unique length
M.removeDuplicate = function(tbl)
    local i = 1
    local t = {}
    while i < #tbl do
        if not(tbl[i].length == tbl[i+1].length
            and tbl[i].posStart[2] == tbl[i+1].posStart[2]) then

            t[#t+1] = tbl[i]
        end
        i = i + 1
    end
    -- Always add the last item
    t[#t+1] = tbl[i]

    return t
end


--- Generate a region table containing different types of text object
--- @param opts table option table
--- @param curBufNr number current buffer number
--- @param cursorPos table cursor position of current window
--- @param tsNode object treesitter node
--- @return table region table
M.getTextObj = function(opts, curBufNr, cursorPos, tsNode)

    local filterSelection = function(i)
        return i.length > 1 and util.withinRegion(cursorPos, i.posStart, i.posEnd)
    end

    local cnt = 1
    local textObjTbl
    local selectionTbl

    repeat
        if cnt == 1 then
            textObjTbl = opts.textObjs
        else
            textObjTbl = vim.tbl_map(function(i) return string.rep(i, cnt) end, opts.textObjs)
        end
        selectionTbl = M.getTextObjSelection(textObjTbl, curBufNr, tsNode)
        if not next(selectionTbl) then
            return selectionTbl
        end
        -- Avoide the last selection is empty
        if selectionTbl[#selectionTbl].length == 0 then
            cmd([[noa norm v]]  .. t"<Esc>")
        end

        -- Sort by text length
        table.sort(selectionTbl, function(a, b) return b.length > a.length end)
        -- Filter out selection out of cursor scope
        selectionTbl = vim.tbl_filter(filterSelection, selectionTbl)

        cnt = cnt + 1
    until #selectionTbl ~= 0 or cnt == 3

    return M.removeDuplicate(selectionTbl)
end

return M
