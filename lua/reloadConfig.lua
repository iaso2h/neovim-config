-- File: reloadConfig
-- Author: iaso2h
-- Description: reload lua package or vim file at Neovim configuration directory
-- Version: 0.0.20
-- Last Modified: 2022-01-26
local fn   = vim.fn
local api  = vim.api
local cmd  = vim.cmd
local path = require("plenary.path")
local loop = vim.loop
local flattenTbl = {}
local M    = {}

local configPath = path:new(fn.stdpath("config"))
-- Force files that match those patterns to be treated as individual lua file
-- module even if they are coming from a the lua directory module
local configPathForceFileLoadTbl    = {configPath:joinpath("lua", "core"), configPath:joinpath("lua", "config")}
local configPathForceFileLoadStrTbl = vim.tbl_map(function (i)
    return i.filename end, configPathForceFileLoadTbl)

local configPathForceDirLoadTbl    = {configPath:joinpath("lua", "onenord")}
local configPathForceDirLoadStrTbl = vim.tbl_map(function (i)
    return i.filename end, configPathForceDirLoadTbl)
local luaModulePath       = configPath:joinpath("lua")
local sep                 = jit.os == "Windows" and "\\" or "/"


local function upperCaseWindowsDrive(fullPathStr)
    if not string.sub(fullPathStr, 1, 1):match("[a-z]") then
        return fullPathStr
    end

    return string.sub(fullPathStr, 1, 1):upper() .. string.sub(fullPathStr, 2, -1)
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
    -- NOTE: generally the length pathPat should shorter than the one it's
    -- goin to match against
    {
        pathPat = luaModulePath:joinpath("core", "mappings.lua").filename,
        config  = function(...)
                _G.CoreMappingsLast = vim.deepcopy(CoreMappings)
                CoreMappings = {}
                CoreMappigsStart = true
            end
    }
}


local luaConfigs = {
    -- NOTE: generally the length pathPat should shorter than the one it's
    -- goin to match against
    {
        -- Call the config func from "<NvimConfig>/lua/config/" if it's callable
        pathPat = luaModulePath:joinpath("config").filename,
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
        pathPat = luaModulePath:joinpath("core", "plugins.lua").filename,
        config  = packerCompileQuery
    },
    {
        pathPat = luaModulePath:joinpath("onenord").filename,
        config  = function(...)
                vim.defer_fn(function ()
                    cmd [[silent colorscheme onenord]]
                end, 0)
            end
    },
    {
        pathPat = luaModulePath:joinpath("core", "mappings.lua").filename,
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
    },
    {
        pathPat = luaModulePath:joinpath("core", "option.lua").filename,
        config  = function(...)
                vim.defer_fn(function ()
                    cmd [[silent colorscheme onenord]]
                end, 0)
            end
    }
}


