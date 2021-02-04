runtime macros/sandwich/keymap/surround.vim
nmap gS ys
xmap iq <Plug>(textobj-sandwich-literal-query-i)
xmap aq <Plug>(textobj-sandwich-literal-query-a)
omap iq <Plug>(textobj-sandwich-literal-query-i)
omap aq <Plug>(textobj-sandwich-literal-query-a)
call operator#sandwich#set('add', 'all', 'hi_duration', 1000)
call operator#sandwich#set('replace', 'all', 'hi_duration', 1000)
let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
mode
let g:sandwich#recipes += [
\   {
\   'buns':     'FolderMaker()',
\   'expr':     0,
\   'listexpr': 1,
\   'regex':    0,
\   'input':    ['c'],
\   'kind':     ['add', 'replace'],
\   'linewise': 2,
\   },
\   ]
let g:sandwich#magicchar#f#patterns = [
\   {
\     'header' : '\<\%(\h\k*\.\)*\h\k*',
\     'bra'    : '(',
\     'ket'    : ')',
\     'footer' : '',
\   },
\ ]
function! FolderMaker()
    let l:markName = input('Makrer Name: ')
    if l:markName ==# ''
        throw 'OpertorSandwichCancel'
    endif
    let l:former = g:FiletypeCommentDelimiter[&filetype] . " " . l:markName . " {{{"
    let l:latter = g:FiletypeCommentDelimiter[&filetype] . " }}} " . l:markName
    return [l:former, l:latter]
endfunction
