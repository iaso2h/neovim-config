local api = vim.api
local fn  = vim.fn


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


local function findCursorIndicator(cursorChar, inputTbl)
    -- Init cursor startup position if cursor indicator exist
    local cursorPos
    local lines = {}
    for idx, line in ipairs(inputTbl) do
        local col = string.find(line, cursorChar)
        if col then
            inputTbl[idx] = nil
            -- {1, 0} index based, ready for vim.api.nvim_win_set_cursor()
            cursorPos = {idx - 1, col - 1}
        else
            lines[#lines+1] = line
        end
    end

    return cursorPos, lines
end


local function setUpBuffer(input, filetype) -- {{{
    local bufNr = api.nvim_create_buf(false, true)
    local cursorPos, lines = findCursorIndicator("▲", vim.split(input, "\n"))

    api.nvim_buf_set_option(bufNr, 'filetype', filetype)
    api.nvim_win_set_buf(0, bufNr)
    api.nvim_buf_set_lines(bufNr, 0, -1, true, lines)

    if cursorPos then
        -- fn.setpos(".", {bufNr, cursorPos[1], cursorPos[2] + 1})
        api.nvim_win_set_cursor(0, cursorPos)
        return cursorPos
    else
        return {1, 0}
    end

end -- }}}


local function runCommandAndAssert(feedkeys, expected) -- {{{
    api.nvim_feedkeys(api.nvim_replace_termcodes(feedkeys, true, true, true),
                        "x", false)
    local resultLines = api.nvim_buf_get_lines(0, 0, api.nvim_buf_line_count(0), false)
    local cursorPos, expectedLines = findCursorIndicator("▲", vim.split(expected, "\n"))

    assert.are.same(expectedLines, resultLines)
    if cursorPos then
        local newPos = api.nvim_win_get_cursor(0)
        assert.are.same(cursorPos, newPos)
    end
end -- }}}


-- NOTE: http://olivinelabs.com/busted/
describe('Replace operator', function() -- {{{
    -- NOTE: not supported in plenary


    -- before_each(function()
    -- end)

    -- after_each(function()
    -- end)

    -- teardown(function()
    -- NOTE: not supported in plenary
    -- end)

    describe('Register type is "v": ', function()

        describe('left-right-motions: ', function() -- {{{
            it("replace with \"l\" motion", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ▲
            ]]
                local expected = [[
    if reg.type == "v" or (robbing.type == "V" and linesCnt == 1) then
                            ▲
            ]]
                local expectedDot = [[
    if reg.type == "v" or (rushing and robbing.type == "V" and linesCnt == 1) then
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "obbin", "c")
                runCommandAndAssert([["*grl]], expected)
                -- replace, via dot
                fn.setreg("*", "ushing and ro", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"h\" motion", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ▲
            ]]
                local expected = [[
    if reg.type == "v" or (dogleg.type == "V" and linesCnt == 1) then
                               ▲
            ]]
                local expectedDot = [[
    if reg.type == "v" or (doggyleg.type == "V" and linesCnt == 1) then
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "dogl", "c")
                runCommandAndAssert([["*grh]], expected)
                -- replace, via dot
                fn.setreg("*", "gyl", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"$\" motion", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ▲
            ]]
                local expected = [[
    if reg.type == "v" or (ruthless
                            ▲
            ]]
                local expectedDot = [[
    if reg.type == "v" or (room
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "uthless", "c")
                runCommandAndAssert([["*gr$]], expected)
                -- replace, via dot
                fn.setreg("*", "oom", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"Te\" motion", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ▲
            ]]
                local expected = [[
    if reg.typescript peg.type == "V" and linesCnt == 1) then
                       ▲
            ]]
                local expectedDot = [[
    if reg.typer's leg.type == "V" and linesCnt == 1) then
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "script p", "c")
                runCommandAndAssert([["*grTe]], expected)
                -- replace, via dot
                fn.setreg("*", "r's l", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

        describe('up-down-motions: ', function() -- {{{
            it("replace with \"3j\" motion", function() -- {{{
                local input = [[
        if reindentCnt < 0 then
            reg.content = string.gsub(reg.content, "^" .. reindents, "")
                   ▲
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
            elseif reindentCnt > 0 then
                reg.content = reindents .. reg.content
                if lineCnt ~= 1 then
                    reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                end
            end
            ]]
                local expected = [[
        if reindentCnt < 0 then
            nulla sunt exuis nsunt velit enim.
                   ▲
                reg.content = reindents .. reg.content
                if lineCnt ~= 1 then
                    reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                end
            end
            ]]
                local expectedDot = [[
        if reindentCnt < 0 then
            Lorem ipsum dolor sit amet.
                end
            end
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "nulla sunt exuis nsunt velit enim.", "c")
                runCommandAndAssert([["*gr3j]], expected)
                -- replace, via dot
                fn.setreg("*", "Lorem ipsum dolor sit amet.", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"3k\" motion", function() -- {{{
                local input = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "^" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
                        reg.content = reindents .. reg.content
                            if lineCnt ~= 1 then
                                end
        reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                                                               ▲
                                        end
            ]]
                local expected = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "^" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
        nulla sunt exuis nsunt velit enim.
        ▲
                                        end
            ]]
                local expectedDot = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "^" .. reindents, "")
        Lorem ipsum dolor sit amet.
                                        end
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "nulla sunt exuis nsunt velit enim.", "c")
                runCommandAndAssert([["*gr3k]], expected)
                -- replace, via dot
                fn.setreg("*", "Lorem ipsum dolor sit amet.", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"4k\" motion", function() -- {{{
                local input = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "^" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
                        reg.content = reindents .. reg.content
                            if lineCnt ~= 1 then
                                end
        reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                                        end
                                         ▲
            ]]
                local expected = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "^" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
                                        endif
                                        ▲
            ]]
                local expectedDot = [[
if reindentCnt < 0 then
                                        fidne
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "endif", "c")
                runCommandAndAssert([["*gr4k]], expected)
                -- replace, via dot
                fn.setreg("*", "fidne", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"_\" motion", function() -- {{{
                local input = [[
            if lineCnt ~= 1 then
                    ▲
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
            elseif reindentCnt > 0 then
                reg.content = reindents .. reg.content
                if lineCnt ~= 1 then
                    reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                end
            end
            ]]
                local expected = [[
            foo
            ▲
                reg.content = reindents .. reg.content
                if lineCnt ~= 1 then
                    reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                end
            end
            ]]
                local expectedDot = [[
            bar
                    reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                end
            end
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "foo", "c")
                runCommandAndAssert([["*gr3_]], expected)
                -- replace, via dot
                fn.setreg("*", "bar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

        describe('word-motions: ', function() -- {{{
            it("replace with \"2W\" motion", function() -- {{{
                local input = [[
            reg.content = string.gsub(reg.content, "^" .. reindents, "")
                                 ▲
            ]]
                local expected = [[
            reg.content = string.find(val1, 2 .. reindents, "")
                                 ▲
            ]]
                local expectedDot = [[
            reg.content = string.global_sub(arg1, 55 .. reindents, "")
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "find(val1, 2 ", "c")
                runCommandAndAssert([["*gr2W]], expected)
                -- replace, via dot
                fn.setreg("*", "global_sub(arg1, 55 ", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"4ge\" motion", function() -- {{{
                local input = [[
local reindentCnt = reindent(reg, regionMotion, motionDirection)
    if indent ~=0 then
        fn.setreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
            ▲
            ]]
                local expected = [[
local reindentCnt = reindent(reg, regionMotion, motionDirection)
    if indent ~= getreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
                ▲
            ]]
                local expectedDot = [[
local reindentCnt = reindent(reg, regionMotion, motionDirection + getreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", " ge", "c")
                runCommandAndAssert([["*gr4ge]], expected)
                -- replace, via dot
                fn.setreg("*", " + ", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"5b\" motion", function() -- {{{
                local input = [[
if M then
        fn.set
            reg = {
                name
                  ▲
            ]]
                local expected = [[
if M then
        fn.help_me
                ▲
            ]]
                local expectedDot = [[
if you can see this lime
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "help_", "c")
                runCommandAndAssert([["*gr5b]], expected)
                -- replace, via dot
                fn.setreg("*", "you can see this li", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"6b\" motion", function() -- {{{
                local input = [[
    if vimMode == "n" then
        if not M.cursorPos then
            else
                if not cursorNS then
                    if motionDirection == 1 then
                                        ▲
            ]]
                local expected = [[
    if vimMode == "n" then
        if not M.cursorPos then
            else
                if number ~= 1 then
                           ▲
            ]]
                local expectedDot = [[
    if vimMode == "n" then
        if not M.factor += 1 then
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "number ~", "c")
                runCommandAndAssert([["*gr6b]], expected)
                -- replace, via dot
                fn.setreg("*", "factor +", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

        describe('object-motions: ', function() -- {{{
            it("replace with \"3{\" motion", function() -- {{{
                local input = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = stringCount(reg.content, "\n")

            -- Reindent the lines if counts do not match up
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))

                if reindentCnt < 0 then
                    reg.content = string.gsub(reg.content, "^" .. reindents, "")

                    if lineCnt ~= 1 then
                        reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    end

                elseif reindentCnt > 0 then
                    reg.content = reindents .. reg.content

                    if lineCnt ~= 1 then
                        reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                    end
                end
            end

            fn.setreg(reg.name, string.sub(reg.content, 1, -2), "V")
        else
            fn.setreg(reg.name, vim.trim(reg.content), "v")
        end

        return true
              ▲
            ]]
                local expected = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = stringCount(reg.content, "\n")

            -- Reindent the lines if counts do not match up
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))

                if reindentCnt < 0 then
                    reg.content = string.gsub(reg.content, "^" .. reindents, "")

                    if lineCnt ~= 1 then
                        reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    end

                elseif reindentCnt > 0 then
                    reg.content = reindents .. reg.content
while true
     ▲
            ]]
                local expectedDot = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = stringCount(reg.content, "\n")

            -- Reindent the lines if counts do not match up
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))
if true
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "while", "c")
                runCommandAndAssert([["*gr3{]], expected)
                -- replace, via dot
                fn.setreg("*", "if", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"4}\" motion", function() -- {{{
                local input = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = stringCount(reg.content, "\n")
                                ▲

            -- Reindent the lines if counts do not match up
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))

                if reindentCnt < 0 then
                    reg.content = string.gsub(reg.content, "^" .. reindents, "")

                    if lineCnt ~= 1 then
                        reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    end

                elseif reindentCnt > 0 then
                    reg.content = reindents .. reg.content

                    if lineCnt ~= 1 then
                        reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                    end
                end
            end

            fn.setreg(reg.name, string.sub(reg.content, 1, -2), "V")
        else
            fn.setreg(reg.name, vim.trim(reg.content), "v")
        end

        return true
            ]]
                local expected = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = foo
                                ▲

                elseif reindentCnt > 0 then
                    reg.content = reindents .. reg.content

                    if lineCnt ~= 1 then
                        reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                    end
                end
            end

            fn.setreg(reg.name, string.sub(reg.content, 1, -2), "V")
        else
            fn.setreg(reg.name, vim.trim(reg.content), "v")
        end

        return true
            ]]
                local expectedDot = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = bar

        return true
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "foo", "c")
                runCommandAndAssert([["*gr4}]], expected)
                -- replace, via dot
                fn.setreg("*", "bar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

        describe('text-objects: ', function() -- {{{
            it("replace with \"iw\" motion", function() -- {{{
                local input = [[
        api.nvim_win_set_cursor(0, {M.cursorPos[1], #cursorLine})
                                                          ▲
            ]]
                local expected = [[
        api.nvim_win_set_cursor(0, {M.cursorPos[1], #foo})
                                                     ▲
            ]]
                local expectedDot = [[
        api.nvim_win_set_cursor(0, {M.cursorPos[1], #bar})
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "foo", "c")
                runCommandAndAssert([["*griw]], expected)
                -- replace, via dot
                fn.setreg("*", "bar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"a)\" motion, charwise", function() -- {{{
                local input = [[
            api.nvim_win_set_cursor(0, {regionReplace.startPos[1], newCol - 1})
                                                         ▲
            ]]
                local expected = [[
            api.nvim_win_set_cursor(2 * (index - 1))
                                   ▲
            ]]
                local expectedDot = [[
            api.nvim_win_set_cursor[index]
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "(2 * (index - 1))", "c")
                runCommandAndAssert([["*gra)]], expected)
                -- replace, via dot
                fn.setreg("*", "[index]", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"a)\" motion, linewise", function() -- {{{
                local input = [[
            local repEndLine = api.nvim_buf_get_lines(curBufNr,
                regionReplace.endPos[1] - 1, regionReplace.endPos[1], false)[1]
                                   ▲
            ]]
                local expected = [[
            local repEndLine = api.nvim_buf_get_lines(bufNr, start, end, true)[1]
                                                     ▲
            ]]
                local expectedDot = [[
            local repEndLine = api.nvim_buf_get_lines_tbl[1]
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "(bufNr, start, end, true)", "c")
                runCommandAndAssert([["*gra)]], expected)
                -- replace, via dot
                fn.setreg("*", "_tbl", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"a<\" motion, linewise", function() -- {{{
                local input = [[
<ul class="something" keyattr="attr and class has no highlight anymore">
    <li class="workaround"
        keyattr="linebreaks">text</li>
                  ▲
</ul>
            ]]
                local expected = [[
<ul class="something" keyattr="attr and class has no highlight anymore">
    <List name="foo">text</li>
    ▲
</ul>
            ]]
                local expectedDot = [[
<ul class="something" keyattr="attr and class has no highlight anymore">
    </li>text</li>
</ul>
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", '<List name="foo">', "c")
                runCommandAndAssert([["*gra<]], expected)
                -- replace, via dot
                fn.setreg("*", "</li>", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i<\" motion, charwise", function() -- {{{
                local input = [[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
             ▲
  <meta name="viewport" content="width= device-width , initial-scale= 1.0 ">
  <title> Document </title>
</head>
<body>
  <div>
            ]]
                local expected = [[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta none>
   ▲
  <meta name="viewport" content="width= device-width , initial-scale= 1.0 ">
  <title> Document </title>
</head>
<body>
  <div>
            ]]
                local expectedDot = [[
<!DOCTYPE html>
<html lang="en">
<head>
  <foobar>
  <meta name="viewport" content="width= device-width , initial-scale= 1.0 ">
  <title> Document </title>
</head>
<body>
  <div>
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "meta none", "c")
                runCommandAndAssert([["*gri<]], expected)
                -- replace, via dot
                fn.setreg("*", "foobar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i<\" motion, linewise", function() -- {{{
                local input = [[
<ul class="something"
             ▲
    keyattr="attr and class has no highlight anymore">
</ul>
            ]]
                local expected = [[
<URL>
 ▲
</ul>
            ]]
                local expectedDot = [[
</ul>
</ul>
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "URL", "c")
                runCommandAndAssert([["*gri<]], expected)
                -- replace, via dot
                fn.setreg("*", "/ul", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i{\" motion, charwise", function() -- {{{
                local input = [[
    local opts = {hlGroup = "Search", timeout = 250}
                  ▲
            ]]
                local expected = [[
    local opts = {timeout = 150}
                  ▲
            ]]
                local expectedDot = [[
    local opts = {vimMode = 'n'}
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "timeout = 150", "c")
                runCommandAndAssert([["*gri{]], expected)
                -- replace, via dot
                fn.setreg("*", "vimMode = 'n'", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i{\" motion, linewise", function() -- {{{
                local input = [[
        regionMotion = {
            startPos = api.nvim_buf_get_mark(curBufNr, "["),
            endPos   = api.nvim_buf_get_mark(curBufNr, "]")
                           ▲
        }
            ]]
                local expected = [[
        regionMotion = {
            foo
            ▲
        }
            ]]
                local expectedDot = [[
        regionMotion = {
            bar
        }
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "foo", "c")
                runCommandAndAssert([["*gri{]], expected)
                -- replace, via dot
                fn.setreg("*", "bar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i[\" motion, charwise", function() -- {{{
                local input = [[
api.nvim_buf_add_highlight(curBufNr, repHLNS, opts["hlGroup"], lineNr, cols[1], cols[2])
                                                     ▲
            ]]
                local expected = [[
api.nvim_buf_add_highlight(curBufNr, repHLNS, opts[myHighlightGroup], lineNr, cols[1], cols[2])
                                                     ▲
            ]]
                local expectedDot = [[
api.nvim_buf_add_highlight(curBufNr, repHLNS, opts['foo'], lineNr, cols[1], cols[2])
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "myHighlightGroup", "c")
                runCommandAndAssert([["*gri[]], expected)
                -- replace, via dot
                fn.setreg("*", "'foo'", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i\"\" motion, test1", function() -- {{{
            -- BUG: seems to have issue with feedkeys
                local input = [[
            it("replace", function()
                     ▲
            ]]
                local expected = [[
            it("bar", function()
                ▲
            ]]
                local expectedDot = [[
            it("foobar", function()
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                assert.are.same(api.nvim_win_get_cursor(0), {1, 21})
                -- replace
                fn.setreg("*", "bar", "c")
                runCommandAndAssert([["*gri"]], expected)
                -- replace, via dot
                fn.setreg("*", "foobar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i\"\" motion, test2", function() -- {{{
                local input = [[
        fn["repeat#set"](t"<Plug>ReplaceExpr")
                     ▲
            ]]
                local expected = [[
        fn["addSortedDataToTable"](t"<Plug>ReplaceExpr")
                     ▲
            ]]
                local expectedDot = [[
        fn["foobar"](t"<Plug>ReplaceExpr")
            ]]

                setUpMapping()
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("*", "addSortedDataToTable", "c")
                runCommandAndAssert([["*gri"]], expected)
                -- replace, via dot
                fn.setreg("*", "foobar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}


        describe('mark-motions: ', function() -- {{{
            it("replace with \"`m\" motion, charwise", function() -- {{{
                local input = [[
        local fn   = vim.fn
        local cmd  = vim.cmd
                         ▲
        local api  = vim.api
                ]]
                    local expected = [[
        local fn   = vim.lsp.cmd
                         ▲
        local api  = vim.api
                ]]
                    local expectedDot = [[
find
        local api  = vim.api
                ]]

                    setUpMapping()
                    setUpBuffer(input, "lua")
                    -- replace
                    vim.cmd("norm! mm")
                    fn.setreg("*", "lsp.", "c")
                    runCommandAndAssert([[gg"*gr`m]], expected)
                    -- replace, via dot
                    vim.cmd("norm! 0")
                    fn.setreg("*", "fin", "c")
                    runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}
    end) -- }}}


    describe('Register type is "V": ', function() -- {{{
        pending("test for linewise register")

    end) -- }}}

end) -- }}}
