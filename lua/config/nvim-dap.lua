local M = {}

M.setup = function()
    map("n", [[<leader>db]],  [[<CMD>lua: require('dap').toggle_breakpoint()<CR>]], {"silent"}, "Dap toggle breakpoint")
    map("n", [[<leader>dcb]], [[<CMD>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint Condition: '), nil, nil, true)<CR>]], {"silent"}, "Dap set conditional break point")
    map("n", [[<leader>dl]],  [[<CMD>lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>]], {"silent"}, "Dap set log point")
    map("n", [[<F5>]],       [[<CMD>lua: require('dap').continue()<CR>]], "Dap continue")
    map("n", [[<S-F5>]],     [[<CMD>lua: require('dap').run_last()<CR>]], "Dap run last")
end

M.config = function()
    local cmd = vim.cmd
    local fn  = vim.fn
    local dap = require("dap")

    -- General mappings {{{
    map("n", [[<leader>c]], [[<CMD>lua: require('dap').run_to_cursor()<CR>]], {"silent"}, "Dap run_to_cursor")
    map("n", [[<leader>s]], [[<CMD>lua: require('dap').step_into()<CR>]],     {"silent"}, "Dap run_to_cursor")
    map("n", [[<leader>n]], [[<CMD>lua: require('dap').step_over()<CR>]],     {"silent"}, "Dap run_to_cursor")
    map("n", [[<leader>o]], [[<CMD>lua: require('dap').step_out()<CR>]],      {"silent"}, "Dap run_to_cursor")

    map("n", [[<leader>k]],  [[<CMD>lua: require('dap').up()<CR>]],    {"silent"}, "Dap run_to_cursor")
    map("n", [[<leader>j]],  [[<CMD>lua: require('dap').down()<CR>]],  {"silent"}, "Dap run_to_cursor")
    map("n", [[<leader>dg]], [[<CMD>lua: require('dap').goto_()<CR>]], {"silent"}, "Dap run_to_cursor")

    map("n", [[<leader>dr]], [[<CMD>lua: require('dap').repl.toggle()<CR>]],      {"silent"}, "Dap run_to_cursor")
    map("n", [[<leader>ld]], [[<CMD>lua: require('dap').list_breakpoints()<CR>]], {"silent"}, "Dap run_to_cursor")

    map("n", [[<C-w>d]], [[<CMDlua require("dap.ui.widgets").sidebar(require("dap.ui.widgets").scopes).toggle({height=15})<CR>]], {"silent"}, "Dap toggle sidebar")
    map("n", [[dK]],     [[<CMDlua require("dap.ui.widgets").hover()<CR>]],  {"silent"}, "Dap hover")

    -- map("n", [[<F12>]], [[:lua require('dap-python').test_method()<CR>]],          {"silent"})
    -- map("x", [[<F5>]],  [[<esc>:lua require('dap-python').debug_selection()<CR>]], {"silent"})
    -- }}} General mappings

    fn.sign_define('DapBreakpoint', {text='●', texthl='DiagnosticError', linehl='', numhl='DiagnosticError'})
    fn.sign_define('DapStopped',    {text='', texthl='DiagnosticWarn',  linehl='', numhl='DiagnosticWarn'})
    fn.sign_define('DapLogPoint',   {text='', texthl='MoreMsg',         linehl='', numhl='MoreMsg'})

    cmd [[
    command! -nargs=0 DapBreakpoints lua require('dap').list_breakpoints()
    command! -nargs=0 DapSidebar     lua require("dap.ui.widgets").sidebar(require("dap.ui.widgets").scopes).toggle({height=15})
    ]]


    dap.configurations.lua = {
        {
            type = "nlua",
            request = "attach",
            name = "Attach to running Neovim instance",
        }
    }

    dap.adapters.nlua = function(callback, config)
        -- callback{type = 'server', host = config.host, port = config.port}
        callback{type = "server", host = config.host or "127.0.0.1" , port = config.port or 8086, }
    end
end

return M

