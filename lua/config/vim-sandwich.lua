return function()
    local fn  = vim.fn
    local cmd = vim.cmd
    vim.g["sandwich#magicchar#f#patterns"] = {
        {
            header = [[\<\%(\h\k*\.\)*\h\k*]],
            bra    = '(',
            ket    = ')',
            footer = '',
        },
    }

    cmd [[runtime macros/sandwich/keymap/surround.vim]]

    map("n", [[gs]], [[ys]])
    map("x", [[iq]], [[<Plug>(textobj-sandwich-literal-query-i)]])
    map("x", [[aq]], [[<Plug>(textobj-sandwich-literal-query-a)]])
    map("o", [[iq]], [[<Plug>(textobj-sandwich-literal-query-i)]])
    map("o", [[aq]], [[<Plug>(textobj-sandwich-literal-query-a)]])

    fn["operator#sandwich#set"]('add',     'all', 'hi_duration', 1000)
    fn["operator#sandwich#set"]('replace', 'all', 'hi_duration', 1000)

    -- mode
    -- NOTE: cannot use table.insert( on vim.g metadata
    local recipes = {
        {buns = {[[\s\+]], [[\s\+]]}, regex = 1, kind = {'delete', 'replace', 'query'}, input = {' '}},

        {buns = {'', ''}, action = {'add'}, motionwise = {'line'}, linewise = 1, input = {t"<CR>"}},

        {buns = {'^$', '^$'}, regex = 1, linewise = 1, input = {t"<CR>"}},

        {buns = {'<', '>'}, expand_range = 0},

        {buns = {'"', '"'}, quoteescape = 1, expand_range = 0, nesting = 0, linewise = 0},
        {buns = {"'", "'"}, quoteescape = 1, expand_range = 0, nesting = 0, linewise = 0},
        {buns = {"`", "`"}, quoteescape = 1, expand_range = 0, nesting = 0, linewise = 0},

        {buns = {'{', '}'}, nesting = 1, skip_break = 1},
        {buns = {'{', '}'}, nesting = 1},
        {buns = {'(', ')'}, nesting = 1},

        {buns = 'sandwich#magicchar#t#tag()',     listexpr = 1, kind = {'add'},     action = {'add'}, input = {'t', 'T'}},
        {buns = 'sandwich#magicchar#t#tag()',     listexpr = 1, kind = {'replace'}, action = {'add'}, input = {'T'}},
        {buns = 'sandwich#magicchar#t#tagname()', listexpr = 1, kind = {'replace'}, action = {'add'}, input = {'t'}},

        {buns = {'sandwich#magicchar#f#fname()', '")"'}, kind = {'add', 'replace'}, action = {'add'}, expr = 1, input = {'f'}},

        {external = {t"<Plug>(textobj-sandwich-tag-i)",       t"<Plug>(textobj-sandwich-tag-a)"},      noremap = 0, kind = {'delete',  'textobj'}, expr_filter = {'operator#sandwich#kind() !=# "replace"'}, input = {'t', 'T'}, linewise = 1},
        {external = {t"<Plug>(textobj-sandwich-tag-i)",       t"<Plug>(textobj-sandwich-tag-a)"},      noremap = 0, kind = {'replace', 'query'},   expr_filter = {'operator#sandwich#kind() ==# "replace"'}, input = {'T'}},
        {external = {t"<Plug>(textobj-sandwich-tagname-i)",   t"<Plug>(textobj-sandwich-tagname-a)"},  noremap = 0, kind = {'replace', 'textobj'}, expr_filter = {'operator#sandwich#kind() ==# "replace"'}, input = {'t'}},

        {external = {t"<Plug>(textobj-sandwich-function-ip)", t"<Plug>(textobj-sandwich-function-i)"}, noremap = 0, kind = {'delete', 'replace', 'query'}, input = {'f'}},
        {external = {t"<Plug>(textobj-sandwich-function-ap)", t"<Plug>(textobj-sandwich-function-a)"}, noremap = 0, kind = {'delete', 'replace', 'query'}, input = {'F'}},

        {buns = 'sandwich#magicchar#i#input("operator")',        kind = {'add',    'replace'},          listexpr = 1, input = {'i'}, action = {'add'}},
        {buns = 'sandwich#magicchar#i#input("textobj", 1)',      kind = {'delete', 'replace', 'query'}, listexpr = 1, input = {'i'}},
        {buns = 'sandwich#magicchar#i#lastinput("operator", 1)', kind = {'add',    'replace'},          listexpr = 1, input = {'I'}, action = {'add'}},
        {buns = 'sandwich#magicchar#i#lastinput("textobj")',     kind = {'delete', 'replace', 'query'}, listexpr = 1, input = {'I'}},

        -- Custom reciipe
        {
            buns     = 'FolderMaker()',
            expr     = 0,
            listexpr = 1,
            regex    = 0,
            input    = {'z'},
            kind     = {'add'},
            linewise = 2,
        }
    }

    vim.g["sandwich#recipes"] = recipes

    cmd [[
    function! FolderMaker()
        let l:markName = input('Fold makrer name: ')
        if l:markName ==# ''
            throw 'OpertorSandwichCancel'
        endif
        let l:former = g:FiletypeCommentDelimiter[&filetype] . " " . l:markName . " {{{"
        let l:latter = g:FiletypeCommentDelimiter[&filetype] . " }}} " . l:markName
        return [l:former, l:latter]
    endfunction
    ]]

end

