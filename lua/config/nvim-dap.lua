local M = {}

M.setup = function()
    map("n", [[<leader>db]], [[:lua require('dap').toggle_breakpoint()<cr>]], {"silent"})
    map("n", [[<F5>]],       [[:lua require('dap').continue()<cr>]],          {"silent"})
    map("n", [[<S-F5>]],     [[:lua require('dap').run_last()<cr>]],          {"silent"})
end

M.config = function()

    local cmd = vim.cmd
    local fn  = vim.fn
    local dap = require("dap")

    -- General mappings {{{
    map("n", [[<leader>c]], [[:lua require('dap').run_to_cursor()<cr>]], {"silent"})
    map("n", [[<leader>s]], [[:lua require('dap').step_into()<cr>]],     {"silent"})
    map("n", [[<leader>n]], [[:lua require('dap').step_over()<cr>]],     {"silent"})
    map("n", [[<leader>o]], [[:lua require('dap').step_out()<cr>]],      {"silent"})

    map("n", [[<leader>k]],  [[:lua require('dap').up()<cr>]],    {"silent"})
    map("n", [[<leader>j]],  [[:lua require('dap').down()<cr>]],  {"silent"})
    map("n", [[<leader>dg]], [[:lua require('dap').goto_()<cr>]], {"silent"})

    map("n", [[<leader>dr]], [[:lua require('dap').repl.open()<cr>]], {"silent"})
    map("n", [[<leader>dB]], [[:lua require('dap').list_breakpoints()cr>]],   {"silent"})
    -- map("n", [[<leader>B]],  [[:lua require('dap').set_breakpoint(vim.fn.input('Breakpoint Condition: '), nil, nil, true)<cr>]], {"silent"})
    -- map("n", [[<leader>dl]], [[:lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>]], {"silent"})


    -- TODO:
    -- map("n", [[<C-w>d]], [[:lua require('dap').toggle({height=15})<cr>]], {"silent"})
    map("n", [[dK]],     [[:lua require('dap.ui.widgets').hover()<cr>]],  {"silent"})

    -- map("n", [[<F12>]], [[:lua require('dap-python').test_method()<cr>]],          {"silent"})
    -- map("x", [[<F5>]],  [[<esc>:lua require('dap-python').debug_selection()<cr>]], {"silent"})
    -- }}} General mappings

    fn.sign_define('DapBreakpoint', {text='●', texthl='Debug', linehl='', numhl='Error'})
    fn.sign_define('DapStopped',    {text='', texthl='MoreMsg',   linehl='', numhl='WarningMsg'})
    fn.sign_define('DapLogPoint',   {text='', texthl='MoreMsg',  linehl='', numhl='MoreMsg'})

    cmd [[
    command! -nargs=0 DapBreakpoints :lua require('dap').list_breakpoints()
    command! -nargs=0 DapSidebar     :lua require('dap').sidebar.toggle()
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

