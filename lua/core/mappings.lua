-- NOTE: Mapping is always recursive unless noremap is specified

-- First thing first
vim.g.mapleader = " "

-- Diagnostic mapping
map("n", [[<C-q>e]],    [[<CMD>lua vim.diagnostic.setqflist()<CR>]],  {"silent"}, "LSP add workspace folder")
map("n", [[<leader>E]], [[<CMD>lua vim.diagnostic.open_float()<CR>]], {"silent"}, "LSP diagnostics")
map("n", [[[e]], [[:lua vim.diagnostic.goto_prev{float = {border = "rounded"}};vim.cmd("norm! zz")<CR>]], {"silent"}, "Go to previous diagnostic symbol")
map("n", [[]e]], [[:lua vim.diagnostic.goto_prev{float = {border = "rounded"}};vim.cmd("norm! zz")<CR>]], {"silent"}, "Go to next diagnostic symbol")
map("n", [[[E]], [[:lua vim.diagnostic.goto_prev{float = {border = "rounded"}, severity = "Error"};vim.cmd("norm! zz")<CR>]], {"silent"}, "Go to previous error")
map("n", [[]E]], [[:lua vim.diagnostic.goto_prev{float = {border = "rounded"}, severity = "Error"};vim.cmd("norm! zz")<CR>]], {"silent"}, "Go to next error")
-- Colorcolumn
map("n", [[]C]], [[:noa windo set cc=80<CR>]], {"silent"}, "Turn on colorcolumn")
map("n", [[[C]], [[:noa windo set cc&<CR>]],   {"silent"}, "Turn off colorcolumn")
-- Quickfix
map("n", [[<leader>q]], [[<CMD>lua require("quickfix.toggle")(false)<CR>]], {"silent"}, "Toggle quickfix")
map("n", [[<leader>Q]], [[<CMD>lua require("quickfix.toggle")(true)<CR>]],  {"silent"}, "Close visible quickfix")
map("n", [[<C-q>g]], [[<CMD>cfirst<CR>zzzv]],    {"silent"}, "Go to first item in quickfix")
map("n", [[<C-q>G]], [[<CMD>clast<CR>zzzv]],     {"silent"}, "Go to last item in quickfix")
map("n", [[<C-q>n]], [[<CMD>cnext<CR>zzzv]],     {"silent"}, "Go to next item in quickfix")
map("n", [[<C-q>N]], [[<CMD>cprevious<CR>zzzv]], {"silent"}, "Go to previous item in quickfix")
map("n", [[<C-q>l]], [[<CMD>lua require("quickfix.convertToLoc")()<CR>]], {"silent"}, "Convert quickfix into location list")
map("n", [[<C-q>m]], [[<CMD>lua require("quickfix.message").main()<CR>]], {"silent"}, "Show messages in quickfix")
-- Expand region
map("n", [[<A-a>]], [[<CMD>lua require("expandRegion").expandShrink("n", 1)<CR>]],  {"silent"}, "Expand selection")
map("n", [[<A-s>]], [[<Nop>]], "which_key_ignore")
map("x", [[<A-a>]], [[:lua require("expandRegion").expandShrink(vim.fn.visualmode(), 1)<CR>]],  {"silent"}, "Expand selection")
map("x", [[<A-s>]], [[:lua require("expandRegion").expandShrink(vim.fn.visualmode(), -1)<CR>]], {"silent"}, "Shrink selection")
-- Interesting word {{{
-- TODO:Conceal word: https://github.com/inkarkat/vim-Concealer
map("n", [[<Plug>InterestingWordOperatorWordBoundary]], function ()
        return vim.fn.luaeval[[
        require("operator").expr(require("interestingWord").operatorWordBoundary,
        false,
        "<Plug>InterestingWordOperatorWordBoundary")
        ]]
end, {"expr", "silent"}, "Interesting word operator")
map("n", [[<Plug>InterestingWordOperatorNoWordBoundary]], function ()
        return vim.fn.luaeval[[
        require("operator").expr(require("interestingWord").operatorNoWordBoundary,
        false,
        "<Plug>InterestingWordOperatorNoWordBoundary")
        ]]
end, {"expr", "silent"}, "Interesting word operator")

map("x", [[<Plug>InterestingWordVisualWordBoundary]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>InterestingWordVisualWordBoundary", vim.v.register);

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>InterestingWordVisualWordBoundary");
    require("interestingWord").operatorWordBoundary(vMotion)<CR>]],
{"silent"}, "Mark selected as interesting words")
map("n", [[<Plug>InterestingWordVisualWordBoundary]], function ()
    vim.fn["repeat#setreg"](t"<Plug>InterestingWordVisualWordBoundary", vim.v.register)
    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0))

    local vMotion = require("operator").vMotion(true)
    table.insert(vMotion, "<Plug>InterestingWordVisualWordBoundary")
    require("interestingWord").operatorWordBoundary(vMotion)
end, {"silent"}, "Visual-repeat for interesting words")

map("x", [[<Plug>InterestingWordVisualNoWordBoundary]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>InterestingWordVisualNoWordBoundary", vim.v.register);

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>InterestingWordVisualNoWordBoundary");
    require("interestingWord").operatorNoWordBoundary(vMotion)<CR>]],
{"silent"}, "Mark selected as interesting words")
map("n", [[<Plug>InterestingWordVisualNoWordBoundary]], function ()
    vim.fn["repeat#setreg"](t"<Plug>InterestingWordVisualNoWordBoundary", vim.v.register)
    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0))

    local vMotion = require("operator").vMotion(true)
    table.insert(vMotion, "<Plug>InterestingWordVisualNoWordBoundary")
    require("interestingWord").operatorNoWordBoundary(vMotion)
