local ok, msg = pcall(require, "core.options")
if not ok then vim.notify(msg, vim.log.levels.ERROR) end

ok, msg = pcall(require, "core.commands")
if not ok then vim.notify(msg, vim.log.levels.ERROR) end

ok, msg = pcall(require, "core.mappings")
if not ok then vim.notify(msg, vim.log.levels.ERROR) end

vim.defer_fn(function()
    local ok1, msg1 = pcall(require, "core.plugins")
    if not ok1 then vim.notify(msg1, vim.log.levels.ERROR) end
end, 0)

ok, msg = pcall(require, "packer_compiled")
if not ok then vim.notify(msg, vim.log.levels.ERROR) end

