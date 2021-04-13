local vim = vim
local fn  = vim.fn
local api = vim.api
local map = require("util").map
local dap = require("dap")
local M = {}

-- General mappings {{{
map("n", [[<F5>]],       [[:lua require('dap').continue()<cr>]],          {"silent"})
map("n", [[<S-F5>]],     [[:lua require('dap').run_last()<cr>]],          {"silent"})
map("n", [[<C-S-l>]],    [[:lua require('dap').step_into()<cr>]],         {"silent"})
map("n", [[<C-S-j>]],    [[:lua require('dap').step_over()<cr>]],         {"silent"})
map("n", [[<C-S-k>]],    [[:lua require('dap').step_out()<cr>]],          {"silent"})
map("n", [[<leader>dk]], [[:lua require('dap').up()<cr>]],                {"silent"})
map("n", [[<leader>dj]], [[:lua require('dap').down()<cr>]],              {"silent"})
map("n", [[<leader>dg]], [[:lua require('dap').goto_()<cr>]],             {"silent"})
map("n", [[<leader>db]], [[:lua require('dap').toggle_breakpoint()<cr>]], {"silent"})
map("n", [[<leader>dB]], [[:lua require('dap').list_breakpoints()cr>]],   {"silent"})

map("n", [[<leader>dc]],  [[:lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>]], {"silent"})
map("n", [[<leader>dl]], [[:lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>]], {"silent"})

map("n", [[<leader>dro]],    [[:lua require('dap').repl.open()<cr>]],                   {"silent"})
map("n", [[<leader>drl]],    [[:lua require('dap').repl.run_last()<cr>`]],              {"silent"})

map("n", [[<F12>]], [[:lua require('dap-python').test_method()<cr>]],          {"silent"})
map("v", [[<F5>]],  [[<esc>:lua require('dap-python').debug_selection()<cr>]], {"silent"})
-- }}} General mappings

fn.sign_define('DapBreakpoint', {text='⏺️', texthl='Error', linehl='', numhl='Error'})
fn.sign_define('DapStopped',    {text='🕓', texthl='WarningMsg', linehl='', numhl='WarningMsg'})
fn.sign_define('DapLogPoint',   {text='📜', texthl='MoreMsg', linehl='', numhl='MoreMsg'})
vim.g.dap_virtual_text = true

dap.defaults.fallback.external_terminal = {
    command = 'alacritty';
    args = {'-e'};
}

local keymapRestore = {}

local function delHoverKeymaps(buf)
    local keymaps = api.nvim_buf_get_keymap(buf, 'n')
    for _, keymap in pairs(keymaps) do
        if keymap.lhs == "K" then
            table.insert(keymapRestore, keymap)
            api.nvim_buf_del_keymap(buf, 'n', 'K')
        end
    end
end

local function setupHoverKeymap()
    dap.listeners.after['event_initialized']['me'] = function()
        for _, buf in pairs(api.nvim_list_bufs()) do
            delHoverKeymaps(buf)
        end
        map('v', 'K', '<c-u>:lua require("dap.ui.variables").visual_hover()<cr>', {"silent"})
        map('n', 'K', ':lua require("dap.ui.variables").hover()<cr>',             {"silent"})
    end

    dap.listeners.after['event_terminated']['me'] = function()
        api.nvim_del_keymap('v', 'K')
        for _, keymap in pairs(keymapRestore) do
            if api.nvim_buf_is_valid(keymap.buffer) then
                api.nvim_buf_set_keymap(
                    keymap.buffer,
                    keymap.mode,
                    keymap.lhs,
                    keymap.rhs,
                    {silent = keymap.silent == 1}
                )
            end
        end
        keymapRestore = {}
    end

    api.nvim_exec([[
        augroup dap-keymap
            au!
            autocmd BufEnter * lua require("config.nvim-dap").setHoverKeymap()
        augroup end
        ]],false)
end

function M.setHoverKeymap()
    if dap.session() then
        local buf = api.nvim_get_current_buf()
        delHoverKeymaps(buf)
    end
end


-- Python {{{
if fn.has('win32') == 1 then
    require('dap-python').setup('D:/anaconda3/envs/test/python.exe')
end
-- }}} Python
setupHoverKeymap()
-- C/C++/Rust {{{
-- LLDB {{{
-- dap.adapters.cpp = {
    -- type   = 'executable',
    -- name   = "lldb",
    -- command = 'lldb-vscode',
    -- attach = {
        -- pidProperty = "pid",
        -- pidSelect   = "ask"
    -- },
    -- env     = {
        -- LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES"
    -- },
-- }
-- -- https://github.com/llvm/llvm-project/tree/main/lldb/tools/lldb-vscode#configurations
-- dap.configurations.cpp = {
    -- {
        -- name    = "lldb for cpp",
        -- type    = "cpp",
        -- request = "launch",
        -- program = function()
            -- return require("compileRun").compileCode(false)
        -- end,
        -- cwd = "${workspaceFolder}",
        -- env = function()
            -- local variables = {}
            -- for k, v in pairs(vim.fn.environ()) do
                -- table.insert(variables, string.format("%s=%s", k, v))
            -- end
            -- return variables
        -- end,
        -- args = {},
        -- stopOnEntry = false
    -- }
-- }
-- dap.adapters.c               = dap.adapters.cpp
-- dap.configurations.c         = vim.deepcopy(dap.configurations.cpp)
-- dap.configurations.c[1].name = "lldb for c"
-- dap.configurations.c[1].type = "c"
-- }}} LLDB
-- CPPtools {{{
local findCPPTools = function()
    CPPTools = fn.glob("~/.vscode/extensions/ms-vscode.cpptools-*", 0, 1)
    if not next(CPPTools) then
        api.nvim_echo({{"VS Code cpptools extensions not found", "WarningMsg"}}, true, {})
        return
    end
    CPPToolsBin = CPPTools[#CPPTools] .. "/bin/cpptools"
    if fn.has("win32") == 1 then CPPToolsBin = CPPToolsBin .. ".exe" end

    dap.adapters.cpp = {
        type = 'executable',
        name = "cppdbg",
        command = CPPToolsBin,
        args = {},
        attach = {
            pidProperty = "processId",
            pidSelect = "ask"
        }
    }
    dap.configurations.cpp  = {
        {
            type = "cpp",
            name = "CPP debug",
            request = "launch",
            program = function ()
                return require("compileRun").compileCode(false)
            end,
            args = {},
            cwd = fn.getcwd(),
            env = function()
                local variables = {}
                for k, v in pairs(vim.fn.environ()) do
                    table.insert(variables, string.format("%s=%s", k, v))
                end
                return variables
            end,
            externalConsole = false,
            MIMode = "gdb",
            MIDebuggerPath = "gdb"
        }
    }
end

findCPPTools()

dap.adapters.c               = dap.adapters.cpp
dap.configurations.c         = vim.deepcopy(dap.configurations.cpp)

-- }}} CPPtools
-- }}} C/C++/Rust
-- end -- }}}

return M

