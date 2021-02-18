local fn = vim.fn
local cmd = vim.cmd
local api = vim.api

function smartClose(type)
    curBufNr = api.nvim_get_current_buf()
    local winCount = #api.nvim_list_wins()
    local bufTableLen = 0
    local bufTable = {}
    local bufName = api.nvim_buf_get_name(0)
    local bufNr = api.
    local bufType = api.nvim_buf_get_option(0, "buftype")

    for idx,val in ipairs(api.nvim_list_bufs) do
        if api.nvim_buf_is_loaded(val) and string.match(api.nvim_buf_get_name(val), "term://") ~= nil then
            bufTableLen = bufTableLen + 1
            table.insert(bufTable, val)
        end
    end
    if type == "window" then
        if bufType == "" then              -- Sepecial buffer
            if bufType ~= "nofile" then
                cmd "bdelete"
            else                          -- nofile, treated like a scratch file
                if bufName == "[Command Line]" then
                    cmd "q"
                else
                    if bufTableLen == 1 then -- 1 Buffer
                        if winCount > 1 then cmd "only" end
                        saveWipe(curBufNr)
                    else                      -- 1+ Buffers
                        if winCount > 1 then      -- 1+ Windows
                            cmd "q"
                            if api.nvim_buf_get_option(0, "modified") and buflisted(bufNr) then
                                cmd "bwipe! " .. bufNr
                            end
                        else                  -- 1 Window
                            saveWipe(bufNr)
                        end
                    end
                end
            end
        else                              -- Standard buffer
            if bufName == "" then -- Scratch File
                if bufTableLen == 1 then -- 1 Buffer
                    if winCount > 1 then cmd "only" end
                    saveWipe(bufNr)
                    cmd "q"
                else                      -- 1+ Buffers
                    if winCount > 1 then       -- 1+ Windows
                        cmd "q"
                        if api.nvim_buf_get_option(0, "modified") and buflisted(bufNr) then
                            cmd "bwipe! " .. bufNr
                        end
                    else                  -- 1 Window
                        saveWipe(bufNr)
                    end
                end
            else                          -- Standard File
                if bufTableLen == 1 then -- 1 Buffer
                    if winCount > 1 then cmd "only" end
                        saveWipe(bufNr)
                else                      -- 1+ Buffers
                    if winCount > 1 then       -- 1+ Windows
                        cmd "q"
                    else                  -- 1 Window
                        saveWipe(bufNr)
                    end
                end
            end
        end
    elseif type == "buffer"
        -- Delete unlisted buffer
        -- TODO
        if !buflisted(expand("%")) then
            cmd "bdelete!"
            do
                return
            end
        end

        if bufTableLen == 1 then        -- 1 Buffer
            if winCount > 1 then cmd"only" end
            saveWipe(bufNr)
        else                              -- 1+ Buffers
            if bufTableLen == 2 then     -- 2 Buffers
                execute bufnr("#") > 0 && buflisted(bufnr("#")) ? "buffer #" : "bprevious"
                only
                call <SID>SaveWipe(s:curBufNr)
            else                          -- 2+ Buffers
                for i in range(l:winCount)
                    wincmd w
                    if bufnr() == s:curBufNr
                        execute bufnr("#") > 0 && buflisted(bufnr("#")) ? "buffer #" : "bprevious"
                    endif
                endfor
                call <SID>SaveWipe(s:curBufNr)
            endif
        endif
    endif
endfunction

function! s:SaveWipe(bufNr)
    if getbufvar(a:bufNr, "&mod")
        echohl MoreMsg
        let l:answer = confirm("Save modification?", ">>> &Save\n&Discard\n&Cancel", 3, "Question")
        echohl None
        if l:answer == 1
            w
            execute "bwipe " . a:bufNr
        elseif l:answer == 2
            execute "bwipe! " . a:bufNr
        endif
    else
        execute "bwipe " . a:bufNr
    endif
endfunction

