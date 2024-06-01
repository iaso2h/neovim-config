-- File: reloadConfig
-- Author: iaso2h
-- Description: reload lua package or vim file at Neovim configuration directory
-- Version: 0.0.28
-- Last Modified: 2023-10-23

---@class ReloadHook
---@field pathPat string|string[] Absolute file path string
---@field unloadOnlyChk boolean Unload the module only, don't reload it
---@field callbackHandler function Callback function to executed specifically

local util = require("autoreload.util")
local ok, valOrMsg = pcall(require, "plenary.path")
local p
if not ok then
    valOrMsg = nil
    return
else
    p = valOrMsg
end

local M = {
    configPath = p:new(_G._config_path),
    opt = {
        lua = {}
    }
}
M.opt.lua.moduleSearchPath = M.configPath:joinpath("lua")
M.opt.lua.blacklist        = {
    -- M.configPath:joinpath("lua", "plugins", "nvim-galaxyline.lua").filename,
    M.configPath:joinpath("lua", "plugins", "nvim-feline.lua").filename,
    M.configPath:joinpath("lua", "plugins", "nvim-null-ls.lua").filename,
    M.configPath:joinpath("lua", "plugins", "init.lua").filename,
    M.configPath:joinpath("lua", "core", "init.lua").filename,
    -- M.configPath:joinpath("lua", "global").filename,
}
M.opt.lua.overrideFileModulePath = {
    M.configPath:joinpath("lua", "core"),
    M.configPath:joinpath("lua", "plugins"),
}

---@type ReloadHook
local defaultHook = {
    pathPat = "",
    unloadOnlyChk = false,
}
---@type ReloadHook
M.opt.lua.setupHook  = { }
---@type ReloadHook
M.opt.lua.configHook = { -- {{{
    {
        pathPat = M.opt.lua.moduleSearchPath:joinpath("plugins", "nvim-lua-gf.lua").filename,
    },
    {
        -- Call the config func from "<NvimConfig>/lua/config/" if it's callable
        pathPat         =  M.opt.lua.moduleSearchPath:joinpath("plugins", "nvim-lspconfig.lua").filename,
        callbackHandler = function(path, callback)
            local err = function(msg)
                vim.notify("Error detect while calling callback function at: " .. path.filename,
                    vim.log.levels.ERROR)
                vim.notify(msg, vim.log.levels.ERROR)
            end

            local ok, msg = pcall(callback)
            if not ok then return err(msg) end

            --- Check modified state of specified buffer numbers and prompt for saving if
            --unsave changes found
            local changeTick = require("util").any(function(bufNr)
                return vim.api.nvim_get_option_value("modified", {buf = bufNr})
            end, require("buffer.util").bufNrs(true))
            local answer = -1
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
        pathPat         = M.opt.lua.moduleSearchPath:joinpath("plugins").filename,
        callbackHandler = function(path, callback)
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
        pathPat = {
            M.opt.lua.moduleSearchPath:joinpath("core", "options.lua").filename,
            M.opt.lua.moduleSearchPath:joinpath("onenord").filename,
        },
        callbackHandler = function(...)
            vim.defer_fn(function()
                vim.cmd [[silent colorscheme onenord]]
            end, 0)
        end
    },
} -- }}}

for idx, hook in ipairs(M.opt.lua.setupHook) do
    M.opt.lua.setupHook[idx] = vim.tbl_deep_extend("keep", hook, defaultHook)
end
for idx, hook in ipairs(M.opt.lua.configHook) do
    M.opt.lua.configHook[idx] = vim.tbl_deep_extend("keep", hook, defaultHook)
end


---Reload lua module path. Called in autocmd
M.reload = function() -- {{{
    local bufNr   = vim.api.nvim_get_current_buf()
    local pathStr = nvim_buf_get_name(bufNr)
    -- Uppercase the first character in Windows
    if _G._os_uname.sysname == "Windows_NT" then
        pathStr = util.upperCaseWindowsDrive(pathStr)
    end
    local path = p:new(pathStr)

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
