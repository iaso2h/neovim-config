return function()
    require("lsp_signature").setup {
        bind           = true,
        hint_enable    = false,
        always_trigger = true,
        doc_lines      = 12
    }
    local flipChk = false

    local api = vim.api
    local fn  = vim.fn
    local helper = require('lsp_signature.helper')
    local match_parameter = helper.match_parameter
    local close_events = { 'CursorMoved', 'CursorMovedI', 'BufHidden', 'InsertCharPre' }
    local function virtual_hint(hint, off_y) -- {{{
        if hint == nil or hint == '' then
            return
        end
        local dwidth = fn.strdisplaywidth
        local r = vim.api.nvim_win_get_cursor(0)
        local line = api.nvim_get_current_line()
        local line_to_cursor = line:sub(1, r[2])
        local cur_line = r[1] - 1  -- line number of current line, 0 based
        local show_at = cur_line - 1 -- show at above line
        local lines_above = vim.fn.winline() - 1
        local lines_below = vim.fn.winheight(0) - lines_above
        if lines_above > lines_below then
            show_at = cur_line + 1 -- same line
        end
        local pl
        local completion_visible = helper.completion_visible()
        if off_y ~= nil and off_y < 0 then -- floating win above first
            if completion_visible then
                show_at = cur_line       -- pum, show at current line
            else
                show_at = cur_line - 1   -- show at below line
            end
        end

        if off_y ~= nil and off_y > 0 then
            if completion_visible then
                show_at = cur_line -- pum, show at current line
            else
                show_at = cur_line + 1 -- show at below line
            end
        end

        if _LSP_SIG_CFG.floating_window == false then
            local prev_line, next_line
            if cur_line > 0 then
                prev_line = vim.api.nvim_buf_get_lines(0, cur_line - 1, cur_line, false)[1]
            end
            next_line = vim.api.nvim_buf_get_lines(0, cur_line + 1, cur_line + 2, false)[1]
            if prev_line and vim.fn.strdisplaywidth(prev_line) < r[2] then
                show_at = cur_line - 1
                pl = prev_line
            elseif next_line and dwidth(next_line) < r[2] + 2 and not completion_visible then
                show_at = cur_line + 1
                pl = next_line
            else
                show_at = cur_line
            end

        end

        if lines_above == 0 then
            show_at = cur_line
        end
        -- get show at line
        if not pl then
            pl = vim.api.nvim_buf_get_lines(0, show_at, show_at + 1, false)[1]
        end
        if pl == nil then
            show_at = cur_line -- no lines below
        end
        pl = pl or ''
        local pad = ''
        local line_to_cursor_width = dwidth(line_to_cursor)
        local pl_width = dwidth(pl)
        if show_at ~= cur_line and line_to_cursor_width > pl_width + 1 then
            pad = string.rep(' ', line_to_cursor_width - pl_width)
            local width = vim.api.nvim_win_get_width(0)
            local hint_width = dwidth(_LSP_SIG_CFG.hint_prefix .. hint)
            -- todo: 6 is width of sign+linenumber column
            if #pad + pl_width + hint_width + 6 > width then
                pad = string.rep(' ', math.max(1, line_to_cursor_width - pl_width - hint_width - 6))
            end
        end
        _LSP_SIG_VT_NS = _LSP_SIG_VT_NS or vim.api.nvim_create_namespace('lsp_signature_vt')

        helper.cleanup(false) -- cleanup extmark

        local vt = { pad .. _LSP_SIG_CFG.hint_prefix .. hint, _LSP_SIG_CFG.hint_scheme }

        if r ~= nil then
            vim.api.nvim_buf_set_extmark(0, _LSP_SIG_VT_NS, show_at, 0, {
                virt_text = { vt },
                virt_text_pos = 'eol',
                hl_mode = 'combine',
                -- hl_group = _LSP_SIG_CFG.hint_scheme
            })
        end
    end  -- }}}

    local signature_handler = function(err, result, ctx, config) -- {{{
        if err ~= nil then
            print(err)
            return
        end

        -- log("sig result", ctx, result, config)
        -- if config.check_client_handlers then
        --   -- this feature will be removed
        --   if helper.client_handler(err, result, ctx, config) then
        --     return
        --   end
        -- end
        local client_id = ctx.client_id
        local bufnr = ctx.bufnr
        if result == nil or result.signatures == nil or result.signatures[1] == nil then
            -- only close if this client opened the signature

            if _LSP_SIG_CFG.client_id == client_id then
                helper.cleanup_async(true, 0.2, true)
                -- need to close floating window and virtual text (if they are active)
            end

            return
        end
        if api.nvim_get_current_buf() ~= bufnr then
            return
        end

        if config.trigger_from_next_sig then
            if #result.signatures > 1 then
                local cnt = math.abs(config.activeSignature - result.activeSignature)
                for _ = 1, cnt do
                    local m = result.signatures[1]
                    table.insert(result.signatures, #result.signatures + 1, m)
                    table.remove(result.signatures, 1)
                end
                result.cfgActiveSignature = config.activeSignature
            end
        else
            result.cfgActiveSignature = 0 -- reset
        end
        _LSP_SIG_CFG.signature_result = result

        local activeSignature = result.activeSignature or 0
        activeSignature = activeSignature + 1
        if activeSignature > #result.signatures then
            -- this is a upstream bug of metals
            activeSignature = #result.signatures
        end

        local actSig = result.signatures[activeSignature]

        if actSig == nil then
            print('no valid signature or incorrect lsp reponse ', vim.inspect(result))
            return
        end

        -- label format and trim
        actSig.label = string.gsub(actSig.label, '[\n\r\t]', ' ')
        if actSig.parameters then
            for i = 1, #actSig.parameters do
                if type(actSig.parameters[i].label) == 'string' then
                    actSig.parameters[i].label = string.gsub(actSig.parameters[i].label, '[\n\r\t]', ' ')
                end
            end
        end

        -- if multiple signatures existed, find the best match and correct parameter
        local _, hint, s, l = match_parameter(result, config)
        local force_redraw = false
        if #result.signatures > 1 then
            force_redraw = true
            for i = #result.signatures, 1, -1 do
                local sig = result.signatures[i]
                -- hack for lua
                local actPar = sig.activeParameter or result.activeParameter or 0
                if actPar > 0 and actPar + 1 > #(sig.parameters or {}) then
                    print('invalid lsp response, active parameter out of boundary')
                    -- reset active parameter to last parameter
                    sig.activeParameter = #(sig.parameters or {})
                end
            end
        end

        local mode = vim.api.nvim_get_mode().mode
        local insert_mode = (mode == 'niI' or mode == 'i')
        local floating_window_on = (
            _LSP_SIG_CFG.winnr ~= nil
            and _LSP_SIG_CFG.winnr ~= 0
            and api.nvim_win_is_valid(_LSP_SIG_CFG.winnr)
            )
        if config.trigger_from_cursor_hold and not floating_window_on and not insert_mode then
            return
        end

        -- trim the doc
        if _LSP_SIG_CFG.doc_lines == 0 and config.trigger_from_lsp_sig then -- doc disabled
            helper.remove_doc(result)
        end

        if _LSP_SIG_CFG.hint_enable == true then
            if _LSP_SIG_CFG.floating_window == false then
                virtual_hint(hint, 0)
            end
        else
            _LSP_SIG_VT_NS = _LSP_SIG_VT_NS or vim.api.nvim_create_namespace('lsp_signature_vt')

            helper.cleanup(false) -- cleanup extmark
        end
        -- I do not need a floating win
        if
            _LSP_SIG_CFG.floating_window == false
            and config.toggle ~= true
            and config.trigger_from_lsp_sig
        then
            return {}, s, l
        end

        if _LSP_SIG_CFG.floating_window == false and config.trigger_from_cursor_hold then
            return {}, s, l
        end
        local off_y
        local ft = vim.api.nvim_buf_get_option(bufnr, 'ft')

        ft = helper.ft2md(ft)
        -- handles multiple file type, we should just take the first filetype
        -- find the first file type and substring until the .
        local dot_index = string.find(ft, '%.')
        if dot_index ~= nil then
            ft = string.sub(ft, 0, dot_index - 1)
        end

        local lines = vim.lsp.util.convert_signature_help_to_markdown_lines(result, ft)

        if lines == nil or type(lines) ~= 'table' then
            return
        end

        lines = vim.lsp.util.trim_empty_lines(lines)
        -- offset used for multiple signatures
        -- makrdown format
        local offset = 2
        local num_sigs = #result.signatures
        if #result.signatures > 1 then
            if string.find(lines[1], [[```]]) then -- markdown format start with ```, insert pos need after that
                offset = 3
            end
            for index, sig in ipairs(result.signatures) do
                if index ~= activeSignature then
                    table.insert(lines, offset, sig.label)
                    offset = offset + 1
                end
            end
        end

        -- log("md lines", lines)
        local label = result.signatures[1].label
        if #result.signatures > 1 then
            label = result.signatures[activeSignature].label
        end


        -- truncate empty document it
        if
            result.signatures[activeSignature].documentation
            and result.signatures[activeSignature].documentation.kind == 'markdown'
            and result.signatures[activeSignature].documentation.value == '```text\n\n```'
        then
            result.signatures[activeSignature].documentation = nil
            lines = vim.lsp.util.convert_signature_help_to_markdown_lines(result, ft)

        end

        local pos = api.nvim_win_get_cursor(0)
        local line = api.nvim_get_current_line()
        local line_to_cursor = line:sub(1, pos[2])

        local woff = 1
        if config.triggered_chars and vim.tbl_contains(config.triggered_chars, '(') then
            woff = helper.cal_woff(line_to_cursor, label)
        end

        -- total lines allowed
        if config.trigger_from_lsp_sig then
            lines = helper.truncate_doc(lines, num_sigs)
        end

        -- log(lines)
        if vim.tbl_isempty(lines) then
            return
        end
        local syntax = vim.lsp.util.try_trim_markdown_code_blocks(lines)

        if config.trigger_from_lsp_sig == true and _LSP_SIG_CFG.preview == 'guihua' then
            -- This is a TODO
            error('guihua text view not supported yet')
        end
        helper.update_config(config)

        if type(_LSP_SIG_CFG.fix_pos) == 'function' then
            local client = vim.lsp.get_client_by_id(client_id)
            _LSP_SIG_CFG._fix_pos = _LSP_SIG_CFG.fix_pos(result, client)
        else
            _LSP_SIG_CFG._fix_pos = _LSP_SIG_CFG.fix_pos or true
        end

        -- when should the floating close
        config.close_events = { 'BufHidden' } -- , 'InsertLeavePre'}
        if not _LSP_SIG_CFG._fix_pos then
            config.close_events = close_events
        end
        if not config.trigger_from_lsp_sig then
            config.close_events = close_events
        end
        if force_redraw and _LSP_SIG_CFG._fix_pos == false then
            config.close_events = close_events
        end
        if
            result.signatures[activeSignature].parameters == nil
            or #result.signatures[activeSignature].parameters == 0
        then
            -- auto close when fix_pos is false
            if _LSP_SIG_CFG._fix_pos == false then
                config.close_events = close_events
            end
        end
        config.zindex = _LSP_SIG_CFG.zindex

        -- fix pos
        local new_line = helper.is_new_line()

        local display_opts

        display_opts, off_y = helper.cal_pos(lines, config)

        if _LSP_SIG_CFG.hint_enable == true then
            local v_offy = off_y
            if v_offy < 0 then
                v_offy = 1 -- put virtual text below current line
            end
            virtual_hint(hint, v_offy)
        end

        if _LSP_SIG_CFG.floating_window_off_x then
            local offx = _LSP_SIG_CFG.floating_window_off_x
            if type(offx) == 'function' then
                woff = woff + offx({ x_off = woff })
            else
                woff = woff + offx
            end
        end

        config.offset_x = woff
        if _LSP_SIG_CFG.padding ~= '' then
            for lineIndex = 1, #lines do
                lines[lineIndex] = _LSP_SIG_CFG.padding .. lines[lineIndex] .. _LSP_SIG_CFG.padding
            end
            config.offset_x = config.offset_x - #_LSP_SIG_CFG.padding
        end

        if _LSP_SIG_CFG.floating_window_off_y then
            string.find("test", "t")
            config.offset_y = _LSP_SIG_CFG.floating_window_off_y
            if type(config.offset_y) == 'function' then
                config.offset_y = _LSP_SIG_CFG.floating_window_off_y(display_opts)
            end
        end

        -- print('Before flip: config.offset_y=' .. config.offset_y, "anchor" .. display_opts.anchor, "off_y:" .. off_y)
        config.offset_y = off_y + config.offset_y
        if flipChk then
            if display_opts.anchor:sub(1, 1) == "N" then
                if off_y >= 0 then
                    config.offset_y = config.offset_y - display_opts.height
                else
                    config.offset_y = config.offset_y + display_opts.height + 3
                end
                display_opts.anchor = "S" .. display_opts.anchor:sub(2, 2)
            else
                config.offset_y = config.offset_y + display_opts.height + 3
                display_opts.anchor = "N" .. display_opts.anchor:sub(2, 2)
            end
            -- print('After flip: config.offset_y=' .. config.offset_y, "anchor" .. display_opts.anchor, "off_y:" .. off_y)
        end
        config.focusable = true -- allow focus
        config.max_height = display_opts.max_height
        config.noautocmd = true

        -- try not to overlap with pum autocomplete menu
        if
            config.check_completion_visible
            and helper.completion_visible()
            and ((display_opts.anchor == 'NW' or display_opts.anchor == 'NE') and off_y == 0)
            and _LSP_SIG_CFG.zindex < 50
        then
            return
        end

        config.noautocmd = true
        if _LSP_SIG_CFG._fix_pos and _LSP_SIG_CFG.bufnr and _LSP_SIG_CFG.winnr then
            if
                api.nvim_win_is_valid(_LSP_SIG_CFG.winnr)
                and _LSP_SIG_CFG.label == label
                and not new_line
            then
            else
                -- vim.api.nvim_win_close(_LSP_SIG_CFG.winnr, true)
                _LSP_SIG_CFG.bufnr, _LSP_SIG_CFG.winnr =
                    vim.lsp.util.open_floating_preview(lines, syntax, config)

                -- vim.api.nvim_buf_set_option(_LSP_SIG_CFG.bufnr, "filetype", "")
                log('sig_cfg bufnr, winnr not valid recreate', _LSP_SIG_CFG.bufnr, _LSP_SIG_CFG.winnr)
                _LSP_SIG_CFG.label = label
                _LSP_SIG_CFG.client_id = client_id
            end
        else
            _LSP_SIG_CFG.bufnr, _LSP_SIG_CFG.winnr =
                vim.lsp.util.open_floating_preview(lines, syntax, config)
            _LSP_SIG_CFG.label = label
            _LSP_SIG_CFG.client_id = client_id


            -- vim.api.nvim_buf_set_option(_LSP_SIG_CFG.bufnr, "filetype", "lsp_signature")
        end

        if
            _LSP_SIG_CFG.transparency
            and _LSP_SIG_CFG.transparency > 1
            and _LSP_SIG_CFG.transparency < 100
        then
            if type(_LSP_SIG_CFG.winnr) == 'number' and vim.api.nvim_win_is_valid(_LSP_SIG_CFG.winnr) then
                vim.api.nvim_win_set_option(_LSP_SIG_CFG.winnr, 'winblend', _LSP_SIG_CFG.transparency)
            end
        end
        local sig = result.signatures
        -- if it is last parameter, close windows after cursor moved

        local actPar = sig.activeParameter or result.activeParameter or 0
        if
            sig and sig[activeSignature].parameters == nil
            or actPar == nil
            or actPar + 1 == #sig[activeSignature].parameters
        then
            if _LSP_SIG_CFG._fix_pos == false then
                vim.lsp.util.close_preview_autocmd(close_events, _LSP_SIG_CFG.winnr)
                -- elseif _LSP_SIG_CFG._fix_pos then
                --   vim.lsp.util.close_preview_autocmd(close_events_au, _LSP_SIG_CFG.winnr)
            end
            if _LSP_SIG_CFG.auto_close_after then
                helper.cleanup_async(true, _LSP_SIG_CFG.auto_close_after)
            end
        end
        helper.highlight_parameter(s, l)

        return lines, s, l
    end -- }}}

    local flipSignature = function()
        flipChk = not flipChk

        if _LSP_SIG_CFG.winnr and _LSP_SIG_CFG.winnr > 0 and
                vim.api.nvim_win_is_valid(_LSP_SIG_CFG.winnr) then

            vim.api.nvim_win_close(_LSP_SIG_CFG.winnr, true)
            _LSP_SIG_CFG.winnr = nil
            _LSP_SIG_CFG.bufnr = nil
            if _LSP_SIG_VT_NS then
                vim.api.nvim_buf_clear_namespace(0, _LSP_SIG_VT_NS, 0, -1)
            end

            -- Close cmp at the same time
            if package.loaded["cmp"] and require("cmp").visible() then
                require("cmp.utils.autocmd").emit("InsertLeave")
            end

        else
            -- Float win is not visible?
            return
        end
        local params = vim.lsp.util.make_position_params()
        local pos = api.nvim_win_get_cursor(0)
        local line = api.nvim_get_current_line()
        local line_to_cursor = line:sub(1, pos[2])
        -- Try using the already binded one, otherwise use it without custom config.
        vim.lsp.buf_request(
            0,
            'textDocument/signatureHelp',
            params,
            vim.lsp.with(signature_handler, {
                check_completion_visible = true,
                trigger_from_lsp_sig = true,
                toggle = true,
                line_to_cursor = line_to_cursor,
                border = _LSP_SIG_CFG.handler_opts.border,
            })
        )
    end

    map("i", "<A-o>", function() flipSignature() end, { "silent", "noremap" }, "Toggle signature")
end
