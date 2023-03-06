return function()
    local fn   = vim.fn
    local dap  = require("dap")
    local icon = require("util.icon")

    -- General mappings {{{
    map("n", [[<leader>c]], [[<CMD>lua require("dap").run_to_cursor()<CR>]], {"silent"}, "Dap run to cursor")
    map("n", [[<leader>N]], [[<CMD>lua require("dap").step_into()<CR>]],     {"silent"}, "Dap step into")
    map("n", [[<leader>n]], [[<CMD>lua require("dap").step_over()<CR>]],     {"silent"}, "Dap step over")
    map("n", [[<leader>o]], [[<CMD>lua require("dap").step_out()<CR>]],      {"silent"}, "Dap step out")

    map("n", [[<leader>dk]], [[<CMD>lua require("dap").up()<CR>]],    {"silent"}, "Dap frame up")
    map("n", [[<leader>dj]], [[<CMD>lua require("dap").down()<CR>]],  {"silent"}, "Dap frame down")
    map("n", [[<leader>dg]], [[<CMD>lua require("dap").goto_()<CR>]], {"silent"}, "Dap Go to")

    -- map("n", [[<leader>db]], [[<CMD>lua require("dap").toggle_breakpoint()<CR>]], {"silent"}, "Dap toggle breakpoint")
    map("n", [[<leader>dc]], [[<CMD>lua require("dap").set_breakpoint(vim.fn.input("Breakpoint Condition: "), nil, nil, true)<CR>]], {"silent"}, "Dap set conditional break point")
    map("n", [[<leader>dl]], [[<CMD>lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>]], {"silent"}, "Dap set log point")
    map("n", [[<C-q>d]],     [[<CMD>lua require("dap").list_breakpoints();require("buf").quickfixToggle()<CR>]], {"silent"}, "Dap list breakpoints in quickfix window")

    map("n", [[<F5>]],   [[<CMD>lua require("dap").continue()<CR>]], "Dap continue")
    map("n", [[<S-F5>]], [[<CMD>lua require("dap").run_last()<CR>]], "Dap run last")

    map("n", [[dK]],     [[<CMD>lua require("dap.ui.widgets").hover()<CR>]],  {"silent"}, "Dap hover")

    -- map("n", [[<F12>]], [[:lua require("dap-python").test_method()<CR>]],          {"silent"})
    -- map("x", [[<F5>]],  [[<esc>:lua require("dap-python").debug_selection()<CR>]], {"silent"})
    -- }}} General mappings

    fn.sign_define("DapBreakpoint", {
        text   = icon.debug.breakpoint,
        texthl = "DiagnosticError",
        linehl = "",
        numhl  = "DiagnosticError",
    })
    fn.sign_define("DapStopped",    {
        text   = icon.ui.BoldArrowRight,
        texthl = "DiagnosticWarn",
        linehl = "DapStoppedLine",
        numhl  = "DiagnosticWarn",
    })
    fn.sign_define("DapLogPoint",   {
        text   = icon.debug.logpoint,
        texthl = "MoreMsg",
        linehl = "DapLogPointLine",
        numhl  = "MoreMsg",
    })

    dap.configurations.lua = {
        {
            type = "nlua",
            request = "attach",
            name = "Attach to running Neovim instance",
            -- port = function()
                -- local val = tonumber(fn.input("Port: "))
                -- assert(val, "Please provide a port number")
                -- return val
            -- end
        }
    }

    dap.adapters.nlua = function(callback, config)
        -- callback{type = "server", host = config.host, port = config.port}
        ---@diagnostic disable-next-line: undefined-field
        callback {type = "server", host = config.host or "127.0.0.1" , port = config.port or 8086, }
    end
end
