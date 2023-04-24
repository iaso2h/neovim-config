local configPath = vim.fn.stdpath("config")
vim.opt.runtimepath:append(configPath)
-- Add plenary.nvim, vim-repeat, vim-visualrepeat in your runtime path. In my
-- case, I manage them via packer.nvim
local packagePathHead = vim.fn.stdpath("data") .. "/lazy/"
vim.opt.runtimepath:append(packagePathHead .. "plenary.nvim")

require("global")
require("util.test")

-- Mapping
-- map("n", [[<C-o>]], function()
--     require("jump.jumplist").go("n", false, "local")
-- end, {"silent"}, "Oldder local jump")
-- map("n", [[<C-i>]], function()
--     require("jump.jumplist").go("n", true, "local")
-- end, {"silent"}, "Newer local jump")

-- map("x", [[<C-o>]], luaRHS[[:lua
--     require("jump.jumplist").visualMode = vim.fn.visualmode();
--     require("jump.jumplist").go(vim.fn.visualmode(), false, "local")<CR>
-- ]], {"silent"}, "Older local jump")
-- map("x", [[<C-i>]], luaRHS[[:lua
--     require("jump.jumplist").visualMode = vim.fn.visualmode();
--     require("jump.jumplist").go(vim.fn.visualmode(), true, "local")<CR>
-- ]], {"silent"}, "Newer local jump")

-- map("n", [[g<C-o>]], function()
--     require("jump.jumplist").go("n", false, "buffer")
-- end, {"silent"}, "Older buffer jump")
-- map("n", [[g<C-i>]], function()
--     require("jump.jumplist").go("n", true, "buffer")
-- end, {"silent"}, "Newer buffer jump")
