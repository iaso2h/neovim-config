return function()

local cmd = vim.cmd
local fn  = vim.fn

cmd [[runtime macros/sandwich/keymap/surround.vim]]

map("n", [[gs]], [[ys]])
map("x", [[iq]], [[<Plug>(textobj-sandwich-literal-query-i)]])
map("x", [[aq]], [[<Plug>(textobj-sandwich-literal-query-a)]])
map("o", [[iq]], [[<Plug>(textobj-sandwich-literal-query-i)]])
map("o", [[aq]], [[<Plug>(textobj-sandwich-literal-query-a)]])

fn["operator#sandwich#set"]('add',     'all', 'hi_duration', 1000)
fn["operator#sandwich#set"]('replace', 'all', 'hi_duration', 1000)

-- mode
vim.tbl_deep_extend("force", {}, vim.g["sandwich#recipes"],
    {
        buns     = 'FolderMaker()',
        expr     = 0,
        listexpr = 1,
        regex    = 0,
        input    = {'z'},
        kind     = {'add'},
        linewise = 2,
    }
)


vim.g["sandwich#magicchar#f#patterns"] = {
    {
        header = [[\<\%(\h\k*\.\)*\h\k*]],
        bra    = '(',
        ket    = ')',
        footer = '',
    },
}

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

