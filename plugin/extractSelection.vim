function! s:ExtractSelection(modeType)
    if a:modeType !=# "V"
        return
    endif

    let l:cwd = getcwd()
    echo "CWD: " . l:cwd
    let l:prompt = "Enter new file path: "
    let l:answer = input(l:prompt)
    " Check valid input
    if l:answer == ""
        echo ""
        echom "Cancel"
        return
    endif
    " Find slash
    let l:slashPos = strridx(l:answer, '/')
    if l:slashPos == -1
        let l:slashPos = strridx(l:answer, '\')
    endif
    " Slash exist
    if l:slashPos != -1
        if l:slashPos == strlen(l:answer) - 1
            echo " "
            echom "Invalid file path"
            return
        endif
        let l:selectedText = VisualSelection("list")
        " Refine file path
        if l:answer[0] ==# "/" || l:answer[0] ==# '\'
            let l:filePath = l:cwd . l:answer
        elseif l:answer[0:2] ==# './'
            let l:filePath = l:cwd . l:answer[1:]
        else
            let l:filePath = l:cwd . "/" . l:answer
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
        catch /.*/
            echo v:exception
            echo " "
            echom "Extraction failed"
        endtry
    " Slash does not exist
    else
        let l:selectedText = VisualSelection("list")
        try
        call writefile(l:selectedText, l:answer, "s")
            echo " "
            echom "File created: " . l:answer
            " Delete selection code
            let l:saveReg = @@
            normal! gvd
            let @@ = l:saveReg
        catch /.*/
            echo v:exception
            echo " "
            echom "Extraction failed"
        endtry
    endif
endfunction

command -range -nargs=0 ExtractSelection call <SID>ExtractSelection(visualmode())
