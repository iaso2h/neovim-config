" Add trailing ;
function! TrailingChar(trailingChar) " {{{
    let l:cursor = getpos('.')
    keepjumps normal g_
    let l:currentChar = strcharpart(getline("."), col(".") - 1, 1)
    execute "normal! a" . a:trailingChar
    if l:currentChar !=# a:trailingChar
    endif
    call cursor(l:cursor[1], l:cursor[2])
endfunction " }}}

function! TrailingLinebreak(direction) " {{{
    let l:cursor = getpos('.')
    if a:direction ==# "down"
        normal! A
        call cursor(l:cursor[1], l:cursor[2])
    elseif a:direction ==# "up"
    endif
endfunction " }}}

function! TrailingFolderMarker(modeType, ...) " {{{
    let l:saveCursor = getpos('.')
    if a:modeType ==# "n"
        execute "normal! A " . g:FiletypeCommentDelimiter[&filetype] . " " . a:1
    elseif a:modeType ==# "v" || a:modeType ==# "V"
        let l:selectStart = getpos("'<")
        let l:selectEnd = getpos("'>")
        if l:selectEnd[1] == l:selectStart[1]
            return
        else
            call cursor(l:selectStart[1], 0)
            execute "normal! g_a " . g:FiletypeCommentDelimiter[&filetype] . " {{{"
            call cursor(l:selectEnd[1], 0)
            execute "normal! g_a " . g:FiletypeCommentDelimiter[&filetype] . " }}}"
            call cursor (l:saveCursor[1], l:saveCursor[2])
        endif
    endif
endfunction " }}}
