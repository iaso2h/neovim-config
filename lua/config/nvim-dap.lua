local M = {}

M.setup = function()
    map("n", [[<leader>db]], require('dap').toggle_breakpoint, "Dap toggle breakpoint")
    map("n", [[<leader>dcb]],  [[:lua require('dap').set_breakpoint(vim.fn.input('Breakpoint Condition: '), nil, nil, true)<CR>]], {"silent"}, "Dap set conditional break point")
    map("n", [[<leader>dl]], [[:lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>]], {"silent"}, "Dap set log point")
    map("n", [[<F5>]],       require('dap').continue, "Dap continue")
    map("n", [[<S-F5>]],     require('dap').run_last, "Dap run last")
end

M.config = function()
    local cmd = vim.cmd
    local fn  = vim.fn
    local dap = require("dap")

    -- General mappings {{{
    map("n", [[<leader>c]], require('dap').run_to_cursor, "Dap run_to_cursor")
    map("n", [[<leader>s]], require('dap').step_into, "Dap run_to_cursor")
    map("n", [[<leader>n]], require('dap').step_over, "Dap run_to_cursor")
    map("n", [[<leader>o]], require('dap').step_out, "Dap run_to_cursor")

    map("n", [[<leader>k]],  require('dap').up, "Dap run_to_cursor")
    map("n", [[<leader>j]],  require('dap').down, "Dap run_to_cursor")
    map("n", [[<leader>dg]], require('dap').goto_, "Dap run_to_cursor")

    map("n", [[<leader>dr]], require('dap').repl.toggle, "Dap run_to_cursor")
    -- BUG: function failed
    map("n", [[<leader>ld]], require('dap').list_breakpoints, "Dap run_to_cursor")

    map("n", [[<C-w>d]], [[:lua require("dap.ui.widgets").sidebar(require("dap.ui.widgets").scopes).toggle({height=15})<CR>]], {"silent"}, "Dap toggle sidebar")
    map("n", [[dK]],     [[:lua require("dap.ui.widgets").hover()<CR>]],  {"silent"}, "Dap hover")

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
            host = '127.0.0.1',
            -- port = '44444',
            -- host = function()
                -- local value = vim.fn.input("Host [127.0.0.1]: ")
                -- if value ~= "" then
                    -- return value
                -- end
                -- return "127.0.0.1"
            -- end,
            port = function()
                local val = tonumber(fn.input("Port: "))
                assert(val, "Please provide a port number")
                return val
            end,
        }
    }

    dap.adapters.nlua = function(callback, config)
        -- callback{type = 'server', host = config.host, port = config.port}
        callback{type = 'server', host = "127.0.0.1", port = config.port, }
    end
end

return M

