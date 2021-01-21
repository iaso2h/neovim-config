" neoclide/coc.nvim {{{
if !get(g:, 'coc_start_at_startup', 1)
    finish
endif

" Extensions {{{
let g:coc_global_extensions = [
            \'coc-clangd',
            \'coc-cmake',
            \'coc-markdownlint',
            \'coc-marketplace',
            \'coc-nextword',
            \'coc-pairs',
            \'coc-pyright',
            \'coc-snippets',
            \'coc-spell-checker',
            \'coc-vimlsp',
            \]
" \'coc-highlight'
" }}}

" AutoCommad {{{
augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
" }}}

" Commands{{{
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call CocActio('runCommand', 'editor.action.organizeImport')
" Toggle Coc Spell-checker
command! -nargs=0 Spell   :CocCommand cSpell.toggleEnableSpellChecker
" }}}

" Document highlight
let g:markdown_fenced_languages = [
            \ 'vim',
            \ 'help'
            \]
" Snippet
let g:coc_snippet_next= "<tab>"
" Completion navigation
inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
inoremap <silent><expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Trigger completion
inoremap <silent><expr> <C-space> coc#refresh()
" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" Navigate through dianostics list
nmap <silent> g[ <Plug>(coc-diagnostic-prev)
nmap <silent> g] <Plug>(coc-diagnostic-next)
" Show all diagnostics.
nnoremap <silent> <leader>d  :<C-u>CocList diagnostics<CR>
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gR <Plug>(coc-references)
" Show Document
nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <silent> <A-q> :call <SID>show_documentation()<CR>
function! s:show_documentation()
    if (index(['help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
    else
        execute '!' . &keywordprg . " " . expand('<cword>')
    endif
endfunction

" Symbol renaming.
nmap <leader>r <Plug>(coc-rename)
nmap <leader>R <Plug>(coc-refactor)
" Formatting selected code.
xnoremap <A-f> <Plug>(coc-format-selected)
nnoremap <A-f> <Plug>(coc-format-selected)
" nmap <A-f> <C-m>zvae<Plug>(coc-format-selected)`z
" Applying codeAction to the selected [[region]].
" Example: `<leader>aap` for current paragraph
xmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>a <Plug>(coc-codeaction-selected)
" Remap keys for applying codeAction to the current buffer.
nmap <A-Enter> <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <A-S-Enter> <Plug>(coc-fix-current)
" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
" NOTE: Remap <C-f> and <C-b> for scroll float windows/popups.
" nnoremap <nowait><expr> <A-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<PageDown>"
" nnoremap <silent><nowait><expr> <A-e> coc#float#has_scroll() ? coc#float#scroll(0) : "\<PageUp>"
" inoremap <silent><nowait><expr> <A-d> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<CR>" : "\<PageDown>"
" inoremap <silent><nowait><expr> <A-e> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<CR>" : "\<PageUp>"
" xnoremap <silent><nowait><expr> <A-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<PageDown>"
" xnoremap <silent><nowait><expr> <A-e> coc#float#has_scroll() ? coc#float#scroll(0) : "\<PageUp>"
" Use <TAB> for selections ranges.
" NOTE: Requires 'textDocument/selectionRange' support from the language server.
" coc-tsserver, coc-python are the examples of servers that support it.
nmap <silent> <leader>S <Plug>(coc-range-select)
xmap <silent> <leader>S <Plug>(coc-range-select)

" Mappings for CoCList:
" Manage extensions.
nnoremap <silent><nowait> <A-c>e :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <A-c>c :<C-u>CocList commands<cr>
" Find symbol of current document.
" nnoremap <silent><nowait> <A-s> :<C-u>CocList outline<cr>
" Search workspace symbols.
" nnoremap <silent><nowait> <leader>s :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <A-c>j :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <A-c>k :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <A-c>p :<C-u>CocListResume<CR>
" Explorer {{{
let g:coc_explorer_global_presets = {
            \   'tab': {
            \     'position': 'tab',
            \     'quit-on-open': v:true,
            \   },
            \   'floating': {
            \     'position': 'floating',
            \     'open-action-strategy': 'sourceWindow',
            \   },
            \   'floatingTop': {
            \     'position': 'floating',
            \     'floating-position': 'center',
            \     'open-action-strategy': 'sourceWindow',
            \   },
            \   'floatingLeftside': {
            \     'position': 'floating',
            \     'floating-position': 'center',
            \     'floating-width': 50,
            \     'open-action-strategy': 'sourceWindow',
            \   },
            \   'floatingRightside': {
            \     'position': 'floating',
            \     'floating-position': 'center',
            \     'floating-width': 50,
            \     'open-action-strategy': 'sourceWindow',
            \   },
            \   'simplify': {
            \     'file-child-template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
            \   },
            \   'buffer': {
            \     'sources': [{'name': 'buffer', 'expand': v:true}]
            \   },
            \ }
" Use preset argument to open it
nmap <leader><A-1> :CocCommand explorer --preset floating<CR>
nmap <A-1> :CocCommand explorer<CR>

" List all presets
nmap <space>el :CocList explPresets
" }}} coc.explorer
" }}} neoclide/coc.nvim
