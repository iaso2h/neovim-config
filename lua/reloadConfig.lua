-- File: reloadConfig
-- Author: iaso2h
-- Description: reload lua package or vim file at Neovim configuration folder
-- Version: 0.0.15
-- Last Modified: 2021-10-03
local fn   = vim.fn
local cmd  = vim.cmd
local path = require("plenary.path")
local loop = vim.loop
local M    = {}

local notLoadAllDir    = {"~/.config/nvim/lua/core"}
local notLoadAllDirStr = vim.tbl_map(function(i) return path:new(i):expand() end, notLoadAllDir)

local configPath    = path:new(fn.stdpath("config"))
local luaModulePath = configPath:joinpath("lua")
local sep           = jit.os == "Windows" and "\\" or "/"


--- Unload lua moldule if it's loaded in table packaga.loaded
--- @param modulePath plenary path object
--- @return string or boolean Return string in lua module in relative
---         way if it's already loaded. e.g. "lua.myModule.treesitter"
local luaUnload = function(modulePath)
    assert(getmetatable(modulePath) == require("plenary.path"),
        string.format("Expected plenary path object or string, got %s", type(modulePath)))

    local fileRelStr = path:new(modulePath.filename):make_relative(luaModulePath.filename)
    local fileRel    = string.gsub(fileRelStr, sep, "."):sub(1, -5)
    if not package.loaded[fileRel] then
        return false
    else
        package.loaded[fileRel] = nil
        return fileRel
    end
end


--- Reload lua module that is a single file
--- @param luaModule string or plenary path object
--- @param checkLuaDir boolean Default is true. Set this to true to check whether the other lua
---        module in the same directory
M.luaLoad = function(luaModule, checkLuaDir) -- {{{
    assert(getmetatable(luaModule) == require("plenary.path") or
        type(luaModule) == "string",
        string.format("Expected plenary path object or string, got %s", type(luaModule)))

    if checkLuaDir == nil then checkLuaDir = true end

    local modulePath
    if type(luaModule) == "string" then
        modulePath = path:new(luaModule)
    else
        modulePath = luaModule
    end

    -- Filter out non-lua path
    if not vim.endswith(modulePath.filename, ".lua") or
        not string.match(modulePath.filename, luaModulePath.filename) then
        return
    end

    -- Check other lua module at the same directory
    if checkLuaDir then
        local parentStr = modulePath:parent().filename
        if not vim.endswith(modulePath.filename, "init.lua") and
            parentStr ~= luaModulePath.filename then

            return M.luaLoadDir(parentStr)
        end
    end

    -- Get lua replative module path
    local fileRel = luaUnload(modulePath)

    if not fileRel then return end

    -- Capture callback from module
    local callback = require(fileRel)
    vim.notify(
        string.format("Reload lua package[%s] at: %s", fileRel, modulePath.filename),
        vim.log.levels.INFO)

    -- Call the config func from "<NvimConfig>/lua/config/" if it's callable
    local ok,msg
    if string.match(modulePath.filename, luaModulePath:joinpath("config").filename) then
        if type(callback) == "function" then
            ok, msg = pcall(callback)
        elseif type(callback) == "table" then
            ok, msg = pcall(callback.config)
            ok, msg = pcall(callback.setup)
        end

        if not ok then
            vim.notify("Error detect while calling callback function at: ", modulePath.filename,
                vim.log.levels.ERROR)
            vim.notify(msg, vim.log.levels.ERROR)
        end

        local answer = fn.confirm("Update packages?", "&Sync\ncom&Pile\n&No", 3)
        if answer == 1 then
            return cmd [[PackerSync]]
        elseif answer == 2 then
            return cmd [[PackerCompile]]
        end
    end

    -- Ask whether to compile lua packages for "<NvimConfig> /lua/core/plugins.lua"
    if modulePath.filename == luaModulePath:joinpath("core", "plugins.lua").filename then
        local answer = fn.confirm("Update packages?", "&Sync\ncom&Pile\n&No", 3)
        if answer == 1 then
            return cmd [[PackerSync]]
        elseif answer == 2 then
            return cmd [[PackerCompile]]
        end
    end
end -- }}}


