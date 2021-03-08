-- Author: iaso2h
-- File: init.lua
-- Description: lua initialization
-- Version: 0.0.2
-- Last Modified: 2021/02/21

local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local map = require("util").map
local M   = {}


-- Build-in plugin {{{
-- c.vim
vim.g.c_gnu = 1
vim.g.c_ansi_typedefs = 1
vim.g.c_ansi_constants = 1
vim.g.c_no_comment_fold = 1
vim.g.c_syntax_for_h = 1
-- doxygen.vim
vim.g.load_doxygen_syntax= 1
vim.g.doxygen_enhanced_color = 1
-- msql.vim
vim.g.msql_sql_query = 1
-- }}} Build-in plugin

-- OS varied settings {{{
if fn.has('win32') == 1 then
    -- o.shell="powershell"
    -- o.shellquote="shellpipe= shellxquote="
    -- o.shellcmdflag="-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
    -- o.shellredir=" Out-File -Encoding UTF8"
    -- Python executable
    local winPython = fn.expand("$HOME/AppData/Local/Programs/Python/Python38/python.exe")
    api.nvim_set_var("python3_host_prog", winPython)
    if fn.executable(winPython) == 0 then
        local pythonPath = (string.gsub(fn.system('python -c "import sys; print(sys.executable)"'),"(\n+$)", ""))
        api.nvim_set_var("python3_host_prog", pythonPath)
        if not fn.executable(api.nvim_get_var("python3_host_prog")) then
            api.nvim_err_write("Python path not found\n")
        end
    end
elseif fn.has('unix') == 1 then
    local pythonPath = (string.gsub(fn.system('which python3'), "\n+$"))
    api.nvim_set_var(pythonPath)
    if not fn.executable(api.nvim_get_var("python3_host_prog")) then
        api.nvim_err_write("Python path not found\n")
    end
end
-- }}} OS varied settings

-- Neovide settings {{{
if vim.g.neovide then
    vim.g.neovide_no_idle                 = true
    vim.g.neovide_cursor_animation_length = 0.04
    vim.g.neovide_cursor_trail_length     = 0.6
    -- vim.g.neovide_cursor_antialiasing     = true
    vim.g.neovide_window_floating_blur    = false
    vim.g.neovide_refresh_rate            = 60
    -- vim.g.neovide_cursor_vfx_mode = "pixiedust"
end
-- }}} Neovide settings

