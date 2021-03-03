" Yggdroot/LeaderF {{{
" let g:Lf_DisableStl = 1 BUG
let g:Lf_CacheDirectory          = expand('~/.nvimcache')
let g:Lf_JumpToExistingWindow    = 0
let g:Lf_IgnoreCurrentBufferName = 1 " Bug
let g:Lf_UseVersionControlTool   = 0 " Bug
let g:Lf_FollowLinks             = 1
let g:Lf_RootMarkers             = ['.git', '.hg', '.svn']
let g:Lf_WorkingDirectoryMode    = 'a'
let g:Lf_WildIgnore              = {
            \ 'dir': ['.svn','.git','.hg'],
            \ 'file': ['*.sw?','~$*','*.bak','*.o','*.so','*.py[co]']
            \}
let g:Lf_ShowHidden              = 1
" External Tool {{{
if has('win32')
    let g:Lf_Ctags               = "D:\\ctags\\ctags.exe"
elseif has('unix')
    let g:Lf_Ctags               = "/usr/local/universal-ctags/ctags"
endif
let g:Lf_CtagsFuncOpts           = {
            \ 'c': '--c-kinds=fp',
            \ 'rust': '--rust-kinds=f',
            \ }
let g:Lf_DefaultExternalTool     = "rg"
if has('win32')
    let g:Lf_Rg                  = 'C:\ProgramData\chocolatey\bin\rg.exe'
elseif has('unix')
    " TODO
endif
let g:Lf_RgConfig                = [
            \ "--glob=!git/*",
            \ "--no-ignore",
            \ "--hidden"
            \ ]
" g:Lf_GtagsAutoGenerate TODO
" }}} External Tool

" Window {{{
let g:Lf_StlColorscheme            = 'one'
let g:Lf_StlSeparator              = { 'left': '', 'right': '' }
let g:Lf_WindowPosition            = 'popup'
let g:Lf_PreviewCode               = 1
let g:Lf_PreviewHorizontalPosition = 'right'
let g:Lf_WindowHeight              = 0.4
let g:Lf_AutoResize                = 1
let g:Lf_PreviewInPopup            = 1
let g:Lf_PopupPosition             = [float2nr(&lines * 0.1), 0]
let g:Lf_PopupHeight               = 0.3
let g:Lf_PopupWidth                = &columns * 2 / 3
let g:Lf_PreviewCode               = 1
let g:Lf_PopupPreviewPosition      = 'bottom'
let g:Lf_PreviewPopupWidth         = 90
let g:Lf_PreviewResult             = {
            \ 'File':        0,
            \ 'Buffer':      0,
            \ 'Mru':         0,
            \ 'Tag':         1,
            \ 'BufTag':      1,
            \ 'Function':    1,
            \ 'Line':        1,
            \ 'Colorscheme': 0,
            \ 'Rg':          1,
            \ 'Gtags':       0
            \}
" }}} Window

" Key mapping {{{
" Input mode
let g:Lf_ShortcutB = ''
let g:Lf_DelimiterChar = ';'
let g:Lf_ShortcutF = '<C-e>'
function! s:checkCWDFirst(cmd, input)
    if has('win32') && &buftype != "help"
        let l:fileDir = expand("%:p:h")
        let l:CWD = getcwd()
        if l:CWD[0] !=# l:fileDir[0]
            execute "cd " . l:fileDir
            echohl MoreMsg | echom "New CWD: " . l:fileDir | echohl None
        endif
    endif
    if a:input == 0
        execute a:cmd
    elseif a:input == 1
        execute input("", a:cmd)
    endif
endfunction
nnoremap <silent> <C-e> :call <SID>checkCWDFirst("LeaderfFile", 0)<cr>
if has("win32")
    nnoremap <C-S-e> :call <SID>checkCWDFirst("LeaderfFile .", 1)<cr>
else
    " nnoremap <C-S-e> :Leaderf .
