local M = {}

M.commentJump = function(keystroke) -- {{{
    local cmd  = vim.cmd
    local api  = vim.api
    local fn   = vim.fn
    if api.nvim_get_current_line() ~= '' then
        local saveReg = fn.getreg('"')
        if keystroke == "o" then
            cmd("noa normal! YpS" .. vim.g.FiletypeCommentDelimiter[vim.bo.filetype] .. " ")
        elseif keystroke == "O" then
            cmd("noa normal! YPS" .. vim.g.FiletypeCommentDelimiter[vim.bo.filetype] .. " ")
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


    map("n", [[g<space>o]], [[:lua require("config.vim-nerdcommenter").commentJump("o")<CR>]], {"silent"}, "Add comment below")
    map("n", [[g<space>O]], [[:lua require("config.vim-nerdcommenter").commentJump("O")<CR>]], {"silent"}, "Add comment above")

    map("n", [[g<space><space>]], [[<plug>NERDCommenterToggle]], "Toggle comment for current line")
    map("x", [[g<space><space>]], [[<plug>NERDCommenterToggle]], "Toggle comment for the selected")
    map("n", [[g<space>n]], [[<plug>NERDCommenterNested]], "Toggle nested comment for current line")
    map("x", [[g<space>n]], [[<plug>NERDCommenterNested]], "Toggle nested comment for the selected")

    map("n", [[g<space>i]], [[<plug>NERDCommenterInvert]], "Toggle comment invert for current line")
    map("x", [[g<space>i]], [[<plug>NERDCommenterInvert]], "Toggle comment invert for the selected")

    map("n", [[g<space>s]], [[<plug>NERDCommenterSexy]], "Toggle comment sexy for current line")
    map("x", [[g<space>s]], [[<plug>NERDCommenterSexy]], "Toggle comment sexy for the selected")

    map("n", [[g<space>y]], [[<plug>NERDCommenterYank]], "Yank, then toggle comment for current line")
    map("x", [[g<space>y]], [[<plug>NERDCommenterYank]], "Yank, then toggle comment for the selected")

    map("n", [[g<space>$]], [[<plug>NERDCommenterToEOL]], "Comment to the end of the line")
    map("n", [[g<space>A]], [[<plug>NERDCommenterAppend]], "Append comment after current line")
    map("n", [[g<space>I]], [[<plug>NERDCommenterInsert]], "Insert comment before current line")

    map("x", [[<A-/>]], [[<plug>NERDCommenterAltDelims]], "Change comment style for the selected")
    map("n", [[<A-/>]], [[<plug>NERDCommenterAltDelims]], "Change comment style of the current line")

    map("n", [[g<space>n]], [[<plug>NERDCommenterAlignLeft]], "Toggle comment and align to the left in current line")
    map("x", [[g<space>n]], [[<plug>NERDCommenterAlignLeft]], "Toggle comment and align to the left for the selected")
    map("n", [[g<space>b]], [[<plug>NERDCommenterAlignBoth]], "Toggle comment and align to the both sides in current line")
    map("x", [[g<space>b]], [[<plug>NERDCommenterAlignBoth]], "Toggle comment and align to the both sides for the selected")

    map("n", [[g<space>u]], [[<plug>NERDCommenterUncomment]], "Uncomment current line")
    map("x", [[g<space>u]], [[<plug>NERDCommenterUncomment]], "Uncomment selected")

    vim.g.NERDSpaceDelims              = 1
    vim.g.NERDRemoveExtraSpaces        = 1
    vim.g.NERDCommentWholeLinesInVMode = 1
    vim.g.NERDLPlace                   = "{{{"
    vim.g.NERDRPlace                   = "}}}"
    vim.g.NERDCompactSexyComs          = 1
    vim.g.NERDToggleCheckAllLines      = 1
end -- }}}

return M

