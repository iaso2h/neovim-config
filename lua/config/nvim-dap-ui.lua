local M = { }

M.filetypeSetup = function ()
    local winInfo = vim.fn.getwininfo()
    for _, win in ipairs(winInfo) do
        local ft = vim.api.nvim_buf_get_option(win.bufnr, "filetype")
        if tbl_idx(require("config.nvim-galaxyline").shortLineList, ft, false) then
            vim.api.nvim_win_set_option(win.winid, "cursorline", false)
            if ft == "dap-repl" then
                vim.api.nvim_create_autocmd("BufEnter",{
                    buffer  = win.bufnr,
                    desc    = "Start insert mode in dap-repl window",
                    command = "startinsert"
                })
            end
        end
    end

    M.filetypeSetupChk = true
end

M.config = function()
    local M     = require("config.nvim-dap-ui")
    local icon  = require("util.icon")
    local dapui = require("dapui")
    local dap   = require("dap")
    dapui.setup { -- {{{
        controls = {
            element = "repl",
            enabled = true,
            icons = {
                disconnect = icon.debug.disconnect,
                pause      = icon.debug.pause,
                play       = icon.debug.play,
                run_last   = icon.debug.runLast,
                step_back  = icon.debug.stepBack,
                step_into  = icon.debug.stepInto,
                step_out   = icon.debug.stepOut,
                step_over  = icon.debug.stepOver,
                terminate  = icon.debug.terminate,
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
                        id = "scopes",
                        size = 0.40
                    },
                    {
                        id = "watches",
                        size = 0.35
                    },
                    {
                        id = "stacks",
                        size = 0.15
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

    _G.dapUIToggle = function(bangChk) require("dapui").toggle{layout = nil, reset = bangChk} end

    vim.cmd[[
        command! -nargs=0 DapUIUpdateRender lua dapui.update_render()
        command! -nargs=0 -bang DapUIToggle call v:lua.dapUIToggle(<q-bang>)
    ]]


    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        vim.cmd[[DapVirtualTextEnable]]
        M.filetypeSetup()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
        vim.cmd[[DapVirtualTextDisable]]
        dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
        vim.cmd[[DapVirtualTextDisable]]
        dapui.close()
    end

    map("n", [[<C-w>d]], [[<CMD>lua require("dapui").toggle {layout=nil,reset=true}<CR>]], {"silent"}, "Dap UI toggle")
    M.filetypeSetup()
end


return M
