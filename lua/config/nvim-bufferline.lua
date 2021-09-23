return function()

-- vim.cmd [[hi! BufferLineBuffer guifg=#66738e guibg=#3B4252]]
require("bufferline").setup {
    options = {
        numbers = function(opts)
                    -- return string.format("%s.%s.", opts.ordinal, opts.id)
                    return string.format("%s", opts.ordinal)
                end,
        close_command        = "bdelete! %d",  -- can be a string | function, see "Mouse actions"
        right_mouse_command  = "bdelete! %d",  -- can be a string | function, see "Mouse actions"
        left_mouse_command   = "buffer %d",    -- can be a string | function, see "Mouse actions"
        middle_mouse_command = nil,            -- can be a string | function, see "Mouse actions"
        -- NOTE: this plugin is designed with this icon in mind,
        -- and so changing this is NOT recommended, this is intended
        -- as an escape hatch for people who cannot bear it for whatever reason
        indicator_icon     = "▎",
        buffer_close_icon  = "",
        modified_icon      = "●",
        close_icon         = "",
        left_trunc_marker  = "",
        right_trunc_marker = "",
        --- name_formatter can be used to change the buffer"s label in the bufferline.
        --- Please note some names can/will break the
        --- bufferline so use this at your discretion knowing that it has
        --- some limitations that will *NOT* be fixed.
        name_formatter = function(buf)  -- buf contains a "name", "path" and "bufnr"
        -- remove extension from markdown files for example
            if buf.name:match("%.md") then
                return vim.fn.fnamemodify(buf.name, ":t:r")
            end
        end,
        max_name_length   = 18,
        max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
        tab_size          = 18,
        diagnostics       = false,
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            return "("..count..")"
            end,
        -- NOTE: this will be called a lot so don"t do any heavy processing here
        custom_filter = function(buf_number)
            -- filter out filetypes you don"t want to see
            if vim.bo[buf_number].filetype ~= "help" then
                return true
            end
            -- filter out by buffer name
            if vim.fn.bufname(buf_number) ~= "nowrite" then
                return true
            end
            -- filter out based on arbitrary rules
            -- e.g. filter out vim wiki buffer from tabline in your work repo
            -- if vim.fn.getcwd() == "<work-repo>" and vim.bo[buf_number].filetype ~= "wiki" then
                -- return true
            -- end
        end,
        offsets = {{filetype = "NvimTree", text = "Nvim Tree", text_align = "left", highlight = "BufferLineBufferSelected"}},
        show_buffer_icons       = true, -- disable filetype icons for buffers
        show_buffer_close_icons = true,
        show_close_icon         = false,
        show_tab_indicators     = true,
        persist_buffer_sort     = true, -- whether or not custom sorted buffers should persist
        -- can also be a table containing 2 custom separators
        -- [focused and unfocused]. eg: { "|", "|" }
        separator_style        = {"", ""},
        enforce_regular_tabs   = false,
        always_show_bufferline = true,
        sort_by                = "id"
    },

    highlights = { -- {{{
        fill = {
            guifg = "#eeeeee",
            guibg = "#3B4252",
        },
        background = {
            guifg = "#66738e",
            guibg = "#3B4252",
        },
        tab = {
            guifg = "#66738e",
            guibg = "#3B4252",
        },
        tab_selected = {
            guifg = "#D8DEE9",
            guibg = "#4C566A",
        },
        tab_close = {
            guifg = "#66738e",
            guibg = "#3B4252",
        },
        close_button = {
            guifg = "#66738e",
            guibg = "#3B4252",
        },
        close_button_visible = {
            guifg = "#66738e",
            guibg = "#3B4252",
        },
        close_button_selected = {
            guifg = "#D8DEE9",
            guibg = "#4C566A",
        },
        buffer_visible = {
            guifg = "#66738e",
            guibg = "#3B4252",
        },
        buffer_selected = {
            guifg = "#D8DEE9",
            guibg = "#4C566A",
            gui = "none"
        },
        modified = {
            guifg = "#9B8473",
            guibg = "#3B4252"
        },
        modified_visible = {
            guifg = "#9B8473",
            guibg = "#3B4252",
        },
        modified_selected = {
            guifg = "#EBCB8B",
            guibg = "#4C566A"
        },
        duplicate_selected = {
            gui = "italic",
            guifg = "#9B8473",
            guibg = "#4C566A"
        },
        duplicate_visible = {
            gui = "italic",
            guifg = "#9B8473",
            guibg = "#4C566A"
        },
        duplicate = {
            gui = "italic",
            guifg = "#9B8473",
            guibg = "#4C566A"
        },
        separator_selected = {
            guifg = "#4C566A",
            guibg = "#4C566A"
        },
        separator_visible = {
            guifg = "#3B4252",
            guibg = "#3B4252"
        },
        separator = {
            guifg = "#3B4252",
            guibg = "#3B4252"
        },
        indicator_selected = {
            guifg = "#88C0D0",
            guibg = "#4C566A"
        },
        pick_selected = {
            guifg = "#4C566A",
            guibg = "#4C566A",
        },
        pick_visible = {
            guifg = "#ED427C",
            guibg = "#3B4252",
            gui = "bold"
        },
        pick = {
            guifg = "#ED427C",
            guibg = "#3B4252",
            gui = "bold"
        }

        -- diagnostic = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>,
        -- },
        -- diagnostic_visible = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>,
        -- },
        -- diagnostic_selected = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>,
            -- gui = "bold,italic"
        -- },
        -- info = {
            -- guifg = <color-value-here>,
            -- guisp = <color-value-here>,
            -- guibg = <color-value-here>
        -- },
        -- info_visible = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>
        -- },
        -- info_selected = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>,
            -- gui = "bold,italic",
            -- guisp = <color-value-here>
        -- },
        -- info_diagnostic = {
            -- guifg = <color-value-here>,
            -- guisp = <color-value-here>,
            -- guibg = <color-value-here>
        -- },
        -- info_diagnostic_visible = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>
        -- },
        -- info_diagnostic_selected = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>,
            -- gui = "bold,italic",
            -- guisp = <color-value-here>
        -- },
        -- warning = {
            -- guifg = <color-value-here>,
            -- guisp = <color-value-here>,
            -- guibg = <color-value-here>
        -- },
        -- warning_visible = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>
        -- },
        -- warning_selected = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>,
            -- gui = "bold,italic",
            -- guisp = <color-value-here>
        -- },
        -- warning_diagnostic = {
            -- guifg = <color-value-here>,
            -- guisp = <color-value-here>,
            -- guibg = <color-value-here>
        -- },
        -- warning_diagnostic_visible = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>
        -- },
        -- warning_diagnostic_selected = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>,
            -- gui = "bold,italic",
            -- guisp = warning_diagnostic_fg
        -- },
        -- error = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>,
            -- guisp = <color-value-here>
        -- },
        -- error_visible = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>
        -- },
        -- error_selected = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>,
            -- gui = "bold,italic",
            -- guisp = <color-value-here>
        -- },
        -- error_diagnostic = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>,
            -- guisp = <color-value-here>
        -- },
        -- error_diagnostic_visible = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>
        -- },
        -- error_diagnostic_selected = {
            -- guifg = <color-value-here>,
            -- guibg = <color-value-here>,
            -- gui = "bold,italic",
            -- guisp = <color-value-here>
        -- },
    } -- }}}
}

