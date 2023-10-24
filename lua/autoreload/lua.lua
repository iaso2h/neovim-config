local util = require("autoreload.util")
local p    = require("plenary.path")
local M    = {
    unloadOnlyChk = false
}


local getAllRelStr
--- Get all path strings relative to the lua module search path
---@param parentStr           string Parent directory string
---@param moduleSearchPathStr string The lua module search path(Deafult: `vim.fn.stdpath("config")` .. "lua")
---@return table # Table that contains relative file paths. The table might contain heavily nested tables
getAllRelStr = function(parentStr, moduleSearchPathStr) -- {{{
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

    local parentFS = vim.loop.fs_opendir(parentStr)
    if not parentFS then return {} end

    local parentPath = p:new(parentStr)
    local parentRelToSearchStr = p:new(parentPath.filename):make_relative(moduleSearchPathStr)
    -- The value of directory name should always at the first place in each
    -- table. This will allows it to be unloaded or loaded before any module
    -- under the same level of directory in the future iteration
    local fileRelStrs = {parentRelToSearchStr}

    while true do
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

    vim.loop.fs_closedir(parentFS)

    return fileRelStrs
end -- }}}
--- Check whether other lua modules under the same lua directory have been
--opened and modified in other buffers. If any did, prompt the user to save the
--changes before reloading them all.
---@param allAbsStr table  Contains all absolute path strings under the
--top parent folder
---@param directParentTailStr string String of the top parent folder directly under
--the lua module search path(Deafult: `vim.fn.stdpath("config")` .. "lua")
local checkOtherOpenMod = function (allAbsStr, directParentTailStr) -- {{{
    local allBufNr = vim.tbl_map(function(absStr)
        local bufnr
        if absStr:sub(-4, -1) ~= ".lua" then
            -- Handle folder path by appending ".lua" or "<foldername>.lua"

            ---@diagnostic disable-next-line: param-type-mismatch
            bufnr = vim.fn.bufnr(string.format(
                "%s%sinit.lua",
                absStr,
                util.sep,
                "init.lua"
            ))

            if bufnr == -1 then
                -- fn.bufnr() will return -1 if buffer doesn't exist
                ---@diagnostic disable-next-line: param-type-mismatch
                bufnr = vim.fn.bufnr(string.format(
                    "%s%s%s.lua",
                    absStr,
                    util.sep,
                    directParentTailStr
                ))
            end
        else
            bufnr = vim.fn.bufnr(absStr)
        end

        return bufnr
    end, allAbsStr)

    local currentBufNr = vim.api.nvim_get_current_buf()
    local allValidBufNr = vim.tbl_filter(function(bufNr)
        if bufNr ~= -1 and -- What bufnr() will return for invalid path
            bufNr ~= currentBufNr and vim.api.nvim_buf_get_option(bufNr, "modified") then
            return true
        else
            return false
        end
    end, allBufNr)

    if #allValidBufNr == 0 then return end

    -- Prompt saving buffers
    local pluralStr = #allValidBufNr > 1 and "s" or ""
    vim.cmd "noa echohl MoreMsg"
    local answer = vim.fn.confirm(
        string.format("Save the modification%s for file%s under the same [%s] directory?",
            pluralStr, pluralStr, directParentTailStr),
        ">>> &Yes\n&No", 2, "Question")
    vim.cmd "noa echohl None"
    if answer == 1 then
        for _, n in ipairs(allValidBufNr) do
            vim.cmd(string.format("%sbufdo noa update", n))
        end
    end
end -- }}}
--- Get the relative lua module path that can be passed directly in the `require()` function
---@param path             Path Plenary path object of the current file
---@param parentPath       Path Plenary path object of the parent folder
---@param moduleSearchPath Path Plenary path object of the lua module search path(Deafult: `vim.fn.stdpath("config") .. "lua"`)
---@return string # Relative lua module path
local getModuleName = function(path, parentPath, moduleSearchPath) -- {{{
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
end -- }}}
--- Call functions before or after reloading specifc lua module
---@param hookTbl         ReloadHook
---@param path            Path Plenary path object of the absolute file path
---@param reloadCallback? function The callback function returned by reloading the lua module
local hook = function(hookTbl, path, reloadCallback) -- {{{
    ---@type ReloadHook
    local currentHook
    --- Match the current reloading module against given path pattern
    ---@param filename string
    ---@param pathPattern string
    ---@return boolean # Return true if a match pattern is found
    local matchPathPattern = function(filename, pathPattern)
        if filename == pathPattern or string.match(filename, pathPattern) then
            if type(currentHook.callbackHandler) == "function" then
                local ok, msg = pcall(currentHook.callbackHandler, path, reloadCallback)
                if not ok then
                    vim.notify("Error occurs while calling callback function from reloading " .. filename,
                        vim.log.levels.ERROR)
                    vim.notify(msg, vim.log.levels.ERROR)
                end
            end

            if currentHook.unloadOnlyChk then
                M.unloadOnlyChk = true
            end

            -- Load hook function only once, return ture to signify the termination
            return true
        else
            return false
        end
    end

    for _, hook in ipairs(hookTbl) do
        currentHook = hook
        if type(hook.pathPat) == "table" then
            for _, pathPat in ipairs(hook.pathPat) do
                if matchPathPattern(path.filename, pathPat) then
                    return
                end
            end
        elseif type(hook.pathPat) == "string" then
            if matchPathPattern(path.filename, hook.pathPat) then
                return
            end
        end
    end
end -- }}}
--- Reload a file lua module
---@param path       Path  Plenary path object. Lua module file
---@param parentPath Path  Plenary path object. Parent folder of the lua module file
---@param opt        table Options table initialized in `reload/init.lua`
M.loadFile = function(path, parentPath, opt) -- {{{
    -- Load setup hook
    hook(opt.setupHook, path)

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
        hook(opt.configHook, path, reloadCallback)
    end

end -- }}}
--- Reload a lua directory module
---@param path Path  Plenary path object. Lua module file
---@param opt  table Options table initialized in `reload/init.lua`
M.loadDir = function(path, opt) -- {{{
    -- Get the top parent folder under `<configpath>/lua/`
    local allParentStr = path:parents()
    local moduleSearchPathStr = opt.moduleSearchPath.filename
    local i = tbl_idx(allParentStr, moduleSearchPathStr, false)
    local directParentStr     = allParentStr[i - 1]
    local directParentTailStr = util.getTail(directParentStr)
    local pathTailRootStr     = util.getTail(path.filename:sub(1, -5))

    local allRelStrs = vim.tbl_flatten((getAllRelStr(directParentStr, moduleSearchPathStr)))
    if not next(allRelStrs) then return end

    local allAbsStrs = vim.tbl_map(function(relStr)
        return moduleSearchPathStr .. util.sep .. relStr
    end, allRelStrs)

    -- Convert to module name form valid for `require()` function call
    local allModules = vim.tbl_map(function(relStr)
        relStr = relStr:gsub(util.sep, ".")
        relStr = relStr:gsub(".lua$", "")
        return relStr
    end, allRelStrs)
    -- Fix the first lua module, namingly the directory module, wasn't loaded as
    -- `require(<dirname>.lua)` instead of `require(<dirname>)`
    if not package.loaded[allModules[1]] then
        if package.loaded[allModules[1] .. ".lua"] then
            allModules[1] = allModules[1] .. ".lua"
        end
    end


    -- Only unload and reload modules found in the `package.loaded` table
    local allLoadedModules = vim.tbl_filter(function(module)
        if package.loaded[module] ~= nil then
            return true
        else
            return false
        end
    end, allModules)

    if #allLoadedModules == 0 then return end

    -- No need to reload other modules except the `<dirname>.lua` file and the
    -- `init.lua` file when that module isn't loaded in runtime. Doesn't worth
    -- reloading the whole directory because of it
    if pathTailRootStr ~= "init" and pathTailRootStr ~= directParentTailStr and
        not vim.tbl_contains(allLoadedModules, allModules[tbl_idx(allAbsStrs, path.filename, false)]) then

        return
    end

    -- Prompt to save other buffers under the same directory when they are modified
    if #allRelStrs ~= 1 then
        checkOtherOpenMod(allAbsStrs, directParentTailStr)
    end

    -- Load setup hook
    hook(opt.setupHook, path)

    -- Unloading
    for _, module in ipairs(allLoadedModules) do
        package.loaded[module] = nil
    end

    if M.unloadOnlyChk then
        M.unloadOnlyChk = false -- reset
        return
    end

    -- Reloading
    for idx, module in ipairs(allLoadedModules) do
        local moduleIdx = tbl_idx(allModules, module, false)
        local relStr = allRelStrs[moduleIdx]
        local absStr = allAbsStrs[moduleIdx]

        local fileChkStr
        -- When moduleIdx == 1, even if the file ends with `.lua`, it's
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
                for j = idx, #allLoadedModules, 1 do
                    vim.notify(
                        string.format("Lua module[%s] has been unloaded", allLoadedModules[j]),
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
        if idx == #allLoadedModules then
            hook(opt.configHook, path)
        end
    end
end -- }}}


return M
