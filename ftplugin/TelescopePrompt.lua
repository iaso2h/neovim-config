 -- TODO: supoort multiple actions

if not TelescopeOverrideBufMap then
    TelescopeOverrideBufMap = function(mode, lhs, rhs, opts)
        local promptBufNr
        local tbl = vim.tbl_keys(TelescopeGlobalState)
        local opts = opts or {silent = true, noremap = true}

        if tbl[1] == "number" then
            promptBufNr = tbl[1]
        else
            promptBufNr = tbl[2]
        end

        vim.api.nvim_buf_set_keymap(promptBufNr, mode, lhs, rhs, opts)
    end
end


-- TODO: Open in floating win or newtab
TelescopeOverrideBufMap("n", [[?]], [[:<C-u>Redir lua Print(require("telescope.actions.state").get_selected_entry())<CR>]])