endif
nnoremap <silent> <C-S-p>         :LeaderfCommand<cr>
nnoremap <silent> <C-S-o>         :LeaderfBufTag<cr>
nnoremap <silent> <leader><C-S-o> :LeaderfBufTagAll<cr>
nnoremap <silent> <C-f>f          :LeaderfFunction<cr>
nnoremap <silent> <C-f><C-f>      :LeaderfFunctionAll<cr>
nnoremap <silent> <C-S-h>         :LeaderfHelp<cr>
nnoremap <silent> <C-f>l          :LeaderfLine<cr>
nnoremap <silent> <C-f><C-l>      :LeaderfLineAll<cr>
nnoremap <silent> <C-f>q          :LeaderfQuickFix<cr>
nnoremap <silent> <C-S-f>         :call <SID>checkCWDFirst("LeaderfRgInteractive", 0)<cr>
" Normal mode
let g:Lf_CommandMap = {
            \'<C-X>': ['<C-s>'],
            \'<Up>': ['<C-k>'],
            \'<Down>': ['<C-j>'],
            \'<Right>': ['<C-l>'],
            \'<Left>': ['<C-h>'],
            \'<Home>': ['<C-a>'],
            \'<End>': ['<C-e>'],
            \'<C-W>': ['<C-BS>'],
            \'<Del>': ['<C-d>'],
            \'<C-]>': ['<C-v>'],
            \'<C-J>': ['<C-n>'],
            \'<C-K>': ['<C-p>'],
            \}
let g:Lf_NormalMap = {
            \ "_":           [["<C-v>", "v"],
                \            ["<C-s>", "x"]
                \           ],
            \ "File":        [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>'],
                \            ["<F6>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']
                \           ],
            \ "Buffer":      [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<CR>'],
                \            ["<F6>", ':exec g:Lf_py "bufExplManager.quit()"<CR>']
                \           ],
            \ "Mru":         [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<CR>']],
            \ "Tag":         [],
            \ "BufTag":      [],
            \ "Function":    [],
            \ "Line":        [],
            \ "History":     [],
            \ "Help":        [],
            \ "Self":        [],
            \ "Colorscheme": []
            \}
" }}} Key mapping

" Color scheme {{{
" Nord {{{
let s:nord0_gui        = "#2E3440"
let s:nord1_gui        = "#3B4252"
let s:nord2_gui        = "#434C5E"
let s:nord3_gui        = "#4C566A"
let s:nord3_gui_bright = "#616E88"
let s:nord4_gui        = "#D8DEE9"
let s:nord5_gui        = "#E5E9F0"
let s:nord6_gui        = "#ECEFF4"
let s:nord7_gui        = "#8FBCBB"
let s:nord8_gui        = "#88C0D0"
let s:nord9_gui        = "#81A1C1"
let s:nord10_gui       = "#5E81AC"
let s:nord11_gui       = "#BF616A"
let s:nord12_gui       = "#D08770"
let s:nord13_gui       = "#EBCB8B"
let s:nord14_gui       = "#A3BE8C"
let s:nord15_gui       = "#B48EAD"

let s:nord1_term  = "0"
let s:nord3_term  = "8"
let s:nord5_term  = "7"
let s:nord6_term  = "15"
let s:nord7_term  = "14"
let s:nord8_term  = "6"
let s:nord9_term  = "4"
let s:nord10_term = "12"
let s:nord11_term = "1"
let s:nord12_term = "11"
let s:nord13_term = "3"
let s:nord14_term = "2"
let s:nord15_term = "5"

let s:nord3_gui_brightened = [
            \ s:nord3_gui,
            \ "#4e586d",
            \ "#505b70",
            \ "#525d73",
            \ "#556076",
            \ "#576279",
            \ "#59647c",
            \ "#5b677f",
            \ "#5d6982",
            \ "#5f6c85",
            \ "#616e88",
            \ "#63718b",
            \ "#66738e",
            \ "#687591",
            \ "#6a7894",
            \ "#6d7a96",
            \ "#6f7d98",
            \ "#72809a",
            \ "#75829c",
            \ "#78859e",
            \ "#7b88a1",
            \ ]
" }}} Nord

let g:Lf_StlPalette = {
            \   'stlName': {
            \       'gui': 'bold',
            \       'font': 'NONE',
            \       'guifg': '#3E4452',
            \       'guibg': '#88C0D0',
            \       'cterm': 'bold',
            \       'ctermfg': '6',
            \       'ctermbg': '76'
            \   },
            \   'stlCategory': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#3E4452',
            \       'guibg': '#81A1C1',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '4'
            \   },
            \   'stlNameOnlyMode': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#3E4452',
            \       'guibg': '#61AFEF',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '75'
            \   },
            \   'stlFullPathMode': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#3E4452',
            \       'guibg': '#5E81AC',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '10'
            \   },
            \   'stlFuzzyMode': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#3E4452',
            \       'guibg': '#EBCB8B',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '180'
            \   },
            \   'stlRegexMode': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#3E4452',
            \       'guibg': '#A3BE8C',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '76'
            \   },
            \   'stlCwd': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#ABB2BF',
            \       'guibg': '#4C566A',
            \       'cterm': 'NONE',
            \       'ctermfg': '145',
            \       'ctermbg': '236'
            \   },
            \   'stlBlank': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#ABB2BF',
            \       'guibg': '#4C566A',
            \       'cterm': 'NONE',
            \       'ctermfg': '145',
            \       'ctermbg': '235'
            \   },
            \   'stlSpin': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#E6E666',
            \       'guibg': '#4C566A',
            \       'cterm': 'NONE',
            \       'ctermfg': '185',
            \       'ctermbg': '235'
            \   },
            \   'stlLineInfo': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#3E4452',
            \       'guibg': '#88C0D0',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '236'
            \   },
            \   'stlTotal': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#3E4452',
            \       'guibg': '#88C0D0',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '236'
            \   }
            \ }

