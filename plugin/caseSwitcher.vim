"-----------------------------------------------------------------
" foo_bar_foo_bar
" foo bar foo bar
" foo Bar Boo Bar
" fooBarBooBar
"-----------------------------------------------------------------
"-----------------------------------------------------------------
" foo_bar_foo_bar
" foo bar foo bar
" foo Bar Boo Bar
" fooBarBooBar
"-----------------------------------------------------------------

function! CaseSwitcher(modeType)
    if a:modeType !=# "v"
        Echo "Not Characterwise Mode!"
        return
    endif
    let l:end = getpos("'<")
    '<,'>s#\C\v<([a-z0-9])+_
    " Echo VisualSelection("string")
    " Echo l:start
    " Echo l:end
    " for i in range(0, 255)
    "     echo isalpha(i) . ", i: " . i
    "     " echo nr2char(i) . ", i: " . i
    " endfor

endfunction
xnoremap <leader>g :<c-u>call CaseSwitcher(visualmode())<cr>
