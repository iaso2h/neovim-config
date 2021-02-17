" michaeljsmith/vim-indent-object {{{
let g:indentLine_color_gui = '#3b4252'
let g:indentLine_char= '▏'
" }}} michaeljsmith/vim-indent-object

" vim-airline/vim-airline {{{
let g:airline_theme='onedarknord'
let g:airline_skip_empty_sections = 1
let g:airline_powerline_fonts = 1
let g:airline_extensions = ['coc', 'tabline', 'wordcount', 'virtualenv', 'branch', 'fzf']
let g:airline#extensions#wordcount#filetypes = ['all']
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#show_tabs = 0
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#switch_buffers_and_tabs = 1
let g:airline#extensions#tabline#exclude_preview = 1
let g:airline#extensions#tabline#tabnr_formatter = 'tabnr'
let g:airline#extensions#tabline#formatter = 'jsformatter'

" Section {{{
function! StatusDiagnostic(type) abort
    let info = get(b:, 'coc_diagnostic_info', {})
    if empty(info) | return '' | endif
    let msgs = []
    if a:type ==# "error"
        if get(info, 'error', 0)
            call add(msgs, '❌ ' . info['error'])
        endif
    elseif a:type ==# "warning"
        if get(info, 'warning', 0)
            call add(msgs, '⚠️ ' . info['warning'])
        endif
        if get(info, 'information', 0)
            call add(msgs, '🔎 ' . info['information'])
        endif
        if get(info, 'hint', 0)
            call add(msgs, '💡 ' . info['hint'])
        endif
    endif
    " echo get(g:, 'coc_status', '')
    return join(msgs, ' ')
endfunction

function! IconFileFormat()
    let expected = get(g:, 'airline#parts#ffenc#skip_expected_string', '')
    let bomb     = &bomb ? '[BOM]' : ''
    let noeolf   = &eol ? '' : '[!EOL]'
" 更纱黑体\ Mono\ SC\ Nerd:h12
    if &ff ==# "unix"
        let ff = "  "
    elseif &ff ==# "dos"
        let ff = "  "
    elseif &ff ==# "mac"
        let ff = "  "
    else
        let ff = &ff
    endif
    return &fenc.bomb.noeolf.ff
endfunction

" set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
" set statusline^=%{coc#status()}
let s:sep = " %{get(g:, 'airline_right_alt_sep', '')} "
" let g:airline_section_x = "%{coc#status()}" . s:sep . "%{strlen(&filetype)?&filetype:'no ft'}"
let g:asyncrun_status = ''
let g:airline_section_error = airline#section#create_right(['%{g:asyncrun_status}'])
let g:airline_section_x = "%{get(b:,'coc_current_function','')}" .
            \s:sep . "%{strlen(&filetype)?&filetype:'no ft'}"
let g:airline_section_z ='%p%% %l:%v'
let g:airline_section_y = airline#section#create_right(['%{IconFileFormat()}'])
let g:airline_section_error = airline#section#create_right(['%{StatusDiagnostic("error")}'])
let g:airline_section_warning = airline#section#create_right(['%{StatusDiagnostic("warning")}'])
" }}} Section

" Symbols {{{
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.maxlinenr = '㏑'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.whitespace = 'Ξ'

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.dirty='⚡'
" }}} Symbols

" Key mapping {{{
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <leader>0 <Plug>AirlineSelectTab0
" }}} Key mapping
" }}} vim-airline/vim-airline

" luochen1990/rainbow {{{
let g:rainbow_active = 1
let g:rainbow_conf = {
            \ 'guifgs': ['Gold', 'DarkOrchid3', 'RoyalBlue2'],
            \ 'ctermfgs': ['yellow', 'magenta', 'lightblue'],
            \	'guis': [''],
            \	'cterms': [''],
            \	'operators': '',
            \	'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
            \	'separately': {
            \		'*': {},
            \		'markdown': {
            \			'parentheses_options': 'containedin=markdownCode contained',
            \		},
            \		'lisp': {
            \			'guifgs': ['Gold', 'DarkOrchid3', 'RoyalBlue2', 'Firebrick', 'SeaGreen3', 'DarkOrange3'],
            \		},
            \		'haskell': {
            \			'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/\v\{\ze[^-]/ end=/}/ fold'],
            \		},
            \		'vim': {
            \			'parentheses_options': 'containedin=vimFuncBody',
            \		},
            \		'perl': {
            \			'syn_name_prefix': 'perlBlockFoldRainbow',
            \		},
            \		'stylus': {
            \			'parentheses': ['start=/{/ end=/}/ fold contains=@colorableGroup'],
            \		},
            \		'css': 1,
            \	}
            \}
" [vim css color](https://github.com/ap/vim-css-color) compatibility
" }}} luochen1990/rainbow
"
"
