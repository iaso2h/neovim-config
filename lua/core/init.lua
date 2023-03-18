local ok, msg = pcall(require, "core.options")
if not ok then vim.notify(msg, vim.log.levels.ERROR) end

vim.api.nvim_create_autocmd("vimEnter", {
    desc     = "Display history on startup",
    callback = function ()
        require("historyStartup").display()
    end
})

vim.defer_fn(function()
    ok, msg = pcall(require, "core.commands")
    if not ok then vim.notify(msg, vim.log.levels.ERROR) end
end, 0)

vim.defer_fn(function()
    _G.CoreMappigsStart = true
    ok, msg = pcall(require, "core.mappings")
    if not ok then vim.notify(msg, vim.log.levels.ERROR) end
    _G.CoreMappigsStart = false
end, 0)

if _G._enablePlugin then
    vim.defer_fn(function()
        ok, msg = pcall(require, "core.plugins")
        if not ok then
            return vim.notify(msg, vim.log.levels.ERROR)
        end
    end, 0)
end
