local fn   = vim.fn
local api  = vim.api
local util = require("autoreload.util")
local p    = require("plenary.path")
local M    = {
    unloadOnlyChk = false
}


-- local packerCompileQuery = function(...)
    -- local answer = fn.confirm("Update packages?", "&Sync\ncom&Pile\n&No", 3)

    -- if answer == 1 then
        -- vim.cmd [[PackerSync]]
    -- elseif answer == 2 then
        -- vim.cmd [[PackerCompile]]
    -- end
-- end


local getAllRelStr
--- Get all path strings relative to the lua module search path
---@param parentStr           object Plenary path object with a directory path as its - filename property
---@param moduleSearchPathStr string The lua module search path(Deafult: vim.fn.stdpath("config") .. "lua")
---@return table              Table  that contains relative file paths. The table might
getAllRelStr = function(parentStr, moduleSearchPathStr)
    -- Value of tbl in each iteration:
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

    -- Output:
    -- || { "buf", { "buf\\action", "buf\\action\\close.lua", "buf\\action\\closeOther.lua", "buf\\action\\cursorRecall.lua", "buf\\action\\cycle.lua", "buf\\action\\newSplit.lua", "buf\\action\\redir.lua" }, "buf\\util.lua", "buf\\var.lua" }

    ---@diagnostic disable-next-line: param-type-mismatch
    local parentFS = vim.loop.fs_opendir(parentStr)
    local parentPath = p:new(parentStr)
    local parentRelToSearchStr = p:new(parentPath.filename):make_relative(moduleSearchPathStr)
    -- The value of directory name should always at the first place in each
    -- table. This will allows it to be unloaded or loaded before any module
    -- under the same level of directory in the future iteration
    local fileRelStrs = {parentRelToSearchStr}

    while true do
        ---@diagnostic disable-next-line: param-type-mismatch
        local tbl = vim.loop.fs_readdir(parentFS)

        if not tbl then break end

        local name = tbl[1].name
        local type = tbl[1].type

        if name:sub(-4, -1) == ".lua" and type == "file" and
            -- Filter out path like:
            -- ~/.config/nvim/replace/replace.init
            -- ~/.config/nvim/replace/init.init
            not name ~= parentRelToSearchStr .. ".lua" and name ~= "init.lua" then

            fileRelStrs[#fileRelStrs+1] = string.format("%s%s%s",
                parentRelToSearchStr, util.sep, name)
        elseif type == "directory" then
            -- Recursive function call
            fileRelStrs[#fileRelStrs+1] = getAllRelStr(parentPath:joinpath(name).filename, moduleSearchPathStr)
        end
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    vim.loop.fs_closedir(parentFS)

    return fileRelStrs
end


--- Check whether other lua modules under the same lua directory have been
--opened and modified in other buffers. If any did, prompt the user to save the
--changes before reloading them all.
---@param allAbsStr        table  Contains all absolute path strings under the
--top parent folder
---@param topParentTailStr string String of the top parent folder directly under
--the lua module search path(Deafult: vim.fn.stdpath("config") .. "lua")
local checkOtherOpenMod = function (allAbsStr, topParentTailStr)
    local allBufNr = vim.tbl_map(function(absStr)
        local bufnr
        if absStr:sub(-4, -1) ~= ".lua" then
            -- Handle folder path by appending ".lua" or "<foldername>.lua"

            ---@diagnostic disable-next-line: param-type-mismatch
            bufnr = fn.bufnr(string.format(
                "%s%sinit.lua", absStr, util.sep, "init.lua"))

            if bufnr == -1 then
                -- fn.bufnr() will return -1 if buffer doesn't exist
                ---@diagnostic disable-next-line: param-type-mismatch
                bufnr = fn.bufnr(string.format(
                    "%s%s%s.lua", absStr, util.sep, topParentTailStr, ".lua"))
            end
        else
            bufnr = fn.bufnr(absStr)
        end

        return bufnr
    end, allAbsStr)

    local currentBufNr = api.nvim_get_current_buf()
    local allValidBufNr = vim.tbl_filter(function(bufNr)
        if bufNr ~= -1 and bufNr ~= currentBufNr and api.nvim_buf_get_option(bufNr, "modified") then
            return true
        else
            return false
        end
    end, allBufNr)

    if #allValidBufNr == 0 then return end

    -- Prompt saving buffers
    local pluralStr = #allValidBufNr > 1 and "s" or ""
    vim.cmd "noa echohl MoreMsg"
    local answer = fn.confirm(
        string.format("Save the modification%s for file%s under the same [%s] directory?",
            pluralStr, pluralStr, topParentTailStr),
        ">>> &Yes\n&No", 1, "Question")
    vim.cmd "noa echohl None"
    if answer == 1 then
        for _, n in ipairs(allValidBufNr) do
            vim.cmd(string.format("%sbufdo noa update", n))
        end
    end
end


--- Get the relative lua module path that can be passed directly in func require()
--- @param path             object Plenary path object of the current file
--- @param parentPath       object Plenary path object of the parent folder
--- @param moduleSearchPath object Plenary path object of the lua module search path(Deafult: vim.fn.stdpath("config") .. "lua")
--- @return string Relative lua module path
local getModuleName = function(path, parentPath, moduleSearchPath)
    local fileRelToSearchStr = path:new(path.filename):make_relative(moduleSearchPath.filename)

    if parentPath:parent().filename == moduleSearchPath.filename then
        -- Handle file has the same root(name without extension) string with the
        -- parent folder or the file is a init.lua file as per.

        local tailStr     = util.getTail(path.filename)
        local tailRootStr = tailStr:sub(1, -5)
        local parentTail  = util.getTail(parentPath.filename)
        if tailRootStr == "init" or tailRootStr == parentTail then
            return parentTail
        else
            local moduleTail = string.gsub(fileRelToSearchStr, util.sep, ".")
            return moduleTail:sub(1, -5)
        end
    else
        local moduleTail = string.gsub(fileRelToSearchStr, util.sep, ".")
        return moduleTail:sub(1, -5)
    end
end


--- Call functions before or after reloading specifc lua module
--- @param hookTbl         table
--- @param path            object   Plenary path object of the absolute file path
--- @param reloadCallback? function The callback function returned by reloading the lua module
local hook = function(hookTbl, path, reloadCallback)
    for _, tbl in ipairs(hookTbl) do
        if string.match(path.filename, tbl.pathPat) then
            local ok, msg = pcall(tbl.callback, path, reloadCallback)
            if not ok then
                vim.notify("Error occurs while loading lua config for " .. path.filename,
                    vim.log.levels.ERROR)
                vim.notify(msg, vim.log.levels.ERROR)
            end

            if tbl.unloadOnlyChk then
                M.unloadOnlyChk = true
            end
        end
    end
end


--- Reload a file lua module
---@param path       object Plenary path object. Lua module file
---@param parentPath object Plenary path object. Parent folder of the lua module file
---@param opt        table  Options table initialized in reload/init.lua
M.loadFile = function(path, parentPath, opt) -- {{{
    -- Load setup hook
    hook(opt.setup, path)

    -- Get lua module name
    local module = getModuleName(path, parentPath, opt.moduleSearchPath)

    -- Unloading
    if not package.loaded[module] then
        return
    else
        package.loaded[module] = nil
    end

    if M.unloadOnlyChk then
        M.unloadOnlyChk = false -- reset
        return
    end

    -- Capture callback from module loading
    local ok, reloadCallback = pcall(require, module)
    if not ok then
        vim.notify(
            string.format("Error detected while reloading lua package[%s] at: %s", module, path.filename),
            vim.log.levels.ERROR)
        vim.notify(" ", vim.log.levels.INFO)
        vim.notify(reloadCallback, vim.log.levels.ERROR)
        vim.notify(" ", vim.log.levels.INFO)
        vim.notify(
            string.format("Lua package[%s] has been unloaded", module),
            vim.log.levels.INFO)
    else
        vim.notify(
            string.format("Reloading lua package[%s] at: %s", module, path.filename),
            vim.log.levels.INFO)

        -- Load configuration AFTER reloading for specific module match the given path
        hook(opt.config, path, reloadCallback)
    end

end -- }}}


--- Reload a lua directory module
---@param path object Plenary path object. Lua module file
---@param opt table Options table initialized in reload/init.lua
M.loadDir = function(path, opt) -- {{{
    -- Get the top parent folder under <configpath>/lua/
    local allParentStr = path:parents()
    local moduleSearchPathStr = opt.moduleSearchPath.filename
    local i = tbl_idx(allParentStr, moduleSearchPathStr)
    local topParentStr     = allParentStr[i - 1]
    local topParentTailStr = util.getTail(topParentStr)
    local pathTailRootStr  = util.getTail(path.filename:sub(1, -5))

    local allRelStr = vim.tbl_flatten((getAllRelStr(topParentStr, moduleSearchPathStr)))
    local allAbsStr = vim.tbl_map(function(relStr)
        return moduleSearchPathStr .. util.sep .. relStr
    end, allRelStr)

    -- Convert to module name form valid for require() function call
    local allModule = vim.tbl_map(function(relStr)
        relStr = relStr:gsub(util.sep, ".")
        relStr = relStr:gsub(".lua$", "")
        return relStr
    end, allRelStr)
    -- Avoid the first lua directory module loaded as "<dirname>.lua" instead as "<dirname>"
    if not package.loaded[allModule[1]] then
        allModule[1] = allModule[1] .. ".lua"
    end

    -- Only unload and reload module found in the package.loaded table
    local allLoadedModule = vim.tbl_filter(function(module)
        if package.loaded[module] ~= nil then
            return true
        else
            return false
        end
    end, allModule)

    if #allLoadedModule == 0 then return end
    -- No need to reload other module except the <dirname>.lua file and the
    -- init.lua when that module isn't loaded in runtime. Doesn't worth
    -- reloading the whole directory because of it
    if pathTailRootStr ~= "init" and pathTailRootStr ~= topParentTailStr and
        not vim.tbl_contains(allLoadedModule, allModule[tbl_idx(allAbsStr, path.filename)]) then
        return
    end

    -- Prompt to save other buffers under the same directory when they are modified
    if #allRelStr ~= 1 then
        checkOtherOpenMod(allAbsStr, topParentTailStr)
    end

    -- Load setup hook
    hook(opt.setup, path)

    -- Unloading
    for _, module in ipairs(allLoadedModule) do
        package.loaded[module] = nil
    end

    if M.unloadOnlyChk then
        M.unloadOnlyChk = false -- reset
        return
    end

    -- Reloading
    for idx, module in ipairs(allLoadedModule) do
        local moduleIdx = tbl_idx(allModule, module)
        local relStr = allRelStr[moduleIdx]
        local absStr = allAbsStr[moduleIdx]

        local fileChkStr
        -- When moduleIdx == 1, even if the file ends with ".lua", it's
        -- still considered as a directory module
        if moduleIdx ~= 1 and relStr:sub(-4, -1) == ".lua" then
            fileChkStr = " at"
        else
            fileChkStr = ""
        end

        -- Since some sub-module will be imported automatically when module in high
        -- hierarchy is being imported, what we need to reload those missing parts
        if not package.loaded[module] then

            local ok, msg = require(module)
            if not ok then
                vim.notify(
                    string.format("Error detected while reloading lua module[%s]%s: %s", module, fileChkStr, absStr),
                    vim.log.levels.ERROR)
                vim.notify(" ", vim.log.levels.INFO)
                vim.notify(msg, vim.log.levels.ERROR)
                vim.notify(" ", vim.log.levels.INFO)
                for i = idx, #allLoadedModule, 1 do
                    vim.notify(
                        string.format("Lua module[%s] has been unloaded", allLoadedModule[i]),
                        vim.log.levels.INFO)
                end
            else
                vim.notify(string.format([[Reloading lua module[%s]%s: %s]],
                    module, fileChkStr, moduleSearchPathStr .. util.sep .. relStr),
                    vim.log.levels.INFO)
            end
        else
            vim.notify(string.format([[             require[%s]%s: %s]],
                module, fileChkStr, moduleSearchPathStr .. util.sep .. relStr),
                vim.log.levels.INFO)
        end

        -- Load configuration AFTER reloading for specific module match the given path
        -- Load the hook func at the last element
        if idx == #allLoadedModule then
            hook(opt.config, path)
        end
    end
end -- }}}


return M