local luaSubfiles
--- Convert relative file path into relative lua module path.
--- @param dirPath object Plenary path object with a directory path as its
--- filename property
--- @param dirStr string The name of parent direcotry.
--- @return table Table that contains relative file paths. The table might
--- have multiple dimensions
luaSubfiles = function(dirPath, dirStr)
    -- Value of tbl in each loop:
    -- || { {
    -- ||     name = "var.lua",
    -- ||     type = "file"
    -- ||   } }
    -- || { {
    -- ||     name = "action",
    -- ||     type = "directory"
    -- ||   } }
    -- || { {
    -- ||     name = "init.lua",
    -- ||     type = "file"
    -- ||   } }
    -- || { {
    -- ||     name = "util.lua",
    -- ||     type = "file"
    -- ||   } }
    -- while true do

    -- Output:
    -- || { "buf", "var.lua", { "action", "close.lua", "closeOther.lua", "newSplit.lua" }, "util.lua" }
    assert(getmetatable(dirPath) == require("plenary.path"),
        string.format("Expected object Plenary path object or string, got %s", type(dirPath)))
    assert(dirPath:is_dir() == true, "The path of the Plenary path object is not a direcotry")

    local dirFS = loop.fs_opendir(dirPath.filename)
    -- The value of directory name should always at the first place in each
    -- table. This will allows it to be unloaded or loaded before any module
    -- under the same level of directory in the future iteration
    local fileRelStrs = {dirStr}

    while true do
        local tbl = loop.fs_readdir(dirFS)

        if not tbl then break end

        local name = tbl[1].name
        local type = tbl[1].type

        if vim.endswith(name, ".lua") and type == "file" and
            -- filter out path like:
            -- ~/.config/nvim/replace/replace.init
            -- ~/.config/nvim/replace/init.init
                not string.match(name, dirStr .. ".lua") and
                name ~= "init.lua" then
            fileRelStrs[#fileRelStrs+1] = name
        elseif type == "directory" then
            -- Enter next recursion
            fileRelStrs[#fileRelStrs+1] = luaSubfiles(dirPath:joinpath(name), name)
        end
    end

    loop.fs_closedir(dirFS)
    return fileRelStrs
end


local fileRel2luaRel
--- Convert relative file path into relative lua module path.
--- @param fileRelStrs table Table that contains string values of relavtive
--- file path. The table can be multi-deimensions
--- @param parentDir string The name of parent direcotry. Default is nil, and
--- its value should always kept as nil
--- @param loadedOnlyChk boolean Whether to only store lua modules that have
--- been loaded inside Neovim. Default is true
--- . The table can be multi-deimensions
--- @return table Table that contains relative lua module paths. The table
--- might have multiple dimensions
fileRel2luaRel = function(fileRelStrs, parentDir, loadedOnlyChk)
    loadedOnlyChk = loadedOnlyChk or true

    -- The current directory name
    local dirRelStr = fileRelStrs[1]
    local luaRelStrs
    local luaRelStr

    if not parentDir then
        -- The first recursion

        -- In the first recursion, the directory should be always valid by
        -- package.loaded[dirStr]
        luaRelStrs = {dirRelStr}
    else

        -- The sub directory name
        local subDirRelStr = string.format("%s.%s", parentDir, dirRelStr)

        -- The directory need to be validated by package.loaded[dirStr]
        if package.loaded[subDirRelStr] then
            luaRelStrs = {subDirRelStr}
        else
            luaRelStrs = {}
        end
    end

    -- Loop through the relavtive file path table and convert its element into
    -- relative lua path
    for idx, fileRel in ipairs(fileRelStrs) do
        if idx ~= 1 then
            if type(fileRel) == "string" then
                if not parentDir then
                    -- The first recursion
                    luaRelStr = string.format("%s.%s", dirRelStr, fileRel):sub(1, -5)
                else
                    luaRelStr = string.format("%s.%s.%s", parentDir, dirRelStr, fileRel):sub(1, -5)
                end

                if package.loaded[luaRelStr] then
                    luaRelStrs[#luaRelStrs+1] = luaRelStr
                end
            elseif type(fileRel) == "table" and #fileRel ~= 1 then
                -- Enter next recursion
                luaRelStrs[#luaRelStrs+1] = fileRel2luaRel(fileRel, dirRelStr)
            end
        end
    end

    return luaRelStrs
end


local luaChkLoaded
--- Check lua relative value have been loaded and listed in table "package.loaded"
--- @param luaRelStrs table Table that contains string values of relavtive lua
--- module path, which can be directly indexed by package.loaded[<luaRelStr>]
--- . The table can be multi-deimensions
--- @return table Table that have multiple dimensions
luaChkLoaded = function (luaRelStrs)
    local luaRelLoadedStrs = {}
    for _, luaRelStr in ipairs(luaRelStrs) do
        if type(luaRelStr) == "string" then
            if package.loaded[luaRelStr] then
                luaRelLoadedStrs[#luaRelLoadedStrs+1] = luaRelStr
            end
        elseif type(luaRelStr) == "table" then
            -- Enter next recursion
            luaRelLoadedStrs[#luaRelLoadedStrs+1] = luaChkLoaded(luaRelStr)
        end
    end

    return luaRelLoadedStrs
end


local flatten
--- Convert any list-liked table that have multiple dimensions into a single
--- dimension table. The new table will always store at flattenTbl
--- @param tbl table Table that have multiple dimensions
flatten = function(tbl)
    for _, value in ipairs(tbl) do
        if type(value) ~= "table" then
            flattenTbl[#flattenTbl+1] = value
        else
            flatten(value)
        end
    end
end


--- Check whether lua modules under the same lua directory have been opened
--- and modified in other Neovim buffer. If any, prompt the user to save the
--- changes before reloading them all.
--- @param fileStrs object Plenary path object
local luaChkLoadedOpenAndMod = function (fileStrs)
    local bufNrTbl = vim.tbl_map(function(buf)
        return tonumber(string.match(buf, "%d+"))
        end, require("buf.util").bufLoadedTbl(false))

    if #bufNrTbl <= 1 then return end

    local bufNrOpenTbl = {}
    local bufNrCur = api.nvim_get_current_buf()
    for _, s in ipairs(fileStrs) do
        for _, n in ipairs(bufNrTbl) do
            local bufName = api.nvim_buf_get_name(n)
            if jit.os == "Windows" then
                bufName = upperCaseWindowsDrive(bufName)
            end
            if n ~= bufNrCur and string.match(bufName, s) and
                    not tbl_idx(bufNrOpenTbl, n) and
                    api.nvim_buf_get_option(n, "modified") then
                bufNrOpenTbl[#bufNrOpenTbl+1] = n
            end
        end
    end

    if #bufNrOpenTbl == 0 then return end

    for _, n in ipairs(bufNrOpenTbl) do
        vim.notify(api.nvim_buf_get_name(n), vim.log.levels.INFO)
    end
    local filePlural = #bufNrOpenTbl > 1 and "s" or ""
    cmd "noa echohl MoreMsg"
    local answer = fn.confirm(
        string.format("Save the modification%s for file%s under the same lua directory?",
            filePlural, filePlural),
        ">>> &Yes\n&No", 1, "Question")
    cmd "noa echohl None"
    if answer == 1 then
        for _, n in ipairs(bufNrOpenTbl) do
            cmd(string.format("%sbufdo noa update", n))
        end
        -- Since "<range>bufdo" will set the current buf in curent window to
        -- the buffer specified by the <range> prefix, an additional action
        -- needed to take to bring back the origin buffer
        api.nvim_win_set_buf(0, bufNrCur)
    end
end

--- Get the relative lua module path that can be passed directly in func require()
--- @param srcPath object Plenary path object
--- @return string Relative lua module path
local getLuaRelStr = function(srcPath)
    assert(getmetatable(srcPath) == require("plenary.path"),
        string.format("Expected object Plenary path object or string, got %s", type(srcPath)))

    local parentStr  = srcPath:parent().filename
    local fileRelStr = path:new(srcPath.filename):make_relative(luaModulePath.filename)
    local luaRelStr = string.gsub(fileRelStr, sep, "."):sub(1, -5)

    -- Get rid of init.lua and <parentDir>.lua whenever possible
    luaRelStr = string.gsub(luaRelStr, ".init.lua$", "")
    luaRelStr = string.gsub(luaRelStr, string.format(".%s.lua$", parentStr), "")

    return luaRelStr
end


--- Call functions before or after reloading specifc lua module
--- @param modulePath object Plenary path object
--- @param callback function the callback return by reloading the lua module
local luaLoadHook = function(hookDict, modulePath, callback)
    assert(getmetatable(modulePath) == require("plenary.path"),
        string.format("Expected object Plenary path object or string, got %s", type(modulePath)))

    for _, hook in ipairs(hookDict) do
        if string.match(modulePath.filename, hook.pathPat) then
            local ok, msg = pcall(hook.config, modulePath, callback)
            if not ok then
                vim.notify("Error occurs while loading lua config for " .. modulePath.filename,
                    vim.log.levels.ERROR)
                vim.notify(msg, vim.log.levels.ERROR)
            end
        end
    end
end


--- Reload lua module that is a single file
--- @param luaModule string/object String or object Plenary path object. Default is string of current file path
--- @param checkLuaDir boolean Default is true. Set this to true to check whether the other lua
---        module in the same directory
M.luaLoadFile = function(luaModule, checkLuaDir) -- {{{
    if not luaModule then
        luaModule = fn.expand("%:p")
        if jit.os == "Windows" then
            luaModule = upperCaseWindowsDrive(luaModule)
        end
    end

    assert(getmetatable(luaModule) == require("plenary.path") or
        type(luaModule) == "string",
        string.format("Expected object Plenary path object or string, got %s", type(luaModule)))

    if checkLuaDir == nil then checkLuaDir = true end

    local srcPath
    if type(luaModule) == "string" then
        srcPath = path:new(luaModule)
        assert(srcPath:is_file(), "Invalid string of file path")

        if jit.os ~= "Windows" then
            assert(string.match(srcPath.filename, luaModulePath.filename) and
                vim.endswith(srcPath.filename, ".lua"), "Unsuppoted file path")
        else
            -- Deal with the lowercase Drive character comparision in Windows
            assert(
                string.match(
                    string.sub(srcPath.filename, 2, -1),
                    string.sub(luaModulePath.filename, 2, -1)
                ) and
                string.sub(srcPath.filename, 1, 1):lower() ==
                string.sub(luaModulePath.filename, 1, 1):lower() and
                vim.endswith(srcPath.filename, ".lua"), "Unsuppoted file path")
        end
    else
        srcPath = luaModule
    end

    -- Check other lua module at the same directory
    local parentDirStr = srcPath:parent().filename
    if checkLuaDir then
        if parentDirStr ~= luaModulePath.filename and
                not vim.tbl_contains(configPathForceFileLoadStrTbl, parentDirStr) then

            return M.luaLoadDir(srcPath, parentDirStr, false)
        end
    end

    -- Load setup BEFORE reloading for specific module match the given path
    luaLoadHook(luaSetups, srcPath)

    -- Get lua replative module path
    local luaRelStr = getLuaRelStr(srcPath)

    -- Unloading
    if not package.loaded[luaRelStr] and type(luaModule) ~= "string" then
        return
    else
        package.loaded[luaRelStr] = nil
    end

    -- Capture callback from module loading
    local ok, callback = pcall(require, luaRelStr)
    if not ok then
        vim.notify(
            string.format("Error detected while reloading lua package[%s] at: %s", luaRelStr, srcPath.filename),
            vim.log.levels.ERROR)
        vim.notify(" ", vim.log.levels.INFO)
        vim.notify(callback, vim.log.levels.ERROR)
        vim.notify(" ", vim.log.levels.INFO)
        vim.notify(
            string.format("Lua package[%s] has been unloaded", luaRelStr),
            vim.log.levels.INFO)
    else
        vim.notify(
            string.format("Reload lua package[%s] at: %s", luaRelStr, srcPath.filename),
            vim.log.levels.INFO)

        -- Load configuration AFTER reloading for specific module match the given path
        luaLoadHook(luaConfigs, srcPath, callback)
    end

end -- }}}


--- Reload lua module that come from a directory
--- @param srcPath object Plenary path object
--- @param dirStr string Diretory string in full path
--- @param checkLoadedFirst boolean Set this to true to make sure directory
---        module is loaded before reloading
M.luaLoadDir = function(srcPath, dirStr, checkLoadedFirst) -- {{{
    assert(type(dirStr) == "string", "Expect string value, got " .. type(dirStr))
    local dirPath = path:new(dirStr)
    assert(dirPath:is_dir() == true, "Invalid dirPath: " .. dirStr)

    local dirRelStr = string.gsub(path:new(dirStr):make_relative(luaModulePath.filename), sep, ".")

    if dirRelStr == "" then return end

    if checkLoadedFirst and
        not vim.tbl_contains(configPathForceDirLoadStrTbl, dirStr) then
        -- Check whether a directory module is loaded. If it does, analyze the
        -- whole directory. If it doesn't, then this module might just happend to
        -- be located at a ordinary directory for the sake of classification
        -- like:
        -- ~/.config/nvim/lua/operator.lua
        -- ~/.config/nvim/lua/redir.lua
        if not package.loaded[dirRelStr] then
            return M.luaLoadFile(srcPath, false)
        end
    end

    local fileRelStrs = luaSubfiles(dirPath, dirRelStr)

    -- Check if any type of module has been loaded. Even if no lua files nested
    -- inside a directory, the first element of the table return by the
    -- luaSubfiles will always be the dirRelStr
    if #fileRelStrs == 1 then return end

    local luaRelStrs = fileRel2luaRel(fileRelStrs)

    flattenTbl = {}
    flatten(luaRelStrs)
    luaRelStrs = vim.deepcopy(flattenTbl)


    -- Prefix each element inside luaRelLoadedStrs with the parent string
    -- eg: "/home/iaso2h/.config/nvim/lua/buf/action/close"
    local fileStrs = vim.tbl_map(function (i)
        return dirPath:parent().filename .. sep .. string.gsub(i, "%.", sep)
    end, luaRelStrs)

    luaChkLoadedOpenAndMod(fileStrs)

    -- Unloading
    -- luaSubfiles() makes sure that relative dir file path always listed
    -- before relative file path, so lua dir module will be always unloaded
    -- and reloaded one step ahead
    for _, s in ipairs(luaRelStrs) do
        package.loaded[s] = nil
    end

    -- Reloading
    for idx, luaRelStr in ipairs(luaRelStrs) do
        -- Prevent some lua modules get imported automatically due to the
        -- import from the last lua module
        if not package.loaded[luaRelStr] then
            local fileStr = fileStrs[idx]
            local fileChk
            if path:new(fileStr):is_dir() then
                fileChk = false
            else
                fileChk = true
                fileStr = fileStr .. ".lua"
            end

            local ok, msg = require(luaRelStr)
            if not ok then
                vim.notify(
                    string.format("Error detected while reloading lua package[%s] at: %s", luaRelStr, fileStr),
                    vim.log.levels.ERROR)
                vim.notify(" ", vim.log.levels.INFO)
                vim.notify(msg, vim.log.levels.ERROR)
                vim.notify(" ", vim.log.levels.INFO)
                for i = idx, #luaRelStrs, 1 do
                    vim.notify(
                        string.format("Lua package[%s] has been unloaded", luaRelStrs[i]),
                        vim.log.levels.INFO)
                end
            else
                if not fileChk then
                    vim.notify(string.format("Reload lua package[%s] at: %s",
                        luaRelStr, dirStr),
                        vim.log.levels.INFO)
                else
                    vim.notify(
                        string.format("Reload lua package[%s]: %s", luaRelStr, fileStr),
                        vim.log.levels.INFO)
                end
            end
        end

        -- Load the hook func at the last element
        if idx == #luaRelStrs then
            luaLoadHook(luaConfigs, path:new(fileStrs[1]))
        end
    end
end -- }}}


----
-- Function: Reload: Reload lua module path. Called in autocmd
--
-- @param module: String value of module path
----
M.reload = function() -- {{{
    local srcFullPathStr = fn.expand("%:p")
    -- Uppercase the first character in Windows
    if jit.os == "Windows" then
        srcFullPathStr = upperCaseWindowsDrive(srcFullPathStr)
    end
    local srcPath = path:new(srcFullPathStr)

    -- Config path only
    if not string.match(srcPath.filename, configPath.filename) then return end

    if vim.bo.filetype == "lua" then
        -- Lua {{{
        -- Only load lua module at: ~/.config/nvim/lua
        if not string.match(srcPath.filename, luaModulePath.filename) then return end

        local srcParentDirStr = srcPath:parent().filename
        if srcParentDirStr ~= luaModulePath.filename and
                not vim.tbl_contains(configPathForceFileLoadStrTbl, srcParentDirStr) then
            -- The lua module is a directory
            local srcParentDirStrs = srcPath:parents()
            -- Filter out any invalid lua sub directories under luaModulePath("~/.config/nvim/lua")
            for i = tbl_idx(srcParentDirStrs, luaModulePath.filename), #srcParentDirStrs do
                srcParentDirStrs[i] = nil
            end

            -- for _, dirStr in ipairs(srcParentDirStrs) do
                -- M.luaLoadDir(srcPath, dirStr, true)
            -- end
            M.luaLoadDir(srcPath, srcParentDirStrs[#srcParentDirStrs], true)
        else
            -- The lua module is a single file
            M.luaLoadFile(srcPath, true)
        end
        -- }}} Lua
    else
        -- Vim {{{
        -- Module path is always full path in VimL
        if srcPath.filename == configPath:joinpath("init.vim").filename or
            string.match(srcPath.filename, configPath:joinpath("plugins").filename) then

            cmd("noa source " .. srcPath)
            vim.notify(string.format("Reload: %s", srcPath), vim.log.levels.INFO)
        elseif string.match(srcPath.filename, configPath:joinpath("colors").filename) then
            local colorDirPath = configPath:joinpath("colors")
            local colorRel     = string.sub(
                path:new(srcPath.filename):make_relative(colorDirPath.filename),
                1, -5)
            cmd("noa silent! colorscheme " .. colorRel)
            vim.notify(string.format("Colorscheme: %s", colorRel), vim.log.levels.INFO)
        end
        -- }}} Vim
    end

end -- }}}

return M
