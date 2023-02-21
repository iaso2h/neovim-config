local M = {}

M.commentJump = function(keystroke) -- {{{
    local cmd  = vim.cmd
    local api  = vim.api
    local fn   = vim.fn
    if api.nvim_get_current_line() ~= '' then
        local saveReg = fn.getreg('"')
        if keystroke == "o" then
            cmd("noa normal! YpS" .. string.format(vim.bo.cms, ""))
        elseif keystroke == "O" then
            cmd("noa normal! YPS" .. string.format(vim.bo.cms, ""))
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


    map("n", [[gco]], [[<CMD>lua require("config.vim-nerdcommenter").commentJump("o")<CR>]], {"silent"}, "Add comment below")
    map("n", [[gcO]], [[<CMD>lua require("config.vim-nerdcommenter").commentJump("O")<CR>]], {"silent"}, "Add comment above")

    map("n", [[gcc]], [[<Plug>NERDCommenterToggle]], "Toggle comment for current line")
    map("x", [[C]],   [[<Plug>NERDCommenterToggle]], "Toggle comment for the selected")
    map("n", [[gcn]], [[<Plug>NERDCommenterNested]], "Toggle nested comment for current line")
    map("x", [[gcn]], [[<Plug>NERDCommenterNested]], "Toggle nested comment for the selected")

    map("n", [[gci]], [[<Plug>NERDCommenterInvert]], "Toggle comment invert for current line")
    map("x", [[gci]], [[<Plug>NERDCommenterInvert]], "Toggle comment invert for the selected")

    map("n", [[gcs]], [[<Plug>NERDCommenterSexy]], "Toggle comment sexy for current line")
    map("x", [[gcs]], [[<Plug>NERDCommenterSexy]], "Toggle comment sexy for the selected")

    map("n", [[gcy]], [[<Plug>NERDCommenterYank]], "Yank, then toggle comment for current line")
    map("x", [[gcy]], [[<Plug>NERDCommenterYank]], "Yank, then toggle comment for the selected")

    map("n", [[gc$]], [[<Plug>NERDCommenterToEOL]], "Comment to the end of the line")
    map("n", [[gcA]], [[<Plug>NERDCommenterAppend]], "Append comment after current line")
    map("n", [[gcI]], [[<Plug>NERDCommenterInsert]], "Insert comment before current line")

    map("x", [[<A-/>]], [[<Plug>NERDCommenterAltDelims]], "Change comment style for the selected")
    map("n", [[<A-/>]], [[<Plug>NERDCommenterAltDelims]], "Change comment style of the current line")

    map("n", [[gcn]], [[<Plug>NERDCommenterAlignLeft]], "Toggle comment and align to the left in current line")
    map("x", [[gcn]], [[<Plug>NERDCommenterAlignLeft]], "Toggle comment and align to the left for the selected")
    map("n", [[gcb]], [[<Plug>NERDCommenterAlignBoth]], "Toggle comment and align to the both sides in current line")
    map("x", [[gcb]], [[<Plug>NERDCommenterAlignBoth]], "Toggle comment and align to the both sides for the selected")

    map("n", [[gcu]], [[<Plug>NERDCommenterUncomment]], "Uncomment current line")
    map("x", [[gcu]], [[<Plug>NERDCommenterUncomment]], "Uncomment selected")

    vim.g.NERDSpaceDelims              = 1
    vim.g.NERDRemoveExtraSpaces        = 1
    vim.g.NERDCommentWholeLinesInVMode = 1
    vim.g.NERDLPlace                   = "{{{"
    vim.g.NERDRPlace                   = "}}}"
    vim.g.NERDCompactSexyComs          = 1
    vim.g.NERDToggleCheckAllLines      = 1
end -- }}}

return M

