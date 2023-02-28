local ok, msg = pcall(require, "core.options")
if not ok then vim.notify(msg, vim.log.levels.ERROR) end

ok, msg = pcall(require, "core.commands")
if not ok then vim.notify(msg, vim.log.levels.ERROR) end

_G.CoreMappigsStart = true
ok, msg = pcall(require, "core.mappings")
if not ok then vim.notify(msg, vim.log.levels.ERROR) end
_G.CoreMappigsStart = false

vim.defer_fn(function()
    local ok1, msg1 = pcall(require, "core.plugins")
    if not ok1 then vim.notify(msg1, vim.log.levels.ERROR) end
end, 0)

ok, msg = pcall(require, string.format("packer_compiled_%s", isTerm and "term" or "gui"))
if not ok then vim.notify(msg, vim.log.levels.ERROR) end

