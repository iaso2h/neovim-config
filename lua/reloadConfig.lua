-- File: reloadConfig
-- Author: iaso2h
-- Description: reload lua package or vim file at Neovim configuration directory
-- Version: 0.0.17
-- Last Modified: 2021-10-08
local fn   = vim.fn
local api  = vim.api
local cmd  = vim.cmd
local path = require("plenary.path")
local loop = vim.loop
local M    = {}

-- Force files that match those patterns to be treated as individual lua file
-- module even if they are coming from a the lua directory module
local forceLoadFileTbl = {"~/.config/nvim/lua/core", "~/.config/nvim/lua/config"}
local forceLoadFile    = vim.tbl_map(function(i) return path:new(i):expand() end, forceLoadFileTbl)

local configPath    = path:new(fn.stdpath("config"))
local luaModulePath = configPath:joinpath("lua")
local sep           = jit.os == "Windows" and "\\" or "/"

--- Escape \ in path string
--- @param str string
--- @return string
local e = function(str)
    if jit.os == "Windows" then
        return str
    else
        return string.gsub(str, [[\]], [[\\]])
    end
end


local packerCompileQuery = function(...)
    local answer = fn.confirm("Update packages?", "&Sync\ncom&Pile\n&No", 3)

    if answer == 1 then
        cmd [[PackerSync]]
    elseif answer == 2 then
        cmd [[PackerCompile]]
    end
end


local luaSetups = {
    {
        pathPat = e(luaModulePath:joinpath("core", "mappings.lua").filename),
        config  = function(...)
                _G.CoreMappingsLast = vim.deepcopy(CoreMappings)
                CoreMappings = {}
                CoreMappigsStart = true
            end
    }
}


local luaConfigs = {
    {
        -- Call the config func from "<NvimConfig>/lua/config/" if it's callable
        pathPat = e(luaModulePath:joinpath("config").filename),
        config  = function(modulePath, callback)
            local ok, msg
            if type(callback) == "function" then
                ok, msg = pcall(callback)
            elseif type(callback) == "table" then
                for _, func in ipairs({"config", "setup"}) do
                    if vim.is_callable(callback[func]) then
                        ok, msg = pcall(callback.config)
                    end
                end
            end


            if not ok then
                vim.notify("Error detect while calling callback function at: " .. modulePath.filename,
                    vim.log.levels.ERROR)
                vim.notify(msg, vim.log.levels.ERROR)
            end
            packerCompileQuery()
        end
    },
    {
        -- Ask whether to compile lua packages for "<NvimConfig> /lua/core/plugins.lua"
        pathPat = e(luaModulePath:joinpath("core", "plugins.lua").filename),
        config  = packerCompileQuery
    },
    {
        pathPat = e(luaModulePath:joinpath("onenord").filename),
        config  = function(...)
                -- cmd [[noa silent colorscheme onenord]]
                api.nvim_feedkeys(":colorscheme onenord", "nt", false)
            end
    },
    {
        pathPat = e(luaModulePath:joinpath("core", "mappings.lua").filename),
        config  = function(...)
                CoreMappigsStart = false
                local ok, msg
                for mode, mappings in pairs(CoreMappingsLast) do
                    for _, mapping in ipairs(mappings) do
                        if not vim.tbl_contains(CoreMappings[mode], mapping) then
                            if mode == "all" then mode = "" end
                            local unmapStr = string.format("%sunmap %s", mode, mapping)
                            vim.notify(unmapStr)
                            ok, msg = pcall(api.nvim_del_keymap, mode, mapping)
                            if not ok then
                                vim.notify("Failed while executing: " .. unmapStr, vim.log.levels.ERROR)
                                vim.notify(msg, vim.log.levels.ERROR)
                            end
                        end
                    end
                end
            end
    }
}


--- Call functions before or after reloading specifc lua module
--- @param modulePath plenary path object
--- @param callback function the callback return by reloading the lua module
local luaLoadHook = function(hookDict, modulePath, callback)
    for _, hook in ipairs(hookDict) do
        if string.match(modulePath.filename, hook.pathPat) then
            local ok, msg = pcall(hook.config, modulePath, callback)
            if not ok then
                vim.notify("Error occurs while loading lua config for " .. modulePath.filename,
                    vim.log.levels.ERROR)
                vim.notify(msg, vim.log.levels.ERROR)
            end
            return
        end
    end
