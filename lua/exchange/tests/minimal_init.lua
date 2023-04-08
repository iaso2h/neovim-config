local configPath = vim.fn.stdpath("config")
vim.opt.runtimepath:append(configPath)
-- Add plenary.nvim, vim-repeat, vim-visualrepeat in your runtime path. In my
-- case, I manage them via packer.nvim
local packagePathHead = vim.fn.stdpath("data") .. "/lazy/"
vim.opt.runtimepath:append(packagePathHead .. "plenary.nvim")
vim.opt.runtimepath:append(packagePathHead .. "vim-repeat")

require("global.keymap")
require("util.test")

require("exchange")._dev = true
require("exchange").highlightChangeChk = false
-- Mapping
map("n", [[<Plug>exchangeOperatorInplace]], function ()
    return vim.fn.luaeval [[require("exchange").expr(true, true)]]
end, {"silent", "expr"}, "exchange operator and restore the cursor position")

map("n", [[gx]],  [[<Plug>exchangeOperatorInplace]], "exchange operator and restore the cursor position")
