local configPath = vim.fn.stdpath("config")
vim.opt.runtimepath:append(configPath)
require("global")
require("util.test")
require("core.mappings")

-- Add plenary.nvim, vim-repeat, vim-visualrepeat in your runtime path. In my
-- case, I manage them via packer.nvim
local packagePathHead = vim.fn.stdpath("data") .. "/lazy/"
vim.opt.runtimepath:append(packagePathHead .. "plenary.nvim")
vim.opt.runtimepath:append(packagePathHead .. "vim-repeat")
vim.opt.runtimepath:append(packagePathHead .. "vim-visualrepeat")

require("replace").suppressMessage = true