end


--- Unload lua moldule if it's loaded in table packaga.loaded
--- @param modulePath plenary path object
--- @param ignoreLoaded boolean Set this it true will ignore whether the
---        module is loaded or not
--- @return string or boolean Return string in lua module in relative
---         way if it's already loaded. e.g. "lua.myModule.treesitter"
---
local luaUnload = function(modulePath, ignoreLoaded)
    assert(getmetatable(modulePath) == require("plenary.path"),
        string.format("Expected plenary path object or string, got %s", type(modulePath)))

    local parentStr  = modulePath:parent().filename
    local fileRelStr = path:new(modulePath.filename):make_relative(luaModulePath.filename)
    local fileRel    = string.gsub(fileRelStr, sep, "."):sub(1, -5)
    -- Get rid of init.lua or <parentDir>.lua whenever possible
    fileRel = string.gsub(fileRel, ".init.lua$", "")
    fileRel = string.gsub(fileRel, string.format(".%s.lua$", parentStr), "")

    if ignoreLoaded then return fileRel end

    if not package.loaded[fileRel] then
        return false
    else
        package.loaded[fileRel] = nil
        return fileRel
    end
end


--- Reload lua module that is a single file
--- @param luaModule string or plenary path object Default is string of current file path
--- @param checkLuaDir boolean Default is true. Set this to true to check whether the other lua
---        module in the same directory
M.luaLoadFile = function(luaModule, checkLuaDir) -- {{{
    if not luaModule then
        local fullPathStr = fn.expand("%:p")
        if jit.os == "Windows" and string.sub(fullPathStr, 1, 1):match("[a-z]") then
            luaModule = string.sub(fullPathStr, 1, 1):upper() .. string.sub(fullPathStr, 2, -1)
        end
    end

    assert(getmetatable(luaModule) == require("plenary.path") or
        type(luaModule) == "string",
        string.format("Expected plenary path object or string, got %s", type(luaModule)))

    if checkLuaDir == nil then checkLuaDir = true end

    local modulePath
    if type(luaModule) == "string" then
        modulePath = path:new(luaModule)
        assert(modulePath:is_file(), "Invalid string of file path")

        assert(string.match(modulePath.filename, e(luaModulePath.filename)) and
            vim.endswith(modulePath.filename, ".lua"), "Unsuppoted file path")
    else
        modulePath = luaModule
    end

    -- Check other lua module at the same directory
    local parentStr = modulePath:parent().filename
    if checkLuaDir then
        if parentStr ~= luaModulePath.filename and
        not vim.tbl_contains(forceLoadFile, parentStr) then
            return M.luaLoadDir(modulePath, parentStr, false)
        end
    end

    -- Load setup BEFORE reloading for specific module match the given path
    luaLoadHook(luaSetups, modulePath)

    -- Get lua replative module path
    local fileRel = luaUnload(modulePath, type(luaModule) == "string")

    if not fileRel then return end

    -- Capture callback from module
    local callback = require(fileRel)
    vim.notify(
        string.format("Reload lua package[%s] at: %s", fileRel, modulePath.filename),
        vim.log.levels.INFO)

    -- Load configuration AFTER reloading for specific module match the given path
    luaLoadHook(luaConfigs, modulePath, callback)

end -- }}}


