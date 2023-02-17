return function()
    require("dressing").setup {
        input = {
            win_options = {
                winblend = 0,
            },
            mapping = {
                i = {
                    ["<C-k>"] = "HistoryPrev",
                    ["<C-j>"] = "HistoryNext"
                }
            }
        },
        select = {
            backend = {
                "telescope",
                "builtin"
            },
            telescope = nil,
            builtin = {
                win_options = {
                    winblend = 0
                }
            }
        }
    }
end
