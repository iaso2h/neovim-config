local promptBufNr
local tbl = vim.tbl_keys(TelescopeGlobalState)
if tbl[1] == "number" then
    promptBufNr = tbl[1]
else
    promptBufNr = tbl[2]
end

-- TODO: supoort multiple actions
if not TelescopeOverrideBufMap then
    TelescopeOverrideBufMap = function(mode, lhs, actionName)
        local rhs

        if mode == "i" then
            rhs = string.format([[<C-\><C-o>:lua require("telescope.actions").%s(%d)<cr>]], actionName, promptBufNr)
        else
            rhs = string.format([[:lua require("telescope.actions").%s(%d)<cr>]], actionName, promptBufNr)
        end

        vim.api.nvim_buf_set_keymap(promptBufNr, mode, lhs, rhs, {silent = true})
    end
end

TelescopeOverrideBufMap("n", [[<A-e>]], "preview_scrolling_up")
TelescopeOverrideBufMap("n", [[<A-d>]], "preview_scrolling_down")
TelescopeOverrideBufMap("i", [[<A-e>]], "preview_scrolling_up")
TelescopeOverrideBufMap("i", [[<A-d>]], "preview_scrolling_down")

TelescopeOverrideBufMap("n", [[<C-s>]], "select_horizontal")
TelescopeOverrideBufMap("i", [[<C-s>]], "select_horizontal")

TelescopeOverrideBufMap("n", [[g]], "move_to_top")
TelescopeOverrideBufMap("i", [[z]], "move_to_middle")
TelescopeOverrideBufMap("i", [[G]], "move_to_bottom")

TelescopeOverrideBufMap("n", [[g]], "move_to_top")
TelescopeOverrideBufMap("i", [[z]], "move_to_middle")
TelescopeOverrideBufMap("i", [[G]], "move_to_bottom")

