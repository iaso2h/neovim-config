local M = {}

M.commentJump = function(keystroke) -- {{{
    local cmd  = vim.cmd
    local api  = vim.api
    local fn   = vim.fn
    if api.nvim_get_current_line() ~= '' then
        local saveReg = fn.getreg('"')
        if keystroke == "o" then
            cmd("normal! YpS" .. vim.g.FiletypeCommentDelimiter[vim.bo.filetype] .. " ")
        elseif keystroke == "O" then
            cmd("normal! YPS" .. vim.g.FiletypeCommentDelimiter[vim.bo.filetype] .. " ")
        end
        fn.setreg('"', saveReg)
        cmd [[startinsert!]]
    end
end -- }}}

M.config = function() -- {{{
    vim.g.NERDAltDelims_c          = 1
    vim.g.NERDAltDelims_cpp        = 1
    vim.g.NERDAltDelims_javascript = 1
    vim.g.NERDAltDelims_lua        = 0
    vim.g.NERDAltDelims_conf       = 0


    map("n", [[g<space>o]], [[:lua require("config.vim-nerdcommenter").commentJump("o")<CR>]], {"silent"})
    map("n", [[g<space>O]], [[:lua require("config.vim-nerdcommenter").commentJump("O")<CR>]], {"silent"})

    vmap("n", [[g<space><space>]], [[<c-u>:call VSCodeCall("editor.action.commentLine")<CR>]])
    vmap("x", [[g<space><space>]], [[:call VSCodeCall("editor.action.commentLine")<CR>]])

    map("n", [[g<space><space>]], [[<plug>NERDCommenterToggle]], {"novscode"})
    map("x", [[g<space><space>]], [[<plug>NERDCommenterToggle]], {"novscode"})
    map("n", [[g<space>n]], [[<plug>NERDCommenterNested]], {"novscode"})
    map("x", [[g<space>n]], [[<plug>NERDCommenterNested]], {"novscode"})

    map("n", [[g<space>i]], [[<plug>NERDCommenterInvert]], {"novscode"})
    map("x", [[g<space>i]], [[<plug>NERDCommenterInvert]], {"novscode"})

    map("n", [[g<space>s]], [[<plug>NERDCommenterSexy]], {"novscode"})
    map("x", [[g<space>s]], [[<plug>NERDCommenterSexy]], {"novscode"})

    map("n", [[g<space>y]], [[<plug>NERDCommenterYank]], {"novscode"})
    map("x", [[g<space>y]], [[<plug>NERDCommenterYank]], {"novscode"})

    map("n", [[g<space>$]], [[<plug>NERDCommenterToEOL]], {"novscode"})
    map("n", [[g<space>A]], [[<plug>NERDCommenterAppend]], {"novscode"})
    map("n", [[g<space>I]], [[<plug>NERDCommenterInsert]], {"novscode"})

    map("x", [[<A-/>]], [[<plug>NERDCommenterAltDelims]], {"novscode"})
    map("n", [[<A-/>]], [[<plug>NERDCommenterAltDelims]], {"novscode"})

    map("n", [[g<space>n]], [[<plug>NERDCommenterAlignLeft]], {"novscode"})
    map("x", [[g<space>n]], [[<plug>NERDCommenterAlignLeft]], {"novscode"})
    map("n", [[g<space>b]], [[<plug>NERDCommenterAlignBoth]], {"novscode"})
    map("x", [[g<space>b]], [[<plug>NERDCommenterAlignBoth]], {"novscode"})

    map("n", [[g<space>u]], [[<plug>NERDCommenterUncomment]], {"novscode"})
    map("x", [[g<space>u]], [[<plug>NERDCommenterUncomment]], {"novscode"})

    vim.g.NERDSpaceDelims              = 1
    vim.g.NERDRemoveExtraSpaces        = 1
    vim.g.NERDCommentWholeLinesInVMode = 1
    vim.g.NERDLPlace                   = "{{{"
    vim.g.NERDRPlace                   = "}}}"
    vim.g.NERDCompactSexyComs          = 1
    vim.g.NERDToggleCheckAllLines      = 1
end -- }}}

return M

