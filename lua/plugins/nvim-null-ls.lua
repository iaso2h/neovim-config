-- TODO: add custom adding stubs action
return function()
    local null_ls       = require "null-ls"
    local mason_null_ls = require "mason-null-ls"

    local onAttach = function(client, bufNr)
        if client.supports_method("textDocument/formatting") then
            bmap(bufNr, "n", [[<A-f>]], function()
                vim.lsp.buf.format {
                    name = "null-ls",
                    async = true
                }
            end, "Format")
            bmap(bufNr, "x", [[<A-f>]], luaRHS[[:lua
            local bufNr = vim.api.nvim_get_current_buf()
            vim.lsp.buf.format {
                name = "null-ls",
                async = true,
                range = {
                    ["start"] = {vim.api.nvim_buf_get_mark(bufNr, "<")[1], 0},
                    ["end"]   = {vim.api.nvim_buf_get_mark(bufNr, ">")[1], 0}
                }
            }<CR>]], { "silent" }, "Format selection")
        end
    end

    --- Create Toggle Ex command for lanuage server
    ---@param valName string Prefix for control variable name in vim.g[] and vim.b[]
    ---@param exCmdName string Prefix for Ex command name
    ---@param initialState boolean
    local toggleCmdCreator = function(valName, exCmdName, initialState) -- {{{
        -- Create Global Ex Command
        vim.g["_" .. valName .. "Enabled"] = initialState
        vim.api.nvim_create_user_command(exCmdName .. "Toggle", function()
            vim.g["_" .. valName .. "Enabled"] = not vim.g["_" .. valName .. "Enabled"]

            local notifyStr = vim.g["_" .. valName .. "Enabled"] and "enabled" or "disabled"
            vim.api.nvim_echo({ { string.format("%s has been %s", exCmdName, notifyStr), "Moremsg" } }, false, {})
        end, {
            desc = string.format("Toggle %s checking", exCmdName),
        })

        -- Create Buffer Ex Command
        vim.b["_" .. valName .. "Enabled"] = true
        vim.api.nvim_create_user_command(exCmdName .. "BufToggle", function()
            -- Toggle
            vim.b["_" .. valName .. "Enabled"] = not vim.b["_" .. valName .. "Enabled"]
            -- Overall State
            local state = vim.g["_" .. valName .. "Enabled"] and vim.b["_" .. valName .. "Enabled"]

            vim.diagnostic.reset(nil, vim.api.nvim_get_current_buf())
            vim.diagnostic.show(nil, vim.api.nvim_get_current_buf(), nil, nil)
            -- UGLY: refresh virtual diagnostic text
            if vim.o.modifiable then
                vim.api.nvim_set_current_line(vim.api.nvim_get_current_line())
            end
            local notifyStr = state and "enabled" or "disabled"
            vim.api.nvim_echo({ { string.format("%s has been %s buffer locally", exCmdName, notifyStr), "Moremsg" } }, false, {})
        end, {
            desc = string.format("Toggle %s checking buffer locally", exCmdName),
        })
    end -- }}}

    local selene = null_ls.builtins.diagnostics.selene.with { -- {{{
        extra_args = function(params)
            local results = vim.fs.find({ "selene.toml" }, {
                upward = true,
                path   = vim.fs.dirname( nvim_buf_get_name(0)),
            })
            if #results == 0 then
                return params
            else
                return { "--config", results[1] }
            end
        end,
        runtime_condition = function(params)
            if vim.g._seleneEnabled and vim.b._seleneEnabled then
                return true
            end
            return false
        end,
        filter = function(diagnostic)
            if type(diagnostic) == "string" then
                -- HACK: https://bbs.archlinux.org/viewtopic.php?id=274705
                if not string.match(diagnostic, "GLIBC") then
                    vim.notify(diagnostic, vim.log.levels.ERROR)
                end
                return false
            end

            if not diagnostic.message then return true end
            local filterMsg = {
                [[use of `_G` is not allowed]],
            }
            for _, msg in ipairs(filterMsg) do
                if string.match(diagnostic.message, msg) then
                    return false
                end
            end
            return true
        end
    } -- }}}
    toggleCmdCreator("selene", "Selene", false)

    local cspell = null_ls.builtins.diagnostics.cspell.with { -- {{{
        disabled_filetypes = _G._short_line_list,
        extra_args = {
            "--gitignore",
            "--config",
            string.format([[%s%scspell.json]], _G._config_path, _G._sep),
        },
        runtime_condition = function(params)
            if params.bufname == "" or not vim.api.nvim_buf_get_option(params.bufnr, "buflisted") then
                return false
            end
            if vim.g._cspellEnabled and vim.b._cspellEnabled then
                return true
            end
            return false
        end,
        diagnostics_postprocess = function(diagnostic)
            if type(diagnostic) ~= "table" then return end
            diagnostic.severity = vim.diagnostic.severity.WARN
        end
    }

    -- Add new word to ignore dictionary {{{
    -- Credit: https://zenn.dev/kawarimidoll/articles/2e99432d27eda3
    local cspellAppend = function(opts)
        local word = opts.args
        if not word or word == "" then
            word = vim.fn.expand("<cword>"):lower()
        end

        local filePath = _G._config_path .. pathStr[[/data/dict/cspell/cspell.txt]]
        io.popen(string.format("echo %s >> %s", word, filePath))
        vim.notify(string.format([["%s" is appended to user dictionary.]], word), vim.log.levels.INFO)

        if vim.o.modifiable then
            vim.api.nvim_set_current_line(vim.api.nvim_get_current_line())
        end
    end

    vim.api.nvim_create_user_command("CSpellAppend", cspellAppend, { nargs = "?", bang = true })

    local cspellAppendAction = {
        method = null_ls.methods.CODE_ACTION,
        filetypes = {},
        generator = {
            fn = function(_)
                local cursorPos   = vim.api.nvim_win_get_cursor(0)
                local lnum        = cursorPos[1] - 1
                local col         = cursorPos[2]

                local diagnostics = vim.diagnostic.get(0, { lnum = lnum })

                local word        = ""
                local regex       = "^Unknown word %((%w+)%)$"
                for _, v in pairs(diagnostics) do
                    -- HACK: v.end_col will be 0 if same error occurred on the
                    -- same line
                    if v.source == "cspell" and v.col <= col and col <= v.end_col and string.match(v.message, regex) then
                        word = string.gsub(v.message, regex, "%1"):lower()
                        break
                    end
                end

                if word == "" then
                    return
                end

                return {
                    {
                        title = 'Append "' .. word .. '" to user dictionary',
                        action = function()
                            cspellAppend({ args = word })
                        end,
                    },
                }
            end,
        },
    } -- }}} Add new word to ignore dictionary
    -- }}}
    toggleCmdCreator("cspell", "CSpell", true)

    local builtinSource = {
        cspellAppend = cspellAppendAction,
    }
    if _G._os_uname.sysname == "Linux" then
        builtinSource.fnlfmt = null_ls.builtins.formatting.fnlfmt.with {
            command = [[/home/iaso2h/Project/Github/fnlfmt/fnlfmt]],
        }
    end

    for _, source in pairs(builtinSource) do null_ls.register(source) end

    -- Auto setup by mason
    local handlerArgs = {
        cspell           = function() null_ls.register(cspell) end,
        ["clang-format"] = function() null_ls.register(null_ls.builtins.formatting.clang_format) end,
        stylua           = function() null_ls.register(null_ls.builtins.formatting.stylua) end,
        selene           = function() null_ls.register(selene) end,
        deno             = function() null_ls.register(null_ls.builtins.formatting.deno_fmt) end,
        black            = function() null_ls.register(null_ls.builtins.formatting.black) end,
        beautysh         = function() null_ls.register(null_ls.builtins.formatting.beautysh) end,
        ["write-good"]   = function() null_ls.register(null_ls.builtins.formatting.emacs_scheme_mode) end,
    }
    mason_null_ls.setup {
        ensure_installed       = vim.tbl_keys(handlerArgs),
        automatic_installation = true,
        automatic_setup        = false,
        handlers               = handlerArgs
    }

    null_ls.setup {
        -- diagnostics_format = "[#{c}] #{m} (#{s})",
        on_attach = onAttach
    }
end
