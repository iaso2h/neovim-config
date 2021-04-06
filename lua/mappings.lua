local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local map = require("util").map
local M   = {}

-- Extraction
map("",  [[gc]], [[luaeval("require('operator').main(require('extraction').main, false)")]], {"silent", "expr"})
map("v", [[C]],  [[:lua require("extraction").main({nil, vim.fn.visualmode()})<cr>]],        {"silent"})
-- Zeal query
map("",  [[gz]], [[luaeval("require('operator').main(require('zeal').nonglobalQuery, false)")]], {"silent", "expr"})
map("",  [[gZ]], [[luaeval("require('operator').main(require('zeal').globalQuery, false)")]],    {"silent", "expr"})
map("v", [[Z]],  [[:lua require("zeal").globalQuery({nil, "v"})<cr>]],                           {"silent"})
-- Don't truncate the name
map("n", [[<C-g>]],   [[:file!<cr>]],         {"silent"})
map("n", [[<C-S-g>]], [[:echo getcwd()<cr>]], {"silent"})
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
    if curPos[1] == startSelectPos[1] then
        api.nvim_win_set_cursor(0, endSelectPos)
        return
    elseif curPos[1] == endSelectPos[1] then
        api.nvim_win_set_cursor(0, startSelectPos)
        return
    end
    local closerToStart  = require("util").posDist(startSelectPos, curPos) < require("util").posDist(endSelectPos, curPos) and true or false
    if closerToStart then api.nvim_win_set_cursor(0, endSelectPos) else api.nvim_win_set_cursor(0, startSelectPos) end
