function! ExtractSelection(modeType)
    if a:modeType !=# "V"
        return
    endif

    let l:CWD = getcwd()
    " Check CWD {{{
    if has('win32')
        " Check file cwd"
        let l:newCWD = expand("%:p:h")
        if getcwd() !=# l:newCWD
            let l:answer = confirm("Change CWD to \"" . l:newCWD . "\"?", "&Yes\n&No")
            if l:answer == 1
                execute "cd " . l:newCWD
                echohl MoreMsg | echom "CWD has changed to: " . l:newCWD
            else
                echohl MoreMsg | echom "CWD: " . l:CWD
            endif
        else
            echohl MoreMsg | echom "CWD: " . l:CWD
        endif
    else
        echohl MoreMsg | echom "CWD: " . l:CWD
    endif " }}} Check CWD
    let l:prompt = "Enter new file path: "
    let s:answer = input(l:prompt)
    " Check valid input
    if s:answer == ""
        echohl WarningMsg
        echo ""
        echom "Cancel"
        echohl None
        return
    endif
    " Find slash
    let l:slashPos = strridx(s:answer, '/')
    if l:slashPos == -1
        let l:slashPos = strridx(s:answer, '\')
    endif
    " Slash exist
    if l:slashPos != -1
        if l:slashPos == strlen(s:answer) - 1
            echohl WarningMsg
            echo " "
            echom "Invalid file path"
            echohl None
            return
        endif
        let l:selectedText = VisualSelection("list")
        " Refine file path
        if s:answer[0] ==# "/" || s:answer[0] ==# '\'
            let l:filePath = l:CWD . s:answer
        elseif s:answer[0:2] ==# './'
            let l:filePath = l:CWD . s:answer[1:]
        else
            let l:filePath = l:CWD . "/" . s:answer
        endif
        " Find folder
        let l:absFolder = strcharpart(l:filePath, 0, l:slashPos + strlen(l:CWD) + 1)
        call mkdir(l:absFolder, "p")
        try
            call writefile(l:selectedText, l:filePath, "s")
            echo " "
            echom "File created: " . l:filePath
            " Delete selection code
            let l:saveReg = @@
            normal! gvd
            let @@ = l:saveReg
            call <SID>AskEditFile()
        catch /.*/
            echo v:exception
            echo " "
            echoerr "Extraction failed"
        endtry
    " Slash does not exist
    else
        let l:selectedText = VisualSelection("list")
        try
        call writefile(l:selectedText, s:answer, "s")
            echo " "
            echom "File created: " . s:answer
            " Delete selection code
            let l:saveReg = @@
            normal! gvd
            let @@ = l:saveReg
            call <SID>AskEditFile()
        catch /.*/
            echohl None
            echo v:exception
            echo " "
            echoerr "Extraction failed"
        endtry
    endif
endfunction

function! s:AskEditFile()
    let l:fileAnswer = confirm("Open and edit new file?", "&Yes\n&No", 1)
    if l:fileAnswer == 1
        execute "e " . s:answer
    endif
    echohl None
endfunction

