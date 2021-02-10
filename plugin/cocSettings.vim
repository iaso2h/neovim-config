" File: cocSettings.vim
" Author: iaso2h
" Description: settings to control coc.nvim and coc plugin's behaviors
" Last Modified: 一月 31, 2021
if !get(g:, 'coc_start_at_startup', 1)
    finish
endif

" Extensions {{{
let g:coc_global_extensions = [
            \'coc-cmake',
            \'coc-explorer',
            \'coc-json',
            \'coc-markdownlint',
            \'coc-marketplace',
            \'coc-pairs',
            \'coc-pyright',
            \'coc-snippets',
            \'coc-spell-checker',
            \'coc-vimlsp',
            \'coc-zi',
            \]
" \'coc-nextword',
" \'coc-highlight'
" }}}

" AutoCommad {{{
augroup myGroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call <SID>checkCOCDiagnosticFirst('highlight')
" }}}

" Commands{{{
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call CocAction('runCommand', 'editor.action.organizeImport')
" Toggle Coc Spell-checker
command! -nargs=0 Spell   :CocCommand cSpell.toggleEnableSpellChecker
" }}}

" Function {{{
function! s:checkCOCDiagnosticFirst(COCAction)
    if exists("b:coc_diagnostic_info")
        if items(b:coc_diagnostic_info) ==
                    \ [['information', 0], ['hint', 0], ['lnums', [0, 0, 0, 0]], ['warning', 0], ['error', 0]]
            call CocActionAsync(a:COCAction)
        else
            echohl WarningMsg | echo "Fix diagnostic info" | echohl None
        endif
    else
        call CocActionAsync(a:COCAction)
    endif
endfunction
" }}} Function

" Document highlight
let g:markdown_fenced_languages = [
            \ 'vim',
            \ 'help'
            \]
" Navigate through diagnostics list
nmap <silent> [e <Plug>(coc-diagnostic-prev)
nmap <silent> ]e <Plug>(coc-diagnostic-next)
" Show all diagnostics.
nnoremap <silent> <leader>d  :<C-u>CocList diagnostics<CR>
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gD <Plug>(coc-type-definition)
nmap <silent> gI <Plug>(coc-implementation)
nmap <silent> gR <Plug>(coc-references)
" Show Document
nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <silent> <C-q> :call <SID>show_documentation()<CR>
function! s:show_documentation()
    if (index(['help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
    else
        execute '!' . &keywordprg . " " . expand('<cword>')
    endif
endfunction

" Symbol renaming
nmap <leader>r :<c-u>call <SID>checkCOCDiagnosticFirst("rename")<cr>
nmap <leader>R :<c-u>call <SID>checkCOCDiagnosticFirst("refactor")<cr>
" Formatting selected code.
xnoremap <A-f> <Plug>(coc-format-selected)
nmap <A-f> <A-m>zvae<Plug>(coc-format-selected)`z
" Codeaction operator
xmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>a <Plug>(coc-codeaction-selected)
" Remap keys for applying codeAction to the current buffer.
nmap <A-Enter> <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <A-S-Enter> <Plug>(coc-fix-current)
" Function & Class text objects {{{
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
" }}} Function & Class text objects
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
nnoremap <silent><nowait> <leader>e :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <leader>c :<C-u>CocList commands<cr>
" Find symbol of current document.
" nnoremap <silent><nowait> <A-s> :<C-u>CocList outline<cr>
" Search workspace symbols.
" nnoremap <silent><nowait> <leader>s :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <leader>j :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <leader>k :<C-u>CocPrev<CR>
" " Resume latest coc list.
" nnoremap <silent><nowait> <leader>l :<C-u>CocListResume<CR>
" COC-Explorer {{{
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
" }}} COC-Explorer
" COC-Snippets {{{
nmap <C-j> :CocCommand snippets
nmap <silent> <leader>j :CocList snippets<cr>
let g:coc_snippet_next = '<Tab>'
let g:coc_snippet_prev = '<S-Tab>'
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" }}} COC-Snippets
" Completion {{{
" Trigger completion
inoremap <silent><expr> <C-space> pumvisible() ? "\<C-e>" : coc#refresh()
" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
"  Auto-Completion
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" }}} Completion