end -- }}}
map("n", [[go]],    [[:lua require("mappings").oppoSelection()<cr>]], { "silent"})
map("n", [[<A-v>]], [[<C-q>]],                                        {"noremap"})
-- }}} Search & Jumping
-- Scratch file
map("n", [[<C-n>]], [[:<c-u>new<cr>]], {"silent"})
-- Open/Search in browser
map("n", [[<C-l>]], [[:lua require("openBrowser").openUrl()<cr>]], {"silent"})
map("v", [[<C-l>]], [[:lua require("openBrowser").openUrl(require("util").visualSelection("string"))<cr>]], {"silent"})
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
map("n", [[g<]],    [[:<c-u>messages<cr>]], {"silent"})
map("n", [[g>]],    [[:<c-u>Messages<cr>]], {"silent", "novscode"})
map("n", [[g>]],    [[:<c-u>messages<cr>]], {"silent", "vscodeonly"})
map("n", [[<A-,>]], [[:<c-u>execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>]])
map("n", [[<A-.>]], [[:<c-u>execute 'messages clear<bar>echohl Moremsg<bar>echo "Message clear"<bar>echohl None'<cr>]])
-- Pageup/Pagedown
map("",  [[<A-e>]], [[<pageup>]],             {"novscode"})
map("t", [[<A-e>]], [[<C-\><C-n><pageup>]],   {"novscode"})
map("",  [[<A-d>]], [[<pagedown>]],           {"novscode"})
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
-- Similar work: https://github.com/ojroques/nvim-bufdel
map("n", [[q]], [[:lua require("buffer").smartClose("window")<cr>]], {"silent"})
map("n", [[Q]], [[:lua require("buffer").smartClose("buffer")<cr>]], {"silent"})
-- Window
map("",  [[<C-w>v]],   [[:lua require("consistantTab").splitCopy("wincmd v")<cr>]], {"silent", "novscode"})
map("",  [[<C-w>s]],   [[:lua require("consistantTab").splitCopy("wincmd s")<cr>]], {"silent", "novscode"})
map("",  [[<C-w>V]],   [[:only<cr><C-w>v]],                                         {"silent", "novscode"})
map("",  [[<C-w>S]],   [[:only<cr><C-w>s]],                                         {"silent", "novscode"})
map("",  [[<C-w>q]],   [[:lua require("buffer").quickfixToggle()<cr>]],             {"silent", "novscode"})
map("i", [[<C-S-w>=]], [[<C-\><C-O>:wincmd =<cr>]],                                 {"silent", "novscode"})
-- Buffers
map("",  [[<C-w>O]], [[:lua require("buffer").wipeOtherBuf()<cr>]], {"silent", "novscode"})
-- Tab
map("", [[<A-<>]], [[:tabp<cr>]], {"silent", "novscode"})
map("", [[<A->>]], [[:tabn<cr>]], {"silent", "novscode"})
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
map("n", [[g{]],              [[:<c-u>call EnhanceFold(mode(), "{{{")<cr>]],                     {"novscode"})
map("n", [[g}]],              [[:<c-u>call EnhanceFold(mode(), "}}}")<cr>]],                     {"novscode"})
map("v", [[g{]],              [[<A-m>z:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z]],       {"novscode"})
map("v", [[g}]],              [[<A-m>z:<c-u>call EnhanceFold(visualmode(), "}}}")<cr>`z]],       {"novscode"})
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

map("n", [[<C-s>]], [[:<c-u>w<cr>]],      {"novscode"})
map("v", [[<C-s>]], [[:<c-u>w<cr>]],      {"novscode"})
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
map("n", [[cP]], [[:lua require("yankPut").convertPut("P")<CR>]])
map("n", [[cp]], [[:lua require("yankPut").convertPut("p")<CR>]])
-- Mimic the VSCode move/copy line up/down behavior {{{
-- Move line
map("i", [[<A-j>]], [[<C-\><C-o>:VSCodeLineMoveDownInsert<cr>]],                             {"silent", "novscode"})
map("i", [[<A-k>]], [[<C-\><C-o>:VSCodeLineMoveUpInsert<cr>]],                               {"silent", "novscode"})
map("i", [[<A-j>]], [[<C-\><C-o>:call VSCodeCall("editor.action.moveLinesDownAction")<cr>]], {"silent", "vscodeonly"})
map("i", [[<A-k>]], [[<C-\><C-o>:call VSCodeCall("editor.action.moveLinesUpAction")<cr>]],   {"silent", "vscodeonly"})
map("n", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("n", "down")<cr>]],             {"silent", "novscode"})
map("n", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("n", "up")<cr>]],               {"silent", "novscode"})
map("n", [[<A-j>]], [[:call VSCodeCall("editor.action.moveLinesDownAction")<cr>]],           {"silent", "vscodeonly"})
map("n", [[<A-k>]], [[:call VSCodeCall("editor.action.moveLinesUpAction")<cr>]],             {"silent", "vscodeonly"})
map("v", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("v", "down")<cr>]],             {"silent", "novscode"})
map("v", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("v", "up")<cr>]],               {"silent", "novscode"})
-- Copy line
map("i", [[<A-S-j>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "down")<cr>]],       {"silent", "novscode"})
map("i", [[<A-S-k>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "up")<cr>]],         {"silent", "novscode"})
map("i", [[<A-S-j>]], [[<C-\><C-o>:call VSCodeCall("editor.action.copyLinesUpAction")]],           {"silent", "vscodeonly"})
map("i", [[<A-S-k>]], [[<C-\><C-o>:call VSCodeCall("editor.action.copyLinesUpAction")]],           {"silent", "vscodeonly"})
map("n", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank("n", "down")<cr>]],                 {"silent", "novscode"})
map("n", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank("n", "up")<cr>]],                   {"silent", "novscode"})
map("n", [[<A-S-j>]], [[:call VSCodeCall("editor.action.copyLinesUpAction")]],                     {"silent", "vscodeonly"})
map("n", [[<A-S-k>]], [[:call VSCodeCall("editor.action.copyLinesUpAction")]],                     {"silent", "vscodeonly"})
map("v", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "down")<cr>]], {"silent", "novscode"})
map("v", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank(vim.fn.visualmode(), "up")<cr>]],   {"silent", "novscode"})
-- }}} Mimic the VSCode move/copy line up/down behavior
-- }}} MS bebhave
-- Convert \ into /
map("n", [[g/]], [[mz:s#\\#\/#e<cr>:noh<cr>g`z]],   {"noremap", "silent"})
map("n", [[g\]], [[mz:s#\\#\\\\#e<cr>:noh<cr>g`z]], {"noremap", "silent"})
-- Mode: Terminal {{{
map("t", [[<A-n>]],      [[<C-\><C-n>]])
map("n", [[<C-`>]],      [[:lua require("terminal").terminalToggle()<cr>]],       {"silent",  "novscode"})
map("t", [[<C-`>]],      [[<A-n>:lua require("terminal").terminalToggle()<cr>]],  {"silent",  "novscode"})
map("t", [[<A-h>]],      [[<A-n><A-h>]],                            {"novscode"})
map("t", [[<A-l>]],      [[<A-n><A-l>]],                            {"novscode"})
map("t", [[<A-S-h>]],    [[<A-n><A-S-h>]],                          {"novscode"})
map("t", [[<A-S-l>]],    [[<A-n><A-S-l>]],                          {"novscode"})
map("t", [[<C-BS>]],     [[<C-w>]],                                 {"novscode", "noremap"})
map("t", [[<C-r>]],      [['\<A-n>"' . nr2char(getchar()) . 'pi']], {"novscode", "expr"})
map("t", [[<C-w>k]],     [[<A-n><C-w>k]],                           {"novscode"})
map("t", [[<C-w>j]],     [[<A-n><C-w>j]],                           {"novscode"})
map("t", [[<C-w>h]],     [[<A-n><C-w>h]],                           {"novscode"})
map("t", [[<C-w>l]],     [[<A-n><C-w>l]],                           {"novscode"})
map("t", [[<C-w>w]],     [[<A-n><C-w>w]],                           {"novscode"})
map("t", [[<C-w><C-w>]], [[<A-n><C-w><C-w>]],                       {"novscode"})
map("t", [[<C-w>=]],     [[<A-n><C-w>=:startinsert<cr>]],           {"silent",  "novscode"})
map("t", [[<C-w>o]],     [[<A-n><C-w>o:startinsert<cr>]],           {"silent",  "novscode"})
map("t", [[<C-w>W]],     [[<A-n><C-w>W:startinsert<cr>]],           {"silent",  "novscode"})
map("t", [[<C-w>H]],     [[<A-n><C-w>H:startinsert<cr>]],           {"silent",  "novscode"})
map("t", [[<C-w>L]],     [[<A-n><C-w>L:startinsert<cr>]],           {"silent",  "novscode"})
map("t", [[<C-w>J]],     [[<A-n><C-w>J:startinsert<cr>]],           {"silent",  "novscode"})
map("t", [[<C-w>K]],     [[<A-n><C-w>K:startinsert<cr>]],           {"silent",  "novscode"})
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
    let l:cmdlineAfterCursor  = strpart(getcmdline(), getcmdpos() - 1)
    let l:cmdlineRoot         = fnamemodify(cmdlineBeforeCursor, ':r')
    let l:result              = (l:cmdlineBeforeCursor ==# l:cmdlineRoot ? substitute(l:cmdlineBeforeCursor, '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '') : l:cmdlineRoot)
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

return M

