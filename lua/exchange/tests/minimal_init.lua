local configPath = vim.fn.stdpath("config")
vim.opt.runtimepath:append(configPath)
-- Add plenary.nvim, vim-repeat, vim-visualrepeat in your runtime path. In my
-- case, I manage them via packer.nvim
local packagePathHead = vim.fn.stdpath("data") .. "/lazy/"
vim.opt.runtimepath:append(packagePathHead .. "plenary.nvim")
vim.opt.runtimepath:append(packagePathHead .. "vim-repeat")

require("global")
require("util.test")
require("core.mappings")

require("exchange")._dev = true
require("exchange").highlightChangeChk = false
