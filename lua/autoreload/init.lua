-- File: reloadConfig
-- Author: iaso2h
-- Description: reload lua package or vim file at Neovim configuration directory
-- Version: 0.0.25
-- Last Modified: Fri 05 May 2023
local util = require("autoreload.util")
local ok, valOrMsg = pcall(require, "plenary.path")
if not ok then
    valOrMsg = nil
    return
end

local M = {
    configPath = valOrMsg:new(_G._config_path),
    opt = {
        lua = {}
    }
}
M.opt.lua.moduleSearchPath = M.configPath:joinpath("lua")
M.opt.lua.blacklist        = {
    M.configPath:joinpath("lua", "plugins", "nvim-galaxyline.lua").filename,
    M.configPath:joinpath("lua", "plugins", "nvim-null-is.lua").filename,
    M.configPath:joinpath("lua", "plugins", "init.lua").filename,
    M.configPath:joinpath("lua", "core", "init.lua").filename,
    -- M.configPath:joinpath("lua", "global").filename,
}
M.opt.lua.overrideFileModulePath = {
    M.configPath:joinpath("lua", "core"),
    M.configPath:joinpath("lua", "plugins"),
}
M.opt.lua.setup  = {}
M.opt.lua.config = { -- {{{
    {
        -- Call the config func from "<NvimConfig>/lua/config/" if it's callable
        pathPat       =  M.opt.lua.moduleSearchPath:joinpath("plugins", "nvim-lspconfig.lua").filename,
        unloadOnlyChk = false,
        callback      = function(path, callback)
            local err = function(msg)
                vim.notify("Error detect while calling callback function at: " .. path.filename,
                    vim.log.levels.ERROR)
                vim.notify(msg, vim.log.levels.ERROR)
            end

            local ok, msg = pcall(callback)
            if not ok then return err(msg) end

            --- Check modified state of specified buffer numbers and prompt for saving if
            --unsave changes found
            local changeTick = false
            local answer = -1
            for _, bufNr in ipairs(require("buffer.util").bufNrs(true)) do
                if vim.api.nvim_buf_get_option(bufNr, "modified") then
                    changeTick = true
                    break
                end
            end
            -- Ask for saving, return when cancel is input
            if changeTick then
                vim.cmd "noa echohl MoreMsg"
                answer = vim.fn.confirm("Save all modification?",
                    ">>> &Save\n&Discard\n&Cancel", 3, "Question")
                vim.cmd "noa echohl None"
                if answer == 3 or answer == 0 then
                    return
                elseif answer == 1 then
                    vim.cmd "noa silent bufdo update"
                end
            end

            -- Reload server
            vim.notify("Reloading lsp clients")
            vim.lsp.stop_client(vim.lsp.get_active_clients())
            vim.cmd [[bufdo e]]
            for _, bufNr in ipairs(require("buffer.util").bufNrs(true)) do
                vim.api.nvim_buf_call(bufNr, require("buffer.cursorRecall"))
            end
        end
    },
    {
        -- Call the config func from "<NvimConfig>/lua/config/" if it's callable
        pathPat       = M.opt.lua.moduleSearchPath:joinpath("plugins").filename,
        unloadOnlyChk = false,
        callback      = function(path, callback)
            local err = function(msg)
                vim.notify("Error detect while calling callback function at: " .. path.filename,
                    vim.log.levels.ERROR)
                vim.notify(msg, vim.log.levels.ERROR)
            end

            local ok, msg
            if type(callback) == "function" then
                ok, msg = pcall(callback)
                if not ok then return err(msg) end
            elseif type(callback) == "table" then
                for _, func in ipairs({ "setup", "config" }) do
                    if vim.is_callable(callback[func]) then
                        ok, msg = pcall(callback.config)
                        if not ok then return err(msg) end
                    end
                end
            end
        end
    },
    {
        pathPat       = M.opt.lua.moduleSearchPath:joinpath("core", "options.lua").filename,
        unloadOnlyChk = false,
        callback      = function(...)
            vim.defer_fn(function()
                vim.cmd [[silent colorscheme onenord]]
            end, 0)
        end
    }
} -- }}}


---Reload lua module path. Called in autocmd
M.reload = function() -- {{{
    if not valOrMsg then return end
    local bufNr   = vim.api.nvim_get_current_buf()
    local pathStr = nvim_buf_get_name(bufNr)
    -- Uppercase the first character in Windows
    if _G._os_uname.sysname == "Windows_NT" then
        pathStr = util.upperCaseWindowsDrive(pathStr)
    end
    local path = valOrMsg:new(pathStr)

    -- Config path only
    if not string.match(path.filename, M.configPath.filename) then return end

    -- Check filetype
    if vim.bo.filetype == "lua" then
        -- Check blacklist
        for _, i in ipairs(M.opt.lua.blacklist) do
            if i == path.filename or string.match(path.filename, i) then
                return
            end
        end

        -- Only reloading lua module from: <nvimConfigPath>/lua/
        if not string.match(path.filename, M.opt.lua.moduleSearchPath.filename) then return end

        local l = require("autoreload.lua")
        local parentPath = path:parent()
        local parentStr  = parentPath.filename
        local overrideFileModuleStr = vim.tbl_map(function(i)
            return i.filename end, M.opt.lua.overrideFileModulePath)
        if parentStr ~= M.opt.lua.moduleSearchPath.filename and
            not vim.tbl_contains(overrideFileModuleStr, parentStr) then
            -- The lua module is a directory
            l.loadDir(path, M.opt.lua)
        else
            -- The lua module is a single file
            l.loadFile(path, parentPath, M.opt.lua)
        end
    elseif vim.bo.filetype == "vim" then
        require("autoreload.vim")(path, M.configPath)
    end
end -- }}}


return M