-- map("n", [[<leader>b]], [[:<C-u>BufferLinePick<CR>]], {"silent"})
map("n", [[<A-1>]], [[:lua require("bufferline").go_to_buffer(1)<CR>]], {"silent"})
map("n", [[<A-2>]], [[:lua require("bufferline").go_to_buffer(2)<CR>]], {"silent"})
map("n", [[<A-3>]], [[:lua require("bufferline").go_to_buffer(3)<CR>]], {"silent"})
map("n", [[<A-4>]], [[:lua require("bufferline").go_to_buffer(4)<CR>]], {"silent"})
map("n", [[<A-5>]], [[:lua require("bufferline").go_to_buffer(5)<CR>]], {"silent"})
map("n", [[<A-6>]], [[:lua require("bufferline").go_to_buffer(6)<CR>]], {"silent"})
map("n", [[<A-7>]], [[:lua require("bufferline").go_to_buffer(7)<CR>]], {"silent"})
map("n", [[<A-8>]], [[:lua require("bufferline").go_to_buffer(8)<CR>]], {"silent"})
map("n", [[<A-9>]], [[:lua require("bufferline").go_to_buffer(9)<CR>]], {"silent"})

map("n", [[<A-h>]], [[:<C-u>BufferLineCyclePrev<CR>]], {"silent"})
map("n", [[<A-l>]], [[:<C-u>BufferLineCycleNext<CR>]], {"silent"})

map("n", [[<A-S-h>]], [[:<C-u>BufferLineMovePrev<CR>]], {"silent"})
map("n", [[<A-S-l>]], [[:<C-u>BufferLineMoveNext<CR>]], {"silent"})

end

