local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {
    flags = {
        c   = "-Wall -Wextra -std=c99 -g",
        cpp = "-Wall -Wextra -std=c+11 -g"
    }
}

function M.compileCode(useAsyncRun)
    local srcPath  = fn.expand('%:p')
    local srcNoExt = fn.expand('%:p:r')
    local fileType = vim.bo.filetype
    if fileType == "c" then
        local ext = fn.has("win32") == 1 and ".exe" or ".out"
        local prog

        if fn.executable('clang') == 1 then
            prog = 'clang'
        elseif fn.executable('gcc') == 1 then
            prog = 'gcc'
        else
            api.nvim_echo({{"No C compiler found!", "WarningMsg"}}, false, {})
            return
        end
        local compileCMD = string.format("%s %s %s -o %s%s", prog, M.flags.c, srcPath, srcNoExt, ext)
        vim.g.asyncrun_status = 0
        if useAsyncRun then
            cmd("AsyncRun " .. compileCMD)
        else
            fn.system(compileCMD)
        end
        return srcNoExt .. ext
    elseif fileType == "c" then
        local ext = fn.has("win32") == 1 and ".exe" or ""
        local prog

        if fn.executable('clang') == 1 then
            prog = 'clang++'
        elseif fn.executable('gcc') == 1 then
            prog = 'gcc++'
        else
            api.nvim_echo({{"No C++ compiler found!", "WarningMsg"}}, false, {})
            return
        end
        local compileCMD = string.format("%s %s %s -o %s%s", prog, M.flags.cpp, srcPath, srcNoExt, ext)
        vim.g.asyncrun_status = 0
        if useAsyncRun then
            cmd("AsyncRun " .. compileCMD)
        else
            fn.system(compileCMD)
        end
        return srcNoExt .. ext
    elseif vim.bo.filetype == "lua" then
        if useAsyncRun then
            cmd [[AsyncRun lua %]]
        else
            fn.system("lua" .. fn.expand("%:p"))
        end
    elseif vim.bo.filetype == "python" then
        if useAsyncRun then
            cmd(fn.has("win32") == 1 and "AsyncRun python %" or "AsyncRun python3 %")
        else
            fn.system(fn.has("win32") == 1 and "python " .. fn.expand("%:p") or "python3" .. fn.expand("%:p"))
        end
    end
end


function M.runCode()
    if vim.bo.modified then cmd "up" end
    api.nvim_echo({{"\n", "Normal"}}, false, {})
    if vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
        if fn.has("win32") == 1 then
            cmd [[!%:p:r]]
        else
            cmd [[!%:p:r.out]]
        end
    elseif vim.bo.filetype == "lua" then
        cmd [[AsyncRun lua %]]
    elseif vim.bo.filetype == "python" then
        cmd(fn.has("win32") == 1 and "AsyncRun python %" or "AsyncRun python3 %")
    end
end

cmd [[
command! -nargs=0 Compile lua require("compileRun").compileCode()
command! -nargs=0 Run     lua require("compileRun").runCode()
]]

return M