let g:Lf_PopupPalette = {
            \  'dark': {
            \      'Lf_hl_popup_cursor': {
            \                'gui': 'NONE',
            \                'font': 'NONE',
            \                'guifg': '#000000',
            \                'guibg': '#FFFFFF',
            \                'cterm': 'NONE',
            \                'ctermfg': '0',
            \                'ctermbg': 'NONE',
            \              },
            \      'Lf_hl_cursorline': {
            \                'gui': 'bold',
            \                'font': 'NONE',
            \                'guifg': '#88C0D0',
            \                'guibg': 'NONE',
            \                'cterm': 'NONE',
            \                'ctermbg': 'NONE',
            \                'ctermfg': '236',
            \              },
            \      'Lf_hl_match': {
            \                'gui': 'NONE',
            \                'font': 'NONE',
            \                'guifg': '#81A1C1',
            \                'guibg': 'NONE',
            \                'cterm': 'NONE',
            \                'ctermfg': '4',
            \                'ctermbg': 'NONE',
            \              },
            \      'Lf_hl_match0': {
            \                'gui': 'NONE',
            \                'font': 'NONE',
            \                'guifg': '#81A1C1',
            \                'guibg': 'NONE',
            \                'cterm': 'NONE',
            \                'ctermfg': '4',
            \                'ctermbg': 'NONE',
            \              },
            \      'Lf_hl_match1': {
            \                'gui': 'NONE',
            \                'font': 'NONE',
            \                'guifg': '#D08770',
            \                'guibg': 'NONE',
            \                'cterm': 'NONE',
            \                'ctermfg': '11',
            \                'ctermbg': 'NONE',
            \              },
            \      'Lf_hl_match2': {
            \                'gui': 'NONE',
            \                'font': 'NONE',
            \                'guifg': '#BF616A',
            \                'guibg': 'NONE',
            \                'cterm': 'NONE',
            \                'ctermfg': '1',
            \                'ctermbg': 'NONE',
            \              },
            \      'Lf_hl_match3': {
            \                'gui': 'NONE',
            \                'font': 'NONE',
            \                'guifg': '#5E81AC',
            \                'guibg': 'NONE',
            \                'cterm': 'NONE',
            \                'ctermfg': '10',
            \                'ctermbg': 'NONE',
            \              },
            \      'Lf_hl_match4': {
            \                'gui': 'NONE',
            \                'font': 'NONE',
            \                'guifg': '#A3BE8C',
            \                'guibg': 'NONE',
            \                'cterm': 'NONE',
            \                'ctermfg': '2',
            \                'ctermbg': 'NONE',
            \              },
            \      'Lf_hl_matchRefine': {
            \                'gui': 'NONE',
            \                'font': 'NONE',
            \                'guifg': '#ED427C',
            \                'guibg': 'NONE',
            \                'cterm': 'NONE',
            \                'ctermfg': '1',
            \                'ctermbg': 'NONE',
            \              },
            \      'Lf_hl_selection': {
            \                'gui': 'NONE',
            \                'font': 'NONE',
            \                'guifg': '#ECEFF4',
            \                'guibg': '#88C0D0',
            \                'cterm': 'NONE',
            \                'ctermfg': '0',
            \                'ctermbg': '6',
            \              },
            \   'Lf_hl_popup_inputText': {
            \       'gui':     'bold',
            \       'font':    'NONE',
            \       'guifg':   '#88C0D0',
            \       'guibg':   '#3B4252',
            \       'cterm':   'bold',
            \       'ctermfg': '6',
            \       'ctermbg': '76',
            \   },
            \   'Lf_hl_popup_normalMode': {
            \       'gui':     'bold',
            \       'font':    'NONE',
            \       'guifg':   '#3B4252',
            \       'guibg':   '#88C0D0',
            \       'cterm':   'bold',
            \       'ctermfg': '76',
            \       'ctermbg': '6',
            \   },
            \   'Lf_hl_popup_window': {
            \       'gui':     'NONE',
            \       'font':    'NONE',
            \       'guifg':   '#D8DEE9',
            \       'guibg':   '#3B4252',
            \       'cterm':   'bold',
            \       'ctermfg': '1',
            \       'ctermbg': '76'
            \   },
            \   'Lf_hl_popup_inputMode': {
            \       'gui':     'bold',
            \       'font':    'NONE',
            \       'guifg':   '#3B4252',
            \       'guibg':   '#A3BE8C',
            \       'cterm':   'bold',
            \       'ctermfg': '76',
            \       'ctermbg': '16',
            \   },
            \   'Lf_hl_popup_category': {
            \       'gui':     'NONE',
            \       'font':    'NONE',
            \       'guifg':   '#3E4452',
            \       'guibg':   '#81A1C1',
            \       'cterm':   'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '4'
            \   },
            \   'Lf_hl_popup_nameOnlyMode': {
            \       'gui':     'NONE',
            \       'font':    'NONE',
            \       'guifg':   '#ECEFF4',
            \       'guibg':   '#61AFEF',
            \       'cterm':   'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '75'
            \   },
            \   'Lf_hl_popup_fullPathMode': {
            \       'gui':     'NONE',
            \       'font':    'NONE',
            \       'guifg':   '#ECEFF4',
            \       'guibg':   '#5E81AC',
            \       'cterm':   'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '10'
            \   },
            \   'Lf_hl_popup_fuzzyMode': {
            \       'gui':     'NONE',
            \       'font':    'NONE',
            \       'guifg':   '#ECEFF4',
            \       'guibg':   '#EBCB8B',
            \       'cterm':   'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '180'
            \   },
            \   'Lf_hl_popup_regexMode': {
            \                'gui':     'NONE',
            \                'font':    'NONE',
            \                'guifg':   '#ECEFF4',
            \                'guibg':   '#ED427C',
            \                'cterm':   'NONE',
            \                'ctermfg': 'NONE',
            \                'ctermbg': '1',
            \   },
            \   'Lf_hl_popup_cwd': {
            \       'gui':     'NONE',
            \       'font':    'NONE',
            \       'guifg':   '#ABB2BF',
            \       'guibg':   '#4C566A',
            \       'cterm':   'NONE',
            \       'ctermfg': '145',
            \       'ctermbg': '236'
            \   },
            \   'Lf_hl_popup_blank': {
            \       'gui':     'NONE',
            \       'font':    'NONE',
            \       'guifg':   '#ABB2BF',
            \       'guibg':   '#4C566A',
            \       'cterm':   'NONE',
            \       'ctermfg': '145',
            \       'ctermbg': '235'
            \   },
            \   'Lf_hl_popup_spin': {
            \       'gui':     'NONE',
            \       'font':    'NONE',
            \       'guifg':   '#E6E666',
            \       'guibg':   '#4C566A',
            \       'cterm':   'NONE',
            \       'ctermfg': '185',
            \       'ctermbg': '235'
            \   },
            \   'Lf_hl_popup_lineInfo': {
            \       'gui':     'NONE',
            \       'font':    'NONE',
            \       'guifg':   '#3E4452',
            \       'guibg':   '#88C0D0',
            \       'cterm':   'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '236'
            \   },
            \   'Lf_hl_popup_total': {
            \       'gui':     'NONE',
            \       'font':    'NONE',
            \       'guifg':   '#3E4452',
            \       'guibg':   '#88C0D0',
            \       'cterm':   'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '236'
            \   }
            \      }
            \  }
" }}} Color scheme
" }}} Yggdroot/LeaderF

