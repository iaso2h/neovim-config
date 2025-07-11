local ok, msg = pcall(require, "core.options")
if not ok then vim.api.nvim_echo({{msg,}}, true, {err=true}) end

vim.api.nvim_create_autocmd("vimEnter", {
    desc     = "Display history on startup",
    callback = function ()
        require("historyStartup").display(false)
    end
})

vim.defer_fn(function()
    ok, msg = pcall(require, "core.commands")
    if not ok then vim.api.nvim_echo({{msg,}}, true, {err=true}) end
end, 0)

vim.defer_fn(function()
    _G.CoreMappigsStart = true
    ok, msg = pcall(require, "core.mappings")
    if not ok then vim.api.nvim_echo({{msg,}}, true, {err=true}) end
    _G.CoreMappigsStart = false
end, 0)
