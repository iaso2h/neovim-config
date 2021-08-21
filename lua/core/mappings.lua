local cmd  = vim.cmd
local map  = require("util").map
local vmap = require("util").vmap
local M    = {}

-- First thing first
vim.g.mapleader = " "

-- Change font size
map("", [[<C-->]],  [[:lua GuiFontSize = GuiFontSize - 1; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<cr>]], {"silent", "novscode"})
map("", [[<C-=>]],  [[:lua GuiFontSize = GuiFontSize + 1; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<cr>]], {"silent", "novscode"})
-- map("", [=[\]]=],  [[:lua GuiFontSize = GuiFontSize + 1; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<cr>]], {"silent", "novscode"})
-- map("", [[\[]],    [[:lua GuiFontSize = GuiFontSize - 1; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<cr>]], {"silent", "novscode"})
map("", [[<C-0>]], [[:lua GuiFontSize = 13; vim.o.guifont = GuiFont ..":h" .. GuiFontSize<cr>]],              {"silent", "novscode"})
-- Extraction
map("",  [[gc]], [[luaeval("require('operator').main(require('extraction').main, false)")]], {"silent", "expr"})
map("v", [[C]],  [[:lua require("extraction").main({nil, vim.fn.visualmode()})<cr>]],        {"silent"})
-- Zeal query
map("",  [[gz]], [[luaeval("require('operator').main(require('zeal').nonglobalQuery, false)")]], {"silent", "expr"})
map("",  [[gZ]], [[luaeval("require('operator').main(require('zeal').globalQuery, false)")]],    {"silent", "expr"})
map("v", [[Z]],  [[:lua require("zeal").globalQuery({nil, "v"})<cr>]],                           {"silent"})
-- Print file name
map("", [[<C-g>]], [[:lua print(" " .. vim.api.nvim_exec("file!", true) .. " 🖵  CWD: " .. vim.fn.getcwd())<cr>]], {"silent", "novscode"})
-- Tab switcher {{{
map("n", [[<S-tab>]], [[:lua require("tabSwitcher").main()<cr>]], {"silent", "novscode"})
-- }}} Tab switcher
-- Compile & run
map("n", [[<F9>]],   [[:lua require("compileRun").compileCode(true)<cr>]], {"noremap", "silent", "novscode"})
map("n", [[<S-F9>]], [[:lua require("compileRun").runCode(true)<cr>]],     {"noremap", "silent", "novscode"})
-- Search & Jumping {{{
-- Disable dj/dk
map("n", [[dj]], [[<Nop>]])
map("n", [[dk]], [[<Nop>]])
-- Inquery word
map("n", [[<leader>i]], [=[[I]=])
map("v", [[<leader>i]], [[:lua vim.cmd("g#" .. require("util").visualSelection("string") .. "#nu")<cr>]], {"silent"})
-- Fast mark & resotre
-- map("n", [[mm]], [[mm]])
map("n", [[M]], [[`m]])
-- Changelist jumping
map("n", [[<A-o>]], [[&diff? "mz`z[czz" : "mz`zg;zz"]], {"noremap", "silent", "expr"})
map("n", [[<A-i>]], [[&diff? "mz`z]czz" : "mz`zg,zz"]], {"noremap", "silent", "expr"})
map("n", [[<C-o>]], [[<C-o>zz]])
map("n", [[<C-i>]], [[<C-i>zz]])
map("n", [[j]], [[:lua require("util").addJumpMotion("j", true)<cr>]],     {"silent"})
map("n", [[k]], [[:lua require("util").addJumpMotion("k", true)<cr>]],     {"silent"})
map("v", [[*]], [[mz`z:<c-u>execute "/" . luaeval('require("util").visualSelection("string")')<cr>]], {"noremap", "silent"})
map("v", [[#]], [[mz`z:<c-u>execute "?" . luaeval('require("util").visualSelection("string")')<cr>]], {"noremap", "silent"})
-- map("v", [[#]], [[mz`z:<c-u>execute "?" . VisualSelection("string")<cr>]], {"noremap", "silent"})
map("v", [[/]], [[*]])
map("v", [[?]], [[#]])
-- Regex very magic
map("n", [[/]], [[/\v]], {"noremap"})
map("n", [[?]], [[?\v]], {"noremap"})
-- Disable highlight search & Exit visual mode
map("n", [[<leader>h]], [[:<c-u>noh<cr>]],     {"silent"})
map("v", [[<leader>h]], [[:<c-u>call ExitVisual()<cr>]], {"silent"})
-- Visual selection
map("n", [[go]],    [[:lua require("selection").oppoSelection()<cr>]], {"silent"})
map("n", [[<A-v>]], [[<C-q>]],                                         {"noremap"})
-- }}} Search & Jumping
-- Scratch file
map("n", [[<C-n>]], [[:<c-u>new<cr>]], {"silent", "novscode"})
-- Open/Search in browser
map("n", [[gl]], [[:lua require("openBrowser").openUrl()<cr>]], {"silent"})
map("v", [[gl]], [[:lua require("openBrowser").openUrl(require("util").visualSelection("string"))<cr>]], {"silent"})
-- Interrupt
map("n", [[<C-A-c>]], [[:<c-u>call interrupt()<cr>]], {"noremap", "silent"})
-- Paragraph & Block navigation
map("", [[{]], [[:lua require("inclusiveParagraph").main("up")<cr>]],   {"noremap", "silent"})
map("", [[}]], [[:lua require("inclusiveParagraph").main("down")<cr>]], {"noremap", "silent"})
-- Line end/start
map("", [[H]], [[^]])
map("", [[L]], [[$]])
-- Non-blank last character
map("", [[g$]], [[g_]], {"noremap"})
-- Trailing character {{{
map("n", [[g.]],      [[:lua require("trailingUtil").trailingChar(".")<cr>]],  {"silent"})
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
vmap("n", [[g>]], [[:<c-u>messages<cr>]])

map("n", [[g<]],    [[:<c-u>messages<cr>]], {"silent"})
map("n", [[g>]],    [[:<c-u>Messages<cr>]], {"silent", "novscode"})
map("n", [[<A-,>]], [[:<c-u>execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>]])
map("n", [[<A-.>]], [[:<c-u>execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>]])
-- Pageup/Pagedown
map("",  [[<A-e>]], [[<PageUp>]], {"novscode"})
map("",  [[<A-d>]], [[<PageDown>]], {"novscode"})
map("t", [[<A-e>]], [[<C-\><C-n><PageUp>]])
map("t", [[<A-d>]], [[<C-\><C-n><PageDown>]])

vmap("n", [[<A-e>]], [[:call VSCodeCall("cursorPageUp")<cr>]])
vmap("n", [[<A-d>]], [[:call VSCodeCall("cursorPageDown")<cr>]])
vmap("i", [[<A-e>]], [[<C-o>:call VSCodeCall("cursorPageUp")<cr>]])
vmap("i", [[<A-d>]], [[<C-o>:call VSCodeCall("cursorPageDown")<cr>]])
vmap("v", [[<A-e>]], [[<C-b>]])
vmap("v", [[<A-d>]], [[<C-f>]])
-- Macro
-- <C-q> has been mapped to COC showDoc
map("n", [[<A-q>]], [[q]], {"noremap"})
-- Register
-- ClearReg() {{{
cmd [[
function! ClearReg()
    for i in range(34,122) | silent! call setreg(nr2char(i), "") | endfor
    echohl Moremsg | echo "Register clear" | echohl None
endfunction
]]
-- }}} ClearReg()
map("",  [[<C-'>]], [[:<c-u>reg<cr>]],             {"silent"})
map("i", [[<C-'>]], [[<C-\><C-o>:reg<cr>]],        {"silent"})
map("",  [[<A-'>]], [[:<c-u>call ClearReg()<cr>]], {"silent"})
-- Buffer & Window & Tab{{{
-- Smart quit
-- Similar work: https://github.com/ojroques/nvim-bufdel
map("n", [[q]], [[:lua require("buffer").smartClose("window")<cr>]], {"silent"})
map("n", [[Q]], [[:lua require("buffer").smartClose("buffer")<cr>]], {"silent"})
map("n", [[<C-u>]], [[:lua vim.cmd(string.format("e %s", require("buffer").lastClosedFilePath))<cr>]], {"silent"})
-- Window
map("",  [[<C-w>v]], [[:lua require("consistantTab").splitCopy("wincmd v")<cr>]], {"silent", "novscode"})
map("",  [[<C-w>s]], [[:lua require("consistantTab").splitCopy("wincmd s")<cr>]], {"silent", "novscode"})
map("",  [[<C-w>V]], [[:only<cr><C-w>v]],                                         {"silent", "novscode"})
map("",  [[<C-w>S]], [[:only<cr><C-w>s]],                                         {"silent", "novscode"})
map("",  [[<C-w>q]], [[:lua require("buffer").quickfixToggle()<cr>]],             {"silent", "novscode"})
map("",  [[<C-w>t]], [[:wincmd T]],                                               {"silent", "novscode"})
map("n", [[<A-=>]],  [[:<c-u>wincmd +<cr>]],                                      {"silent", "novscode"})
map("i", [[<A-=>]],  [[<C-\><C-O>:wincmd +<cr>]],                                 {"silent", "novscode"})
map("n", [[<A-->]],  [[:<c-u>wincmd -<cr>]],                                      {"silent", "novscode"})
map("i", [[<A-->]],  [[<C-\><C-O>:wincmd -<cr>]],                                 {"silent", "novscode"})
map("i", [[<C-w>=]], [[<C-\><C-O>:wincmd =<cr>]],                                 {"silent", "novscode"})

-- Buffers
map("",  [[<C-w>O]], [[:lua require("buffer").wipeOtherBuf()<cr>]], {"silent", "novscode"})
-- Tab
map("", [[<A-<>]], [[:tabp<cr>]],     {"silent", "novscode"})
map("", [[<A->>]], [[:tabn<cr>]],     {"silent", "novscode"})
-- map("", [[<C-T>o]], [[:tabonly<cr>]], {"silent", "novscode"})
-- }}} Buffer & Window & Tab
-- Folding {{{
map("",  [[[Z]],              [[zk]])
map("",  [[]Z]],              [[zj]])
map("",  [[[z]],              [[:<c-u>call EnhanceFoldJump("previous", 1, 0)<cr>]],              {"noremap", "silent", "novscode"})
map("",  [[]z]],              [[:<c-u>call EnhanceFoldJump("next",     1, 0)<cr>]],              {"noremap", "silent", "novscode"})
map("",  [[g[z]],             [[[z]],                                                            {"noremap", "silent", "novscode"})
map("",  [[g]z]],             [[]z]],                                                            {"noremap", "silent", "novscode"})
map("",  [[<leader>z]],       [[:<c-u>call EnhanceFoldHL("No fold marker found", 500, "")<cr>]], {"silent", "novscode"})
map("n", [[dz]],              [[:<c-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<cr>]],        {"silent", "novscode"})
map("n", [[zd]],              [[:<c-u>call EnhanceFoldHL("", 800, "EnhanceDelete")<cr>]],        {"silent", "novscode"})
map("n", [[cz]],              [[:<c-u>call EnhanceFoldHL("", 0, "EnhanceChange")<cr>]],          {"silent", "novscode"})
map("n", [[zc]],              [[:<c-u>call EnhanceFoldHL("", 0, "EnhanceChange")<cr>]],          {"silent", "novscode"})
map("n", [[g{]],              [[:<c-u>call EnhanceFold(mode(), "{{{")<cr>]],                     {"novscode"})
map("n", [[g}]],              [[:<c-u>call EnhanceFold(mode(), "}}}")<cr>]],                     {"novscode"})
map("v", [[g{]],              [[mz:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z]],       {"novscode"})
map("v", [[g}]],              [[mz:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z]],       {"novscode"})
map("n", [[<leader><Space>]], [[@=(foldlevel('.') ? 'za' : '\<Space>')<cr>]],                    {"noremap", "silent"})
map("n", [[<S-Space>]],       [[@=(foldlevel('.') ? 'zA' : '\<Space>')<cr>]],                    {"noremap", "silent"})
for i=0, 9 do map("", string.format("z%d", i), string.format([[:set foldlevel=%d<bar>echohl Moremsg<bar>echo 'Foldlevel set to: %d'<bar>echohl None<cr>]], i, i), {}) end
-- }}} Folding
-- MS behavior {{{
-- <C-z/v/s> {{{
map("n", [[<C-z>]], [[u]],           {"novscode"})
map("v", [[<C-z>]], [[<esc>u]],      {"novscode"})
map("i", [[<C-z>]], [[<C-\><C-o>u]], {"novscode"})

map("n", [[<C-c>]], [[Y]], {"novscode"})
map("v", [[<C-c>]], [[y]], {"novscode"})
-- map("i", [[<C-c>]], [[<C-\><C-o>Y]])

map("n", [[<C-v>]], [[p]],                {"noremap", "novscode"})
map("v", [[<C-v>]], [[<esc>i<C-v><esc>]], {"novscode"})
map("i", [[<C-v>]], [[<C-r>*]],           {"novscode"})

-- map("n", [[<C-s>]], [[:<c-u>w<cr>]],      {"novscode"})
-- map("v", [[<C-s>]], [[:<c-u>w<cr>]],      {"novscode"})
map("i", [[<C-s>]], [[<C-\><C-o>:w<cr>]], {"novscode"})
-- }}} <C-z/x/v/s>
-- Save as..
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
map("",  [[y]], [[luaeval("require('operator').main(require('yankPut').inplaceYank, false, nil)")]], {"silent", "expr"})
-- Inplace put
map("n", [[p]], [[:lua require("yankPut").inplacePut("n", "p")<cr>]], {"silent"})
map("v", [[p]], [[:lua require("yankPut").inplacePut("v", "p")<cr>]], {"silent"})
map("n", [[P]], [[:lua require("yankPut").inplacePut("n", "P")<cr>]], {"silent"})
map("v", [[P]], [[:lua require("yankPut").inplacePut("v", "P")<cr>]], {"silent"})
-- Inplace replace
-- Repeat not defined in visual mode, but enabled through visualrepeat.vim.
map("n", [[gr]],  [[luaeval("require('replace').expression()")]], {"silent", "expr"})
map("n", [[grr]], [[<Plug>InplaceReplaceLine]])
map("n", [[<Plug>InplaceReplaceLine]], [[:<c-u>execute 'normal! V' . v:count1 . "_\<lt>Esc>"<bar> lua ReplaceOperator({"visual", "InplaceReplaceLine"})<cr>]], {"noremap", "silent"})
map("v", [[R]], [[<Plug>InplaceReplaceVisual]])
map("v", [[<Plug>InplaceReplaceVisual]], [[:lua ReplaceOperator({"visual", "InplaceReplaceVisual"})<cr>]], {"noremap", "silent"})
map("v", [[<Plug>InplaceReplaceVisual]], [[:lua ReplaceVisualMode()<cr>]],                                 {"noremap", "silent"})
-- Convert paste
map("n", [[cP]], [[:lua require("yankPut").convertPut("P")<cr>]])
map("n", [[cp]], [[:lua require("yankPut").convertPut("p")<cr>]])
-- Mimic the VSCode move/copy line up/down behavior {{{
-- Move line
map("i", [[<A-j>]], [[<C-\><C-o>:VSCodeLineMoveDownInsert<cr>]],                 {"silent", "novscode"})
map("i", [[<A-k>]], [[<C-\><C-o>:VSCodeLineMoveUpInsert<cr>]],                   {"silent", "novscode"})
map("n", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("n", "down")<cr>]], {"silent", "novscode"})
map("n", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("n", "up")<cr>]],   {"silent", "novscode"})
map("v", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("v", "down")<cr>]], {"silent", "novscode"})
map("v", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("v", "up")<cr>]],   {"silent", "novscode"})
-- Copy line
map("i", [[<A-S-j>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "down")<cr>]],       {"silent"})
map("i", [[<A-S-k>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "up")<cr>]],         {"silent"})
map("n", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank("n", "down")<cr>]],                 {"silent"})
map("n", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank("n", "up")<cr>]],                   {"silent"})
map("v", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "down")<cr>]], {"silent"})
map("v", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "up")<cr>]],   {"silent"})

vmap("n", [[<A-j>]],   [[:call VSCodeCall("editor.action.moveLinesDownAction")<cr>]])
vmap("n", [[<A-k>]],   [[:call VSCodeCall("editor.action.moveLinesUpAction")<cr>]])
vmap("i", [[<A-j>]],   [[<C-\><C-o>:call VSCodeCall("editor.action.moveLinesDownAction")<cr>]])
vmap("i", [[<A-k>]],   [[<C-\><C-o>:call VSCodeCall("editor.action.moveLinesUpAction")<cr>]])
vmap("i", [[<A-S-j>]], [[<C-\><C-o>:call VSCodeCall("editor.action.copyLinesUpAction")]])
vmap("i", [[<A-S-k>]], [[<C-\><C-o>:call VSCodeCall("editor.action.copyLinesUpAction")]])
vmap("n", [[<A-S-j>]], [[:call VSCodeCall("editor.action.copyLinesUpAction")]])
vmap("n", [[<A-S-k>]], [[:call VSCodeCall("editor.action.copyLinesUpAction")]])
-- }}} Mimic the VSCode move/copy line up/down behavior
-- }}} MS bebhave
-- Convert \ into /
map("n", [[g/]], [[mz:s#\\#\/#e<cr>:noh<cr>g`z]],   {"noremap", "silent"})
map("n", [[g\]], [[mz:s#\\#\\\\#e<cr>:noh<cr>g`z]], {"noremap", "silent"})
-- Mode: Terminal {{{
map("t", [[<A-n>]],      [[<C-\><C-n>]])
map("n", [[<C-`>]],      [[:lua require("terminal").terminalToggle()<cr>]],      {"silent"})
map("t", [[<C-`>]],      [[<A-n>:lua require("terminal").terminalToggle()<cr>]], {"silent"})
map("t", [[<A-h>]],      [[<A-n><A-h>]])
map("t", [[<A-l>]],      [[<A-n><A-l>]])
map("t", [[<A-S-h>]],    [[<A-n><A-S-h>]])
map("t", [[<A-S-l>]],    [[<A-n><A-S-l>]])
map("t", [[<C-BS>]],     [[<C-w>]],                                 { "noremap"})
map("t", [[<C-r>]],      [['\<A-n>"' . nr2char(getchar()) . 'pi']], { "expr"})
map("t", [[<C-w>k]],     [[<A-n><C-w>k]])
map("t", [[<C-w>j]],     [[<A-n><C-w>j]])
map("t", [[<C-w>h]],     [[<A-n><C-w>h]])
map("t", [[<C-w>l]],     [[<A-n><C-w>l]])
map("t", [[<C-w>w]],     [[<A-n><C-w>w]])
map("t", [[<C-w><C-w>]], [[<A-n><C-w><C-w>]])
map("t", [[<C-w>=]],     [[<A-n><C-w>=:startinsert<cr>]], {"silent"})
map("t", [[<C-w>o]],     [[<A-n><C-w>o:startinsert<cr>]], {"silent"})
map("t", [[<C-w>W]],     [[<A-n><C-w>W:startinsert<cr>]], {"silent"})
map("t", [[<C-w>H]],     [[<A-n><C-w>H:startinsert<cr>]], {"silent"})
map("t", [[<C-w>L]],     [[<A-n><C-w>L:startinsert<cr>]], {"silent"})
map("t", [[<C-w>J]],     [[<A-n><C-w>J:startinsert<cr>]], {"silent"})
map("t", [[<C-w>K]],     [[<A-n><C-w>K:startinsert<cr>]], {"silent"})
-- TODO: Split terminal in new instance
-- }}} Mode: Terminal
-- Mode: Commandline & Insert {{{
map("i", [[<C-cr>]],  [[<esc>o]],  {"novscode"})
map("i", [[<S-cr>]],  [[<esc>O]],  {"novscode"})
map("i", [[jj]],      [[<esc>`^]], {"noremap", "novscode"})
map("i", [[<C-S-[>]], [[<C-d>]],   {"noremap", "novscode"})
map("i", [[<C-S-]>]], [[<C-t>]],   {"noremap", "novscode"})
map("i", [[<C-d>]],   [[<Del>]],   {"novscode"})
map("i", [[<C-.>]],   [[<C-a>]],   {"noremap"})
map("i", [[<C-S-.>]], [[<C-@>]],   {"noremap"})
map("i", [[<C-BS>]],  [[<C-w>]],   {"noremap"})
-- Navigation {{{
map("!", [[<C-a>]], [[<Home>]])
-- Overide in nvim-comp
-- map("!", [[<C-e>]], [[<End>]])
map("!", [[<C-h>]], [[<Left>]])
map("!", [[<C-l>]], [[<Right>]])
map("!", [[<C-j>]], [[<Down>]])
map("!", [[<C-k>]], [[<Up>]])
map("!", [[<C-b>]], [[<C-Left>]])
map("!", [[<C-w>]], [[<C-Right>]])
map("!", [[<C-h>]], [[<Left>]])
-- }}} Navigation
-- RemoveLastPathComponent() {{{
cmd [[
function! RemoveLastPathComponent()
    let l:cmdlineBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
    let l:cmdlineAfterCursor  = strpart(getcmdline(), getcmdpos() - 1)
    let l:cmdlineRoot         = fnamemodify(cmdlineBeforeCursor, ':r')
    let l:result              = (l:cmdlineBeforeCursor ==# l:cmdlineRoot ? substitute(l:cmdlineBeforeCursor, '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '') : l:cmdlineRoot)
    call setcmdpos(strlen(l:result) + 1)
    return l:result . l:cmdlineAfterCursor
endfunction
]]
-- }}} RemoveLastPathComponent()
map("c", [[<C-BS>]],  [[<C-\>e(RemoveLastPathComponent())<cr>]])
map("c", [[<C-S-l>]], [[<C-d>]], {"noremap"})
map("c", [[<C-d>]],   [[<Del>]])
map("c", [[<C-S-e>]], [[<C-\>e]])
map("c", [[<C-v>]],   [[<C-R>*]])
-- }}} Mode: Commandline & Insert

return M

