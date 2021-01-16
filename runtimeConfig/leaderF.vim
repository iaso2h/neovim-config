" Leaderf {
" let g:Lf_DisableStl = 1 BUG
let g:Lf_JumpToExistingWindow = 0
let g:Lf_IgnoreCurrentBufferName = 1
let g:Lf_UseVersionControlTool = 0
let g:Lf_RootMarkers = ['.git', '.hg', '.svn']
let g:Lf_WorkingDirectoryMode = 'A'
let g:Lf_FollowLinks = 1
let g:Lf_WildIgnore = {
            \ 'dir': ['.svn','.git','.hg', '.vim'],
            \ 'file': ['*.sw?','~$*','*.bak','*.o','*.so','*.py[co]']
            \}
" External Tool {{{
if has('win32')
    let g:Lf_Ctags = "D:\\ctags\\ctags.exe"
elseif has('unix')
    let g:Lf_Ctags = "/usr/local/universal-ctags/ctags"
endif
let g:Lf_CacheDirectory = expand('~/.nvimcache')
let g:Lf_CtagsFuncOpts = {
        \ 'c': '--c-kinds=fp',
        \ 'rust': '--rust-kinds=f',
        \ }
" let g:Lf_DefaultExternalTool = ""
" let g:Lf_Rg = 'C:\Windows\System32\rg.exe'
" let g:Lf_RgConfig = [
"     \ "--max-columns=150",
"     \ "--type-add web:*.{html,css,js}*",
"     \ "--glob=!git/*",
"     \ "--hidden"
" \ ]
" g:Lf_GtagsAutoGenerate TODO
" }}} External Tool

" Window {{{
let g:Lf_StlColorscheme = 'default'
let g:Lf_StlSeparator = { 'left': '', 'right': '' }
" let g:Lf_WindowPosition = 'popup'
let g:Lf_WindowHeight = 0.4
let g:Lf_PopupHeight = 0.6
let g:Lf_AutoResize = 1
let g:Lf_PreviewCode = 0
" let g:Lf_PreviewInPopup = 1
" let g:Lf_PreviewPopupWidth = 0.5
let g:Lf_PreviewResult = {
            \ 'File': 1,
            \ 'Buffer': 1,
            \ 'Mru': 0,
            \ 'Tag': 0,
            \ 'BufTag': 1,
            \ 'Function': 1,
            \ 'Line': 0,
            \ 'Colorscheme': 0,
            \ 'Rg': 1,
            \ 'Gtags': 0
            \}
" }}} Window

" Key mapping {{{
"|leaderf-prompt|
" let g:Lf_CommandMap = {'<C-F>': ['<C-D>'], '<ESC>': ['<C-A>', '<C-B>']}
" let g:Lf_NormalMap = {
"     \ "_":      [["<C-j>", "j"],
"     \            ["<C-k>", "k"]
"     \           ],
"     \ "File":   [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>'],
"     \            ["<F6>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']
"     \           ],
"     \ "Buffer": [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<CR>'],
"     \            ["<F6>", ':exec g:Lf_py "bufExplManager.quit()"<CR>']
"     \           ],
"     \ "Mru":    [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<CR>']],
"     \ "Tag":    [],
"     \ "BufTag": [],
"     \ "Function": [],
"     \ "Line":   [],
"     \ "History":[],
"     \ "Help":   [],
"     \ "Self":   [],
"     \ "Colorscheme": []
"     \}
" }
" }}} Key mapping

" Color scheme {{{
" let g:Lf_DevIconsPalette = {
"     \  'light': {
"     \      '_': {
"     \                'gui': 'NONE',
"     \                'font': 'NONE',
"     \                'guifg': '#505050',
"     \                'guibg': 'NONE',
"     \                'cterm': 'NONE',
"     \                'ctermfg': '238',
"     \                'ctermbg': 'NONE'
"     \              },
"     \      'default': {
"     \                'guifg': '#505050',
"     \                'ctermfg': '238',
"     \              },
"     \      },
"     \      'vim': {
"     \                'guifg': '#007F00',
"     \                'ctermfg': '28',
"     \              },
"     \      },
"     \      '.gitignore': {
"     \                'guifg': '#dd4c35',
"     \                'ctermfg': '166',
"     \              },
"     \      },
"     \  'dark': {
"     \         ...
"     \         ...
"     \      }
"     \  }
""let g:Lf_StlPalette = {
        " \   'stlName': {
        " \       'gui': 'bold',
        " \       'font': 'NONE',
        " \       'guifg': '#2F5C00',
        " \       'guibg': '#BAFFA3',
        " \       'cterm': 'bold',
        " \       'ctermfg': '22',
        " \       'ctermbg': '157'
        " \   },
        " \   'stlCategory': {
        " \       'gui': 'NONE',
        " \       'font': 'NONE',
        " \       'guifg': '#000000',
        " \       'guibg': '#F28379',
        " \       'cterm': 'NONE',
        " \       'ctermfg': '16',
        " \       'ctermbg': '210'
        " \   },
        " \   'stlNameOnlyMode': {
        " \       'gui': 'NONE',
        " \       'font': 'NONE',
        " \       'guifg': '#000000',
        " \       'guibg': '#E8ED51',
        " \       'cterm': 'NONE',
        " \       'ctermfg': '16',
        " \       'ctermbg': '227'
        " \   },
        " \   'stlFullPathMode': {
        " \       'gui': 'NONE',
        " \       'font': 'NONE',
        " \       'guifg': '#000000',
        " \       'guibg': '#AAAAFF',
        " \       'cterm': 'NONE',
        " \       'ctermfg': '16',
        " \       'ctermbg': '147'
        " \   },
        " \   'stlFuzzyMode': {
        " \       'gui': 'NONE',
        " \       'font': 'NONE',
        " \       'guifg': '#000000',
        " \       'guibg': '#E8ED51',
        " \       'cterm': 'NONE',
        " \       'ctermfg': '16',
        " \       'ctermbg': '227'
        " \   },
        " \   'stlRegexMode': {
        " \       'gui': 'NONE',
        " \       'font': 'NONE',
        " \       'guifg': '#000000',
        " \       'guibg': '#7FECAD',
        " \       'cterm': 'NONE',
        " \       'ctermfg': '16',
        " \       'ctermbg': '121'
        " \   },
        " \   'stlCwd': {
        " \       'gui': 'NONE',
        " \       'font': 'NONE',
        " \       'guifg': '#EBFFEF',
        " \       'guibg': '#606168',
        " \       'cterm': 'NONE',
        " \       'ctermfg': '195',
        " \       'ctermbg': '241'
        " \   },
        " \   'stlBlank': {
        " \       'gui': 'NONE',
        " \       'font': 'NONE',
        " \       'guifg': 'NONE',
        " \       'guibg': '#3B3E4C',
        " \       'cterm': 'NONE',
        " \       'ctermfg': 'NONE',
        " \       'ctermbg': '237'
        " \   },
        " \   'stlLineInfo': {
        " \       'gui': 'NONE',
        " \       'font': 'NONE',
        " \       'guifg': '#000000',
        " \       'guibg': '#EBFFEF',
        " \       'cterm': 'NONE',
        " \       'ctermfg': '16',
        " \       'ctermbg': '195'
        " \   },
        " \   'stlTotal': {
        " \       'gui': 'NONE',
        " \       'font': 'NONE',
        " \       'guifg': '#000000',
        " \       'guibg': '#BCDC5C',
        " \       'cterm': 'NONE',
        " \       'ctermfg': '16',
        " \       'ctermbg': '149'
        " \   }
        " \ }
" let g:Lf_PopupColorscheme = 'default' TODO
" let g:Lf_PopupPalette = {
"     \  'light': {
"     \      'Lf_hl_match': {
"     \                'gui': 'NONE',
"     \                'font': 'NONE',
"     \                'guifg': 'NONE',
"     \                'guibg': '#303136',
"     \                'cterm': 'NONE',
"     \                'ctermfg': 'NONE',
"     \                'ctermbg': '236'
"     \              },
"     \      'Lf_hl_cursorline': {
"     \                'gui': 'NONE',
"     \                'font': 'NONE',
"     \                'guifg': 'NONE',
"     \                'guibg': '#303136',
"     \                'cterm': 'NONE',
"     \                'ctermfg': 'NONE',
"     \                'ctermbg': '236'
"     \              },
"     \      },
"     \  'dark': {
"     \         ...
"     \         ...
"     \      }
"     \  }
" }}} Color scheme
