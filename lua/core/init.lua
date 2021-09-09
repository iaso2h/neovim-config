local ok, _ = pcall(require, "core.options")
if not ok then
    vim.api.nvim_echo({{"Options config loaded unsuccessfully", "ErrorMsg"}}, true, {})
    vim.api.nvim_echo({{_, "ErrorMsg"}}, true, {})
end

ok, _ = pcall(require, "core.mappings")
if not ok then
    vim.api.nvim_echo({{"Mappings config loaded unsuccessfully", "ErrorMsg"}}, true, {})
    vim.api.nvim_echo({{_, "ErrorMsg"}}, true, {})
end

ok, _ = pcall(require, "core.commands")
if not ok then
    vim.api.nvim_echo({{"Commands config loaded unsuccessfully", "ErrorMsg"}}, true, {})
    vim.api.nvim_echo({{_, "ErrorMsg"}}, true, {})
end

vim.defer_fn(function()
    local ok, _ = pcall(require, "core.plugins")
    if not ok then
        vim.api.nvim_echo({{"Plugins config loaded unsuccessfully", "ErrorMsg"}}, true, {})
        vim.api.nvim_echo({{_, "ErrorMsg"}}, true, {})
    end
end, 0)

