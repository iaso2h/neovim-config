local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M = {
    writable = [=[[-a-zA-Z0-9"*+_/]]=],
         all = [=[[-a-zA-Z0-9":.%#=*+~/]]=]
}

M.clear = function()
    local regexWritable = vim.regex(M.writable)
    local char
    for i=34, 122 do
        char = string.char(i)
        if regexWritable:match_str(char) then
            fn.setreg(char, "")
        end
    end
    vim.api.nvim_echo({{"Register cleared", "MoreMsg"}}, true, {})
end


M.insertPrompt = function()
    -- TODO: Custom register completion prompt
    local regexAll = vim.regex(M.all)
    local reg
    cmd [[noa reg]]

    cmd [[noa echohl Moremsg]]
    repeat
        reg = fn.input("Register: ")
    until (#reg == 1 and regexAll:match_str(reg)) or vim.notify("    Invalid register name", vim.log.levels.ERROR)
    cmd [[noa echohl None]]

    -- local regContent = reg == "=" and fn.getreg(reg, 1) or fn.getreg(reg, 0)
    local regType    = fn.getregtype(reg)
    local regContent = fn.getreg(reg, 0)

    if regType == "" then
        return
    elseif regType == "V" or regType == "line" then
        regContent = string.gsub(regContent, "\n", "")
        api.nvim_put({regContent}, "c", true, false)
    else
        api.nvim_put({regContent}, "c", true, false)
    end
end

return M

