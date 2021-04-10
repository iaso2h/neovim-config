local lspStatus = require('lsp-status')
local M = {}

function M.setup() -- {{{
    local kindSymbols = {
        '',           -- Text
        '',       -- Function
        '',         -- Method
        '',    -- Constructor
        '',          -- Field
        '',       -- Variable
        '',          -- Class
        '',      -- Interface
        '',         -- Module
        '',       -- Property
        '',           -- Unit
        '',          -- Value
        '',           -- Enum
        ' ',        -- Keyword
        '',        -- Snippet
        '',          -- Color
        '',           -- File
        '',      -- Reference
        '',         -- Folder
        '',     -- EnumMember
        '',       -- Constant
        '',         -- Struct
        '',          -- Event
        '⨋',       -- Operator
        '',  -- TypeParameter
    }

    lspStatus.config {
        kind_labels = kindSymbols,
        select_symbol = function(cursor_pos, symbol)
            if symbol.valueRange then
                local value_range = {
                    ['start'] = {character = 0, line = vim.fn.byte2line(symbol.valueRange[1])},
                    ['end'] = {character = 0, line = vim.fn.byte2line(symbol.valueRange[2])}
                }

                return require('lsp-status/util').in_range(cursor_pos, value_range)
            end
        end,
        current_function   = false,
    }

    lspStatus.register_progress()
end -- }}}


-- LSP Message for galaxyline.nvim {{{
local spinnerFrames = { '🌑', '🌒', '🌓', '🌔', '🌕', '🌖', '🌗', '🌘' }
function M.lspMsg()
    local msgs = lspStatus.messages()
    if next(msgs) then -- {{{
        local parsedMsg
        for _, msg in ipairs(msgs) do
            -- local clientName = "[" .. msg.name .. "]"
            parsedMsg = ""
            if msg.progress then
                parsedMsg = parsedMsg .. " " .. msg.title
                if msg.message then parsedMsg = parsedMsg .. " " .. msg.message end
                if msg.percentage == 0 or not msg.percentage then return "" end
                if msg.percentage then parsedMsg = parsedMsg .. " (" .. msg.percentage .. "%)" end
                if msg.spinner then
                    parsedMsg = spinnerFrames[(msg.spinner % #spinnerFrames) + 1] .. " " .. parsedMsg
                end
                -- elseif msg.status then
                -- parsedMsg = parsedMsg .. " " .. msg.contents
                -- if msg.uri then
                -- local fileName = vim.uri_from_fname(msg.uri)
                -- fileName = vim.fn.fnamemodify(fileName, ":~:.")
                -- local space = math.min(60, math.floor(0.6 * fn.winwidth(0)))
                -- if #fileName > space then fileName = fn.pathshorten(fileName) end

                -- parsedMsg = "(" .. fileName .. ") " .. parsedMsg
                -- end
                -- else
                -- parsedMsg = parsedMsg .. " " .. msg.content
            end
        end
        return parsedMsg
    end -- }}}
    return ""
end
-- }}} LSP Message for galaxyline.nvim

return M