--- Reload lua module that come from a directory
--- @param modulePath plenary path object
--- @param dirStr string Diretory string in full path
--- @param checkLoadedFirst boolean Set this to true to make sure directory
---        module is loaded before reloading
M.luaLoadDir = function(modulePath, dirStr, checkLoadedFirst) -- {{{
    assert(type(dirStr) == "string", "Expect string value, got " .. type(dirStr))

    local dirRel = string.gsub(path:new(dirStr):make_relative(luaModulePath.filename), sep, ".")
    if checkLoadedFirst then
        -- Check whether a directory module is loaded. If it does, analyze the
        -- whole directory. If it doesn't, then this module might just happend to
        -- be located at a ordinary directory for the sake of classification.
        if package.loaded[dirRel] then
            -- Unload lua diretory module first
            package.loaded[dirRel] = nil
        else
            return M.luaLoadFile(modulePath, false)
        end
    end

    local fileStrs = {}
    local filePaths
    local fileRels
    local tbl

    local dir = loop.fs_opendir(dirStr)
    while true do
        tbl = loop.fs_readdir(dir)

        if not tbl then break end

        if tbl and vim.endswith(tbl[1].name, ".lua") and
            tbl[1].type == "file" and
            not string.match(tbl[1].name, dirRel .. ".lua") and
            tbl[1].name ~= "init.lua" then

            fileStrs[#fileStrs+1] = tbl[1].name
        end
    end
    loop.fs_closedir(dir)

    -- Check if any type of module has been loaded
    if not dirRel and not next(fileStrs) then return end

    -- Unload all loaded lua file module
    if next(fileStrs) then
        filePaths = vim.tbl_map(function (i) return path:new(dirStr):joinpath(i) end, fileStrs)
        fileRels = vim.tbl_map(luaUnload, filePaths)
    end

    -- Reload lua directory module
    if dirRel then
        require(dirRel)
        vim.notify(string.format("Reload lua package[%s] at: %s%s",
                dirRel, dirStr, sep),
                vim.log.levels.INFO)
    end

    -- Reload all lua file modules
    if next(fileStrs) then
        for idx, fileRel in ipairs(fileRels) do
            require(fileRel)
            vim.notify(
                string.format("Reload lua package[%s] under: %s%s", fileRel, dirStr, sep),
                vim.log.levels.INFO)

            if idx == #fileRels then
                luaLoadHook(luaConfigs, filePaths[idx])
            end
        end
    end
end -- }}}


----
-- Function: Reload: Reload lua module path. Called in autocmd
--
-- @param module: String value of module path
----
M.reload = function() -- {{{
    local fullPathStr = fn.expand("%:p")
    if jit.os == "Windows" and string.sub(fullPathStr, 1, 1):match("[a-z]") then
        fullPathStr = string.sub(fullPathStr, 1, 1):upper() .. string.sub(fullPathStr, 2, -1)
    end
    local modulePath  = path:new(fullPathStr)

    -- Config path only
    if not string.match(modulePath.filename, e(configPath.filename)) then return end

    if vim.bo.filetype == "lua" then
        -- Lua {{{
        -- Only load lua module at: ~/.config/nvim/lua
        if not string.match(modulePath.filename, e(luaModulePath.filename)) then return end

        local parentDirStr = modulePath:parent().filename
        if parentDirStr ~= luaModulePath.filename and
            not vim.tbl_contains(forceLoadFile, parentDirStr) then

            -- The lua module is a directory
            local parentDirStrs = modulePath:parents()
            -- Filter out valid lua sub module
            for i = tbl_idx(parentDirStrs, luaModulePath.filename), #parentDirStrs do
                parentDirStrs[i] = nil
            end

            for _, dirStr in ipairs(parentDirStrs) do
                -- Do not load directory of module coming from this
                -- table. load current directory instead
                M.luaLoadDir(modulePath, dirStr, true)
            end
        else
            -- The lua module is a single file
            M.luaLoadFile(modulePath, true)
        end
        -- }}} Lua
    else
        -- Vim {{{
        -- Module path is always full path in VimL
        if modulePath.filename == configPath:joinpath("init.vim").filename or
            string.match(modulePath.filename, e(configPath:joinpath("plugins").filename)) then

            cmd("noa source " .. modulePath)
            vim.notify(string.format("Reload: %s", modulePath), vim.log.levels.INFO)
        elseif string.match(modulePath.filename, e(configPath:joinpath("colors").filename)) then
            local colorDirPath = configPath:joinpath("colors")
            local colorRel     = string.sub(
                path:new(modulePath.filename):make_relative(colorDirPath.filename),
                1, -5)
            cmd("noa silent! colorscheme " .. colorRel)
            vim.notify(string.format("Colorscheme: %s", colorRel), vim.log.levels.INFO)
        end
        -- }}} Vim
    end

end -- }}}

return M
