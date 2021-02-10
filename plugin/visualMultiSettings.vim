" mg979/vim-visual-multi-multi {{{
let g:VM_silent_exit = 1
let g:VM_quit_after_leaving_insert_mode = 1
let g:VM_use_first_cursor_in_line = 1
let g:VM_reselect_first = 1
let g:VM_verbose_commands = 1
let g:VM_skip_shorter_lines = 0
let g:VM_skip_empty_lines = 1
let g:VM_insert_special_keys = ['c-v', 'c-e', 'c-a']
" Theme
let g:VM_theme = 'nord'
" Settings

" NOTE: There are two main modes VM can work in, |cursor-mode| and |extend-mode|.
" NOTE: They roughly correspond to |normal-mode| and |visual-mode|.
" Add new mapping while preserving the orginal mapping at the same time
let g:VM_custom_remaps = {"<C-v>": "<C-r>", "s": "c"}
" To remap any key to normal! commands. Example:
let g:VM_custom_noremaps = {"==": "==", "<<": "<<", ">>": ">>"}
function! VM_Start()
    " TODO remap coc enter
    imap <C-BS> <C-\><C-o>db
    nmap S ys
    nmap <leader>h <esc>
    nmap <C-n> ,<C-n>
    nmap <C-p> ,<C-p>
endfunction

function! VM_Exit()
    nmap <silent> <leader>h :noh<cr>
    nnoremap <C-p> <C-p>
endfunction

augroup VmStartMapping
    autocmd!
    autocmd User visual_multi_start   call VM_Start()
    autocmd User visual_multi_exit    call VM_Exit()
augroup END

let g:VM_maps = {}
let g:VM_mouse_mappings = 1
let g:VM_maps['Reselect Last']  = 'gm'
let g:VM_maps['Find Under']      = '<C-d>'
let g:VM_maps['Visual Add']      = '<C-d>'
let g:VM_maps["Select Cursor Down"] = ',j'
let g:VM_maps["Select Cursor Up"]   = ',k'
let g:VM_maps['Skip Region']     = '<C-k>'
let g:VM_maps['Remove Region'] = 'u'
let g:VM_maps['Select All']      = '<C-S-a>'
let g:VM_maps['Visual All']      = '<C-S-a>'

" Navigaton
let g:VM_maps['Invert Direction'] = 'o'
let g:VM_maps['Find Next'] = 'n'
let g:VM_maps['Find Prev'] = 'N'
let g:VM_maps['Goto Next'] = ',<C-n>'    " Without adding new occurrences
let g:VM_maps['Goto Prev'] = ',<C-p>'  " Without adding new occurrences
" Modify selection
let g:VM_maps['Enlarge']       = '<A-a>'
let g:VM_maps['Shrink']        = '<A-s>'
" Number
" Align
let g:VM_maps['Align Char'] = ',>'
" Run
let g:VM_maps['Run Normal'] = ',!'
let g:VM_maps['Run Macro'] = ',@'
let g:VM_maps['Show Register'] = ',"'
" }}} mg979/vim-visual-multi-multi
