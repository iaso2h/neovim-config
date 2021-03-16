local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api

map = require("util").map
map("n", [[<F5>]],       [[:lua require('dap').continue()<cr>]],                                                    {"noremap", "silent"})
map("n", [[<F10>]],      [[:lua require('dap').step_over()<cr>]],                                                   {"noremap", "silent"})
map("n", [[<F11>]],      [[:lua require('dap').step_into()<cr>]],                                                   {"noremap", "silent"})
map("n", [[<F12>]],      [[:lua require('dap').step_out()<cr>]],                                                    {"noremap", "silent"})
map("n", [[<leader>b]],  [[:lua require('dap').toggle_breakpoint()<cr>]],                                           {"noremap", "silent"})
map("n", [[<leader>B]],  [[:lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>]],        {"noremap", "silent"})
map("n", [[<leader>lp]], [[:lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>]], {"noremap", "silent"})
map("n", [[<leader>dr]], [[:lua require('dap').repl.open()<cr>]],                                                   {"noremap", "silent"})
map("n", [[<leader>dl]], [[:lua require('dap').repl.run_last()<cr>`]],                                              {"noremap", "silent"})
map("n", [[<leader>dn]], [[:lua require('dap-python').test_method()<cr>]],                                          {"noremap", "silent"})
map("v", [[<leader>ds]], [[<esc>:lua require('dap-python').debug_selection()<cr>]],                                 {"noremap", "silent"})

if fn.has('win32') == 1 then
    require('dap-python').setup('D:/anaconda3/envs/test/python.exe')
end