end, {"silent"}, "Visual-repeat for interesting words")

map("n", [[gw]], [[<Plug>InterestingWordOperatorWordBoundary]],   "Highlight interesting word operator")
map("n", [[gW]], [[<Plug>InterestingWordOperatorNoWordBoundary]], "Highlight interesting word operator(ignore word boundary)")
map("x", [[gw]], [[<Plug>InterestingWordVisualWordBoundary]],     "Highlight selected as interesting words")
map("x", [[gW]], [[<Plug>InterestingWordVisualNoWordBoundary]],   "Highlight selected as interesting words(ignore word boundary)")

map("n", [[gww]], [[<CMD>lua require("interestingWord").reapplyColor()<CR>]], {"silent"}, "Recolor last interesting word")
map("n", [[<leader>w]], [[<CMD>lua require("interestingWord").clearColor()<CR>]],   {"silent"}, "Clear interesting word")
map("n", [[<leader>W]], [[<CMD>lua require("interestingWord").restoreColor()<CR>]], {"silent"}, "Restore interesting word")
-- }}} Interesting word
-- Zeal query {{{
map("n", [[<Plug>ZealOperator]], function ()
    return vim.fn.luaeval[[
    require("operator").expr(
        require("zeal").zeal,
        false,
        "<Plug>ZealOperator")
    ]]
end, {"silent", "expr"}, "Zeal look up operator")

map("n", [[<Plug>ZealOperatorGlobal]], function ()
    return vim.fn.luaeval[[
    require("operator").expr{
        require("zeal").zealGlobal,
        false,
        "<Plug>ZealOperatorGlobal"}
    ]]
end, {"silent", "expr"}, "Zeal look up universally operator")

map("x", [[<Plug>ZealVisual]],
luaRHS[[:lua
    vim.fn["repeat#setreg"](t"<Plug>ZealVisual", vim.v.register);

    local vMotion = require("operator").vMotion(true);
    table.insert(vMotion, "<Plug>ZealVisual");
    require("zeal").zeal(vMotion)<CR>]],
{"silent"}, "Zeal look up selected")

map("n", [[<Plug>ZealVisual]], function ()
    vim.fn["repeat#setreg"](t"<Plug>ZealVisual", vim.v.register)
    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0))

    local vMotion = require("operator").vMotion(true)
    table.insert(vMotion, "<Plug>ZealVisual")
    require("zeal").zeal(vMotion)
end, {"silent"}, "Zeal look up selected")

map("n", [[gz]], [[<Plug>ZealOperator]],       "Zeal look up...")
map("n", [[gZ]], [[<Plug>ZealOperatorGlobal]], "Zeal look up...universally")
map("x", [[Z]],  [[<Plug>ZealVisual]], "Zeal look up selected")
-- }}} Zeal query
-- HistoryStartup
map("n", [[<C-s>]], [[<CMD>lua require("historyStartup").display(true)<CR>]], {"silent"}, "Enter HistoryStartup")
-- Extraction {{{
-- map("n", [[<Plug>RefactorOperator]], function ()
    -- return vim.fn.luaeval [[require("RefactorOperator").expr()]]
-- end, {"silent", "expr"}, "Refactor operator")
map("n", [[<Plug>Extract]], function ()
    return vim.fn.luaeval[[
    require("operator").expr(
        require("extraction").main,
        false,
        "<Plug>Extract")
    ]]
end, {"silent", "expr"}, "Extract operator")
map("n", [[gf]], [[<Plug>Extract]], "Extract operator")
map("n", [[gF]], [[gf]], {"noremap"}, "Go to file")
-- }}} Extraction
map("n", [[<C-g>]],
[[:lua print(vim.api.nvim_exec2("file!", {output = true}).output .. " 🖵  CWD: " .. vim.fn.getcwd())<CR>]],
{"silent"}, "Display file info")
map("n", [[<S-Tab>]], function()
    local newWidth = vim.bo.shiftwidth == 4 and 2 or 4
    vim.bo.shiftwidth = newWidth; vim.bo.tabstop = newWidth; vim.bo.softtabstop = newWidth
    vim.api.nvim_echo({ { string.format("Shiftwidth has been changed to %d", newWidth), "Moremsg" } }, true, {})
end, "Change tab size")
-- Delete & Change & Replace & Exchange {{{
-- Delete
map("n", [[dj]], [[<Nop>]], "which_key_ignore")
map("n", [[dk]], [[<Nop>]], "which_key_ignore")
map("n", [[<Plug>DeleteUnderForward]],
    [[:lua require("changeUnder").init("diw", 1, "<Plug>DeleteUnderForward")<CR>]],
    {"silent"}, "Delete the whole word under cursor, then highlight it forward")
map("n", [[<Plug>DeleteUnderBackward]],
    [[:lua require("changeUnder").init("diw", 0, "<Plug>DeleteUnderBackward")<CR>]],
    {"silent"}, "Delete the whole word under cursor, then highlight it backward")
map("n", [[dn]], [[<Plug>DeleteUnderForward]], "Delete the whole word under cursor, then highlight it forward")
map("n", [[dN]], [[<Plug>DeleteUnderBackward]], "Delete the whole word under cursor, then highlight it backward")
map("n", [[d<Space>]], [[<CMD>call setline(".", "")<CR>]],  {"silent"}, "Empty current line,")
-- Change under cursor
map("n", [[cn]], [[v:hlsearch? "cgn" : "*``cgn"]], {"noremap", "expr"}, "Change whole word under cursor, then highlight it forward")
map("n", [[cN]], [[v:hlsearch? "cgN" : "#``cgN"]], {"noremap", "expr"}, "Change whole word under cursor, then highlight it backward")
-- Replace
map("n", [[<Plug>ReplaceOperatorInplace]], function ()
    return vim.fn.luaeval [[require("replace").expr(true, true)]]
end, {"silent", "expr"}, "Replace operator and restore the cursor position")

map("n", [[<Plug>ReplaceOperator]], function ()
    return vim.fn.luaeval [[require("replace").expr(false, false)]]
end, {"silent", "expr"}, "Replace operator")

map("n", [[<Plug>ReplaceExpr]],
    [[<CMD>let g:ReplaceExpr=getreg("=")<Bar>exec "norm!" . v:count1 . "."<CR>]],
    {"silent"}, "Replace expression"
)

map("n", [[<Plug>ReplaceCurLine]], function ()
    require("replace").saveCountReg()

    vim.fn["repeat#setreg"](t"<Plug>ReplaceCurLine", vim.v.register)

    if require("replace").regType == "=" then
        vim.g.ReplaceExpr = vim.fn.getreg("=")
    end

    require("replace").operator{"line", "V", "<Plug>ReplaceCurLine", true}
end, {"noremap", "silent"}, "Replace current line")

-- NOTE: function passed in to arg will ignore current selected region

-- map("x", [[<Plug>ReplaceVisual]], function ()
    -- require("replace").saveCountReg()

    -- vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register)

    -- if require("replace").regType == "=" then
        -- vim.g.ReplaceExpr = vim.fn.getreg("=")
    -- end

    -- local vMotion = require("operator").vMotion(false)
    -- table.insert(vMotion, "<Plug>ReplaceVisual")
    -- require("replace").operator(vMotion)
-- end, {"noremap", "silent"}, "Replace selected")

map("x", [[<Plug>ReplaceVisual]],
    luaRHS[[
    :lua require("replace").saveCountReg();

    vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register);

    if require("replace").regType == "=" then
        vim.g.ReplaceExpr = vim.fn.getreg("=")
    end;

    local vMotion = require("operator").vMotion(false);
    table.insert(vMotion, "<Plug>ReplaceVisual");
    require("replace").operator(vMotion)<CR>
    ]],
    {"noremap", "silent"}, "Replace selected")

map("n", [[<Plug>ReplaceVisual]], function ()
    require("replace").saveCountReg()

    vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register)

    if require("replace").regType == "=" then
        vim.g.ReplaceExpr = vim.fn.getreg("=")
    end

    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0))

    local vMotion = require("operator").vMotion(false)
    table.insert(vMotion, "<Plug>ReplaceVisual")
    require("replace").operator(vMotion)
