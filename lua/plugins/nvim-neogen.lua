return function()
    require("neogen").setup {
        enabled             = true,
        input_after_comment = true,
        languages = {
            lua = {
                template = {
                    annotation_convention = "emmylua"
                }
            },
            python = {
                template = {
                    annotation_convention = "google_docstrings"
                }
            },
            c = {
                template = {
                    annotation_convention = "doxygen"
                }
            },
            csharp = {
                template = {
                    annotation_convention = "xmldoc"
                }
            },
            rust = {
                template = {
                    annotation_convention = "rustdoc"
                }
            },
            typescript = {
                template = {
                    annotation_convention = "jsdoc"
                }
            },
            typescriptreact = {
                template = {
                    annotation_convention = "jsdoc"
                }
            },
        }
    }
    map("n", [[gcd]], [[<CMD>lua vim.api.nvim_feedkeys(":Neogen <Tab>", "nt", true)<CR>]], "Document generation")
end
