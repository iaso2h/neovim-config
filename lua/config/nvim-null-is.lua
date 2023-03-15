return function()
    local null_ls = require "null-ls"
    local mason_null_is = require "mason-null-ls"

    mason_null_is.setup {
        ensure_installed = {
            "stylua", "selene",
            "deno",
            "black",
            "beautysh",
            "write-good",
        },
        automatic_installation = true,
    }

    local onAttach = function(client, bufNr)
        if client.supports_method("textDocument/formatting") then
            bmap(bufNr, "n", [[<A-f>]], [[<CMD>lua vim.lsp.buf.format{async=true}<CR>]], { "silent" }, "Format")
            bmap(bufNr, "x", [[<A-f>]],
[[:lua vim.lsp.buf.format{async=true,range={start=vim.api.nvim_buf_get_mark(0,"<"),["end"]=vim.api.nvim_buf_get_mark(0, ">")}}<CR>]],
                { "silent" }, "Format")
        end
    end

    null_ls.setup {
        -- Not supported by mason.
        sources = {
            null_ls.builtins.formatting.emacs_scheme_mode
        },
        -- diagnostics_format = "[#{c}] #{m} (#{s})",
        on_attach = onAttach
    }

    mason_null_is.setup_handlers {
        function(source_name, methods)
            -- all sources with no handler get passed here To keep the original
            -- functionality of `automatic_setup = true`, please add the below.
            require("mason-null-ls.automatic_setup")(source_name, methods)
        end,
        selene = function(source_name, methods)
            null_ls.register(null_ls.builtins.diagnostics.selene.with {
                extra_args = function(params)
                    local results = vim.fs.find({ "selene.toml" }, {
                        upward = true,
                        path = vim.api.nvim_buf_get_name(0),
                    })
                    if #results == 0 then
                        return params
                    else
                        return { "--config", results[1] }
                    end
                end
            })
        end,
    }
end
