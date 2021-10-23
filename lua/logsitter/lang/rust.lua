local M = {}

function M.log(text, funcStr, cursorPos, insertPos)
    if insertPos[1] < cursorPos[1] then
        cursorPos[1] = cursorPos[1] + 1
    end
    return string.format([[%s("LOG: %s, line %s: %s: " .. %s)]], funcStr, vim.fn.expand("%"), cursorPos[1], text, text)
end

return M

