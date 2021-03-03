local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

function M.compileCode()
    if vim.bo.filetype == "c" then
        local srcPath = fn.expand('%:p')
        local srcNoExt = fn.expand('%:p:r')
        local flags = '-Wall -std=c99'
        local prog

        if fn.executable('clang') then
            prog = 'clang'
        elseif fn.executable('gcc') then
            prog = 'gcc'
        else
            api.nvim_echo({{"No C compiler found!", "WarningMsg"}}, false, {})
            return
        end
        -- lua require("%s").create_term_buf('v', 80)
        local compileCMD = string.format("%s %s %s -o %s.exe", prog, flags, srcPath, srcNoExt)
        vim.g.asyncrun_status = 0
        cmd("AsyncRun " .. compileCMD)
        -- cmd printf('term %s.exe', l:srcNoExt)
        -- call system(l:srcNoExt.".exe")
    elseif vim.bo.filetype == "lua" then
        cmd [[AsyncRun lua %]]
    elseif vim.bo.filetype == "python" then
        cmd(fn.has("win32") == 1 and "AsyncRun python %" or "AsyncRun python3 %")
    end
end

-- function M.create_term_buf(_type, size)
    -- if _type == 'v'   vnew   else   new   end
    -- cmd 'resize ' .. size
-- end

function M.runCode()
    if vim.bo.modified then cmd "up" end
    if vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
        cmd [[e]]
    elseif vim.bo.filetype == "lua" then
        cmd [[AsyncRun lua %]]
    elseif vim.bo.filetype == "python" then
        cmd(fn.has("win32") == 1 and "AsyncRun python %" or "AsyncRun python3 %")
    end
end

return M

