return function()
    vim.g["sexp_filetypes"] = "clojure,scheme,lisp,timl,fennel,query"
    vim.g["sexp_enable_insert_mode_mappings"] = 0
    vim.g["sexp_mappings"] = {
        -- h: <Plug>(sexp_flow_to_next_open)
        sexp_outer_list                = 'af',
        sexp_inner_list                = 'if',
        sexp_outer_top_list            = 'aF',
        sexp_inner_top_list            = 'iF',

        sexp_outer_string              = 'as',
        sexp_inner_string              = 'is', --?

        -- sexp_outer_element             = 'ae',
        -- sexp_inner_element             = 'ie',
        sexp_outer_element             = '',
        sexp_inner_element             = '',

        sexp_move_to_prev_bracket      = '<A-9>',
        sexp_move_to_next_bracket      = '<A-0>',
        sexp_move_to_prev_element_head = 'B',
        sexp_move_to_next_element_head = 'W',
        -- sexp_move_to_prev_element_tail = 'gE',
        sexp_move_to_prev_element_tail = '',
        sexp_move_to_next_element_tail = 'E',

        -- sexp_flow_to_prev_close        = '<A-9>',
        -- sexp_flow_to_next_open         = '<A-0>',
        sexp_flow_to_prev_close        = '',
        sexp_flow_to_next_open         = '',
        sexp_flow_to_prev_open         = '(',
        sexp_flow_to_next_close        = ')',
        sexp_flow_to_prev_leaf_head    = '<A-b>',
        sexp_flow_to_next_leaf_head    = '<A-w>',
        sexp_flow_to_prev_leaf_tail    = 'gE',
        sexp_flow_to_next_leaf_tail    = '',
        -- sexp_flow_to_prev_leaf_head    = '',
        -- sexp_flow_to_next_leaf_head    = '',
        -- sexp_flow_to_prev_leaf_tail    = '',
        -- sexp_flow_to_next_leaf_tail    = '',

        sexp_move_to_prev_top_element  = '[[',
        sexp_move_to_next_top_element  = ']]',

        -- sexp_select_prev_element       = '[e',
        -- sexp_select_next_element       = ']e',
        sexp_select_prev_element       = '',
        sexp_select_next_element       = '',

        sexp_indent                    = '==',
        sexp_indent_top                = '=-',
        sexp_round_head_wrap_list      = 'g(',
        sexp_round_tail_wrap_list      = 'g)',
        sexp_square_head_wrap_list     = 'g[',
        sexp_square_tail_wrap_list     = 'g]',
        sexp_curly_head_wrap_list      = 'g{',
        sexp_curly_tail_wrap_list      = 'g}',
        sexp_round_head_wrap_element   = '<(',
        sexp_round_tail_wrap_element   = '>)',
        sexp_square_head_wrap_element  = '<[',
        sexp_square_tail_wrap_element  = '>]',
        sexp_curly_head_wrap_element   = '<{',
        sexp_curly_tail_wrap_element   = '>}',
        -- sexp_insert_at_list_head       = '<C-h>',
        -- sexp_insert_at_list_tail       = '<C-l>',
        sexp_insert_at_list_head       = '',
        sexp_insert_at_list_tail       = '',
        -- sexp_splice_list               = '<Leader>@',
        -- sexp_convolute                 = '<Leader>?',
        sexp_splice_list               = '',
        sexp_convolute                 = '',
        sexp_raise_list                = '<W',
        sexp_raise_element             = '<w',

        sexp_swap_list_backward        = '<M-k>',
        sexp_swap_list_forward         = '<M-j>',
        sexp_swap_element_backward     = '<M-h>',
        sexp_swap_element_forward      = '<M-l>',

        sexp_emit_head_element         = 'gs(',
        sexp_emit_tail_element         = 'gs)',
        sexp_capture_prev_element      = 'ga(',
        sexp_capture_next_element      = 'ga)',
    }
end
