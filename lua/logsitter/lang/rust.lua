local M = {}

function M.log(text, funcStr, cursorPos)
    return string.format([[%s("LOG: %s, line %s: %s: " .. %s)]], funcStr, vim.fn.expand("%"), cursorPos[1], label, text)
end

return M

