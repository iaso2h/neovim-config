if (empty($TMUX))
    " For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
    " Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
    " <https://github.com/neovim/neovim/wiki/Following-HEAD#20160511>
    if (has("termguicolors"))
        set termguicolors
    endif
endif
colorscheme nord
let g:airline_theme='nord'
" let g:nord_cursor_line_number_background = 1
let g:nord_uniform_status_lines = 1
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
" Custom
hi TermCursor guifg=white guibg=black
hi CursorLine guibg=#3E4452
hi Visual guibg=#5F6972
hi MatchParen guibg=DarkYellow guifg=black " ctermbg=blue ctermfg=white
" Airline

" let spc = ' '
" let g:airline_section_x = airline#section#create_right(['vista', 'gutentags', 'grepper', 'filetype'])
" let g:airline_section_y = airline#section#create_right(['ffenc'])
" let g:airline_section_error = airline#section#create(['ale_error_count', 'coc_error_count'])
" let g:airline_section_warning = airline#section#create(['ale_warning_count', 'whitespace', 'coc_warning_count'])
let g:airline_section_c = '%<%F%m %#__accent_red#%{airline#util#wrap(airline#parts#readonly(),0)}%#__restore__#'
let g:airline_powerline_fonts = 1
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#wordcount#filetypes = ['all']
let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#virtualenv#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#show_tab_nr = 1
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
" Rainbow
let g:rainbow_active = 1
let g:rainbow_conf = {
            \ 'guifgs': ['Gold', 'DarkOrchid3', 'RoyalBlue3'],
            \ 'ctermfgs': ['yellow', 'magenta', 'lightblue'],
            \}
" } Theme
