return function()
    local NoNeckPain = require("no-neck-pain")

    NoNeckPain.setup {         -- {{{
        -- The width of the focused window that will be centered. When the terminal width is less than the `width` option, the side buffers won't be created.
        --- @type integer|"textwidth"|"colorcolumn"
        width = 100,
        -- Represents the lowest width value a side buffer should be.
        -- This option can be useful when switching window size frequently, example:
        -- in full screen screen, width is 210, you define an NNP `width` of 100, which creates each side buffer with a width of 50. If you resize your terminal to the half of the screen, each side buffer would be of width 5 and thereforce might not be useful and/or add "noise" to your workflow.
        --- @type integer
        minSideBufferWidth = 10,
        autocmds = {
            enableOnVimEnter = false,
            enableOnTabEnter = false,
        },
        mappings = {
            enabled    = true,
            toggle     = "<Leader>z",
            widthUp    = "<Leader>z+",
            widthDown  = "<Leader>z-",
            scratchPad = "<Leader>Z",
        },
        buffers = {
            -- Leverages the side buffers as notepads, which work like any Neovim buffer and automatically saves its content at the given `location`.
            -- note: quitting an unsaved scratchpad buffer is non-blocking, and the content is still saved.
            --- see |NoNeckPain.bufferOptionsScratchpad|
            scratchPad = NoNeckPain.bufferOptionsScratchpad,
            -- colors to apply to both side buffers, for buffer scopped options @see |NoNeckPain.bufferOptions|
            --- see |NoNeckPain.bufferOptionsColors|
            colors = NoNeckPain.bufferOptionsColors,
            -- Vim buffer-scoped options: any `vim.bo` options is accepted here.
            --- @see NoNeckPain.bufferOptionsBo `:h NoNeckPain.bufferOptionsBo`
            bo = NoNeckPain.bufferOptionsBo,
            -- Vim window-scoped options: any `vim.wo` options is accepted here.
            --- @see NoNeckPain.bufferOptionsWo `:h NoNeckPain.bufferOptionsWo`
            wo = NoNeckPain.bufferOptionsWo,
            --- Options applied to the `left` buffer, options defined here overrides the `buffers` ones.
            --- @see NoNeckPain.bufferOptions `:h NoNeckPain.bufferOptions`
            left = NoNeckPain.bufferOptions,
            --- Options applied to the `right` buffer, options defined here overrides the `buffers` ones.
            --- @see NoNeckPain.bufferOptions `:h NoNeckPain.bufferOptions`
            right = NoNeckPain.bufferOptions,
        },
        integrations = {
            NvimTree = {
                position = "left",
                reopen = false,
            },
        },
    }         -- }}}
    NoNeckPain.bufferOptions = {
        -- When `false`, the buffer won't be created.
        enabled = true,
        colors = NoNeckPain.bufferOptionsColors,
        bo = NoNeckPain.bufferOptionsBo,
        wo = NoNeckPain.bufferOptionsWo,
        scratchPad = NoNeckPain.bufferOptionsScratchpad,
    }

    NoNeckPain.bufferOptionsWo = {
        cursorline = true,
        cursorcolumn = false,
        colorcolumn = "80",
        number = true,
        relativenumber = false,
        foldenable = true,
        list = false,
        wrap = true,
        linebreak = true,
    }

    NoNeckPain.bufferOptionsBo = {
        filetype = "no-neck-pain",
        buftype = "nofile",
        bufhidden = "hide",
        buflisted = false,
        swapfile = false,
    }

    --- NoNeckPain's scratchpad buffer options.
    NoNeckPain.bufferOptionsScratchpad = {
        -- When `true`, automatically sets the following options to the side buffers:
        -- - `autowriteall`
        -- - `autoread`.
        --- @type boolean
        enabled = false,
        -- The name of the generated file. See `location` for more information.
        --- @type string
        --- @example: `no-neck-pain-left.norg`
        fileName = "scratchPad",
        -- By default, files are saved at the same location as the current Neovim session.
        -- note: filetype is defaulted to `norg` (https://github.com/nvim-neorg/neorg), but can be changed in `buffers.bo.filetype` or |NoNeckPain.bufferOptions| for option scoped to the `left` and/or `right` buffer.
        --- @type string?
        --- @example: `no-neck-pain-left.norg`
        location = nil,
    }

    NoNeckPain.bufferOptionsColors = {
        background = nil,
        blend = 0,
        text = nil,
    }
end
