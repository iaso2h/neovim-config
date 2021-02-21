let g:caseSwitcherTimer = []
let g:caseSwitcherDefaultCMDList = ["Camel", "Snake", "Pascal", "Snakecaps"]

function! CaseSwitcher() abort " {{{
    let l:cursorPos = getpos('.')
    " When timer fire, the timer list will be empty, and the default cmdlist ->
    " will be used
    if !exists("g:caseSwitcherCMDList") || g:caseSwitcherTimer == []
        let g:caseSwitcherCMDList = deepcopy(g:caseSwitcherDefaultCMDList)
    endif
    let l:firstCMD = remove(g:caseSwitcherCMDList, 0)
    silent! execute l:firstCMD
    echo " "
    echohl MoreMsg | echo "Switch to \"" . l:firstCMD . "\"" | echohl None
    call cursor(l:cursorPos[1], l:cursorPos[2])
    " When the first CMD is execute, it will reappend to the list
    call add(g:caseSwitcherCMDList, l:firstCMD)
    " Stop previous timer, make sure only the latest timer can run
    if len(g:caseSwitcherTimer) > 1
        let l:timerIndex = 0
        for timer in g:caseSwitcherTimer[1:]
            let l:timerIndex += 1
            call timer_stop(remove(g:caseSwitcherTimer, l:timerIndex))
        endfor
    endif
    " Set new timer
    call add(g:caseSwitcherTimer, timer_start(1000, "CaseSwitcherTimerRest"))
endfunction " }}}

function! CaseSwitcherTimerRest(timer) " {{{
    call remove(g:caseSwitcherTimer, 0)
endfunction " }}}

function! CaseSwitcherDefaultCMDListOrder() " {{{
    call add(g:caseSwitcherDefaultCMDList, remove(g:caseSwitcherDefaultCMDList, 0))
    echohl MoreMsg
    Echo "Default CMD order has been changed to: "
    echom g:caseSwitcherDefaultCMDList
    echohl None
endfunction " }}}

