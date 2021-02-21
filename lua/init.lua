-- File: init.lua
-- Author: iaso2h
-- Description: lua initialization
-- Version: 0.0.2
-- Last Modified: 2021/02/21
local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local map = require("util").map
local M   = {}

-- OS varied settings {{{
if fn.has('win32') == 1 then
    -- o.shell="powershell"
    -- o.shellquote="shellpipe= shellxquote="
    -- o.shellcmdflag="-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
    -- o.shellredir=" Out-File -Encoding UTF8"
    -- Python executable
    api.nvim_set_var("python3_host_prog", fn.expand("$HOME/AppData/Local/Programs/Python/Python38/python.exe"))
    if fn.executable(api.nvim_get_var("python3_host_prog")) == 0 then
        local pythonPath = (string.gsub(fn.system('python -c "import sys; print(sys.executable)"'),"(\n+$)", ""))
        api.nvim_set_var(pythonPath)
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

-- Key mapping {{{
vim.g.mapleader = " " -- First thing first
-- Search & Jumping {{{
-- Changelist jumping
map("n", [[<A-o>]], [[&diff? "mz`z[czz" : "mz`zg;zz"]], {"noremap", "silent", "expr"})
map("n", [[<A-i>]], [[&diff? "mz`z]czz" : "mz`zg,zz"]], {"noremap", "silent", "expr"})
map("n", [[<C-o>]], [[<C-o>zz]],                        {})
map("n", [[<C-i>]], [[<C-i>zz]],                        {})
-- Count specified j/k
map("n", [[j]], [[:<c-u>call AddJumpMotion(1, "j")<cr>]], {"silent"})
map("n", [[k]], [[:<c-u>call AddJumpMotion(1, "k")<cr>]], {"silent"})
map("v", [[*]], [[mz`z:<c-u>execute "/" . VisualSelection("string")<cr>]], {"noremap", "silent"})
map("v", [[#]], [[mz`z:<c-u>execute "?" . VisualSelection("string")<cr>]], {"noremap", "silent"})
map("v", [[/]], [[*]], {})
map("v", [[?]], [[#]], {})
-- Regex very magic
map("n", [[/]], [[/\v]], {"noremap"})
map("n", [[?]], [[?\v]], {"noremap"})
-- Disable highlight search & Exit visual mode
map("n", [[<leader>h]], [[:<c-u>noh<cr>]],                         {"silent"})
map("v", [[<leader>h]], [[:<c-u>call InplaceDisableVisual()<cr>]], {"silent"})
-- Visual selection
function M.oppoSelection() -- {{{
    local curPos         = api.nvim_win_get_cursor(0)
    local startSelectPos = api.nvim_buf_get_mark(0, "<")
    local endSelectPos   = api.nvim_buf_get_mark(0, ">")
    local closerToStart = math.abs(startSelectPos[1] - curPos[1]) <
    math.abs(endSelectPos[1] - curPos[1]) and true or
    false
    if closerToStart then api.nvim_win_set_cursor(0, endSelectPos) else api.nvim_win_set_cursor(0, startSelectPos) end
end -- }}}
map("n", [[go]],    [[:lua require("init").oppoSelection()<cr>]], { "silent"})
map("n", [[<A-v>]], [[<C-q>]],                                    {"noremap"})
-- }}} Search & Jumping
-- Scratch file
map("n", [[<C-n>]], [[:<c-u>new<cr>]], {"silent"})
-- Open/Search in browser
-- TODO:
map("n", [[<C-l>]], [[:<c-u>call OpenUrl()<cr>]],                                {"silent"})
map("x", [[<C-l>]], [[:<c-u>call OpenInBrowser(VisualSelection("string"))<cr>]], {"silent"})
-- Interrupt
map("n", [[<C-A-c>]], [[:<c-u>call interrupt()<cr>]], {"noremap"})
-- Paragraph & Block navigation
map("", [[{]], [[:call InclusiveParagraph("up")<cr>]],   {"noremap", "silent"})
map("", [[}]], [[:call InclusiveParagraph("down")<cr>]], {"noremap", "silent"})
-- Line end/start
map("", [[H]], [[^]], {})
map("", [[L]], [[$]], {})
-- Non-blank last character
map("", [[g$]], [[g_]], {"noremap"})
-- Trailing character {{{
map("n", [[g,]],      [[:<c-u>call TrailingChar(",")<cr>]],         {"silent"})
map("n", [[g;]],      [[:<c-u>call TrailingChar(";")<cr>]],         {"silent"})
map("n", [[g:]],      [[:<c-u>call TrailingChar(":")<cr>]],         {"silent"})
map("n", [[g"]],      [[:<c-u>call TrailingChar("\"")<cr>]],        {"silent"})
map("n", [[g']],      [[:<c-u>call TrailingChar("'")<cr>]],         {"silent"})
map("n", [[g)]],      [[:<c-u>call TrailingChar(")")<cr>]],         {"silent"})
map("n", [[g(]],      [[:<c-u>call TrailingChar("(")<cr>]],         {"silent"})
map("n", [[g<C-cr>]], [[:<c-u>call TrailingLinebreak("down")<cr>]], {"silent"})
map("n", [[g<S-cr>]], [[:<c-u>call TrailingLinebreak("up")<cr>]],   {"silent"})
-- }}} Trailing character
-- Messages
map("n", [[g<]],    [[:<c-u>messages<cr>]], {"silent"})
map("n", [[g>]],    [[:<c-u>Messages<cr>]], {"silent"})
map("n", [[<A-,>]], [[:<c-u>execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>]], {})
map("n", [[<A-.>]], [[:<c-u>execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>]], {})
-- Pageup/Pagedown
map("",  [[<A-e>]], [[<pageup>]],             {})
map("t", [[<A-e>]], [[<C-\><C-n><pageup>]],   {})
map("",  [[<A-d>]], [[<pagedown>]],           {})
map("t", [[<A-d>]], [[<C-\><C-n><pagedown>]], {})
-- Macro
-- TODO
map("n", [[<A-q>]], [[q]], {"noremap"})
-- Register
map("",  [[<C-'>]], [[:<c-u>reg<cr>]],             {"silent"})
map("i", [[<C-'>]], [[<C-\><C-o>:reg<cr>]],        {"silent"})
map("",  [[<A-'>]], [[:<c-u>call ClearReg()<cr>]], {"silent"})
-- Buffer & Window & Tab{{{
-- Smart quit
map("n", [[q]], [[:lua require"smartClose".smartClose("window")<cr>]], {"silent"})
map("n", [[Q]], [[:lua require"smartClose".smartClose("buffer")<cr>]], {"silent"})
-- Window
function M.winFocus(command) cmd(command); if vim.bo.buftype == "terminal" then cmd "startinsert" end end
map("", [[<C-w>h]], [[:lua require("init").winFocus("wincmd h")<cr>]], {"silent"})
map("", [[<C-w>l]], [[:lua require("init").winFocus("wincmd l")<cr>]], {"silent"})
map("", [[<C-w>j]], [[:lua require("init").winFocus("wincmd j")<cr>]], {"silent"})
map("", [[<C-w>k]], [[:lua require("init").winFocus("wincmd k")<cr>]], {"silent"})
-- Buffers
function M.bufSwitcher(command)
    cmd(command)
    while vim.bo.buftype == "terminal" or vim.bo.buftype == "quickfix" do
        cmd(command)
    end
end
map("", [[<A-h>]],  [[:lua require("init").bufSwitcher("bp")<cr>]],     {"silent"})
map("", [[<A-l>]],  [[:lua require("init").bufSwitcher("bn")<cr>]],         {"silent"})
map("", [[<C-w>O]], [[:lua require("closeOtherBuffer").closeOtherBuf()<cr>]], {"silent"})
-- Tab
map("", [[<A-S-h>]], [[:tabp<cr>]], {"silent"})
map("", [[<A-S-l>]], [[:tabn<cr>]], {"silent"})
-- }}} Buffer & Window & Tab
-- Folding {{{
map("",  [[[Z]],              [[zk]], {})
map("",  [[]Z]],              [[zj]], {})
map("",  [[[z]],              [[:<c-u>call EnhanceFoldJump("previous", 1, 0)<cr>]], {"noremap", "silent"})
map("",  [[]z]],              [[:<c-u>call EnhanceFoldJump("next",     1, 0)<cr>]], {"noremap", "silent"})
map("",  [[g[z]],             [[[z]], {"noremap", "silent"})
map("",  [[g]z]],             [[]z]], {"noremap", "silent"})
map("",  [[<leader>z]],       [[:<c-u>call EnhanceFoldHL("No fold marker found", 500, "")<cr>]], {"silent"})
map("n", [[dz]],              [[:<c-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<cr>]],        {"silent"})
map("n", [[zd]],              [[:<c-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<cr>]],        {"silent"})
map("n", [[cz]],              [[:<c-u>call EnhanceFoldHL("", 0, "EnhanceChange")<cr>]],          {"silent"})
map("n", [[g{]],              [[:<c-u>call EnhanceFold(mode(), "{{{")<cr>]],                     {})
map("n", [[g}]],              [[:<c-u>call EnhanceFold(mode(), "}}}")<cr>]],                     {})
map("v", [[g{]],              [[<A-m>z:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z]],       {})
map("v", [[g}]],              [[<A-m>z:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z]],       {})
map("",  [[<leader><Space>]], [[@=(foldlevel('.') ? 'za' : '\<Space>')<cr>]], {"noremap", "silent"})
map("",  [[<S-Space>]],       [[@=(foldlevel('.') ? 'zA' : 'zC')<cr>]],       {"noremap", "silent"})
for i=0, 9 do map("", string.format("z%d", i), string.format([[:set foldlevel=%d<bar>echohl Moremsg<bar>echo 'Foldlevel set to: %d'<bar>echohl None<cr>]], i, i), {}) end
-- }}} Folding
-- MS behavior {{{
-- <C-z/v/s> {{{
map("n", [[<C-z>]], [[u]],                {})
map("v", [[<C-z>]], [[<esc>u]],           {})
map("i", [[<C-z>]], [[<C-\><C-o>u]],      {})

map("n", [[<C-c>]], [[Y]],                {})
map("v", [[<C-c>]], [[y]],                {})
map("i", [[<C-c>]], [[<C-\><C-o>Y]],      {})

map("n", [[<C-v>]], [[p]],                {"noremap"})
map("v", [[<C-v>]], [[<esc>i<C-v><esc>]], {})
map("i", [[<C-v>]], [[<C-r>*]],           {})

map("n", [[<C-s>]], [[:<c-u>w<cr>]],      {})
map("v", [[<C-s>]], [[:<c-u>w<cr>]],      {})
map("i", [[<C-s>]], [[<C-\><C-o>:w<cr>]], {})
-- }}} <C-z/x/v/s>
-- Saveas
cmd [[command! -nargs=0 Saveas echohl Moremsg  echo "CWD: ".getcwd()  execute input("", "saveas ")  echohl None<cr>]]
map("",  [[<C-S-s>]], [[:<c-u>Saveas<cr>]],      {"silent"})
map("i", [[<C-S-s>]], [[<C-\><C-o>:Saveas<cr>]], {"silent"})
-- Delete
map("n", [[<C-S-d>]], [[:<c-u>d<cr>]],      {"silent"})
map("v", [[<C-S-d>]], [[:d<cr>]],           {"silent"})
map("i", [[<C-S-d>]], [[<C-\><C-o>:d<cr>]], {"silent"})
-- Put content from registers 0
map("n", [[<leader>p]], [["0p]], {})
map("n", [[<leader>P]], [["0P]], {})
-- Highlight New Paste Content
map("n", [[gy]], [[:<c-u>call HighlightLastYP("yank")<cr>]], {"silent"})
map("n", [[gY]], [[gy]],                                     {})
map("n", [[gp]], [[:<c-u>call HighlightLastYP("put")<cr>]],  {"silent"})
map("n", [[gP]], [[gp]],                                     {})
-- Inplace yank
map("n", [[Y]], [[yy]],               {})
map("v", [[Y]], [[y]],                {})
map("",  [[y]], [[SetInplaceYank()]], {"expr", "silent"})
-- Inplace put
map("n", [[p]], [[:<c-u>call InplacePut(mode(),       "p")<cr>]], {"silent"})
map("v", [[p]], [[:<c-u>call InplacePut(visualmode(), "p")<cr>]], {"silent"})
map("n", [[P]], [[:<c-u>call InplacePut(mode(),       "P")<cr>]], {"silent"})
map("v", [[P]], [[:<c-u>call InplacePut(visualmode(), "P")<cr>]], {"silent"})
-- Convert paste
map("n", [[cP]], [[:<c-u>call ConvertPut("P")<CR>]], {})
map("n", [[cp]], [[:<c-u>call ConvertPut("p")<CR>]], {})
-- Mimic the VSCode move/copy line up/down behavior {{{
-- Move line
cmd [[command! -nargs=0 VSCodeLineMoveDownInsert m .+1  execute "normal! =="]]
cmd [[command! -nargs=0 VSCodeLineMoveUpInsert   m .-2  execute "normal! =="]]
map("i", [[<A-j>]], [[<C-\><C-o>:VSCodeLineMoveDownInsert<cr>]], {})
map("i", [[<A-k>]], [[<C-\><C-o>:VSCodeLineMoveUpInsert<cr>]],   {})
map("n", [[<A-j>]], [[:<c-u>m .+1<cr>==]],                       {"silent"})
map("n", [[<A-k>]], [[:<c-u>m .-2<cr>==]],                       {"silent"})
map("v", [[<A-j>]], [[:m '>+1<cr>gv=gv]],                        {"silent"})
map("v", [[<A-k>]], [[:m '<-2<cr>gv=gv]],                        {"silent"})
-- Copy line
map("i", [[<A-S-j>]], [[<C-\><C-o>:call VSCodeLineYank(mode(),  "down")<cr>]], {"silent"})
map("i", [[<A-S-k>]], [[<C-\><C-o>:call VSCodeLineYank(mode(),  "up")<cr>]],   {"silent"})
map("n", [[<A-S-j>]], [[:<c-u>call VSCodeLineYank(mode(),       "down")<cr>]], {"silent"})
map("n", [[<A-S-k>]], [[:<c-u>call VSCodeLineYank(mode(),       "up")<cr>]],   {"silent"})
map("v", [[<A-S-j>]], [[:<c-u>call VSCodeLineYank(visualmode(), "down")<cr>]], {"silent"})
map("v", [[<A-S-k>]], [[:<c-u>call VSCodeLineYank(visualmode(), "up")<cr>]],   {"silent"})
-- }}} Mimic the VSCode move/copy line up/down behavior
-- }}} MS bebhave
-- Convert \ into /
map("n", [[g/]], [[mz:s#\\#\/#e<cr>:noh<cr>g`z]],   {"silent", "noremap"})
map("n", [[g\]], [[mz:s#\\#\\\\#e<cr>:noh<cr>g`z]], {"silent", "noremap"})
-- Mode - Terminal {{{
map("t", [[<A-n>]],      [[<C-\><C-n>]],                            {})
map("n", [[<C-`>]],      [[:<c-u>call TerminalToggle()<cr>]],       {"silent"})
map("t", [[<C-`>]],      [[<A-n>:call TerminalToggle()<cr>]],       {"silent"})
map("n", [[<A-`>]],      [[<A-n>:call TerminalClose()<cr>]],        {"silent"})
map("t", [[<A-`>]],      [[<A-n>:call TerminalClose()<cr>]],        {"silent"})
map("t", [[<A-h>]],      [[<A-n><A-h>]],                            {})
map("t", [[<A-l>]],      [[<A-n><A-l>]],                            {})
map("t", [[<A-S-h>]],    [[<A-n><A-S-h>]],                          {})
map("t", [[<A-S-l>]],    [[<A-n><A-S-l>]],                          {})
map("t", [[<C-r>]],      [['\<A-n>"' . nr2char(getchar()) . 'pi']], {"expr"})
map("t", [[<C-w>k]],     [[<A-n><C-w>k]],                           {})
map("t", [[<C-w>j]],     [[<A-n><C-w>j]],                           {})
map("t", [[<C-w>h]],     [[<A-n><C-w>h]],                           {})
map("t", [[<C-w>l]],     [[<A-n><C-w>l]],                           {})
map("t", [[<C-w>w]],     [[<A-n><C-w>w]],                           {})
map("t", [[<C-w><C-w>]], [[<A-n><C-w><C-w>]],                       {})
map("t", [[<C-w>W]],     [[<A-n><C-w>W]],                           {})
map("t", [[<C-w>H]],     [[<A-n><C-w>H]],                           {})
map("t", [[<C-w>L]],     [[<A-n><C-w>L]],                           {})
map("t", [[<C-w>J]],     [[<A-n><C-w>J]],                           {})
map("t", [[<C-w>K]],     [[<A-n><C-w>K]],                           {})
-- }}} Mode - Terminal
-- Mode: Commandline & Insert {{{
map("i", [[<C-cr>]],  [[<esc>o]],       {})
map("i", [[<S-cr>]],  [[<esc>O]],       {})
map("i", [[jj]],      [[<esc>`^]],      {})
map("i", [[<C-d>]],   [[<Del>]],        {})
map("i", [[<S-Tab>]], [[<C-d>]],        {"noremap"})
map("i", [[<C-.>]],   [[<C-a>]],        {"noremap"})
map("i", [[<C-S-.>]], [[<C-@>]],        {"noremap"})
map("i", [[<C-BS>]],  [[<C-\><C-o>db]], {})
-- Navigation {{{
map("!", [[<C-a>]], [[<Home>]],    {})
map("!", [[<C-e>]], [[<End>]],     {})
map("!", [[<C-h>]], [[<Left>]],    {})
map("!", [[<C-l>]], [[<Right>]],   {})
map("!", [[<C-j>]], [[<Down>]],    {})
map("!", [[<C-k>]], [[<Up>]],      {})
map("!", [[<C-b>]], [[<C-Left>]],  {})
map("!", [[<C-w>]], [[<C-Right>]], {})
map("!", [[<C-h>]], [[<Left>]],    {})
-- }}} Navigation
map("c", [[<C-BS>]],  [[<C-\>e(RemoveLastPathComponent())<cr>]], {})
map("c", [[<C-S-l>]], [[<C-d>]],                                 {"noremap"})
map("c", [[<C-d>]],   [[<Del>]],                                 {})
map("c", [[<C-S-e>]], [[<C-\>e]],                                {})
map("c", [[<C-v>]],   [[<C-R>*]],                                {})
-- }}} Mode: Commandline & Insert
-- }}} Key mapping

-- Plug-ins settings  {{{
-- inkarkat/vim-ReplaceWithRegister {{{
map("n", [[grr]], [[<Plug>ReplaceWithRegisterLine==]],       {"nowait"})
map("v", [[R]],   [[<Plug>ReplaceWithRegisterVisual`<v`>=]], {})
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
-- }}} AndrewRadev/splitjoin.vim
-- lag13/vim-create-variable {{{
map("v", [[C]], [[<Plug>Createvariable]], {})
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
map("n", [[gco]], [[:lua require("init").commentJump("o")<cr>]], {})
map("n", [[gcO]], [[:lua require("init").commentJump("O")<cr>]], {})

map("n", [[gc<space>]], [[<plug>NERDCommenterToggle]], {})
map("v", [[gc<space>]], [[<plug>NERDCommenterToggle]], {})
-- map("n", [[gcn]], [[<plug>NERDCommenterNested]], {})
-- map("v", [[gcn]], [[<plug>NERDCommenterNested]], {})
map("n", [[gci]], [[<plug>NERDCommenterInvert]], {})
map("v", [[gci]], [[<plug>NERDCommenterInvert]], {})

map("n", [[gcs]], [[<plug>NERDCommenterSexy]], {})
map("v", [[gcs]], [[<plug>NERDCommenterSexy]], {})

map("n", [[gcy]], [[<plug>NERDCommenterYank]], {})
map("v", [[gcy]], [[<plug>NERDCommenterYank]], {})

map("n", [[gc$]], [[<plug>NERDCommenterToEOL]], {})
map("n", [[gcA]], [[<plug>NERDCommenterAppend]], {})
map("n", [[gcI]], [[<plug>NERDCommenterInsert]], {})

map("v", [[<A-/>]], [[<plug>NERDCommenterAltDelims]], {})
map("n", [[<A-/>]], [[<plug>NERDCommenterAltDelims]], {})

map("n", [[gcn]], [[<plug>NERDCommenterAlignLeft]], {})
map("v", [[gcn]], [[<plug>NERDCommenterAlignLeft]], {})
map("n", [[gcb]], [[<plug>NERDCommenterAlignBoth]], {})
map("v", [[gcb]], [[<plug>NERDCommenterAlignBoth]], {})

map("n", [[gcu]], [[<plug>NERDCommenterUncomment]], {})
map("v", [[gcu]], [[<plug>NERDCommenterUncomment]], {})

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
vim.g.easy_align_delimiters = {
    pattern       = '--',
    left_margin   = 2,
    right_margin  = 1,
    stick_to_left = 0 ,
    ignore_groups = {'String'}
    }
map("v", [[A]],  [[<Plug>(EasyAlign)]], {})
map("n", [[ga]], [[<Plug>(EasyAlign)]], {})
-- }}} junegunn/vim-easy-align
-- szw/vim-maximizer {{{
map("", [[<C-w>m]], [[<f3>]], {})
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
map("x", [[am]],        [[<Plug>(matchup-a%)]],          {})
map("x", [[im]],        [[<Plug>(matchup-i%)]],          {})
map("o", [[am]],        [[<Plug>(matchup-a%)]],          {})
map("o", [[im]],        [[<Plug>(matchup-i%)]],          {})
-- Inclusive
map("",  [[<C-m>]],     [[<Plug>(matchup-%)]],           {})
map("",  [[<C-S-m>]],   [[<Plug>(matchup-g%)]],          {})
-- Exclusive
map("",  [[m]],         [[<Plug>(matchup-]%)]],          {})
map("",  [[M]],         [[<Plug>(matchup-[%)]],          {})
-- Origin mark
map("",  [[<A-m>]],     [[m]],                           {"noremap"})
-- Highlight
map("n", [[<leader>m]], [[<plug>(matchup-hi-surround)]], {})
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
map("", [[<A-a>]], [[<Plug>(expand_region_expand)]], {})
map("", [[<A-s>]], [[<Plug>(expand_region_shrink)]], {})
-- }}} landock/vim-expand-region
-- liuchengxu/vista.vim {{{
vim.g.vista_default_executive = 'ctags'
vim.g.vista_icon_indent = {"╰─▸ ", "├─▸ "}
cmd [=[let g:vista#finders = ['fzf']]=]
-- Base on Sarasa Nerd Mono SC
cmd [[let g:vista#renderer#icons = {"variable": "\uF194"}]]
map("n", [[<leader>s]], [[:Vista!!<cr>]], {})
-- }}} liuchengxu/vista.vim
-- mbbill/undotree {{{
map("n", [[<c-u>]], [[vim.bo.buftype? ":UndotreeToggle\<cr>" : ":UndotreeToggle\<bar>UndotreeFocus\<cr>"]], {"silent", "expr"})
-- }}} mbbill/undotree
-- Exchange {{{
map("n", [[gx]],  [[<Plug>(Exchange)]],      {})
map("x", [[X]],   [[<Plug>(Exchange)]],      {})
map("n", [[gxc]], [[<Plug>(ExchangeClear)]], {})
map("n", [[gxx]], [[<Plug>(ExchangeLine)]],  {})
-- }}} Exchange
-- tpope/vim-repeat {{{
cmd [[silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)]]
-- }}} tpope/vim-repeat
-- }}} Plug-ins settings

return M

