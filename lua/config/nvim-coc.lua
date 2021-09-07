-- File: cocSettings.vim
-- Author: iaso2h
-- Description: settings to control coc.nvim and coc plugin's behaviors
-- Last Modified: 2021-03-23
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}

-- Extensions {{{
vim.g.coc_global_extensions = {
    'coc-cmake',
    'coc-diagnostic',
    'coc-json',
    'coc-lines',
    'coc-lua',
    'coc-marketplace',
    'coc-pairs',
    'coc-pyright',
    'coc-snippets',
    'coc-spell-checker',
    'coc-vimlsp',
    'coc-zi'
}
-- 'coc-nextword',
-- }}}

-- Known issue: https://github.com/neovim/neovim/issues/12587
-- AutoCommad {{{
api.nvim_exec([[
augroup COC
autocmd!
autocmd CursorHold *               lua CheckCOCDiagnosticFirst('highlight')
autocmd FileType   typescript,json setlocal formatexpr=CocAction('formatSelected')
autocmd FileType   lua,python      let b:coc_root_patterns =  ['.git', '.env']
autocmd User                       CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
]], false)
-- }}}

-- Commands {{{
cmd [[command! -nargs=0 Format :call CocAction('format')]]
cmd [[command! -nargs=0 OR     :call CocAction('runCommand', 'editor.action.organizeImport')]]
cmd [[command! -nargs=0 Spell  :CocCommand cSpell.toggleEnableSpellChecker]]
-- }}} Commands

-- Function {{{
function CheckCOCDiagnosticFirst(cocAction) -- {{{
    if vim.b.coc_diagnostic_info and vim.bo.filetype ~= "lua" then
        if vim.b.coc_diagnostic_info["warning"] == 0 and
            vim.b.coc_diagnostic_info["error"] == 0 then
            api.nvim_call_function("CocActionAsync", {cocAction})
        else
            if cocAction ~= "highlight" then
                api.nvim_echo({{"Fix diagnostic info", "WarningMsg"}}, true, {})
            end
        end
    else
        api.nvim_call_function("CocActionAsync", {cocAction})
    end
end -- }}}
function M.showDoc() -- {{{
    if vim.bo.buftype == "help" then
        cmd('h ' .. fn.expand('<cword>'))
    elseif api.nvim_eval("coc#rpc#ready()") == 1 then
        fn.CocActionAsync("doHover")
    else
        cmd('!' .. vim.o.keywordprg .. " " .. fn.expand('<cword>'))
    end
end -- }}}
function M.formatCode(mode) -- {{{
    cmd "up"
    if mode == "n" then
        if vim.bo.filetype == "vim" then
            local saveView = fn.winsaveview()
            cmd [[normal vae=]]
            fn.winrestview(saveView)
        elseif vim.bo.filetype == "lua" then
            local saveView = fn.winsaveview()
            local flags
            flags = vim.b.luaFormatflags or [[--indent-width=4 --tab-width=4 --continuation-indent-width=4]]
            cmd([[silent %!lua-format % ]] .. flags)
            fn.winrestview(saveView)
        else
            api.nvim_call_function("CocActionAsync", {'format'})
        end
    else
        if vim.bo.filetype == "vim" then
            local saveView = fn.winsaveview()
            cmd [[normal! gv=]]
            fn.winrestview(saveView)
        elseif vim.bo.filetype == "lua" then
            local saveView = fn.winsaveview()
            cmd [[normal! gv=]]
            fn.winrestview(saveView)
        else
            api.nvim_call_function("CocActionAsync", {"formatSelected", mode})
        end
    end
end -- }}}
-- }}} Function