--- Reload lua module that come from a directory
--- @param dirStr string
M.luaLoadDir = function(dirStr) -- {{{
    assert(type(dirStr) == "string", "Expect string value, got " .. type(dirStr))

    local dir = loop.fs_opendir(dirStr)
    local fileStrs = {}
    local fileRels
    local dirRel
    local tbl
    while true do
        tbl = loop.fs_readdir(dir)

        if not tbl then break end

        if tbl[1].name == "init.lua" then
            -- Unload lua diretory module
            dirRel = string.gsub(path:new(dirStr):make_relative(luaModulePath.filename),
                                                    sep, ".")
            if package.loaded[dirRel] then

                package.loaded[dirRel] = nil
            else
                dirRel = nil
            end
        elseif tbl and vim.endswith(tbl[1].name, ".lua") and
            tbl[1].type == "file" then

            fileStrs[#fileStrs+1] = tbl[1].name
        end
    end
    loop.fs_closedir(dir)

    -- Check if any type of module has been loaded
    if not dirRel and not next(fileStrs) then return end

    -- Unload all loaded lua file module
    if next(fileStrs) then
        local filePaths = vim.tbl_map(function (i) return path:new(dirStr):joinpath(i) end, fileStrs)
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
        for _, fileRel in ipairs(fileRels) do
            require(fileRel)
            vim.notify(
                string.format("Reload lua package[%s] under: %s%s", fileRel, dirStr, sep),
                vim.log.levels.INFO)
        end
    end
end -- }}}


----
-- Function: Reload: Reload lua module path
--
-- @param module: String value of module path
----
M.reload = function() -- {{{
    local modulePath  = path:new(fn.expand("%:p"))

    -- Config path only
    if not string.match(modulePath.filename, configPath.filename) then return end

    if vim.bo.filetype == "lua" then
        -- Lua {{{
        -- Only load lua module at: ~/.config/nvim/lua
        if not string.match(modulePath.filename, luaModulePath.filename) then return end

        -- DEBUG:
        -- modulePath = luaModulePath:joinpath("expandRegion", "treesitter.lua")
        -- modulePath = luaModulePath:joinpath("core", "plugins.lua")


        if modulePath:parent().filename ~= luaModulePath.filename then
            -- The lua module is a folder
            local parentDirStrs = modulePath:parents()
            -- Filter out valid lua sub module
            for i = tbl_idx(parentDirStrs, luaModulePath.filename), #parentDirStrs do
                parentDirStrs[i] = nil
            end

            for _, dirStr in ipairs(parentDirStrs) do
                -- Do not load directory of module coming from this
                -- table. load current directory instead

                if vim.tbl_contains(notLoadAllDirStr, dirStr) then
                    M.luaLoad(modulePath, false)
                else
                    M.luaLoadDir(dirStr)
                end
            end
        else
            -- The lua module is a single file
            M.luaLoad(modulePath)
        end
        -- }}} Lua
    else
        -- Vim {{{
        -- Module path is always full path in VimL
        if modulePath.filename == configPath:joinpath("init.vim").filename or
            string.match(modulePath.filename, configPath:joinpath("plugins").filename) then

            cmd("source " .. modulePath)
            vim.notify(string.format("Reload: %s", modulePath), vim.log.levels.INFO)
        elseif string.match(modulePath.filename, configPath:joinpath("colors").filename) then
            local colorDirPath = configPath:joinpath("colors")
            local colorRel     = string.sub(
                path:new(modulePath.filename):make_relative(colorDirPath.filename),
                1, -5)
            cmd("colorscheme " .. colorRel)
            vim.notify(string.format("Colorscheme: %s", colorRel), vim.log.levels.INFO)
        end
        -- }}} Vim
    end

end -- }}}

return M
