" Leaderf {
if has('win32')
    let g:Lf_Ctags = "D:\\ctags\\ctags.exe"
elseif has('unix')
    let g:Lf_Ctags = "/usr/local/universal-ctags/ctags"
endif
" let g:Lf_DefaultExternalTool = ""
let g:Lf_WindowPosition = 'popup'
let g:Lf_WindowHeight = 0.8
let g:Lf_DefaultMode = 'Fuzzy'
let g:Lf_WildIgnore = {
            \ 'dir': ['.svn','.git','.hg', '.vim'],
            \ 'file': ['*.sw?','~$*','*.bak','*.o','*.so','*.py[co]']
            \}
let g:Lf_CacheDirectory = expand('~/.nvimcache')
let g:Lf_StlColorscheme = 'default'
let g:Lf_StlSeparator = { 'left': '', 'right': '' }
let g:Lf_PreviewCode = 1
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
" let g:Lf_CommandMap = {'<C-F>': ['<C-D>'], '<ESC>': ['<C-A>', '<C-B>']}
let g:Lf_RootMarkers = ['.git', '.hg', '.svn']
let g:Lf_WorkingDirectoryMode = 'A'
" }
