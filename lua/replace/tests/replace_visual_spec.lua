-- TODO: restore cursor for dot repeat

local function setUpMapping() -- {{{
    require("util")

    map("n", [[<Plug>ReplaceOperator]],
        luaRHS[[luaeval("require('replace').expr()")]],
        {"silent", "expr"}
    )

    map("n", [[<Plug>ReplaceExpr]],
        [[:<C-u>let g:ReplaceExpr=getreg("=")<Bar>exec "norm!" . v:count1 . "."<CR>]],
        {"silent"}
    )
    map("n", [[<Plug>ReplaceCurLine]],
        luaRHS[[
        :lua require("replace").replaceSave();

        vim.fn["repeat#setreg"](t"<Plug>ReplaceCurLine", vim.v.register);

        if require("replace").regType == "=" then
            vim.g.ReplaceExpr = vim.fn.getreg("=")
        end;

        require("replace").operator{"line", "V", "<Plug>ReplaceCurLine", true}<CR>
        ]],
        {"noremap", "silent"})
    map("x", [[<Plug>ReplaceVisual]],
        luaRHS[[
        :lua require("replace").replaceSave();

        vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register);

        if require("replace").regType == "=" then
            vim.g.ReplaceExpr = vim.fn.getreg("=")
        end;

        local vMotion = require("operator").vMotion(false);
        table.insert(vMotion, "<Plug>ReplaceVisual");
        require("replace").operator(vMotion)<CR>
        ]],
        {"noremap", "silent"})
    map("n", [[<Plug>ReplaceVisual]],
        luaRHS[[
        :lua require("replace").replaceSave();

        vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register);

        if require("replace").regType == "=" then
            vim.g.ReplaceExpr = vim.fn.getreg("=")
        end;

        vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0));

        local vMotion = require("operator").vMotion(false);
        table.insert(vMotion, "<Plug>ReplaceVisual");
        require("replace").operator(vMotion)<CR>
        ]],
        {"noremap", "silent"})

    map("n", [[gr]],  [[<Plug>ReplaceOperator]])
    map("n", [[grr]], [[<Plug>ReplaceCurLine]])
    map("n", [[grn]], [[*``griw]], {"noremap"}, "Replace word under cursor forward")
    map("n", [[grN]], [[#``griw]], {"noremap"}, "Replace word under cursor backward")
    map("x", [[R]],   [[<Plug>ReplaceVisual]])
end -- }}}


