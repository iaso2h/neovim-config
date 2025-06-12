vim.g.markdown_fenced_languages = {
    'vim',
    'help'
}
return {
    init_options = {
        isNeovim    = true,
        runtimepath = "",
        vimruntime  = "",
        suggest     = {
            fromRuntimepath = true,
            fromVimruntime = true
        },
    },
}
