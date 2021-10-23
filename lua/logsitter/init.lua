-------------------------
-- Logsitter module
--
-- @module logsitter
--
-- @todo Handle Function Name declaration (print ”Funtion <naninana> called”)
-- @todo Handle Properties in literal object declaration
-- @todo Handle visual selection (only single line ones)
-- @todo Handle motions (no multiline)
--
local tsutils = require('nvim-treesitter.ts_utils')

local constants = require('logsitter.constants')
local utils     = require('logsitter.utils')
local api       = vim.api
local loggers   = {}
local M   = {}
local opts = {
    logFunc = {
        lua        = "print",
        go         = "fmt.Printf",
        rust       = "dbg",
        javascript = "console.log",
    }
}

--- Finds the node after which the "log" should be inserted
-- @todo refactor to be more legible
local function parent_declaration(checks, node)
    local parent = node

    while parent ~= nil do
        local type = parent:type()
        local r
        local placement

        for _, c in ipairs(checks) do
            if c.test(parent, type) then
                r, placement = c.handle(parent, type)

                if r ~= nil then
                    vim.notify(string.format([[Put %s a "%s" node]], placement, c.name), vim.log.levels.INFO)
                    return r, placement
                end
            end
        end

        parent = parent:parent()
    end

    vim.notify(string.format([[Cannot find a available place for "%s"]], node:type()), vim.log.levels.INFO)
    return nil
end

-- returns the posistion at which the log
-- should be inserted
local function getInsertPos(logger, node, cursorPos)
    local line, col = unpack(cursorPos)
    local decl, placement = parent_declaration(logger.checks, node)

    if decl ~= nil then
        if placement == constants.PLACEMENT_BELOW then
            line, col = decl:end_()
            line = line + 1

        elseif placement == constants.PLACEMENT_ABOVE then
            line, col = decl:start()

        elseif placement == constants.PLACEMENT_INSIDE then
            line, col = decl:start()
            line = line + 1
        end
    end

    return {line, col}
end


function M.setup(customOpts)
    if not customOpts then return end
    assert(type(customOpts) == "table", "Expect table")

    opts = vim.tbl_deep_extend("force", opts, customOpts)

    for _, lang in ipairs{
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
        } do
        if not opts.logFunc[lang] then
            opts.logFunc[lang] = opts.logFunc.javascript
        end
    end
end


function M.register(logger, for_file_types)
    for _, filetype in ipairs(for_file_types) do loggers[filetype] = logger end
end

local function getLogger(filetype)
    return loggers[filetype]
end

function M.log()
    if not opts.logFunc[vim.bo.filetype] then return vim.notify("Unsuppoted filetype") end

    local logger = getLogger(vim.bo.filetype)
    if logger == nil then
        return vim.notify("No logger for " .. vim.bo.filetype, vim.log.levels.INFO)
    end

    local winNr     = api.nvim_get_current_win()
    local node      = tsutils.get_node_at_cursor(winNr)
    local cursorPos = api.nvim_win_get_cursor(winNr)

    if node == nil then return vim.notify("No node found", vim.log.levels.ERROR)end

    local insertPos = getInsertPos(logger, node, cursorPos)

    local text = utils.node_text(logger.expand(node))

    local output = logger.log(text, opts.logFunc[vim.bo.filetype], cursorPos, insertPos)

    api.nvim_win_set_cursor(winNr, insertPos)
    api.nvim_put({output}, "l", true, false)
    vim.cmd[[noa norm! ==^]]
end

M.register(require('logsitter.lang.javascript'),
           {'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx'})
M.register(require('logsitter.lang.go'), {'go'})
M.register(require('logsitter.lang.lua'), {'lua'})

return M