end, {"noremap", "silent"}, "Visual-repeat for replaced selected")

map("n", [[gr]],  [[<Plug>ReplaceOperatorInplace]], "Replace operator and restore the cursor position")
map("n", [[gru]], [[<Plug>ReplaceOperator]],        "Replace operator")
map("n", [[grr]], [[<Plug>ReplaceCurLine]],         "Replace current line")
map("x", [[R]],   [[<Plug>ReplaceVisual]],          "Replace selected")

map("n", [[<Plug>ReplaceUnderForward]],
    [[:lua require("changeUnder").init("gruiw", 1, "<Plug>ReplaceUnderForward")<CR>]],
    {"silent"}, "Replace the whole word under cursor, then highlight it forward")
map("n", [[<Plug>ReplaceUnderBackward]],
    [[:lua require("changeUnder").init("gruiw", -1, "<Plug>ReplaceUnderBackward")<CR>]],
    {"silent"}, "Replace the whole word under cursor, then highlight it backward")
map("n", [[grn]], [[<Plug>ReplaceUnderForward]], "Replace the whole word under cursor, then highlight it forward")
map("n", [[grN]], [[<Plug>ReplaceUnderBackward]], "Replace the whole word under cursor, then highlight it backward")
-- Exchange
map("n", [[<Plug>exchangeOperatorInplace]], function ()
    return vim.fn.luaeval [[require("exchange").expr(true, true)]]
end, {"silent", "expr"}, "Exchange operator and restore the cursor position")
map("n", [[gx]],  [[<Plug>exchangeOperatorInplace]], "Exchange operator and restore the cursor position")
map("n", [[gxc]], [[<CMD>lua require("exchange").clear()<CR>]], "Exchange clear")

