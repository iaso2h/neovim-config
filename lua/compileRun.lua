local util = require("util")
local M   = {
    flags = {
        c   = "-Wall -Wextra -std=c99 -g",
        cpp = "-Wall -Wextra -std=c+11 -g"
    }
}

--- Compile the code in current buffer
---@param useAsyncRun boolean Whether to use AsyncRun plug-in to display the compile result
function M.compileCode(useAsyncRun) -- {{{
    local srcPath  = vim.fn.expand("%:p")
    local srcNoExt = vim.fn.expand("%:p:r")
    local fileType = vim.bo.filetype
    if fileType == "c" then
        local ext = _G._os_uname.sysname == "Windows_NT" and ".exe" or ".out"
        local prog

        if util.ex("clang") then
            prog = "clang"
        elseif util.ex("gcc") then
            prog = "gcc"
        else
            return vim.api.nvim_echo({ { "No compiler found" } }, true, { err=true })
        end
        local compileCMD = string.format("%s %s %s -o %s%s", prog, M.flags.c, srcPath, srcNoExt, ext)
        vim.g.asyncrun_status = 0
        if useAsyncRun then
            vim.cmd("AsyncRun " .. compileCMD)
        else
            vim.fn.system(compileCMD)
        end
        return srcNoExt .. ext
    elseif fileType == "cpp" then
        local ext = vim.fn.has("win32") == 1 and ".exe" or ""
        local prog

        if vim.fn.executable('clang') == 1 then
            prog = 'clang++'
        elseif vim.fn.executable('gcc') == 1 then
            prog = 'gcc++'
        else
            vim.api.nvim_echo({{"No C++ compiler found!", "WarningMsg"}}, false, {})
            return
        end
        local compileCMD = string.format("%s %s %s -o %s%s", prog, M.flags.cpp, srcPath, srcNoExt, ext)
        vim.g.asyncrun_status = 0
        if useAsyncRun then
            vim.cmd("AsyncRun " .. compileCMD)
        else
            vim.fn.system(compileCMD)
        end
        return srcNoExt .. ext
    elseif vim.bo.filetype == "lua" then
        if useAsyncRun then
            vim.cmd [[AsyncRun lua %]]
        else
            vim.fn.system("lua" .. vim.fn.expand("%:p"))
        end
    elseif vim.bo.filetype == "python" then
        if useAsyncRun then
            vim.cmd(vim.fn.has("win32") == 1 and "AsyncRun python %" or "AsyncRun python3 %")
        else
            vim.fn.system(vim.fn.has("win32") == 1 and "python " .. vim.fn.expand("%:p") or "python3" .. vim.fn.expand("%:p"))
        end
    end
end -- }}}
--- Run the code in Neovim terminal
function M.runCode() -- {{{
    -- Close the current window if it's a quickfix window
    if vim.bo.buftype == "quickfix" then
        vim.cmd [[cclose]]
    end
    -- Close quickfix in other windows
    local winInfos = vim.fn.getwininfo()
    for _, winInfo in ipairs(winInfos) do
        if winInfo["quickfix"] == 1 then
            vim.api.nvim_win_close(winInfo.winid, false)
        end
    end

    if vim.bo.modified then vim.cmd "up" end
    vim.api.nvim_echo({{"\n", "Normal"}}, false, {})
    if vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
        if vim.fn.has("win32") == 1 then
            vim.cmd [[!%:p:r]]
        else
            vim.cmd [[!%:p:r.out]]
        end
    elseif vim.bo.filetype == "lua" then
        vim.cmd [[AsyncRun lua %]]
    elseif vim.bo.filetype == "python" then
        vim.cmd(vim.fn.has("win32") == 1 and "AsyncRun python %" or "AsyncRun python3 %")
    elseif vim.bo.filetype == "cs" then
        vim.cmd [[AsyncRun dotnet run]]
    end
end -- }}}


return M
