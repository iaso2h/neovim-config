return function()

    local cmd = vim.cmd

    -- set to 1, nvim will open the preview window after entering the markdown buffer
    -- defaulvim.t. 0
    vim.g.mkdp_auto_start = 0

    -- set to 1, the nvim will auto close current preview window when change
    -- from markdown buffer to another buffer
    -- defaulvim.t. 1
    vim.g.mkdp_auto_close = 1

    -- set to 1, the vim will refresh markdown when save the buffer or
    -- leave from insert mode, default 0 is auto refresh markdown as you edit or
    -- move the cursor
    -- defaulvim.t. 0
    vim.g.mkdp_refresh_slow = 1

    -- set to 1, the MarkdownPreview command can be use for all files,
    -- by default it can be use in markdown file
    -- defaulvim.t. 0
    vim.g.mkdp_command_for_global = 0

    -- set to 1, preview server available to others in your network
    -- by default, the server listens on localhost (127.0.0.1)
    -- defaulvim.t. 0
    vim.g.mkdp_open_to_the_world = 0

    -- use custom IP to open preview page
    -- useful when you work in remote vim and preview on local browser
    -- more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
    -- default empty
    vim.g.mkdp_open_ip = ''

    -- specify browser to open preview page
    -- defaulvim.t. ''
    vim.g.mkdp_browser = ''

    -- set to 1, echo preview page url in command line when open preview page
    -- default is 0
    vim.g.mkdp_echo_preview_url = 0

    -- a custom vim function name to open preview page
    -- this function will receive url as param
    -- default is empty
    -- vim.g.mkdp_browserfunc = [[require("getLink").main]]
    vim.g.mkdp_browserfunc = ''
    -- options for markdown render
    -- mkivim.t. markdown-it options for render
    -- katex: katex options for math
    -- uml: markdown-it-plantuml options
    -- maid: mermaid options
    -- disable_sync_scroll: if disable sync scroll, default 0
    -- sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
    --   middle: mean the cursor position alway show at the middle of the preview page
    --   top: mean the vim top viewport alway show at the top of the preview page
    --   relative: mean the cursor position alway show at the relative positon of the preview page
    -- hide_yaml_met if hide yaml metadata, default is 1
    -- sequence_diagrams: js-sequence-diagrams options
    -- content_editable: if enable content editable for preview page, defaulvim.t. vim.v.false
    -- disable_filename: if disable filename header for preview page, defaulvim.t. 0
    vim.g.mkdp_preview_options = {
        mkit                = {},
        katex               = {},
        uml                 = {},
        maid                = {},
        disable_sync_scroll = 1,
        sync_scroll_type    = 'middle',
        hide_yaml_meta      = 1,
        sequence_diagrams   = {},
        flowchart_diagrams  = {},
        content_editable    = false,
        disable_filename    = 0
    }

    -- use a custom markdown style must be absolute path
    -- like '/Users/username/markdown.css' or fn.expand('~/markdown.css')
    vim.g.mkdp_markdown_css = ''

    -- use a custom highlight style must absolute path
    -- like '/Users/username/highlight.css' or fn.expand('~/highlight.css')
    vim.g.mkdp_highlight_css = ''

    -- use a custom port to start server or random for empty
    vim.g.mkdp_port = ''

    -- preview page title
    -- ${name} will be replace with the file name
    vim.g.mkdp_page_title = '「${name}」'

    -- recognized filetypes
    -- these filetypes will have MarkdownPreview... commands
    vim.g.mkdp_filetypes = {'markdown'}

    -- use a custom markdown style must be absolute path
    -- like '/Users/username/markdown.css' or fn.expand('~/markdown.css')
    vim.g.mkdp_markdown_css = ''

    -- use a custom highlight style must absolute path
    -- like '/Users/username/highlight.css' or fn.expand('~/highlight.css')
    vim.g.mkdp_highlight_css = ''

    -- use a custom port to start server or random for empty
    vim.g.mkdp_port = ''

    -- preview page title
    -- ${name} will be replace with the file name
    vim.g.mkdp_page_title = '「${name}」'

    -- recognized filetypes
    -- these filetypes will have MarkdownPreview... commands
    vim.g.mkdp_filetypes = {'markdown'}
end
