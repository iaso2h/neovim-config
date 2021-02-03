function! ExtractSelection(modeType)
    if a:modeType !=# "V"
        return
    endif

    let l:cwd = getcwd()
    echo "CWD: " . l:cwd
    let l:prompt = "Enter new file path: "
    let s:answer = input(l:prompt)
    " Check valid input
    if s:answer == ""
        echo ""
        echom "Cancel"
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
            echo " "
            echom "Invalid file path"
            return
        endif
        let l:selectedText = VisualSelection("list")
        " Refine file path
        if s:answer[0] ==# "/" || s:answer[0] ==# '\'
            let l:filePath = l:cwd . s:answer
        elseif s:answer[0:2] ==# './'
            let l:filePath = l:cwd . s:answer[1:]
        else
            let l:filePath = l:cwd . "/" . s:answer
        endif
        " Find folder
        let l:absFolder = strcharpart(l:filePath, 0, l:slashPos + strlen(l:cwd) + 1)
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
            echom "Extraction failed"
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
            echo v:exception
            echo " "
            echom "Extraction failed"
        endtry
    endif
endfunction

function! s:AskEditFile()
    let l:fileAnswer = confirm("Open and edit new file?", "&Yes\n&No", 1)
    if l:fileAnswer == 1
        execute "e " . s:answer
    endif
endfunction

