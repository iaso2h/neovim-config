local M = {}

local utils = require('logsitter.utils')
local constants = require('logsitter.constants')

M.checks = {
    {
        name = "function_call",
        test = function(_, type)
            return type == 'function_call'
        end,
        handle = function(node, _)
            local grand_parent = node:parent()

            if grand_parent == nil then return node, constants.PLACEMENT_BELOW end

            local gp_type = grand_parent:type()
            local below = {
                "statement_block",
                "function_definition",
                "local_function",
            }
            local above = {
                "return_statement" ,
                "for_statement",
                "while_statement"
            }

            if vim.tbl_contains(below, gp_type) then
                return node, constants.PLACEMENT_BELOW
            end

            if vim.tbl_contains(above, gp_type) then
                return node, constants.PLACEMENT_ABOVE
            end

            return nil, nil
        end
    }, {
        name = "parameter",
        test = function(node, type)
            local parent = node:parent()
            return parent ~= nil and parent:type() == "parameters" and type == "identifier"
        end,
        handle = function(node, _)
            return node:parent(), constants.PLACEMENT_BELOW
        end
    }, {
        name = "return",
        test = function(node, _)
            local parent = node:parent()
            return parent ~= nil and parent:type() == "return_statement"
        end,
        handle = function(node, _)
            return node:parent(), constants.PLACEMENT_ABOVE
        end
    }, {
        name = "declaration",
        test = function(_, type)
            return utils.ends_with(type, "declaration") or utils.ends_with(type, "declarator")
        end,
        handle = function(node, _)
            return node, constants.PLACEMENT_BELOW
        end
    }, {
        name = "if, for, while",
        test = function(_, type)
            return type == "condition_expression"
        end,
        handle = function(node, _)
            local parent = node:parent()
            if parent ~= nil then
                local first_child = parent:child(1)
                return first_child, constants.PLACEMENT_BELOW
                -- return first_child, constants.PLACEMENT_INSIDE
            end
            return node
        end
    }
}

function M.expand(node)
    local parent = node:parent()

    if parent ~= nil then
        local type = parent:type()

        if type == 'function_call' or type == 'field_expression' then return parent end
    end

    return node
end

function M.log(text, funcStr, cursorPos)
    local label = text:gsub('"', '\\"')
    return string.format([[%s("LOG: %s, line %s: %s: " .. %s)]], funcStr, vim.fn.expand("%"), cursorPos[1], label, text)
end

return M