map("n", [[[e]], [[mz`z:call CocActionAsync('diagnosticPrevious',        )<CR>]], {"silent", "noremap"})
map("n", [[]e]], [[mz`z:call CocActionAsync('diagnosticNext',            )<CR>]], {"silent", "noremap"})
map("n", [[[E]], [[mz`z:call CocActionAsync('diagnosticPrevious', 'error')<CR>]], {"silent", "noremap"})
map("n", [[]E]], [[mz`z:call CocActionAsync('diagnosticNext',     'error')<CR>]], {"silent", "noremap"})
map("n", [[<leader>e]], [[:CocList diagnostics<cr>]], {"silent"})
-- GoTo code navigation.
map("n", [[gd]], [[<Plug>(coc-definition)]])
map("n", [[gD]], [[<Plug>(coc-type-definition)]])
map("n", [[gI]], [[<Plug>(coc-implementation)]])
map("n", [[gR]], [[<Plug>(coc-references-used)]])
-- Show Document
map("n", [[K]],     [[:lua require("config.coc").showDoc()<cr>]], {"silent"})
map("n", [[<C-q>]], [[:lua require("config.coc").showDoc()<cr>]], {"silent"})
-- Symbol renaming
map("n", [[<leader>r]], [[:lua CheckCOCDiagnosticFirst("rename")<cr>]])
map("n", [[<leader>R]], [[:lua CheckCOCDiagnosticFirst("refactor")<cr>]])
-- Formatting selected code.
map("n", [[<A-f>]], [[:lua require("config.coc").formatCode(vim.fn.mode())<cr>]],       {"silent"})
map("v", [[<A-f>]], [[:lua require("config.coc").formatCode(vim.fn.visualmode())<cr>]], {"silent"})
-- Code action operator
map("v", [[<leader>a]], [[<Plug>(coc-codeaction-selected)]])
map("n", [[<leader>a]], [[<Plug>(coc-codeaction-selected)]])
-- Remap keys for applying codeAction to the current buffer.
map("n", [[<A-Enter>]], [[<Plug>(coc-codeaction)]])
-- Apply AutoFix to problem on the current line.
map("n", [[<A-S-Enter>]], [[<Plug>(coc-fix-current)]])
-- Function & Class text objects {{{
-- NOTE: Requires 'textDocument.documentSymbol' support from the language server.
map("v", [[if]], [[<Plug>(coc-funcobj-i)]])
map("o", [[if]], [[<Plug>(coc-funcobj-i)]])
map("v", [[af]], [[<Plug>(coc-funcobj-a)]])
map("o", [[af]], [[<Plug>(coc-funcobj-a)]])
map("v", [[ic]], [[<Plug>(coc-classobj-i)]])
map("o", [[ic]], [[<Plug>(coc-classobj-i)]])
map("v", [[ac]], [[<Plug>(coc-classobj-a)]])
map("o", [[ac]], [[<Plug>(coc-classobj-a)]])
-- }}} Function & Class text objects
-- Scroll float windows/popups.
map("n", [[<A-d>]], [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<PageDown>"]],    {"nowait",  "noremap", "expr"})
map("n", [[<A-e>]], [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<PageUp>"]],      {"nowait",  "noremap", "silent", "expr"})
map("i", [[<A-d>]], [[coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : ""]], {"noremap", "silent",  "nowait", "expr"})
map("i", [[<A-e>]], [[coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : ""]], {"noremap", "silent",  "nowait", "expr"})
-- map("v", [[<A-d>]], [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<PageDown>"]],               {"nowait", "noremap", "silent", "expr"})
-- map("v", [[<A-e>]], [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<PageUp>"]],                 {"nowait", "noremap", "silent", "expr"})

-- Use <TAB> for selections ranges.
-- NOTE: Requires 'textDocument/selectionRange' support from the language server.
-- coc-tsserver, coc-python are the examples of servers that support it.
-- map("n", [[<leader>s]], [[<Plug>(coc-range-select)]], {"silent"})
-- map("v", [[<leader>s]], [[<Plug>(coc-range-select)]], {"silent"})
-- Mappings for COC list
map("n", [[<leader>ce]], [[:CocList extensions<cr>]], {"nowait", "noremap", "silent"})
map("n", [[<leader>cc]], [[:CocList commands<cr>]],   {"nowait", "noremap", "silent"})
-- COC-Explorer {{{
vim.g.coc_explorer_global_presets = {
    tab = {["position"] = 'tab', ["quit-on-open"] = true},
    floating = {
        ['position'] = 'floating',
        ['open-action-strategy'] = 'sourceWindow'
    },
    floatingTop = {
        ['position'] = 'floating',
        ['floating-position'] = 'center',
        ['open-action-strategy'] = 'sourceWindow'
    },
    floatingLeftside = {
        ['position'] = 'floating',
        ['floating-position'] = 'center',
        ['floating-width'] = 50,
        ['open-action-strategy'] = 'sourceWindow'
    },
    floatingRightside = {
        ['position'] = 'floating',
        ['floating-position'] = 'center',
        ['floating-width'] = 50,
        ['open-action-strategy'] = 'sourceWindow'
    },
    simplify = {['file-child-template'] = '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'},
    buffer = {['sources'] = {{['name'] = 'buffer', ['expand'] = true}}}
}
-- Use preset argument to open it
map("n", [[<leader><C-w>e]], [[:CocCommand explorer --preset floating<cr>]],      {"silent"})
map("t", [[<leader><C-w>e]], [[<A-n>:CocCommand explorer --preset floating<cr>]], {"silent"})
map("n", [[<C-w>e]],         [[:CocCommand explorer<cr>]],                        {"silent"})
map("t", [[<C-w>e]],         [[<A-n>:CocCommand explorer<cr>]],                   {"silent"})
-- map("n", [[<space>1]], [[:CocList explPresets<cr>]])
-- }}} COC-Explorer

-- COC-Snippets {{{
map("n", [[<C-j>]],     [[:CocCommand snippets]])
map("n", [[<leader>j]], [[:CocList snippets<cr>]], {"silent"})
vim.g.coc_snippet_next = '<Tab>'
vim.g.coc_snippet_prev = '<S-Tab>'
map("i", [[<TAB>]], [[pumvisible() ? coc#_select_confirm() : coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" : CheckBackspace() ? "\<TAB>" : coc#refresh()]], {"noremap", "silent", "expr"})
api.nvim_exec([[
function! CheckBackspace()
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction
]], false)
-- }}} COC-Snippets
-- Completion {{{
-- Trigger completion
map("i", [[<C-space>]], [[pumvisible() ? "\<C-e>" : coc#refresh()]], {"noremap", "silent", "expr"})
-- Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
-- Auto-Completion
map("i", [[<cr>]], [[pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], {"noremap", "silent", "expr"})

-- Close float windows
map("i", [[<C-c>]], [[<C-\><C-o>:call coc#float#close(g:coc_last_float_win)<cr>]], {"silent"})
map("i", [[<C-f>]], [[<C-\><C-o>:call coc#float#jump()<cr>]],                      {"silent"})
map("i", [[<C-f>]], [[<C-\><C-o>:call coc#float#jump()<cr>]],                      {"silent"})
-- }}} Completion

-- }}} LSP

return M

