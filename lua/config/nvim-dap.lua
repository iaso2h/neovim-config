local M = {}

M.setup = function()
    map("n", [[<leader>db]], [[:lua require('dap').toggle_breakpoint()<CR>]], {"silent"})
    map("n", [[<F5>]],       [[:lua require('dap').continue()<CR>]],          {"silent"})
    map("n", [[<S-F5>]],     [[:lua require('dap').run_last()<CR>]],          {"silent"})
end

M.config = function()

    local cmd = vim.cmd
    local fn  = vim.fn
    local dap = require("dap")

    -- General mappings {{{
    map("n", [[<leader>c]], [[:lua require('dap').run_to_cursor()<CR>zz]], {"silent"})
    map("n", [[<leader>s]], [[:lua require('dap').step_into()<CR>zz]],     {"silent"})
    map("n", [[<leader>n]], [[:lua require('dap').step_over()<CR>zz]],     {"silent"})
    map("n", [[<leader>o]], [[:lua require('dap').step_out()<CR>zz]],      {"silent"})

    map("n", [[<leader>k]],  [[:lua require('dap').up()<CR>]],    {"silent"})
    map("n", [[<leader>j]],  [[:lua require('dap').down()<CR>]],  {"silent"})
    map("n", [[<leader>dg]], [[:lua require('dap').goto_()<CR>]], {"silent"})

    map("n", [[<leader>dr]], [[:lua require('dap').repl.toggle()<CR>]],      {"silent"})
    map("n", [[<leader>dB]], [[:lua require('dap').list_breakpoints()<CR>]], {"silent"})
    -- map("n", [[<leader>B]],  [[:lua require('dap').set_breakpoint(vim.fn.input('Breakpoint Condition: '), nil, nil, true)<CR>]], {"silent"})
    -- map("n", [[<leader>dl]], [[:lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>]], {"silent"})


    -- TODO:
    map("n", [[<C-w>d]], [[:lua require("dap.ui.widgets").sidebar(require("dap.ui.widgets").scopes).toggle({height=15})<CR>]], {"silent"})
    map("n", [[dK]],     [[:lua require("dap.ui.widgets").hover()<CR>]],  {"silent"})

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

