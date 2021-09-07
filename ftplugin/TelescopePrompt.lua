-- TODO: supoort multiple actions

vim.cmd[[setlocal wrap number]]


if not TelescopeOverrideBufMap then
    TelescopeOverrideBufMap = function(mode, lhs, actionName)
        local promptBufNr
        local tbl = vim.tbl_keys(TelescopeGlobalState)
        local rhs

        if tbl[1] == "number" then
            promptBufNr = tbl[1]
        else
            promptBufNr = tbl[2]
        end

        if mode == "i" then
            rhs = string.match(actionName, "<") and actionName or
                string.format([[<C-\><C-o>:lua require("telescope.actions").%s(%d)<cr>]], actionName, promptBufNr)
        else
            rhs = string.format([[:lua require("telescope.actions").%s(%d)<cr>]], actionName, promptBufNr)
        end

        vim.api.nvim_buf_set_keymap(promptBufNr, mode, lhs, rhs, {silent = true, noremap = true})
    end
end

TelescopeOverrideBufMap("n", [[<A-e>]], "preview_scrolling_up")
TelescopeOverrideBufMap("n", [[<A-d>]], "preview_scrolling_down")
TelescopeOverrideBufMap("i", [[<A-e>]], "preview_scrolling_up")
TelescopeOverrideBufMap("i", [[<A-d>]], "preview_scrolling_down")

TelescopeOverrideBufMap("n", [[<C-s>]], "select_horizontal")
TelescopeOverrideBufMap("i", [[<C-s>]], "select_horizontal")

TelescopeOverrideBufMap("n", [[g]], "move_to_top")
TelescopeOverrideBufMap("n", [[z]], "move_to_middle")
TelescopeOverrideBufMap("n", [[G]], "move_to_bottom")

TelescopeOverrideBufMap("i", [[<C-]>]], "complete_tag")

TelescopeOverrideBufMap("i", [[<C-j>]], "cycle_history_next")
TelescopeOverrideBufMap("i", [[<C-k>]], "cycle_history_prev")

TelescopeOverrideBufMap("i", [[<C-d>]], "<Del>")

TelescopeOverrideBufMap("i", [[<C-u>]], "<C-u>")