--- Find cursor or cursor region in given text table
--- @param cursorChar string Character to indicate the cursor position
--- @param inputTbl table Table of string elements with each content of elements is
---                       a string of buffer line
--- @param cursorRegionChk boolean Determine wether to return a table of cursorRegion or a table
---                                of a cursor
--- @return table
local function findCursorIndicator(cursorChar, inputTbl, cursorRegionChk)
    -- Init cursor startup position if cursor indicator exist
    local cursorRegion = {}
    local lines = {}
    for idx, line in ipairs(inputTbl) do
        if cursorRegionChk then
            local col = 0
            local cursorFound = false
            repeat
                col = string.find(line, cursorChar, col, true)
                if col then
                    if inputTbl[idx] then inputTbl[idx] = nil end
                    -- {1, 0} index based, ready for vim.api.nvim_win_set_cursor()
                    if #lines == 0 then
                        cursorRegion[#cursorRegion+1] = {idx - 1, col - 1}
                    else
                        cursorRegion[#cursorRegion+1] = {#lines, col - 1}
                    end
                    cursorFound = true
                    col = col + 1
                end

            until not col

            if not cursorFound then
                lines[#lines+1] = line
            end

        else
            local col = string.find(line, cursorChar, 1, true)
            if col then
                -- {1, 0} index based, ready for vim.api.nvim_win_set_cursor()
                cursorRegion = {idx - 1, col - 1}
            else
                lines[#lines+1] = line
            end
        end
    end

    if cursorRegionChk then
        assert.are.same(2, #cursorRegion)
    end

    return cursorRegion, lines
end


--- Setup a scratch buffer and cursor to run test on it
--- @param input string Multi-lines content of the output
--- @param filetype string The filetype of the test buffer
--- @param cursorNearEnd boolean Whether the cursor is palced near the end of
---                              the visual region
--- @param visualCMD string Command to start visual selection
local function setUpBuffer(input, filetype, cursorNearEnd, visualCMD, cursorRegionChk) -- {{{
    local bufNr = vim.api.nvim_create_buf(false, true)
    local cursorRegion, lines = findCursorIndicator("^", vim.split(input, "\n"), cursorRegionChk)

    vim.api.nvim_buf_set_option(bufNr, 'filetype', filetype)
    vim.api.nvim_win_set_buf(0, bufNr)
    vim.api.nvim_buf_set_lines(bufNr, 0, -1, true, lines)

    if type(cursorRegion[1]) == "table" then
        if cursorNearEnd then
            vim.api.nvim_win_set_cursor(0, cursorRegion[1])
            vim.cmd([[noa norm! ]] .. visualCMD)
            vim.api.nvim_win_set_cursor(0, cursorRegion[2])
            vim.cmd([[noa norm! ]] .. t"<Esc>")
        else
            vim.api.nvim_win_set_cursor(0, cursorRegion[2])
            vim.cmd([[noa norm! ]] .. visualCMD)
            vim.api.nvim_win_set_cursor(0, cursorRegion[1])
            vim.cmd([[noa norm! ]] .. t"<Esc>")
        end
    else
        vim.api.nvim_win_set_cursor(0, cursorRegion)
        vim.cmd([[noa norm! ]] .. visualCMD .. t"<Esc>")
    end

end -- }}}


--- Run command and then assert the output with expected
--- @param feedkeys string Commands to execute in Neovim
--- @param expected string Multi-lines content of the output
local function runCommandAndAssert(feedkeys, expected) -- {{{
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feedkeys, true, true, true),
                        "x", false)
    local resultLines = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
    local expectCursorPos, expectedLines = findCursorIndicator("^", vim.split(expected, "\n"), false)

    assert.are.same(expectedLines, resultLines)
    if expectCursorPos and next(expectCursorPos) then
        local resultCursorPos = vim.api.nvim_win_get_cursor(0)
        assert.are.same(expectCursorPos, resultCursorPos)
    end
end -- }}}


-- NOTE: http://olivinelabs.com/busted/
describe('Replace visual selection: ', function() -- {{{
    -- NOTE: not supported in plenary


    -- before_each(function()
    -- end)

    -- after_each(function()
    -- end)

    -- teardown(function()
    -- NOTE: not supported in plenary
    -- end)

    describe('charwise-visual: ', function()
        local visualCMD = "v"

        describe('v-type register', function() -- {{{

            it("replace in the same line, cursor near the end of visual selection, content shrink", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                           ^                 ^
            ]]
                local expected = [[
    if reg.type == "v" or (not linesCnt == 1) then
                             ^
            ]]
                local expectedDot = [[
    if reg.type == "v" or (foobar) then
            ]]

                setUpMapping()
                setUpBuffer(input, "lua", true, visualCMD, true)
                -- replace
                vim.fn.setreg("a", "not", "v")
                runCommandAndAssert([[gv"aR]], expected)
                -- replace, via dot
                vim.fn.setreg("a", "foobar) ", "v")
                runCommandAndAssert([[b.]], expectedDot)
            end) -- }}}

            it("replace in the same line, cursor near the end of visual selection, content expand", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                ^                            ^
            ]]
                local expected = [[
    if reg.type ~= "V" and (reg.name ~= "0" and reg.type ~= "V" linesCnt == 1) then
                                                              ^
            ]]
                local expectedDot = [[
    if reg.type ~= "V" and (motionType == "V" linesCnt == 1) then
            ]]

                setUpMapping()
                setUpBuffer(input, "lua", true, visualCMD, true)
                -- replace
                vim.fn.setreg("a", '~= "V" and (reg.name ~= "0" and reg.type ~= "V"', "v")
                runCommandAndAssert([[gv"aR]], expected)
                -- replace, via dot
                vim.fn.setreg("a", "motionType =", "v")
                runCommandAndAssert([[Fr;.]], expectedDot)
            end) -- }}}

            it("replace in the same line, cursor near the start of visual selection, content shrink", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                       ^                     ^
            ]]
                local expected = [[
    if reg.type == "v" and not ( linesCnt == 1) then
                       ^
            ]]
                local expectedDot = [[
    if reg.type == "v" and not ( linesCnt == 1) then
            ]]

                setUpMapping()
                setUpBuffer(input, "lua", false, visualCMD, true)
                -- replace
                vim.fn.setreg("a", 'and not (', "v")
                runCommandAndAssert([[gv"aR]], expected)
                -- replace, via dot
                vim.fn.setreg("a", "or count ~= 44", "v")
                runCommandAndAssert([[Fr;.]], expectedDot)
            end) -- }}}

            it("replace in the same line, cursor near the start of visual selection, content expand", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                           ^ ^
            ]]
                local expected = [[
    if reg.type == "v" or (Register.type == "V" and linesCnt == 1) then
                           ^
            ]]
                local expectedDot = [[
    if reg.type == "v" or (MyLogister.type == "V" and linesCnt == 1) then
            ]]

                setUpMapping()
                setUpBuffer(input, "lua", false, visualCMD, true)
                -- replace
                vim.fn.setreg("a", 'Register', "v")
                runCommandAndAssert([[gv"aR]], expected)
                -- replace, via dot
                vim.fn.setreg("a", "MyLog", "v")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace multi-lines, cursor near the end of visual selection, content shrink", function() -- {{{
                local input = [[
    if M.regName == "=" then
        fn.setreg('"', vim.g.ReplaceExpr)
                           ^
        reg = {
          ^
            name    = '"',
            type    = fn.getregtype(M.regName),
            content = vim.g.ReplaceExpr
        }
            ]]
                local expected = [[
    if M.regName == "=" then
        fn.setreg('"', vim.option = {
                                ^
            name    = '"',
            type    = fn.getregtype(M.regName),
            content = vim.g.ReplaceExpr
        }
            ]]
                local expectedDot = [[
    if M.regName == "=" then
        fn.setreg('"', vim.optiofoobar name    = '"',
            type    = fn.getregtype(M.regName),
            content = vim.g.ReplaceExpr
        }
            ]]

                setUpMapping()
                setUpBuffer(input, "lua", true, visualCMD, true)
                -- replace
                vim.fn.setreg("a", 'option', "v")
                runCommandAndAssert([[gv"aR]], expected)
                -- replace, via dot
                vim.fn.setreg("a", "foobar", "v")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace multi-lines, cursor near the end of visual selection, content expand", function() -- {{{
                local input = [[
    if M.regName == "=" then
        fn.setreg('"', vim.g.ReplaceExpr)
                  ^
        reg = {
        ^
            name    = '"',
            type    = fn.getregtype(M.regName),
            content = vim.g.ReplaceExpr
        }
            ]]
                local expected = [[
    if M.regName == "=" then
        fn.setreg(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8,
arg9, arg10, arg11, eg = {
                   ^
            name    = '"',
            type    = fn.getregtype(M.regName),
            content = vim.g.ReplaceExpr
        }
            ]]

                setUpMapping()
                setUpBuffer(input, "lua", true, visualCMD, true)
                -- replace
                vim.fn.setreg("a", 'arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8,\narg9, arg10, arg11, ', "v")
                runCommandAndAssert([[gv"aR]], expected)
            end) -- }}}

        end) -- }}}

        describe('V-type register', function() -- {{{

            it("replace in the same line, cursor near the end of visual selection", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                      ^                                     ^
            ]]
                local expected = [[
    if reg.type == "v"
    and motionType == "char" or
    vimMode == "n"
                 ^
 then
            ]]
                setUpMapping()
                setUpBuffer(input, "lua", true, visualCMD, true)
                -- replace
                vim.fn.setreg("a", '    and motionType == "char" or\n    vimMode == "n"', "V")
                runCommandAndAssert([[gv"aR]], expected)
            end) -- }}}

            it("replace in the same line, cursor near the start of visual selection", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                         ^                    ^
            ]]
                local expected = [[
    if reg.type == "v" or
    vimMode == "n" and
    ^
linesCnt == 1) then
            ]]
                setUpMapping()
                setUpBuffer(input, "lua", false, visualCMD, true)
                -- replace
                vim.fn.setreg("a", '    vimMode == "n" and', "V")
                runCommandAndAssert([[gv"aR]], expected)
            end) -- }}}

        end) -- }}}

    end)

    describe('linewise-visual: ', function()
        local visualCMD = "V"

        describe('v-type register', function() -- {{{

            it("replace one single line, shrink content, part1", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                           ^
            ]]
                local expected = [[
    local input
    ^
            ]]
                local expectedDot = [[
    foobar
            ]]

                setUpMapping()
                setUpBuffer(input, "lua", false, visualCMD, false)
                -- replace
                vim.fn.setreg("a", "local input", "v")
                runCommandAndAssert([[gv"aR]], expected)
                -- replace, via dot
                vim.fn.setreg("a", " foobar", "v")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace one single line, shrink content, part2", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                           ^
            ]]
                local expected = [[
    if reg.type == "v" and #reg.content ~= 0 then
                           ^
            ]]
                local expectedDot = [[
    if #reg.content >= 9999 then
            ]]
                setUpMapping()
                setUpBuffer(input, "lua", true, visualCMD, false)
                -- replace
                vim.fn.setreg("a", 'if reg.type == "v" and #reg.content ~= 0 then', "v")
                runCommandAndAssert([[gv"aR]], expected)
                -- replace, via dot
                vim.fn.setreg("a", 'if #reg.content >= 9999 then', "v")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace one single line, expand content", function() -- {{{
                local input = [[
    elseif vimMode == "n" then
                ^
        if reg.type == "v" then
            if motionType == "line" then
                local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
            ]]
                local expected = [[
    Lorem ipsum dolor sit amet, qui minim labore adipisicing minim sint cillum sint consectetur cupidatat.
                ^
        if reg.type == "v" then
            if motionType == "line" then
                local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
            ]]
                local expectedDot = [[
    if #reg.content >= 9999 then
        if reg.type == "v" then
            if motionType == "line" then
                local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
            ]]
                setUpMapping()
                setUpBuffer(input, "lua", true, visualCMD, false)
                -- replace
                vim.fn.setreg("a", 'Lorem ipsum dolor sit amet, qui minim labore adipisicing minim sint cillum sint consectetur cupidatat.', "v")
                runCommandAndAssert([[gv"aR]], expected)
                -- replace, via dot
                vim.fn.setreg("a", 'if #reg.content >= 9999 then', "v")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace one multiple lines, shrink content", function() -- {{{
                local input = [[
    elseif vimMode == "n" then
                ^
        if reg.type == "v" then
                ^
            if motionType == "line" then
                local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
            ]]
                local expected = [[
    Lorem ipsum dolor sit amet.
    ^
            if motionType == "line" then
                local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
            ]]
                local expectedDot = [[
    qui minim labore adipisicing minim sint cillum sint consectetur cupidatat.
                local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
            ]]
                setUpMapping()
                setUpBuffer(input, "lua", true, visualCMD, true)
                -- replace
                vim.fn.setreg("a", 'Lorem ipsum dolor sit amet.', "v")
                runCommandAndAssert([[gv"aR]], expected)
                -- -- replace, via dot
                vim.fn.setreg("a", 'qui minim labore adipisicing minim sint cillum sint consectetur cupidatat.', "v")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace lines(grr), shrink content, part1", function() -- {{{
                local input = [[
    elseif vimMode == "n" then
                ^
        if reg.type == "v" then
            if motionType == "line" then
                local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
            ]]
                local expected = [[
    if vimMode then
                ^
        if reg.type == "v" then
            if motionType == "line" then
                local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
            ]]
                local expectedDot = [[
    while 1 do
        if reg.type == "v" then
            if motionType == "line" then
                local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
            ]]
                setUpMapping()
                setUpBuffer(input, "lua", true, visualCMD, false)
                -- replace
                vim.fn.setreg("a", 'if vimMode then', "v")
                runCommandAndAssert([["agrr]], expected)
                -- -- replace, via dot
                vim.fn.setreg("a", 'while 1 do', "v")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace lines(grr), shrink content, part2", function() -- {{{
                local input = [[
        elseif reindentCnt > 0 then
                   ^
            regContentNew = reindents .. regContent
            if lineCnt > 1 then
                if endLnStart then
                    if endLnEnd ~= endLnStart then
                        regContentNew = string.sub(regContentNew, 1, #regContentNew - reindentCnt * 2 - 1)
                    else
                        regContentNew = string.sub(regContentNew, 1, #regContentNew - reindentCnt - 1)
                    end
            ]]
                local expected = [[
        while true do
                   ^
            if lineCnt > 1 then
                if endLnStart then
                    if endLnEnd ~= endLnStart then
                        regContentNew = string.sub(regContentNew, 1, #regContentNew - reindentCnt * 2 - 1)
                    else
                        regContentNew = string.sub(regContentNew, 1, #regContentNew - reindentCnt - 1)
                    end
            ]]
                local expectedDot = [[
        while 1 do
                if endLnStart then
                    if endLnEnd ~= endLnStart then
                        regContentNew = string.sub(regContentNew, 1, #regContentNew - reindentCnt * 2 - 1)
                    else
                        regContentNew = string.sub(regContentNew, 1, #regContentNew - reindentCnt - 1)
                    end
            ]]
                setUpMapping()
                setUpBuffer(input, "lua", true, visualCMD, false)
                -- replace
                vim.fn.setreg("a", 'while true do', "v")
                runCommandAndAssert([["a2grr]], expected)
                -- -- replace, via dot
                vim.fn.setreg("a", 'while 1 do', "v")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace lines(grr), expand content", function() -- {{{
                local input = [[
        elseif reindentCnt > 0 then
                   ^
            regContentNew = reindents .. regContent
            if lineCnt > 1 then
                if endLnStart then
                    if endLnEnd ~= endLnStart then
                        regContentNew = string.sub(regContentNew, 1, #regContentNew - reindentCnt * 2 - 1)
                    else
                        regContentNew = string.sub(regContentNew, 1, #regContentNew - reindentCnt - 1)
                    end
            ]]
                local expected = [[
        Lorem ipsum dolor sit amet, qui minim labore adipisicing minim sint cillum sint consectetur cupidatat.
                   ^
                if endLnStart then
                    if endLnEnd ~= endLnStart then
                        regContentNew = string.sub(regContentNew, 1, #regContentNew - reindentCnt * 2 - 1)
                    else
                        regContentNew = string.sub(regContentNew, 1, #regContentNew - reindentCnt - 1)
                    end
            ]]
                local expectedDot = [[
        Yberz vcfhz qbybe fvg nzrg, dhv zvavz ynober nqvcvfvpvat zvavz fvag pvyyhz fvag pbafrpgrghe phcvqngng.
                        regContentNew = string.sub(regContentNew, 1, #regContentNew - reindentCnt * 2 - 1)
                    else
                        regContentNew = string.sub(regContentNew, 1, #regContentNew - reindentCnt - 1)
                    end
            ]]
                setUpMapping()
                setUpBuffer(input, "lua", true, visualCMD, false)
                -- replace
                vim.fn.setreg("a", 'Lorem ipsum dolor sit amet, qui minim labore adipisicing minim sint cillum sint consectetur cupidatat.', "v")
                runCommandAndAssert([["a3grr]], expected)
                -- -- replace, via dot
                vim.fn.setreg("a", 'Yberz vcfhz qbybe fvg nzrg, dhv zvavz ynober nqvcvfvpvat zvavz fvag pvyyhz fvag pbafrpgrghe phcvqngng.', "v")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

        end) -- }}}

        describe('V-type register', function() -- {{{


        end) -- }}}
    end)


end) -- }}}

