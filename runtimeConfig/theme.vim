if (empty($TMUX))
    " For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
    " Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
    " <https://github.com/neovim/neovim/wiki/Following-HEAD#20160511>
    if (has("termguicolors"))
        set termguicolors
    endif
endif

" Indent line
let g:indentLine_color_gui = '#313A42'
let g:indentLine_char= '▏'
colorscheme nord
let g:airline_theme='nord'
" let g:nord_cursor_line_number_background = 1
let g:nord_uniform_status_lines = 1
let g:nord_bold_vertical_split_line = 0
let g:nord_uniform_diff_background = 1
" let g:nord_bold = 1
let g:nord_italic = 1
let g:nord_underline = 1
let g:nord_italic_comments = 1
" One dark
let g:onedark_terminal_italics = 1
if (has("autocmd") && !has("gui_running"))
    augroup colorset
        autocmd!
        let s:test_white = { "gui": "#FFFFFF", "cterm": "145", "cterm16" : "7" }
        let s:test_black = { "gui": "#000000", "cterm": "145", "cterm16" : "7" }
        autocmd ColorScheme * call onedark#set_highlight("Cursor", { "fg": s:test_white, "bg": s:test_black })
    augroup END
endif
colorscheme onedark
" Custom highlight for :match
highligh NordMain guifg=#88c0d0
highlight Myw term=bold guifg=white
highlight Mywb term=bold guibg=white
highlight Myg term=bold guifg=green
highlight Myb term=bold guifg=blue
highlight Myy term=bold guifg=yellow
highlight Myr term=bold guifg=red
highlight Mym term=bold guifg=magenta
" Override highlight
highlight CursorLine guibg=#303643
highlight CursorColumn guibg=#424755
highlight! link CocHighlightText CursorColumn
highlight Visual guibg=#5F6972
highlight MatchParen guibg=#F04C04 guifg=black
highlight MatchWord guifg=DarkTurquoise gui=italic
" highlight MatchParen guibg=black guifg=white
" highlight MatchWord gui=underline,italic
highlight MatchBackground guibg=#21252B
highlight! OffscreenPopup guibg=#21252B guifg=DarkTurquoise gui=italic,underline
highlight TermCursor guifg=black guibg=yellow
highlight Cursor guifg=black guibg=white
set guicursor=n-v:block-NordMain,c-i-ci-ve:ver25,r-cr:hor25,o:hor50,a:blinkwait300-blinkoff150-blinkon200-Cursor,sm:block-blinkwait175-blinkoff150-blinkon175
" Airline

" let spc = ' '
if !exists('g:GuiLoaded')
    set guifont=更纱黑体\ Mono\ SC\ Nerd:h13
endif
" set guifont=JetBrainsMono\ Nerd\ Font\ Mono:h13
" let g:airline_section_c = '%<%F%m %#__accent_red#%{airline#util#wrap(airline#parts#readonly(),0)}%#__restore__#'
" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
let g:airline_section_c = airline#section#create(['%f  ' , '%{get(b:,''coc_current_function'','''')}'])
let g:airline_powerline_fonts = 1
let g:airline_extensions = ['coc', 'tabline', 'wordcount', 'virtualenv', 'branch', 'fzf']
let g:airline#extensions#branch#enabled = 1
let g:airline_highlighting_cache = 1
let airline#extensions#coc#stl_format_err = '%E{[%e(#%fe)]}'
let airline#extensions#coc#stl_format_warn = '%W{[%w(#%fw)]}'
let g:airline#extensions#wordcount#filetypes = ['all']
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#switch_buffers_and_tabs = 1
let g:airline#extensions#tabline#exclude_preview = 1
let g:airline#extensions#tabline#tabnr_formatter = 'tabnr'
let g:airline#extensions#tabline#formatter = 'jsformatter'
let g:airline#extensions#tabline#tabs_label = ' '
let g:airline#extensions#tabline#buffers_label = ' '
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

function! StatusDiagnostic() abort
    let info = get(b:, 'coc_diagnostic_info', {})
    if empty(info) | return '' | endif
    let msgs = []
    if get(info, 'error', 0)
        call add(msgs, ' ' . info['error'])
    endif
    if get(info, 'warning', 0)
        call add(msgs, ' ' . info['warning'])
    endif
    if get(info, 'information', 0)
        call add(msgs, ' ' . info['information'])
    endif
    if get(info, 'hint', 0)
        call add(msgs, ' ' . info['hint'])
    endif
    " echo get(g:, 'coc_status', '')
    return join(msgs, ' ')
endfunction
let g:airline_section_warning = airline#section#create_right(['%{StatusDiagnostic()}'])
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

" Rainbow
let g:rainbow_active = 1
let g:rainbow_conf = {
            \ 'guifgs': ['Gold', 'DarkOrchid3', 'RoyalBlue2'],
            \ 'ctermfgs': ['yellow', 'magenta', 'lightblue'],
            \}
" } Theme
