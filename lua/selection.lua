local api = vim.api
local cmd = vim.cmd
local fn  = vim.fn
local M   = {}


function M.oppoSelection() -- {{{
    local curPos         = api.nvim_win_get_cursor(0)
    local startSelectPos = api.nvim_buf_get_mark(0, "<")
    if startSelectPos[1] == 0 then return end  -- Sanity check
    local endSelectPos   = api.nvim_buf_get_mark(0, ">")
    if curPos[1] == startSelectPos[1] then
        api.nvim_win_set_cursor(0, endSelectPos)
        return
    elseif curPos[1] == endSelectPos[1] then
        api.nvim_win_set_cursor(0, startSelectPos)
        return
    end
    local closerToEnd = require("util").posDist(startSelectPos, curPos) > require("util").posDist(endSelectPos, curPos)
    if closerToEnd then
        local endSelectLen = #api.nvim_buf_get_lines(0, endSelectPos[1] - 1, endSelectPos[1], false)[1]
        if endSelectLen < endSelectPos[2] then
            api.nvim_win_set_cursor(0, {endSelectPos[1], endSelectLen - 1})
        else
            api.nvim_win_set_cursor(0, endSelectPos)
        end
    else
        api.nvim_win_set_cursor(0, startSelectPos)
    end
end -- }}}


M.visualSub = function()
    local str = string.gsub(M.getSelect("string"), [[\]], [[\\]])
    api.nvim_feedkeys(string.format([[:s#\V%s]], str), "nt", false)
end


M.mirror = function()
    cmd("norm! gvd")
    local keyStr = "i" .. string.reverse(fn.getreg("-", 1)) .. t"<ESC>"
    api.nvim_feedkeys(keyStr, "tn", true)
end


-- HACK: different behaviors between vim.getpos() and nvim_buf_get_mark() when selection is empty
M.getSelect = function(returnType, returnNormal) -- {{{
    -- Not support blockwise visual mode
    local mode = fn.visualmode()
    if mode == "\22" then return end
    -- Return (1,0)-indexed line,col info
    local selectStart = api.nvim_buf_get_mark(0, "<")
    local selectEnd = api.nvim_buf_get_mark(0, ">")
    local lines = api.nvim_buf_get_lines(0, selectStart[1] - 1, selectEnd[1],
                                         false)

    if #lines == 0 then
        return {""}
    end
    -- Needed to remove the last character to make it match the visual selction
    if vim.o.selection == "exclusive" then selectEnd[2] = selectEnd[2] - 1 end
    if mode == "v" then
        lines[#lines] = lines[#lines]:sub(1, selectEnd[2] + 1)
        lines[1]      = lines[1]:sub(selectStart[2] + 1)
    end

    if returnNormal then cmd("norm! " .. t"<Esc>") end

    if returnType == "list" then
        return lines
    elseif returnType == "string" then
        return table.concat(lines, "\n")
    end
end -- }}}


return M

