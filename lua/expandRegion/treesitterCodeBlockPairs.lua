-- UGLY: Because in some cases, keyword cannot be used as the key of a table,
-- so as a workaroudn, every key item has to be prefix with "ts_"

-- Take the "ts_if_statement" key table for example, the "pairs" key is used
-- to indicate a table in which every keyword can form a syntax pairs that can
-- determine a code block together will ts_if_statement(namely "if_statement").
-- If the "pairs" key table contains only nil as element, then there is no
-- correspond treesitter keyword statement node to mark the end of the code
-- block. In that case, we have to cycle all the ts_if_statement(namely
-- "if_statement") child nodes untill no more child is available, then we will
-- retrieve the last valid child node to mark the end of the code block.
-- The "skip" key table is used to skip the code block analyze process when
-- the last expand region candidate node comes from these treesitter
-- nodes(usually including "condition_expression")
return {
    ts_if_statement = {
        childStart = 1,
        pairs      = {"elseif", "else"},
        skips      = {"elseif", "else", "condition_expression"}
    },
    ts_elseif = {
        childStart = 1,
        pairs      = {"else"},
        skips      = {"else", "condition_expression"}
    },
    ts_else = {
        childStart = 0,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_function_definition = {
        childStart = 1,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_while_statement = {
        childStart = 1,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_repeat_statement = {
        childStart = 0,
        pairs      = {"condition_expression"},
        skips      = {"condition_expression"}
    },
    ts_for_in_statement = {
        childStart = 1,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_do_block = {
        childStart = 0,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_object = {
        childStart = 0,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_object_type = {
        childStart = 0,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_array = {
        childStart = 0,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_parenthesized_expression = {
        childStart = 0,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_formal_parameters = {
        childStart = 0,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_arguments = {
        childStart = 0,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_parameters = {
        childStart = 0,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_statement_block = {
        childStart = 0,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_compound_statement = {
        childStart = 0,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_case_statement = {
        childStart = 1,
        pairs      = {nil},
        skips      = {nil}
    },
    ts_initializer_list = {
        childStart = 0,
        pairs      = {nil},
        skips      = {nil}
    },
}