map("n", [[gvr]], function()
    require("selection").extmarkSelect(
        require("replace").lastReplaceNs,
        require("replace").lastReplaceExtmark,
        require("replace").lastReplaceLinewise)
end, "Select last yank")
-- }}} Delete & Change & Replace & Exchange
-- Search & Jumping {{{
-- In case of mistouching
-- Inquiry word
map("n", [[<leader>i]], [=[[I]=], "Inquiry word under cursor")
map("x", [[<leader>i]], [[:lua vim.cmd("noa g#\\V" .. string.gsub(require("selection").get("string", false), "\\", "\\\\") .. "#number")<CR>]], {"silent"}, "Inquiry selected words")
-- Fast mark restore
map("n", [[M]], [[<CMD>lua require("jump.search").centerHop("`m", true, false)<CR>]], "Restore mark M")
-- Changelist/Jumplist jumping
map("n", [[<A-o>]], [[<CMD>lua require("jump.search").centerHop("g;", false, false)<CR>]], {"silent"}, "Older change")
map("n", [[<A-i>]], [[<CMD>lua require("jump.search").centerHop("g,", false, false)<CR>]], {"silent"}, "Newer change")
map("n", [[<C-o>]], function()
    require("jump.search").centerHop(function()
        require("jump.jumplist").go("n", false, "local")
    end, true, true)
end, {"silent"}, "Older local jump")
map("n", [[<C-i>]], function()
    require("jump.search").centerHop(function()
        require("jump.jumplist").go("n", true, "local")
    end, true, true)
end, {"silent"}, "Newer local jump")
map("x", [[<C-o>]], luaRHS[[:lua
    require("jump.jumplist").visualMode = vim.fn.visualmode();
    require("jump.search").centerHop(function()
        require("jump.jumplist").go(vim.fn.visualmode(), false, "local")
    end, true, true)<CR>
]], {"silent"}, "Older local jump")
map("x", [[<C-i>]], luaRHS[[:lua
    require("jump.jumplist").visualMode = vim.fn.visualmode();
    require("jump.search").centerHop(function()
        require("jump.jumplist").go(vim.fn.visualmode(), true, "local")
    end, true, true)<CR>
]], {"silent"}, "Newer local jump")
map("n", [[g<C-o>]], function()
    require("jump.search").centerHop(function()
        require("jump.jumplist").go("n", false, "buffer")
    end, true, true)
end, {"silent"}, "Older buffer jump")
map("n", [[g<C-i>]], function()
    require("jump.search").centerHop(function()
        require("jump.jumplist").go("n", true, "buffer")
    end, true, true)
end, {"silent"}, "Newer buffer jump")
-- Swap default mapping
map("n", [[*]],  [[<CMD>lua require("jump.search").cword("*", false)<CR>]],  {"noremap", "silent"}, "Search <cword> forward")
map("n", [[#]],  [[<CMD>lua require("jump.search").cword("#", false)<CR>]],  {"noremap", "silent"}, "Search <cword> back")
map("n", [[g*]], [[<CMD>lua require("jump.search").cword("*", true)<CR>]], {"noremap", "silent"}, "Search <cWORD> forward")
map("n", [[g#]], [[<CMD>lua require("jump.search").cword("#", true)<CR>]], {"noremap", "silent"}, "Search <cWORD> backward")
-- Search visual selected
map("x", [[/]], [[:lua require("jump.search").searchSelected("/")<CR>]], {"silent"}, "Search selected forward")
map("x", [[?]], [[:lua require("jump.search").searchSelected("?")<CR>]], {"silent"}, "Search selected backward")
map("x", [[*]], [[/]], "Search selected forward")
map("x", [[#]], [[?]], "Search selected backward")
-- Regex very magic
map("n", [[n]], [[<CMD>lua require("jump.search").cycle("n")<CR>]], {"silent"}, "Cycle through search result forward")
map("n", [[N]], [[<CMD>lua require("jump.search").cycle("N")<CR>]], {"silent"}, "Cycle through search result backward")
-- Disable highlight search & Exit visual mode
map("",  [[<C-l>]], [[<Nop>]], "which_key_ignore")
map("",  [[<leader>H]], [[<C-l>]],                           {"noremap", "silent"}, "Refresh screen")
map("n", [[<leader>h]], [[<CMD>noh | echo<CR>]],             {"silent"}, "Clear highlight")
map("x", [[<leader>h]], [[<CMD>exec "norm! \<lt>Esc>"<CR>]], {"silent"}, "Disable highlight")
-- Matchit
map("", [[<C-m>]], [[%]], {"silent"}, "Go to match parenthesis")
-- Visual selection
map("n", [[gvv]], [[gv]], {"noremap"}, "Select previous selected region")
map("n", [[gvo]], [[<CMD>lua require("selection").corner(-1)<CR>]], {"silent"}, "Go to opposite of the selection")
map({"n", "x"}, [[<A-v>]], [[<C-q>]], {"noremap"}, "Visual Block Mode")
map({"n", "x"}, [[<C-q>]], [[<Nop>]], "which_key_ignore")
-- }}} Search & Jumping
-- Scratch file
map("n", [[<C-n>]], [[<CMD>new<CR>]], {"silent"}, "New buffer")
-- Open/Search in browser
map("n", [[gl]], [[<CMD>lua require("getLink").main()<CR>]], {"silent"}, "Open link")
map("x", [[gl]], [[:lua require("getLink").main(require("selection").get("string", false))<CR>]], {"silent"}, "Open selected as link")
-- Interrupt
map("n", [[<C-A-c>]], [[<CMD>call interrupt()<CR>]], {"noremap", "silent"}, "Interrupt")
-- Line end/start
map("", [[H]], [[^]], "Start of line(non-blank)")
map("", [[L]], [[$]], "End of line")
-- Non-blank last character
map("", [[g$]], [[g_]], {"noremap"}, "End of line(non-blank)")
-- Trailing character {{{
map("n", [[g.]], [[<CMD>lua require("trailingChar").main("n", ".")<CR>]],  {"silent"}, "Add trailing .")
map("x", [[g.]], [[:lua require("trailingChar").main("v", ".")<CR>]],      {"silent"}, "Add trailing .")
map("n", [[g,]], [[<CMD>lua require("trailingChar").main("n", ",")<CR>]],  {"silent"}, "Add trailing ,")
map("x", [[g,]], [[:lua require("trailingChar").main("v", ",")<CR>]],      {"silent"}, "Add trailing ,")
map("n", [[g;]], [[<CMD>lua require("trailingChar").main("n", ";")<CR>]],  {"silent"}, "Add trailing ;")
map("x", [[g;]], [[:lua require("trailingChar").main("v", ";")<CR>]],      {"silent"}, "Add trailing ;")
map("n", [[g:]], [[<CMD>lua require("trailingChar").main("n", ":")<CR>]],  {"silent"}, "Add trailing :")
map("x", [[g:]], [[:lua require("trailingChar").main("v", ":")<CR>]],      {"silent"}, "Add trailing :")
map("n", [[g"]], [[<CMD>lua require("trailingChar").main("n", "\"")<CR>]], {"silent"}, 'Add trailing "')
map("x", [[g"]], [[:lua require("trailingChar").main("v", "\"")<CR>]],     {"silent"}, 'Add trailing "')
-- map("n", [[g']], [[<CMD>lua require("trailingChar").main("n", "'")<CR>]],  {"silent"}, "Add trailing '")
-- map("x", [[g']], [[:lua require("trailingChar").main("v", "'")<CR>]],      {"silent"}, "Add trailing '")
map("n", [[g(]], [[<CMD>lua require("trailingChar").main("n", "(")<CR>]],  {"silent"}, "Add trailing (")
map("x", [[g(]], [[:lua require("trailingChar").main("v", "(")<CR>]],      {"silent"}, "Add trailing (")
map("n", [[g)]], [[<CMD>lua require("trailingChar").main("n", ")")<CR>]],  {"silent"}, "Add trailing )")
map("x", [[g)]], [[:lua require("trailingChar").main("v", ")")<CR>]],      {"silent"}, "Add trailing )")
map("n", [[g>]], [[<CMD>lua require("trailingChar").main("n", ">")<CR>]],  {"silent"}, "Add trailing >")
map("n", [[g<C-CR>]], [[<CMD>call append(line("."),   repeat([""], v:count1))<CR>]], {"silent"}, "Add new line below")
map("n", [[g<S-CR>]], [[<CMD>call append(line(".")-1, repeat([""], v:count1))<CR>]], {"silent"}, "Add new line above")
map("n", [[g<CR>]],   [[<CMD>lua require("breakLine").main()<CR>]], {"silent"}, "Break line at cursor")
-- }}} Trailing character

-- PageUp/PageDown
map("", [[<C-f>]], [[<Nop>]], "which_key_ignore")
map("", [[<C-h>]], [[<Nop>]], "which_key_ignore")
map({"n", "x"}, [[<C-e>]], [[<C-y>]], {"noremap"}, "Scroll up")
map({"n", "x"}, [[<C-d>]], [[<C-e>]], {"noremap"}, "Scroll down")
map("t", [[<C-e>]], [[<C-\><C-n><C-y>]], "Scroll up")
map("t", [[<C-d>]], [[<C-\><C-n><C-d>]], "Scroll down")

map({"n", "x"}, [[<A-e>]], [[<PageUp>]],      "Scroll one window up")
map({"n", "x"}, [[<A-d>]], [[<PageDown>]],    "Scroll one window down")
map("t", [[<A-e>]], [[<C-\><C-n><PageUp>]],   "Scroll one window up")
map("t", [[<A-d>]], [[<C-\><C-n><PageDown>]], "Scroll one window down")

-- Macro
map("n", [[<A-q>]], [[q]], {"noremap"}, "Macro")

-- Messages

map({"n", "x"}, [[g<]], [[:s#^\s*\ze\S## | noh<CR>]], {"silent"}, "Clear all indents")
map("n", [[gm]], [[g<]], {"noremap"}, "Clear messages")
map("n", [[gM]], [[<CMD>messages<CR>]], {"silent"}, "Clear messages")
map("n", [[<leader>m]], [[<CMD>execute 'messages clear<Bar>echohl Moremsg<Bar>echo "Message clear"<Bar>echohl None'<CR>]], "Clear messages")

-- Register
map({"n", "x"}, [[<leader>']], [[:lua require("register").clear()<CR>]], {"silent"}, "Clear registers")
map("n", [[g']], [[<CMD>lua require("register").insertPrompt("n")<CR>]], {"silent"}, "Registers in prompt");
map("i", [[<C-r><C-r>]], [[<C-\><C-o><CMD>lua require("register").insertPrompt("i")<CR>]], {"silent"}, "Registers in prompt")

-- Buffer & Window & Tab{{{
-- Smart quit
map("n", [[q]],     [[<CMD>lua require("buf").close("window")<CR>]],    {"silent"}, "Close window")
map("n", [[Q]],     [[<CMD>lua require("buf").close("buffer")<CR>]],    {"silent"}, "Close buffer")
map("n", [[<C-u>]], [[<CMD>lua require("buf").restoreClosedBuf()<CR>]], {"silent"}, "Restore last closed buffer")
-- Window
map("n", [[<C-w>V]], [[<CMD>wincmd o | wincmd v<CR>]], {"silent"}, "Split only current window vertically")
map("n", [[<C-w>S]], [[<CMD>wincmd o | wincmd s<CR>]], {"silent"}, "Split only current window vertically")
map("i", [[<C-w>k]], [[<C-\><C-n><C-w>k]], {"noremap"}, "Window above")
map("i", [[<C-w>j]], [[<C-\><C-n><C-w>j]], {"noremap"}, "Window below")
map("i", [[<C-w>h]], [[<C-\><C-n><C-w>h]], {"noremap"}, "Window left")
map("i", [[<C-w>l]], [[<C-\><C-n><C-w>l]], {"noremap"}, "Window right")

--TODO: <C-w>.
map("n", [[<C-w>t]], [[<C-w>T]], {"noremap"}, "Move current window to new tab")
map("n", [[<C-w>T]], [[<C-w>t]], {"noremap"}, "Move current window to top left")
map("n", [[<C-w>b]], [[<Nop>]],  {"noremap"}, "which_key_ignore")
map("n", [[<C-w>B]], [[<C-w>b]], {"noremap"}, "Move current window to bottom right")

map({"n", "x"}, [[<A-=>]],  [[<CMD>wincmd +<CR>]],       {"silent"}, "Increase window size")
map("i",        [[<A-=>]],  [[<C-\><C-O>:wincmd +<CR>]], {"silent"}, "Increase window size")
map({"n", "x"}, [[<A-->]],  [[<CMD>wincmd -<CR>]],       {"silent"}, "Decrease window size")
map("i",        [[<A-->]],  [[<C-\><C-O>:wincmd -<CR>]], {"silent"}, "Decrease window size")

-- Buffers
map("n", [[<C-w>O]], [[<CMD>lua require("buf").closeOther()<CR>]], {"silent"}, "Wipe other buffer")
map("n", [[<C-Tab>]],   [[<CMD>lua require("buf.action.cycle").init(1)<CR>]],  {"silent"}, "Next buffer")
map("n", [[<C-S-Tab>]], [[<CMD>lua require("buf.action.cycle").init(-1)<CR>]], {"silent"}, "Previous buffer")
map("n", [[<A-,>]],     [[<CMD>lua require("buf.action.cycle").init(-1)<CR>]], {"silent"}, "Previous buffer")
map("n", [[<A-.>]],     [[<CMD>lua require("buf.action.cycle").init(1)<CR>]],  {"silent"}, "Next buffer")
-- Tab
map("n", [[<C-t>,]], [[<CMD>tabp | echo "tabpage " . tabpagenr()<CR>]], {"silent"}, "Previous tab")
map("n", [[<C-t>.]], [[<CMD>tabn | echo "tabpage " . tabpagenr()<CR>]], {"silent"}, "Next tab")
map("n", [[<C-t>o]], [[<CMD>tabonly<CR>]],  {"silent"}, "Tab only")
-- }}} Buffer & Window & Tab
-- Folding {{{
map("",  [[zj]], [[<Nop>]], "which_key_ignore")
map("",  [[zk]], [[<Nop>]], "which_key_ignore")
map("n", [[dz]], [[<CMD>lua require("foldmarker").modifyCurrentMarkerRegion(false, false)<CR>]], {"silent"}, "Delete folds")
map("n", [[dZ]], [[<CMD>lua require("foldmarker").modifyCurrentMarkerRegion(true,  false)<CR>]], {"silent"}, "Delete fold markers")
map("n", [[cz]], [[<CMD>lua require("foldmarker").modifyCurrentMarkerRegion(false, true)<CR>]],  {"silent"}, "Change fold")
map("n", [[zd]], [[<Nop>]], "which_key_ignore")
map("n", [[g{]], [[<CMD>lua require("trailingChar").main("n", "{")<CR>]], {"silent"}, "Add fold marker start")
map("x", [[g{]], [[:lua require("trailingChar").main("v", "{")<CR>]],     {"silent"}, "Add fold marker start")
map("n", [[g}]], [[<CMD>lua require("trailingChar").main("n", "}")<CR>]], {"silent"}, "Add fold marker end")
map("x", [[g}]], [[:lua require("trailingChar").main("v", "}")<CR>]],     {"silent"}, "Add fold marker end")

-- map("n", [[<leader>z]], [[<CMD>lua require("foldmarker").highlightCurrentMarkerRegion()<CR>]], {"silent"}, "Highlight current fold marker")
map("", [[zm]], [[zM]],   {"noremap"}, "Close all folds recursively")
map("", [[zr]], [[zRzz]], {"noremap"}, "Open all folds recursively")
map("", [[zM]], [[zm]],   {"noremap"}, "Close folds recursively")
map("", [[zR]], [[zrzz]], {"noremap"}, "Open folds recursively")
map("", [[zA]], [[za]],   {"noremap"}, "Toggle current fold")
map("", [[za]], [[:lua require("foldmarker").snap("norm! zA", true, 0.5)<CR>]],
    {"silent"}, "Snap to closest fold then toggle it recursively")
map("",  [[<leader><Space>]], [[:lua require("foldmarker").snap("norm! za", true, 0.5)<CR>]],
    {"silent"}, "Snap to closest fold then toggle it")
-- }}} Folding

-- Paste mode
map({"i","n"}, [[<F3>]], function ()
    if vim.o.paste then
        vim.api.nvim_echo({{"Paste mode off", "Moremsg"}}, false, {})
        vim.opt.paste = false
    else
        vim.api.nvim_echo({{"Paste mode on", "Moremsg"}}, false, {})
        vim.opt.paste = true
    end
end, "Toggle paste mode")
-- Inplace join
map("n", [[J]], function ()
    vim.cmd("norm! m`" .. vim.v.count1 .. "J``")
end, {"noremap"}, "Join line in place")
-- Inplace yank
map("", [[<Plug>InplaceYank]], function ()
   return vim.fn.luaeval[[require("operator").expr(require("yankPut").inplaceYank, false, "<Plug>InplaceYank")]]
end, {"expr", "silent"}, "Yank operator")

map("",  [[y]], [[<Plug>InplaceYank]], "Yank operator")
map("n", [[Y]], [[yy]], "Yank line")
-- Inplace put
map("n", [[p]], [[:lua require("yankPut").inplacePut("n", "p", false)<CR>]], {"silent"}, "Put after")
map("x", [[p]], [[:lua require("yankPut").inplacePut("v", "p", false)<CR>]], {"silent"}, "Put after")
map("n", [[P]], [[:lua require("yankPut").inplacePut("n", "P", false)<CR>]], {"silent"}, "Put before")
map("x", [[P]], [[:lua require("yankPut").inplacePut("v", "P", false)<CR>]], {"silent"}, "Put before")
-- Highlight New Paste Content
local yp = require("yankPut")
map("n", [[gvy]], function()
    require("selection").extmarkSelect(yp.lastYankNs, yp.lastYankExtmark, yp.lastYankLinewise)
end, "Select last yank")
map("n", [[gvp]], function()
    require("selection").extmarkSelect(yp.lastPutNs, yp.lastPutExtmark, yp.lastPutLinewise)
end, "Select last put")
-- Convert put
map("n", [[cp]], [[:lua require("yankPut").inplacePut("n", "p", true)<CR>]], {"silent"}, "Convert put after")
map("n", [[cP]], [[:lua require("yankPut").inplacePut("n", "P", true)<CR>]], {"silent"}, "Convert put before")
-- Put from registers 0
map("n", [[<leader>p]],  [["0p]],  "Put after from register 0")
map("n", [[<leader>P]],  [["0P]],  "Put after from register 0")
map("n", [[<leader>cp]], [["0cp]], "Convert put after from register 0")
map("n", [[<leader>cP]], [["0cP]], "Convert put after from register 0")
-- Mimic the VSCode move/copy line up/down behavior {{{
-- Move line
map("i", [[<A-j>]], [[<C-\><C-o><CMD>lua require("yankPut").VSCodeLineMove("n", "down")<CR>]], {"silent"}, "Move line down")
map("i", [[<A-k>]], [[<C-\><C-o><CMD>lua require("yankPut").VSCodeLineMove("n", "up")<CR>]],   {"silent"}, "Move line up")
map("n", [[<A-j>]], [[<CMD>lua require("yankPut").VSCodeLineMove("n", "down")<CR>]],           {"silent"}, "Move line down")
map("n", [[<A-k>]], [[<CMD>lua require("yankPut").VSCodeLineMove("n", "up")<CR>]],             {"silent"}, "Move line up")
map("x", [[<A-j>]], [[:lua require("yankPut").VSCodeLineMove("v", "down")<CR>]],               {"silent"}, "Move line down")
map("x", [[<A-k>]], [[:lua require("yankPut").VSCodeLineMove("v", "up")<CR>]],                 {"silent"}, "Move line up")
-- Copy line
map("i", [[<A-S-j>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "down")<CR>]], {"silent"}, "Copy line down")
map("i", [[<A-S-k>]], [[<C-\><C-o>:lua require("yankPut").VSCodeLineYank("n", "up")<CR>]],   {"silent"}, "Copy line up")
map("n", [[<A-S-j>]], [[<CMD>lua require("yankPut").VSCodeLineYank("n", "down")<CR>]],       {"silent"}, "Copy line down")
map("n", [[<A-S-k>]], [[<CMD>lua require("yankPut").VSCodeLineYank("n", "up")<CR>]],         {"silent"}, "Copy line up")
map("x", [[<A-S-j>]], [[:lua require("yankPut").VSCodeLineYank("v", "down")<CR>]],           {"silent"}, "Copy line down")
map("x", [[<A-S-k>]], [[:lua require("yankPut").VSCodeLineYank("v", "up")<CR>]],             {"silent"}, "Copy line up")
-- }}} Mimic the VSCode move/copy line up/down behavior

-- Convert \ into /
map("n", [[g/]], [[m`:s#\\#\/#e<CR>:noh<CR>g``]],   {"noremap", "silent"}, [[Convert \ to /]])
map("n", [[g\]], [[m`:s#\/#\\\\#e<CR>:noh<CR>g``]], {"noremap", "silent"}, [[Convert / to \]])
-- Mode: Terminal {{{
map("t", [[<A-n>]],      [[<C-\><C-n>]], "Enter Normal mode")
map("n", [[<C-`>]],      [[<CMD>lua require("terminal").terminalToggle()<CR>]], {"silent"}, "Terminal toggle")
map("n", [[<leader>t]],  [[<CMD>lua require("terminal").terminalToggle()<CR>]], {"silent"}, "Terminal toggle")
map("t", [[<C-`>]],      [[<A-n><CMD>lua require("terminal").terminalToggle()<CR>]], {"silent"}, "Toggle Terminal")
map("t", [[<A-h>]],      [[<A-n><A-h>]], "Previous buffer")
map("t", [[<A-l>]],      [[<A-n><A-l>]], "Next buffer")
map("t", [[<A-C-h>]],    [[<A-n><A-C-h>]], "Previous tab")
map("t", [[<A-C-l>]],    [[<A-n><A-C-l>]], "Next tab")
map("t", [[<C-BS>]],     [[<C-w>]], {"noremap"}, "Delete word before")
map("t", [[<C-r>]],      [['\<A-n>"' . nr2char(getchar()) . 'pi']], {"expr"}, "Insert from register")
map("t", [[<C-w>k]],     [[<A-n><C-w>k]], "Window above")
map("t", [[<C-w>j]],     [[<A-n><C-w>j]], "Window below")
map("t", [[<C-w>h]],     [[<A-n><C-w>h]], "Window left")
map("t", [[<C-w>l]],     [[<A-n><C-w>l]], "Window right")
map("t", [[<C-w>w]],     [[<A-n><C-w>w]], "Next window")
map("t", [[<C-w>W]],     [[<A-n><C-w>W:startinsert<CR>]], {"silent"}, "Previous window")
map("t", [[<C-w><C-w>]], [[<A-n><C-w><C-w>]], "Next window")
map("t", [[<C-w>=]],     [[<A-n><C-w>=:startinsert<CR>]], {"silent"}, "Make all window equal")
map("t", [[<C-w>o]],     [[<A-n><C-w>o:startinsert<CR>]], {"silent"}, "Close other windows")
map("t", [[<C-w>H]],     [[<A-n><C-w>H:startinsert<CR>]], {"silent"}, "Move the current window to the far left")
map("t", [[<C-w>L]],     [[<A-n><C-w>L:startinsert<CR>]], {"silent"}, "Move the current window to the far right")
map("t", [[<C-w>J]],     [[<A-n><C-w>J:startinsert<CR>]], {"silent"}, "Move the current window to the bottommost left")
map("t", [[<C-w>K]],     [[<A-n><C-w>K:startinsert<CR>]], {"silent"}, "Move the current window to the topmost left")
-- }}} Mode: Terminal
-- Mode: Commandline & Insert {{{
map("i", [[<C-[>]], [[<C-[>l]], {"noremap"}, "which_key_ignore")
if _G._os_uname.machine == "aarch64" then
    map("i", [[jj]], [[<C-[>]], "Exit insert mode")
end
-- Insert
map("i", [[<S-Tab>]], [[<C-d>]], {"noremap"}, "Delete indent")
map("i", [[<A-[>]],   [[<C-d>]], {"noremap"}, "Delete indent")
map("i", [[<A-]>]],   [[<C-t>]], {"noremap"}, "Add indent")
map("i", [[<C-k>]],   [[pumvisible() ? "\<C-e>\<Up>" : "\<Up>"]],     {"noremap", "expr"}, "Move cursor up")
map("i", [[<C-j>]],   [[pumvisible() ? "\<C-e>\<Down>" : "\<Down>"]], {"noremap", "expr"}, "Move cursor down")
map("i", [[<C-CR>]],  [[pumvisible() ? "\<C-e>\<CR>" : "\<CR>"]],     {"noremap", "expr"}, "Add new line below")
map("i", [[<S-CR>]],  [[<ESC>O]], "Add new line above")
map("i", [[<C-.>]],   [[<C-a>]], {"noremap"}, "Insert previous insert character")
map("i", [[<C-BS>]],  [[<C-w>]], {"noremap"}, "Delete word before")
map("i", [[<C-y>]],   [[pumvisible() ? "\<C-e>\<C-y>" : "\<C-y>"]], {"noremap", "expr"}, "Insert character from above")
map("i", [[<A-y>]],   [[<C-x><C-l>]], {"noremap"}, "Insert from sentence")
map("i", [[,]], [[,<C-g>u]], {"noremap"}, "which_key_ignore")
map("i", [[.]], [[.<C-g>u]], {"noremap"}, "which_key_ignore")
map("i", [[!]], [[!<C-g>u]], {"noremap"}, "which_key_ignore")
map("i", [[*]], [[*<C-g>u]], {"noremap"}, "which_key_ignore")
-- Navigation
map("c", [[<C-a>]],  [[<Home>]],              "Move cursor to the start")
map("i", [[<C-a>]],  [[<C-o>I]], {"noremap"}, "Move cursor to the start")
map("!", [[<C-e>]],  [[<End>]],               "Move cursor to the end")
map("!", [[<C-h>]],  [[<Left>]],              "Move cursor to one character left")
map("!", [[<C-l>]],  [[<Right>]],             "Move cursor to one character right")
map("c", [[<C-b>]],  [[<C-Left>]],            "Move cursor to one word backward")
map("i", [[<C-b>]],  [[<C-o>b]], {"noremap"}, "Move cursor to one word backward")
map("!", [[<C-d>]],  [[<Del>]],               "Delete character to the right")
map("!", [[<C-w>]],  [[<C-Right>]],           "Move cursor to one word forward")
map("i", [[<C-w>W]], [[<C-Right>]],           "Move cursor to one WORD forward")
map("i", [[<C-w>w]], [[<C-o>w]], {"noremap"}, "Move cursor to one word forward")
-- Commandline
map("c", [[<C-BS>]],  [[<C-\>e(RemoveLastPathComponent())<CR>]], "Delete word before")
map("c", [[<C-j>]], [[<Down>]], "Move cursor down")
map("c", [[<C-k>]], [[<Up>]], "Move cursor up")
map("c", [[<A-l>]], [[<C-d>]],  {"noremap"}, "List more commands")
map("c", [[<A-e>]], [[<C-\>e]], {"noremap"}, "Evaluate in Vimscript")
-- }}} Mode: Commandline & Insert
