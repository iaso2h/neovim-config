local vim = vim
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

-- let &path.="src/include,/usr/include/AL,"
if vim.fn.executable('rg') == 1 then
    vim.o.grepprg = 'rg --vimgrep'
    vim.o.grepformat = '%f:%l:%c:%m'
end

-- Basic settings {{{
local optsLocal = {
    autoindent    = "bo",
    cindent       = "bo",
    expandtab     = "bo",
    cinkeys       = "bo",
    cinoptions    = "bo",
    cinwords      = "bo",
    shiftwidth    = "bo",
    syntax        = "bo",
    tabstop       = "bo",
    textwidth     = "bo",
    concealcursor = "wo",
    conceallevel  = "wo",
    cursorline    = "wo",
    fillchars     = "wo",
    number        = "wo",
    scrolloff     = "wo",
    signcolumn    = "wo",
    winhighlight  = "wo",
}

vim.g.winminheight = 2

local opts = {
    autoindent = true, cindent = true, expandtab = true, shiftround = true, shiftwidth=4, softtabstop=4, tabstop=4,
    clipboard      = "unnamed",
    cmdheight      = 2,
    complete       = ".,w,b,u,t,kspell,i,d,t",
    completeopt    = "menuone,noselect,noinsert",
    conceallevel   = 0,
    concealcursor  = "nc",
    cpoptions      = vim.o.cpoptions .. "q",
    cursorline     = true,
    fileencodings  = "utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1",
    diffopt        = "context:10000,filler,closeoff,vertical,algorithm:patience",
    fileignorecase = true,
    fillchars      = "fold:-,vert:╎",
    foldcolumn = "auto:4", signcolumn = "auto:4", foldmethod = "expr", foldexpr = "EnhanceFoldExpr()",
    gdefault       = true,
    hidden         = true,
    ignorecase     = true, smartcase = true,
    inccommand     = "nosplit",
    listchars      = "tab:>-,precedes:❮,extends:❯,trail:-,nbsp:%,eol:↴",
    langmenu       = "en",
    lazyredraw     = true,
    matchpairs     = vim.o.matchpairs .. ",<:>,《:》,（:）,【:】,“:”,‘:’",
    mouse          = "a",
    joinspaces     = false,
    number         = true,
    path           = vim.o.path .. "**",
    ruler          = false,
    scrolloff      = 10,
    sessionoptions = "buffers,curdir,folds,help,resize,slash,tabpages,winpos,winsize",
    shada          = "!,'100,/100,:100,<100,s100,h",
    shortmess      = "clxTI",
    showtabline    = 2,
    showcmd = false, showmode = false,
    showbreak      = "↳",
    splitbelow = true, splitright = true, switchbuf = "split",
    termguicolors  = true,
    timeoutlen     = 500,
    undofile = true, undodir = os.getenv("HOME") .. "/.nvimcache/undodir", backup = false, swapfile = false, writebackup = false,
    updatetime     = 150,
    wildignore     = vim.o.wildignore .. "*/tmp/*,*.so,*.swp,*.zip,*.db,*.sqlite,*.bak",
    wildignorecase = true,
    wildoptions    = "pum",
    winminwidth = 3, winheight = 3,
    winhighlight   = "NormalNC:WinNormalNC",
}

if not vim.g.vscode then
    for key, val in pairs(opts) do
        if optsLocal[key] ~= nil then
            vim[optsLocal[key]][key] = val
        end
        vim["o"][key] = val
    end


    -- GUI
    cmd [[colorscheme onedarknord]]
    GuiFontSizes = 13
    if vim.g.neovide ~= nil then
        vim.o.guifont = "更纱黑体 Mono SC Nerd:h" .. (GuiFontSizes + 5)
    else
        vim.o.guifont = "更纱黑体 Mono SC Nerd:h" .. GuiFontSizes
    end
    vim.o.guicursor = "n-v-sm:block,i-c-ci:ver25-Cursor,ve-o-r-cr:hor20"
end
-- }}} Basic settings
-- VS Code settings {{{
local vscodeOpts = {
    clipboard      = "unnamed,unnamedplus",
    complete       = ".,w,b,u,t,kspell,i,d,t",
    completeopt    = "menuone,noselect,noinsert",
    conceallevel   = 0,
    concealcursor  = "nc",
    cpoptions      = vim.o.cpoptions .. "q",
    cursorline     = true,
    gdefault       = true,
    hidden         = true,
    ignorecase     = true, smartcase = true,
    inccommand     = "nosplit",
    listchars      = "tab:>-,precedes:❮,extends:❯,trail:-,nbsp:%,eol:↴",
    langmenu       = "en",
    lazyredraw     = true,
    mouse          = "a",
    joinspaces     = false,
    path           = vim.o.path .. "**",
    scrolloff      = 10,
    sessionoptions = "buffers,curdir,folds,help,resize,slash,tabpages,winpos,winsize",
    shada          = "!,'100,/100,:100,<100,s100,h",
    shortmess      = "clxTI",
    showtabline    = 2,
    showbreak      = "↳",
    splitbelow = true, splitright = true, switchbuf = "split",
    termguicolors  = true,
    timeoutlen     = 500,
    updatetime     = 150,
    wildignore     = vim.o.wildignore .. "*/tmp/*,*.so,*.swp,*.zip,*.db,*.sqlite,*.bak",
    wildignorecase = true,
    winhighlight   = "NormalNC:WinNormalNC",
}

if vim.g.vscode then
    for key, val in pairs(vscodeOpts) do
        if optsLocal[key] ~= nil then
            vim[optsLocal[key]][key] = val
        end
        vim["o"][key] = val
    end
end
-- }}} VS Code settings
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
    local pythonPath = (fn.system('which python3')):gsub("\n+$", "")
    api.nvim_set_var("python3_host_prog", pythonPath)
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

return M