-- Key mapping {{{
vim.g.mapleader = " " -- First thing first
-- Don't truncate the name
map("n", [[<C-g>]], [[:file!<cr>]], {"silent"})
-- Tab switcher {{{
map("n", [[<S-tab>]], [[:lua require("tabSwitcher").main()<cr>]], {"silent", "novscode"})
-- }}} Tab switcher
-- Compile & run
map("n", [[<F9>]],   [[:lua require("compileRun").compileCode()<cr>]], {"noremap", "silent", "novscode"})
map("n", [[<S-F9>]], [[:lua require("compileRun").runCode()<cr>]],     {"noremap", "silent", "novscode"})
-- Search & Jumping {{{
-- Changelist jumping
map("n", [[<A-o>]], [[&diff? "mz`z[czz" : "mz`zg;zz"]], {"noremap", "silent", "expr"})
map("n", [[<A-i>]], [[&diff? "mz`z]czz" : "mz`zg,zz"]], {"noremap", "silent", "expr"})
map("n", [[<C-o>]], [[<C-o>zz]], {"novscode"})
map("n", [[<C-i>]], [[<C-i>zz]], {"novscode"})
map("n", [[j]], [[:lua require("util").addJumpMotion("j", true)<cr>]],     {"silent"})
map("n", [[k]], [[:lua require("util").addJumpMotion("k", true)<cr>]],     {"silent"})
map("v", [[*]], [[mz`z:<c-u>execute "/" . VisualSelection("string")<cr>]], {"noremap", "silent"})
map("v", [[#]], [[mz`z:<c-u>execute "?" . VisualSelection("string")<cr>]], {"noremap", "silent"})
map("v", [[/]], [[*]])
map("v", [[?]], [[#]])
-- Regex very magic
map("n", [[/]], [[/\v]], {"noremap"})
map("n", [[?]], [[?\v]], {"noremap"})
-- Disable highlight search & Exit visual mode

-- ExitVisual() {{{
api.nvim_exec([[
function! ExitVisual()
    normal! gv
    execute "normal! \<esc>"
endfunction
]], false)
-- }}} ExitVisual()
map("n", [[<leader>h]], [[:<c-u>noh<cr>]],     {"silent"})
map("v", [[<leader>h]], [[:<c-u>call ExitVisual()<cr>]], {"silent"})
-- Visual selection
function M.oppoSelection() -- {{{
    local curPos         = api.nvim_win_get_cursor(0)
    local startSelectPos = api.nvim_buf_get_mark(0, "<")
    local endSelectPos   = api.nvim_buf_get_mark(0, ">")
    local closerToStart  = require("util").posDist(startSelectPos, curPos) < require("util").posDist(endSelectPos, curPos) and true or false
    if closerToStart then api.nvim_win_set_cursor(0, endSelectPos) else api.nvim_win_set_cursor(0, startSelectPos) end
end -- }}}
map("n", [[go]],    [[:lua require("init").oppoSelection()<cr>]], { "silent"})
map("n", [[<A-v>]], [[<C-q>]],                                    {"noremap"})
-- }}} Search & Jumping
-- Scratch file
map("n", [[<C-n>]], [[:<c-u>new<cr>]], {"silent"})
-- Open/Search in browser
-- TODO:
map("v", [[<C-l>]], [[:lua require("openBrowser").openInBrowser(require("util").visualSelection("string"))<cr>]], {"silent"})
-- Interrupt
map("n", [[<C-A-c>]], [[:<c-u>call interrupt()<cr>]], {"noremap"})
-- Paragraph & Block navigation
map("", [[{]], [[:lua require("inclusiveParagraph").main("up")<cr>]],   {"noremap", "silent"})
map("", [[}]], [[:lua require("inclusiveParagraph").main("down")<cr>]], {"noremap", "silent"})
-- Line end/start
-- https://github.com/ryanoasis/nerd-fonts)
map("", [[H]], [[^]])
map("", [[L]], [[$]])
-- Non-blank last character
map("", [[g$]], [[g_]], {"noremap"})
-- Trailing character {{{
map("n", [[g,]],      [[:lua require("trailingUtil").trailingChar(",")<cr>]],  {"silent"})
map("n", [[g;]],      [[:lua require("trailingUtil").trailingChar(";")<cr>]],  {"silent"})
map("n", [[g:]],      [[:lua require("trailingUtil").trailingChar(":")<cr>]],  {"silent"})
map("n", [[g"]],      [[:lua require("trailingUtil").trailingChar("\"")<cr>]], {"silent"})
map("n", [[g']],      [[:lua require("trailingUtil").trailingChar("'")<cr>]],  {"silent"})
map("n", [[g)]],      [[:lua require("trailingUtil").trailingChar(")")<cr>]],  {"silent"})
map("n", [[g(]],      [[:lua require("trailingUtil").trailingChar("(")<cr>]],  {"silent"})
map("n", [[g<C-cr>]], [[:lua require("trailingUtil").trailingChar("o")<cr>]],  {"silent"})
map("n", [[g<S-cr>]], [[:lua require("trailingUtil").trailingChar("O")<cr>]],  {"silent"})
-- }}} Trailing character
-- Messages
map("n", [[g<]],    [[:<c-u>messages<cr>]], {"silent"})
map("n", [[g>]],    [[:<c-u>Messages<cr>]], {"silent", "novscode"})
-- TODO
-- map("n", [[g>]],    [[:<c-u>messages<cr>]], {"silent", "vscodeonly"})
map("n", [[<A-,>]], [[:<c-u>execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>]])
map("n", [[<A-.>]], [[:<c-u>execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>]])
-- Pageup/Pagedown
map("",  [[<A-e>]], [[<pageup>]], {"novscode"})
map("t", [[<A-e>]], [[<C-\><C-n><pageup>]], {"novscode"})
map("",  [[<A-d>]], [[<pagedown>]], {"novscode"})
map("t", [[<A-d>]], [[<C-\><C-n><pagedown>]], {"novscode"})
-- Macro
-- <C-q> has been mapped to COC showDoc
map("n", [[<A-q>]], [[q]], {"noremap"})
-- Register
-- ClearReg() {{{
api.nvim_exec([[
function! ClearReg()
    for i in range(34,122) | silent! call setreg(nr2char(i), "") | endfor
    echohl Moremsg | echo "Register clear" | echohl None
endfunction
]], false)
-- }}} ClearReg()
map("",  [[<C-'>]], [[:<c-u>reg<cr>]],             {"silent"})
map("i", [[<C-'>]], [[<C-\><C-o>:reg<cr>]],        {"silent"})
map("",  [[<A-'>]], [[:<c-u>call ClearReg()<cr>]], {"silent"})
-- Buffer & Window & Tab{{{
-- Smart quit
map("n", [[q]], [[:lua require"smartClose".main("window")<cr>]], {"silent"})
map("n", [[Q]], [[:lua require"smartClose".main("buffer")<cr>]], {"silent"})
-- Window
function M.winFocus(command) cmd(command); if vim.bo.buftype == "terminal" then cmd "startinsert" end end
map("", [[<C-w>h]], [[:lua require("init").winFocus("wincmd h")<cr>]],           {"silent", "novscode"})
map("", [[<C-w>l]], [[:lua require("init").winFocus("wincmd l")<cr>]],           {"silent", "novscode"})
map("", [[<C-w>j]], [[:lua require("init").winFocus("wincmd j")<cr>]],           {"silent", "novscode"})
map("", [[<C-w>k]], [[:lua require("init").winFocus("wincmd k")<cr>]],           {"silent", "novscode"})
map("", [[<C-w>v]], [[:lua require("consistantTab").splitCopy("wincmd v")<cr>]], {"silent", "novscode"})
map("", [[<C-w>s]], [[:lua require("consistantTab").splitCopy("wincmd s")<cr>]], {"silent", "novscode"})
map("", [[<C-w>V]], [[:only<cr><C-w>v]], {"silent", "novscode"})
map("", [[<C-w>S]], [[:only<cr><C-w>s]], {"silent", "novscode"})
-- Buffers
function M.bufSwitcher(command)
    cmd(command)
    while vim.bo.buftype == "terminal" or vim.bo.buftype == "quickfix" do cmd(command) end
end
map("", [[<A-h>]],  [[:lua require("init").bufSwitcher("bp")<cr>]],  {"silent", "novscode"})
map("", [[<A-l>]],  [[:lua require("init").bufSwitcher("bn")<cr>]],  {"silent", "novscode"})
map("", [[<C-w>O]], [[:lua require("closeOtherBuffer").main()<cr>]], {"silent", "novscode"})
-- Tab
map("", [[<A-S-h>]], [[:tabp<cr>]], {"silent", "novscode"})
map("", [[<A-S-l>]], [[:tabn<cr>]], {"silent", "novscode"})
-- }}} Buffer & Window & Tab
-- Folding {{{
map("",  [[[Z]],              [[zk]])
map("",  [[]Z]],              [[zj]])
map("",  [[[z]],              [[:<c-u>call EnhanceFoldJump("previous", 1, 0)<cr>]], {"noremap", "silent", "novscode"})
map("",  [[]z]],              [[:<c-u>call EnhanceFoldJump("next",     1, 0)<cr>]], {"noremap", "silent", "novscode"})
map("",  [[g[z]],             [[[z]], {"noremap", "silent", "novscode"})
map("",  [[g]z]],             [[]z]], {"noremap", "silent", "novscode"})
map("",  [[<leader>z]],       [[:<c-u>call EnhanceFoldHL("No fold marker found", 500, "")<cr>]], {"silent", "novscode"})
map("n", [[dz]],              [[:<c-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<cr>]],        {"silent"})
map("n", [[zd]],              [[:<c-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<cr>]],        {"silent"})
map("n", [[cz]],              [[:<c-u>call EnhanceFoldHL("", 0, "EnhanceChange")<cr>]],          {"silent"})
map("n", [[g{]],              [[:<c-u>call EnhanceFold(mode(), "{{{")<cr>]])
map("n", [[g}]],              [[:<c-u>call EnhanceFold(mode(), "}}}")<cr>]])
map("v", [[g{]],              [[<A-m>z:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z]])
map("v", [[g}]],              [[<A-m>z:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z]])
map("",  [[<leader><Space>]], [[@=(foldlevel('.') ? 'za' : '\<Space>')<cr>]], {"noremap", "silent"})
map("",  [[<S-Space>]],       [[@=(foldlevel('.') ? 'zA' : '\<Space>')<cr>]], {"noremap", "silent"})
for i=0, 9 do map("", string.format("z%d", i), string.format([[:set foldlevel=%d<bar>echohl Moremsg<bar>echo 'Foldlevel set to: %d'<bar>echohl None<cr>]], i, i), {}) end
-- }}} Folding
-- MS behavior {{{
-- <C-z/v/s> {{{
map("n", [[<C-z>]], [[u]], {"novscode"})
map("v", [[<C-z>]], [[<esc>u]], {"novscode"})
map("i", [[<C-z>]], [[<C-\><C-o>u]], {"novscode"})

map("n", [[<C-c>]], [[Y]], {"novscode"})
map("v", [[<C-c>]], [[y]], {"novscode"})
-- map("i", [[<C-c>]], [[<C-\><C-o>Y]])

map("n", [[<C-v>]], [[p]],                {"noremap", "novscode"})
map("v", [[<C-v>]], [[<esc>i<C-v><esc>]], {"novscode"})
map("i", [[<C-v>]], [[<C-r>*]], {"novscode"})

map("n", [[<C-s>]], [[:<c-u>w<cr>]], {"novscode"})
map("v", [[<C-s>]], [[:<c-u>w<cr>]], {"novscode"})
map("i", [[<C-s>]], [[<C-\><C-o>:w<cr>]], {"novscode"})
-- }}} <C-z/x/v/s>
-- Saveas
cmd [[command! -nargs=0 Saveas echohl Moremsg | echo "CWD: ".getcwd() | execute input("", "saveas ") | echohl None<cr> | e!]]
map("",  [[<C-S-s>]], [[:<c-u>Saveas<cr>]],      {"silent", "novscode"})
map("i", [[<C-S-s>]], [[<C-\><C-o>:Saveas<cr>]], {"silent", "novscode"})
-- Delete
map("n", [[<C-S-d>]], [[:<c-u>d<cr>]],      {"silent", "novscode"})
map("v", [[<C-S-d>]], [[:d<cr>]],           {"silent", "novscode"})
map("i", [[<C-S-d>]], [[<C-\><C-o>:d<cr>]], {"silent", "novscode"})
-- Highlight New Paste Content
map("n", [[gy]], [[:lua require("yankPut").lastYankPut("yank")<cr>]], {"silent"})
map("n", [[gY]], [[gy]])
map("n", [[gp]], [[:lua require("yankPut").lastYankPut("put")<cr>]],  {"silent"})
map("n", [[gP]], [[gp]])
-- Put content from registers 0
map("n", [[<leader>p]], [["0p]])
map("n", [[<leader>P]], [["0P]])
-- Inplace yank
map("n", [[Y]], [[yy]])
map("",  [[y]], [[luaeval("require('operator').main(require('yankPut').inplaceYank)")]], {"silent", "expr"})
-- Inplace put
map("n", [[p]], [[:lua require("yankPut").inplacePut("n", "p")<cr>]], {"silent"})
map("v", [[p]], [[:lua require("yankPut").inplacePut("v", "p")<cr>]], {"silent"})
map("n", [[P]], [[:lua require("yankPut").inplacePut("n", "P")<cr>]], {"silent"})
map("v", [[P]], [[:lua require("yankPut").inplacePut("v", "P")<cr>]], {"silent"})
-- Convert paste
map("n", [[cP]], [[:lua require("yankPut").convertPut("P")<CR>]])
map("n", [[cp]], [[:lua require("yankPut").convertPut("p")<CR>]])
-- Mimic the VSCode move/copy line up/down behavior {{{
-- Move line
cmd [[command! -nargs=0 VSCodeLineMoveDownInsert m .+1  execute "normal! =="]]
cmd [[command! -nargs=0 VSCodeLineMoveUpInsert   m .-2  execute "normal! =="]]
map("i", [[<A-j>]], [[<C-\><C-o>:VSCodeLineMoveDownInsert<cr>]], {"novscode"})
map("i", [[<A-k>]], [[<C-\><C-o>:VSCodeLineMoveUpInsert<cr>]], {"novscode"})
map("i", [[<A-j>]], [[<C-\><C-o>:call VSCodeCall("editor.action.moveLinesDownAction")<cr>]],                       {"silent", "vscodeonly"})
map("i", [[<A-k>]], [[<C-\><C-o>:call VSCodeCall("editor.action.moveLinesUpAction")<cr>]],                       {"silent", "vscodeonly"})
map("n", [[<A-j>]], [[:<c-u>m .+1<cr>==]],                       {"silent", "novscode"})
map("n", [[<A-k>]], [[:<c-u>m .-2<cr>==]],                       {"silent", "novscode"})
map("n", [[<A-j>]], [[:call VSCodeCall("editor.action.moveLinesDownAction")<cr>]],                       {"silent", "vscodeonly"})
map("n", [[<A-k>]], [[:call VSCodeCall("editor.action.moveLinesUpAction")<cr>]],                       {"silent", "vscodeonly"})
map("v", [[<A-j>]], [[:m '>+1<cr>gv=gv]],                        {"silent", "novscode"})
map("v", [[<A-k>]], [[:m '<-2<cr>gv=gv]],                        {"silent", "novscode"})
-- Copy line
map("i", [[<A-S-j>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n",       "down")<cr>]], {"silent", "vscode"})
map("i", [[<A-S-k>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n",       "up")<cr>]],   {"silent", "vscode"})
map("i", [[<A-S-j>]], [[<C-\><C-o>:call VSCodeCall("editor.action.copyLinesUpAction")]], {"silent", "vscodeonly"})
map("i", [[<A-S-k>]], [[<C-\><C-o>:call VSCodeCall("editor.action.copyLinesUpAction")]], {"silent", "vscodeonly"})
map("n", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank("n",                 "down")<cr>]], {"silent", "vscode"})
map("n", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank("n",                 "up")<cr>]],   {"silent", "vscode"})
map("n", [[<A-S-j>]], [[:call VSCodeCall("editor.action.copyLinesUpAction")]], {"silent", "vscodeonly"})
map("n", [[<A-S-k>]], [[:call VSCodeCall("editor.action.copyLinesUpAction")]], {"silent", "vscodeonly"})
map("v", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "down")<cr>]], {"silent", "vscode"})
map("v", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "up")<cr>]],   {"silent", "vscode"})
-- }}} Mimic the VSCode move/copy line up/down behavior
-- }}} MS bebhave
-- Convert \ into /
map("n", [[g/]], [[mz:s#\\#\/#e<cr>:noh<cr>g`z]],   {"noremap", "silent"})
map("n", [[g\]], [[mz:s#\\#\\\\#e<cr>:noh<cr>g`z]], {"noremap", "silent"})
-- Mode: Terminal {{{
map("t", [[<A-n>]],      [[<C-\><C-n>]])
map("n", [[<C-`>]],      [[:<c-u>call TerminalToggle()<cr>]],       {"silent", "novscode"})
map("t", [[<C-`>]],      [[<A-n>:call TerminalToggle()<cr>]],       {"silent", "novscode"})
map("n", [[<A-`>]],      [[<A-n>:call TerminalClose()<cr>]],        {"silent", "novscode"})
map("t", [[<A-`>]],      [[<A-n>:call TerminalClose()<cr>]],        {"silent", "novscode"})
map("t", [[<A-h>]],      [[<A-n><A-h>]], {"novscode"})
map("t", [[<A-l>]],      [[<A-n><A-l>]], {"novscode"})
map("t", [[<A-S-h>]],    [[<A-n><A-S-h>]], {"novscode"})
map("t", [[<A-S-l>]],    [[<A-n><A-S-l>]], {"novscode"})
map("t", [[<C-BS>]],     [[<C-w>]],                                 {"noremap", "novscode"})
map("t", [[<C-r>]],      [['\<A-n>"' . nr2char(getchar()) . 'pi']], {"expr", "novscode"})
map("t", [[<C-w>k]],     [[<A-n><C-w>k]], {"novscode"})
map("t", [[<C-w>j]],     [[<A-n><C-w>j]], {"novscode"})
map("t", [[<C-w>h]],     [[<A-n><C-w>h]], {"novscode"})
map("t", [[<C-w>l]],     [[<A-n><C-w>l]], {"novscode"})
map("t", [[<C-w>w]],     [[<A-n><C-w>w]], {"novscode"})
map("t", [[<C-w><C-w>]], [[<A-n><C-w><C-w>]], {"novscode"})
map("t", [[<C-w>W]],     [[<A-n><C-w>W]], {"novscode"})
map("t", [[<C-w>H]],     [[<A-n><C-w>H]], {"novscode"})
map("t", [[<C-w>L]],     [[<A-n><C-w>L]], {"novscode"})
map("t", [[<C-w>J]],     [[<A-n><C-w>J]], {"novscode"})
map("t", [[<C-w>K]],     [[<A-n><C-w>K]], {"novscode"})
-- }}} Mode: Terminal
-- Mode: Commandline & Insert {{{
map("i", [[<C-cr>]],  [[<esc>o]], {"novscode"})
map("i", [[<S-cr>]],  [[<esc>O]], {"novscode"})
map("i", [[jj]],      [[<esc>`^]], {"novscode"})
map("i", [[<C-d>]],   [[<Del>]], {"novscode"})
map("i", [[<S-Tab>]], [[<C-d>]], {"noremap"})
map("i", [[<C-.>]],   [[<C-a>]], {"noremap"})
map("i", [[<C-S-.>]], [[<C-@>]], {"noremap"})
map("i", [[<C-BS>]],  [[<C-w>]], {"noremap"})
-- Navigation {{{
map("!", [[<C-a>]], [[<Home>]])
map("!", [[<C-e>]], [[<End>]])
map("!", [[<C-h>]], [[<Left>]])
map("!", [[<C-l>]], [[<Right>]])
map("!", [[<C-j>]], [[<Down>]])
map("!", [[<C-k>]], [[<Up>]])
map("!", [[<C-b>]], [[<C-Left>]])
map("!", [[<C-w>]], [[<C-Right>]])
map("!", [[<C-h>]], [[<Left>]])
-- }}} Navigation
-- RemoveLastPathComponent() {{{
api.nvim_exec([[
function! RemoveLastPathComponent()
    let l:cmdlineBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:cmdlineAfterCursor = strpart(getcmdline(), getcmdpos() - 1)
    let l:cmdlineRoot = fnamemodify(cmdlineBeforeCursor, ':r')
    let l:result = (l:cmdlineBeforeCursor ==# l:cmdlineRoot ? substitute(l:cmdlineBeforeCursor, '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '') : l:cmdlineRoot)
    call setcmdpos(strlen(l:result) + 1)
    return l:result . l:cmdlineAfterCursor
endfunction
]], false)
-- }}} RemoveLastPathComponent()
map("c", [[<C-BS>]],  [[<C-\>e(RemoveLastPathComponent())<cr>]])
map("c", [[<C-S-l>]], [[<C-d>]], {"noremap"})
map("c", [[<C-d>]],   [[<Del>]])
map("c", [[<C-S-e>]], [[<C-\>e]])
map("c", [[<C-v>]],   [[<C-R>*]])
-- }}} Mode: Commandline & Insert
-- }}} Key mapping

-- Plug-ins settings  {{{
-- Build-in plugin {{{
-- Netrow
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1
-- }}} Build-in plugin
if vim.g.vscode == 1 then
  -- VSCode do not need the next settings
  return
end
-- inkarkat/vim-ReplaceWithRegister {{{
map("n", [[grr]], [[<Plug>ReplaceWithRegisterLine==]], {"nowait"})
map("v", [[R]],   [[<Plug>ReplaceWithRegisterVisual`<v`>=]])
-- }}} inkarkat/vim-ReplaceWithRegister
-- RishabhRD/nvim-cheat.sh {{{
map("n", [[<C-S-l>]], [[:<c-u>Cheat<cr>]], {"silent"})
-- }}} RishabhRD/nvim-cheat.sh
-- mg979/docgen.vim {{{
map("n", [[,d]], [[:<c-u>DocGen<cr>]], {"silent"})
-- }}} mg979/docgen.vim
-- AndrewRadev/splitjoin.vim {{{
vim.g.splitjoin_align = 1
vim.g.splitjoin_curly_brace_padding = 0
map("n", [["gS"]], [[:<c-u>SplitjoinSplit<cr>]], {"silent"})
map("n", [["gJ"]], [[:<c-u>SplitjoinJoin<cr>]],  {"silent"})
-- }}} AndrewRadev/splitjoin.vim
-- lag13/vim-create-variable {{{
map("v", [[C]], [[<Plug>Createvariable]])
-- }}} lag13/vim-create-variable
-- SirVer/ultisnips {{{
-- Disable UltiSnips keymapping in favour of coc-snippets
vim.g.UltiSnipsExpandTrigger = ""
vim.g.UltiSnipsListSnippets = ""
vim.g.UltiSnipsJumpForwardTrigger = ""
vim.g.UltiSnipsJumpBackwardTrigger = ""
-- }}} SirVer/ultisnips
-- preservim/nerdcommenter {{{
vim.g.NERDAltDelims_c = 1
vim.g.NERDAltDelims_cpp = 1
vim.g.NERDAltDelims_javascript = 1
vim.g.NERDAltDelims_lua = 0
function M.commentJump(keystroke) -- {{{
    if api.nvim_get_current_line() ~= '' then
        local saveReg = fn.getreg('"')
        if keystroke == "o" then
            cmd("normal! YpS" .. vim.g.FiletypeCommentDelimiter[vim.bo.filetype] .. " ")
        elseif keystroke == "O" then
            cmd("normal! YPS" .. vim.g.FiletypeCommentDelimiter[vim.bo.filetype] .. " ")
        end
        fn.setreg('"', saveReg)
        cmd [[startinsert!]]
    end
end -- }}}
map("n", [[gco]], [[:lua require("init").commentJump("o")<cr>]], {"silent"})
map("n", [[gcO]], [[:lua require("init").commentJump("O")<cr>]], {"silent"})

map("n", [[gc<space>]], [[<plug>NERDCommenterToggle]])
map("v", [[gc<space>]], [[<plug>NERDCommenterToggle]])
-- map("n", [[gcn]], [[<plug>NERDCommenterNested]])
-- map("v", [[gcn]], [[<plug>NERDCommenterNested]])
map("n", [[gci]], [[<plug>NERDCommenterInvert]])
map("v", [[gci]], [[<plug>NERDCommenterInvert]])

map("n", [[gcs]], [[<plug>NERDCommenterSexy]])
map("v", [[gcs]], [[<plug>NERDCommenterSexy]])

map("n", [[gcy]], [[<plug>NERDCommenterYank]])
map("v", [[gcy]], [[<plug>NERDCommenterYank]])

map("n", [[gc$]], [[<plug>NERDCommenterToEOL]])
map("n", [[gcA]], [[<plug>NERDCommenterAppend]])
map("n", [[gcI]], [[<plug>NERDCommenterInsert]])

map("v", [[<A-/>]], [[<plug>NERDCommenterAltDelims]])
map("n", [[<A-/>]], [[<plug>NERDCommenterAltDelims]])

map("n", [[gcn]], [[<plug>NERDCommenterAlignLeft]])
map("v", [[gcn]], [[<plug>NERDCommenterAlignLeft]])
map("n", [[gcb]], [[<plug>NERDCommenterAlignBoth]])
map("v", [[gcb]], [[<plug>NERDCommenterAlignBoth]])

map("n", [[gcu]], [[<plug>NERDCommenterUncomment]])
map("v", [[gcu]], [[<plug>NERDCommenterUncomment]])

vim.g.NERDSpaceDelims              = 1
vim.g.NERDRemoveExtraSpaces        = 1
vim.g.NERDCommentWholeLinesInVMode = 1
vim.g.NERDLPlace                   = "{{{"
vim.g.NERDRPlace                   = "}}}"
vim.g.NERDCompactSexyComs          = 1
vim.g.NERDToggleCheckAllLines      = 1
-- }}} preservim/nerdcommenter
-- junegunn/vim-easy-align {{{
vim.g.easy_align_delimiters = vim.g.easy_align_delimiters or {}
-- Lua comment
vim.g.easy_align_delimiters = { ["l"] = {
    pattern       = '--',
    left_margin   = 2,
    right_margin  = 1,
    stick_to_left = 0 ,
    ignore_groups = {'String'}
    }
}
map("v", [[A]],  [[<Plug>(EasyAlign)]])
map("n", [[ga]], [[<Plug>(EasyAlign)]])
-- }}} junegunn/vim-easy-align
-- szw/vim-maximizer {{{
map("", [[<C-w>m]], [[:MaximizerToggle<cr>]], {"silent"})
-- }}} szw/vim-maximizer
-- zatchheems/vim-camelsnek {{{
vim.g.camelsnek_alternative_camel_commands = 1
vim.g.camelsnek_no_fun_allowed             = 1
vim.g.camelsnek_iskeyword_overre           = 0
map("v", [[<A-c>]],   [[:call CaseSwitcher()<cr>]],                         {"silent"})
map("n", [[<A-c>]],   [[:<c-u>call CaseSwitcher()<cr>]],                    {"silent"})
map("n", [[<A-S-c>]], [[:<c-u>call CaseSwitcherDefaultCMDListOrder()<cr>]], {"silent"})
-- }}} zatchheems/vim-vimsnek
-- bkad/camelcasemotion {{{
vim.g.camelcasemotion_key = ','
-- }}} bkad/camelcasemotion
-- andymass/vim-matchup {{{
-- vim.g.matchup_matchparen_deferred = 1
-- vim.g.matchup_matchparen_hi_surround_always = 1
-- vim.g.matchup_matchparen_hi_background = 1
vim.g.matchup_matchparen_offscreen = {method = 'popup', highlight = 'OffscreenPopup'}
vim.g.matchup_matchparen_nomode = "i"
vim.g.matchup_delim_noskips = 0
-- Text obeject
map("x", [[am]],      [[<Plug>(matchup-a%)]])
map("x", [[im]],      [[<Plug>(matchup-i%)]])
map("o", [[am]],      [[<Plug>(matchup-a%)]])
map("o", [[im]],      [[<Plug>(matchup-i%)]])
-- Inclusive
map("",  [[<C-m>]],   [[<Plug>(matchup-%)]])
map("",  [[<C-S-m>]], [[<Plug>(matchup-g%)]])
-- Exclusive
map("",  [[m]],       [[<Plug>(matchup-]%)]])
map("",  [[M]],       [[<Plug>(matchup-[%)]])
-- Highlight
map("n", [[<leader>m]], [[<plug>(matchup-hi-surround)]])
-- Origin mark
map("",  [[<A-m>]], [[m]], {"noremap"})
-- }}} andymass/vim-matchup
-- landock/vim-expand-region {{{
vim.g.expand_region_text_objects = {
            ['iw'] = 0,
            ['iW'] = 0,
            ['i"'] = 0,
            ["i'"] = 0,
            ['i]'] = 1,
            ['ib'] = 1,
            ['iB'] = 1,
            ['il'] = 0,
            ['ii'] = 0,
            ['ip'] = 1,
            ['ie'] = 0,
            }
cmd([[call expand_region#custom_text_objects({ "\/\\n\\n\<CR>": 0, 'i,w':1, 'i%':0, 'a]' :0, 'ab' :0, 'aB' :0, 'ai' :0, })]])
map("", [[<A-a>]], [[<Plug>(expand_region_expand)]])
map("", [[<A-s>]], [[<Plug>(expand_region_shrink)]])
-- }}} landock/vim-expand-region
-- liuchengxu/vista.vim {{{
vim.g.vista_default_executive = 'ctags'
vim.g.vista_icon_indent = {"╰─▸ ", "├─▸ "}
cmd [=[let g:vista#finders = ['fzf']]=]
-- Base on Sarasa Nerd Mono SC
cmd [[let g:vista#renderer#icons = {"variable": "\uF194"}]]
map("n", [[<leader>s]], [[:Vista!!<cr>]], {"silent"})
-- }}} liuchengxu/vista.vim
-- simnalamburt/vim-mundo {{{
vim.g.mundo_help               = 1
vim.g.mundo_tree_statusline    = 'Mundo'
vim.g.mundo_preview_statusline = 'Mundo Preview'
map("n", [[<c-u>]], [[:<c-u>MundoToggle<cr>]], {"silent"})
-- }}} simnalamburt/vim-mundo
-- tommcdo/vim-exchange {{{
map("n", [[gx]],  [[<Plug>(Exchange)]])
map("x", [[X]],   [[<Plug>(Exchange)]])
map("n", [[gxc]], [[<Plug>(ExchangeClear)]])
map("n", [[gxx]], [[<Plug>(ExchangeLine)]])
-- }}} tommcdo/vim-exchange
-- phaazon/hop.nvim {{{
map("", [[<leader>f]], [[:lua require("hop").hint_char1()<cr>]], {"silent"})
map("", [[<leader>F]], [[:lua require("hop").hint_lines()<cr>]], {"silent"})
-- }}} phaazon/hop.nvim
-- michaeljsmith/vim-indent-object {{{
vim.g.indentLine_char                   = '▏'
vim.g.indent_blankline_buftype_exclude  = {'terminal'}
vim.g.indent_blankline_filetype_exclude = {'help'}
vim.g.indent_blankline_bufname_exclude  = {'*.md'}
vim.g.indent_blankline_use_treesitter   = true
vim.g.indent_blankline_char_highlight   = 'SignColumn'
-- }}} michaeljsmith/vim-indent-object
-- Startify {{{
vim.g.startify_session_dir  = '~/.nvimcache/session'
vim.g.startify_padding_left = 20
vim.g.startify_lists = {
{type = 'files',     header = {string.rep(" ", vim.g.startify_padding_left) .. 'MRU'}            },
{type = 'dir',       header = {string.rep(" ", vim.g.startify_padding_left) .. 'MRU ' .. fn.getcwd()}},
{type = 'sessions',  header = {string.rep(" ", vim.g.startify_padding_left) .. 'Sessions'}       },
{type = 'bookmarks', header = {string.rep(" ", vim.g.startify_padding_left) .. 'Bookmarks'}      },
}
vim.g.startify_update_oldfiles        = 1
vim.g.startify_session_autoload       = 1
if fn.has("win32") == 1 then
    vim.g.startify_bookmarks = {{v = '~/AppData/Local/nvim'}, {c = "H:/code"}}
end
vim.g.startify_session_before_save    = {'echo "Cleaning up before saving.."' }
vim.g.startify_session_persistence    = 1
vim.g.startify_session_delete_buffers = 1
vim.g.startify_change_to_vcs_root     = 1
vim.g.startify_fortune_use_unicode    = 1
vim.g.startify_relative_path          = 1
vim.g.startify_use_env                = 1
if fn.has("win32") == 1 then table.insert(vim.g.startify_bookmarks, 'H:/code') end
-- }}} Startify
-- tpope/vim-repeat {{{
cmd [[silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)]]
-- }}} tpope/vim-repeat
-- iaso2h/nlua {{{
vim.g.nlua_keywordprg_map_key = "<C-S-q>"
-- }}} iaso2h/nlua
-- }}} Plug-ins settings

return M
