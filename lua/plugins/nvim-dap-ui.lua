local M = {
    winID = { }
}

M.filetypeSetup = function ()
    local winInfo = vim.fn.getwininfo()
    for _, win in ipairs(winInfo) do
        local ft = vim.api.nvim_buf_get_option(win.bufnr, "filetype")

        if vim.tbl_contains({
        "dap-repl",
        "dapui_watches",
        "dapui_console",
        "dapui_stacks",
        "dapui_breakpoints",
        "dapui_scopes",
    }, ft) then
            M.winID[ft] = win.winid
            vim.api.nvim_win_set_option(win.winid, "cursorline", false)
            if ft == "dap-repl" or ft == "dapui_watches" then
                vim.api.nvim_create_autocmd("BufEnter",{
                    buffer  = win.bufnr,
                    command = "startinsert"
                })
            end
        end
    end

    M.filetypeSetupChk = true
end


M.config = function()
    local M     = require("plugins.nvim-dap-ui")
    local icon  = require("util.icon")
    local dapui = require("dapui")
    local dap   = require("dap")
    dapui.setup { -- {{{
        controls = {
            element = "repl",
            enabled = true,
            icons = {
                disconnect = icon.debug.Disconnect,
                pause      = icon.debug.Pause,
                play       = icon.debug.Play,
                run_last   = icon.debug.RunLast,
                step_back  = icon.debug.StepBack,
                step_into  = icon.debug.StepInto,
                step_out   = icon.debug.StepOut,
                step_over  = icon.debug.StepOver,
                terminate  = icon.debug.Terminate,
            }
        },
        element_mappings = {},
        expand_lines = true,
        floating = {
            border = "rounded",
            mappings = {
                close = { "q", "<Esc>" }
            }
        },
        force_buffers = true,
        icons = {
            collapsed     = icon.ui.ChevronShortRight,
            expanded      = icon.ui.ChevronShortDown,
            current_frame = icon.ui.BoldArrowRight,
        },
        layouts = {
            {
                elements = {
                    {
                        id = "watches",
                        size = 0.20
                    },
                    {
                        id = "scopes",
                        size = 0.60
                    },
                    {
                        id = "stacks",
                        size = 0.10
                    },
                    {
                        id = "breakpoints",
                        size = 0.10
                    }
                },
                position = "left",
                size = 40 -- Width
            }, {
                elements = {
                    {
                        id = "repl",
                        size = 0.5
                    },
                    {
                        id = "console",
                        size = 0.5
                    }
                },
                position = "bottom",
                size = 10 -- Height
            }
        },
        -- VIMCOMMAND: h dapui.elements.scopes
        mappings = {
            edit = "e",
            expand = { "<CR>", "<2-LeftMouse>" },
            open = "o",
            remove = "d",
            repl = {"r", ">"},
            toggle = "t"
        },
        render = {
            indent = 1,
            max_value_lines = 100
        }
    } -- }}}

    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        vim.cmd[[DapVirtualTextEnable]]
        M.filetypeSetup()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
        vim.cmd[[DapVirtualTextDisable]]
        dapui.close()
        M.winID = {}
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
        vim.cmd[[DapVirtualTextDisable]]
        dapui.close()
        M.winID = {}
    end


    -- key mappings {{{
    local uiToggle = function(bangChk) require("dapui").toggle{layout = nil, reset = bangChk} end

    local windowFocus = function(filetype) -- {{{
        if not next(M.winID) then return end
        vim.cmd(t[[norm! <C-\><C-n>]])
        if filetype == "dapui_scopes" or filetype ==  "dapui_scopes" or filetype ==  "dapui_scopes" or filetype ==  "dapui_scopes" then
            if require("dapui.windows").layouts[1]:is_open() then
                local winid = M.winID[filetype]
                if vim.api.nvim_win_is_valid(winid) then
                    vim.api.nvim_set_current_win(winid)
                else
                    vim.notify(string.format("The %s window is no longer valid", filetype), vim.log.levels.INFO)
                end
            end
        else
            if require("dapui.windows").layouts[2]:is_open() then
                local winid = M.winID[filetype]
                if vim.api.nvim_win_is_valid(winid) then
                    vim.api.nvim_set_current_win(winid)
                else
                    vim.notify(string.format("The %s window is no longer valid", filetype), vim.log.levels.INFO)
                end
            end
        end
    end -- }}}

    vim.api.nvim_create_user_command("DapUIUpdateRender", function()
        dapui.update_render()
    end, {desc = "Dap UI Update"} )
    vim.api.nvim_create_user_command("DapUIToggle", function()
        uiToggle()
    end, {desc = "Dap UI Toggle"} )

    map("n", [[<C-w>dd]], [[<CMD>lua require("dapui").toggle {layout=nil,reset=true}<CR>]], {"silent"}, "Dap UI toggle")
    map({"i", "n"}, [[<C-w>ds]], function() windowFocus("dapui_scopes") end,      "Go ot Dap scopes window")
    map({"i", "n"}, [[<C-w>dw]], function() windowFocus("dapui_watches") end,     "Go ot Dap watches window")
    map({"i", "n"}, [[<C-w>dS]], function() windowFocus("dapui_stacks") end,      "Go ot Dap stacks window")
    map({"i", "n"}, [[<C-w>db]], function() windowFocus("dapui_breakpoints") end, "Go ot Dap breakpoints window")
    map({"i", "n"}, [[<C-w>dr]], function() windowFocus("dap-repl") end,          "Go ot Dap repl window")
    map({"i", "n"}, [[<C-w>dc]], function() windowFocus("dapui_console") end,     "Go ot Dap console window")
    -- }}} key mappings
end


return M
