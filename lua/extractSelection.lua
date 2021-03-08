local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local util = require("util")
local M   = {}

function M.main(modeType)
    if string.lower(modeType) ~= "v" then return end
    if modeType == "v" then
        local selectStart = api.nvim_buf_get_mark(0, "<")
        local selectEnd = api.nvim_buf_get_mark(0, ">")
        api.nvim_win_set_cursor(0, selectStart)
        cmd [[normal! V]]
        api.nvim_win_set_cursor(0, selectEnd)
    end

    local CWD = fn.getcwd()
    -- Check CWD {{{
    if fn.has('win32') == 1 then
        -- Check file cwd"
        local newCWD = fn.expand("%:p:h")
        if CWD ~= newCWD then
            local answer = fn.confirm("Change CWD to \"" .. newCWD .. "\"?", "&Yes\n&No")
            if answer == 1 then
                cmd("cd " .. newCWD)
                CWD = newCWD
            elseif answer == 0 then
                return
            end
        end
    end
    api.nvim_echo({{"CWD: " .. CWD, "Moremsg"}}, false, {})
    -- }}} Check CWD
    local answer = fn.input("Enter new file path: ")
    -- Check valid input
    if answer == "" then return end
    -- Find slash
    local byteSlashIndex = util.matchAll(answer, '/')
    if not next(byteSlashIndex) then byteSlashIndex = util.matchAll(answer, '/') end

    local filePath
    local selectedText
    if next(byteSlashIndex) then -- Slash exist
        if byteSlashIndex == #answer - 1 then
            api.nvim_echo({{"Invalid file path", "WarningMsg"}}, false, {})
            return
        end
        selectedText = util.visualSelection("string")
        -- Refine file path
        if answer[1] == "/" or answer[1] == '\\' then
            filePath = CWD .. answer
        elseif string.sub(answer, 1, 2) == './' then
            filePath = CWD .. string.sub(answer, 2)
        else
            filePath = CWD .. "/" .. answer
        end
        -- Make sure folder created before file creation
        local absFolder = string.sub(filePath, 1, byteSlashIndex[#byteSlashIndex] + #CWD + 1)
        fn.mkdir(absFolder, "p")
    else -- Slash does not exist
        filePath = answer
        selectedText = util.visualSelection("string")
    end

    local f = io.open(filePath, "w")
    if not f then
        api.nvim_echo({{"Unable to create file: " .. filePath, "ErrorMsg"}}, false, {})
        return
    end
    f:write(selectedText)
    f:close()
    api.nvim_echo({{"File created: " .. filePath, "false"}}, true, {})
    -- Delete selection code
    util.saveReg()
    cmd [[normal! gvd]]
    util.restoreReg()
    local openFileAnswer = fn.confirm("Open and edit new file?", "&Yes\n&No", 1)
    if openFileAnswer == 1 then cmd("e " .. filePath) end
end

return M

