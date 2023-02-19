local api = vim.api
local fn  = vim.fn


local function findCursorIndicator(cursorChar, inputTbl)
    -- Init cursor startup position if cursor indicator exist
    local cursorPos
    local lines = {}
    for idx, line in ipairs(inputTbl) do
        local col = string.find(line, cursorChar, 1, true)
        if col then
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
    local cursorPos, lines = findCursorIndicator("^", vim.split(input, "\n"))

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


--- Run command and then assert the output with expected
--- @param feedkeys string Commands to execute in Neovim
--- @param expected string Multi-lines content of the output
local runCommandAndAssert = function(feedkeys, expected) -- {{{
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
                            ^
            ]]
                local expected = [[
    if reg.type == "v" or (robbing.type == "V" and linesCnt == 1) then
                            ^
            ]]
                local expectedDot = [[
    if reg.type == "v" or (rushing and robbing.type == "V" and linesCnt == 1) then
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "obbin", "c")
                runCommandAndAssert([["agrl]], expected)
                -- replace, via dot
                fn.setreg("a", "ushing and ro", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"h\" motion", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ^
            ]]
                local expected = [[
    if reg.type == "v" or (dogleg.type == "V" and linesCnt == 1) then
                            ^
            ]]
                local expectedDot = [[
    if reg.type == "v" or (frandrogleg.type == "V" and linesCnt == 1) then
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "dogl", "c")
                runCommandAndAssert([["agrh]], expected)
                -- replace, via dot
                fn.setreg("a", "frandr", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"$\" motion", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ^
            ]]
                local expected = [[
    if reg.type == "v" or (ruthless
                            ^
            ]]
                local expectedDot = [[
    if reg.type == "v" or (room
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "uthless", "c")
                runCommandAndAssert([["agr$]], expected)
                -- replace, via dot
                fn.setreg("a", "oom", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"Te\" motion", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ^
            ]]
                local expected = [[
    if reg.typescript peg.type == "V" and linesCnt == 1) then
               ^
            ]]
                local expectedDot = [[
    if reg.typer's script peg.type == "V" and linesCnt == 1) then
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "script p", "c")
                runCommandAndAssert([["agrTe]], expected)
                -- replace, via dot
                fn.setreg("a", "r's ", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

        describe('up-down-motions: ', function() -- {{{
            it("replace with \"3j\" motion", function() -- {{{
                local input = [[
        if reindentCnt < 0 then
            reg.content = string.gsub(reg.content, "▲" .. reindents, "")
                   ^
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
                   ^
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

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "nulla sunt exuis nsunt velit enim.", "c")
                runCommandAndAssert([["agr3j]], expected)
                -- replace, via dot
                fn.setreg("a", "Lorem ipsum dolor sit amet.", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"3k\" motion", function() -- {{{
                local input = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "▲" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
                        reg.content = reindents .. reg.content
                            if lineCnt ~= 1 then
                                end
        reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                                                               ^
                                        end
            ]]
                local expected = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "▲" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
        nulla sunt exuis nsunt velit enim.
        ^
                                        end
            ]]
                local expectedDot = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "▲" .. reindents, "")
        Lorem ipsum dolor sit amet.
                                        end
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "nulla sunt exuis nsunt velit enim.", "c")
                runCommandAndAssert([["agr3k]], expected)
                -- replace, via dot
                fn.setreg("a", "Lorem ipsum dolor sit amet.", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"4k\" motion", function() -- {{{
                local input = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "▲" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
                        reg.content = reindents .. reg.content
                            if lineCnt ~= 1 then
                                end
        reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                                        end
                                         ^
            ]]
                local expected = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "▲" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
                                        endif
                                        ^
            ]]
                local expectedDot = [[
if reindentCnt < 0 then
                                        fidne
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "endif", "c")
                runCommandAndAssert([["agr4k]], expected)
                -- replace, via dot
                fn.setreg("a", "fidne", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"_\" motion", function() -- {{{
                local input = [[
            if lineCnt ~= 1 then
                    ^
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
            ^
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

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "foo", "c")
                runCommandAndAssert([["agr3_]], expected)
                -- replace, via dot
                fn.setreg("a", "bar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

        describe('word-motions: ', function() -- {{{
            it("replace with \"2W\" motion", function() -- {{{
                local input = [[
            reg.content = string.gsub(reg.content, "▲" .. reindents, "")
                                 ^
            ]]
                local expected = [[
            reg.content = string.find(val1, 2 .. reindents, "")
                                 ^
            ]]
                local expectedDot = [[
            reg.content = string.global_sub(arg1, 55 .. reindents, "")
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "find(val1, 2 ", "c")
                runCommandAndAssert([["agr2W]], expected)
                -- replace, via dot
                fn.setreg("a", "global_sub(arg1, 55 ", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"4ge\" motion", function() -- {{{
                local input = [[
local reindentCnt = reindent(reg, regionMotion, motionDirection)
    if indent ~=0 then
        fn.setreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
            ^
            ]]
                local expected = [[
local reindentCnt = reindent(reg, regionMotion, motionDirection)
    if indent ~= getreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
                ^
            ]]
                local expectedDot = [[
local reindentCnt = reindent(reg, regionMotion, motionDirection + getreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", " ge", "c")
                runCommandAndAssert([["agr4ge]], expected)
                -- replace, via dot
                fn.setreg("a", " + ", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"5b\" motion", function() -- {{{
                local input = [[
if M then
        fn.set
            reg = {
                name
                  ^
            ]]
                local expected = [[
if M then
        fn.call_me
           ^
            ]]
                local expectedDot = [[
It said: call_me
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "call_", "c")
                runCommandAndAssert([["agr5b]], expected)
                -- replace, via dot
                fn.setreg("a", "It said: ", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"6b\" motion", function() -- {{{
                local input = [[
    if vimMode == "n" then
        if not M.cursorPos then
            else
                if not cursorNS then
                    if motionDirection == 1 then
                                        ^
            ]]
                local expected = [[
    if vimMode == "n" then
        if not M.cursorPos then
            else
                if number ~= 1 then
                   ^
            ]]
                local expectedDot = [[
    if vimMode == "n" then
        if not factor + number ~= 1 then
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "number ~", "c")
                runCommandAndAssert([["agr6b]], expected)
                -- replace, via dot
                fn.setreg("a", "factor + ", "c")
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
                    reg.content = string.gsub(reg.content, "▲" .. reindents, "")

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
              ^
            ]]
                local expected = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = stringCount(reg.content, "\n")

            -- Reindent the lines if counts do not match up
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))

                if reindentCnt < 0 then
                    reg.content = string.gsub(reg.content, "▲" .. reindents, "")

                    if lineCnt ~= 1 then
                        reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    end

                elseif reindentCnt > 0 then
                    reg.content = reindents .. reg.content
while true
^
            ]]
                local expectedDot = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = stringCount(reg.content, "\n")

            -- Reindent the lines if counts do not match up
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))
foobar
while true
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "while", "c")
                runCommandAndAssert([["agr3{]], expected)
                -- replace, via dot
                fn.setreg("a", "foobar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"4}\" motion", function() -- {{{
                local input = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = stringCount(reg.content, "\n")
                                ^

            -- Reindent the lines if counts do not match up
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))

                if reindentCnt < 0 then
                    reg.content = string.gsub(reg.content, "▲" .. reindents, "")

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
                                ^

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

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "foo", "c")
                runCommandAndAssert([["agr4}]], expected)
                -- replace, via dot
                fn.setreg("a", "bar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

        describe('text-objects: ', function() -- {{{
            it("replace with \"iw\" motion", function() -- {{{
                local input = [[
        api.nvim_win_set_cursor(0, {M.cursorPos[1], #cursorLine})
                                                          ^
            ]]
                local expected = [[
        api.nvim_win_set_cursor(0, {M.cursorPos[1], #foo})
                                                     ^
            ]]
                local expectedDot = [[
        api.nvim_win_set_cursor(0, {M.cursorPos[1], #bar})
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "foo", "c")
                runCommandAndAssert([["agriw]], expected)
                -- replace, via dot
                fn.setreg("a", "bar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"a)\" motion, charwise", function() -- {{{
                local input = [[
            api.nvim_win_set_cursor(0, {regionReplace.startPos[1], newCol - 1})
                                                         ^
            ]]
                local expected = [[
            api.nvim_win_set_cursor(2 * (index - 1))
                                   ^
            ]]
                local expectedDot = [[
            api.nvim_win_set_cursor[index]
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "(2 * (index - 1))", "c")
                runCommandAndAssert([["agra)]], expected)
                -- replace, via dot
                fn.setreg("a", "[index]", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"a)\" motion, linewise", function() -- {{{
                local input = [[
            local repEndLine = api.nvim_buf_get_lines(curBufNr,
                regionReplace.endPos[1] - 1, regionReplace.endPos[1], false)[1]
                                   ^
            ]]
                local expected = [[
            local repEndLine = api.nvim_buf_get_lines(bufNr, start, end, true)[1]
                                                     ^
            ]]
                local expectedDot = [[
            local repEndLine = api.nvim_buf_get_lines_tbl[1]
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "(bufNr, start, end, true)", "c")
                runCommandAndAssert([["agra)]], expected)
                -- replace, via dot
                fn.setreg("a", "_tbl", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"a<\" motion, linewise", function() -- {{{
                local input = [[
<ul class="something" keyattr="attr and class has no highlight anymore">
    <li class="workaround"
        keyattr="linebreaks">text</li>
                  ^
</ul>
            ]]
                local expected = [[
<ul class="something" keyattr="attr and class has no highlight anymore">
    <List name="foo">text</li>
    ^
</ul>
            ]]
                local expectedDot = [[
<ul class="something" keyattr="attr and class has no highlight anymore">
    </li>text</li>
</ul>
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", '<List name="foo">', "c")
                runCommandAndAssert([["agra<]], expected)
                -- replace, via dot
                fn.setreg("a", "</li>", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i<\" motion, charwise", function() -- {{{
                local input = [[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
             ^
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
   ^
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

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "meta none", "c")
                runCommandAndAssert([["agri<]], expected)
                -- replace, via dot
                fn.setreg("a", "foobar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i<\" motion, linewise", function() -- {{{
                local input = [[
<ul class="something"
             ^
    keyattr="attr and class has no highlight anymore">
</ul>
            ]]
                local expected = [[
<URL>
 ^
</ul>
            ]]
                local expectedDot = [[
</ul>
</ul>
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "URL", "c")
                runCommandAndAssert([["agri<]], expected)
                -- replace, via dot
                fn.setreg("a", "/ul", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i{\" motion, charwise", function() -- {{{
                local input = [[
    local opts = {hlGroup = "Search", timeout = 250}
                  ^
            ]]
                local expected = [[
    local opts = {timeout = 150}
                  ^
            ]]
                local expectedDot = [[
    local opts = {vimMode = 'n'}
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "timeout = 150", "c")
                runCommandAndAssert([["agri{]], expected)
                -- replace, via dot
                fn.setreg("a", "vimMode = 'n'", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i{\" motion, linewise", function() -- {{{
                local input = [[
        regionMotion = {
            startPos = api.nvim_buf_get_mark(curBufNr, "["),
            endPos   = api.nvim_buf_get_mark(curBufNr, "]")
                           ^
        }
            ]]
                local expected = [[
        regionMotion = {
            foo
            ^
        }
            ]]
                local expectedDot = [[
        regionMotion = {
            bar
        }
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "foo", "c")
                runCommandAndAssert([["agri{]], expected)
                -- replace, via dot
                fn.setreg("a", "bar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i[\" motion, charwise", function() -- {{{
                local input = [[
api.nvim_buf_add_highlight(curBufNr, repHLNS, opts["hlGroup"], lineNr, cols[1], cols[2])
                                                     ^
            ]]
                local expected = [[
api.nvim_buf_add_highlight(curBufNr, repHLNS, opts[myHighlightGroup], lineNr, cols[1], cols[2])
                                                     ^
            ]]
                local expectedDot = [[
api.nvim_buf_add_highlight(curBufNr, repHLNS, opts['foo'], lineNr, cols[1], cols[2])
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "myHighlightGroup", "c")
                runCommandAndAssert([["agri[]], expected)
                -- replace, via dot
                fn.setreg("a", "'foo'", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i\"\" motion, test1", function() -- {{{
                local input = [[
            it("replace", function()
                     ^
            ]]
                local expected = [[
            it("bar", function()
                ^
            ]]
                local expectedDot = [[
            it("foobar", function()
            ]]

                setUpBuffer(input, "lua")
                assert.are.same(api.nvim_win_get_cursor(0), {1, 21})
                -- replace
                fn.setreg("a", "bar", "c")
                runCommandAndAssert([["agri"]], expected)
                -- replace, via dot
                fn.setreg("a", "foobar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i\"\" motion, test2", function() -- {{{
                local input = [[
        fn["repeat#set"](t"<Plug>ReplaceExpr")
                     ^
            ]]
                local expected = [[
        fn["addSortedDataToTable"](t"<Plug>ReplaceExpr")
                     ^
            ]]
                local expectedDot = [[
        fn["foobar"](t"<Plug>ReplaceExpr")
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "addSortedDataToTable", "c")
                runCommandAndAssert([["agri"]], expected)
                -- replace, via dot
                fn.setreg("a", "foobar", "c")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

        describe('mark-motions: ', function() -- {{{
            it("replace with \"`m\" motion, charwise", function() -- {{{
                local input = [[
        local fn   = vim.fn
        local cmd  = vim.cmd
                         ^
        local api  = vim.api
                ]]
                    local expected = [[
        local fn   = vim.lsp.cmd
                         ^
        local api  = vim.api
                ]]
                    local expectedDot = [[
find
        local api  = vim.api
                ]]

                    setUpBuffer(input, "lua")
                    -- replace
                    vim.cmd("norm! mm")
                    fn.setreg("a", "lsp.", "c")
                    runCommandAndAssert([[gg"agr`m]], expected)
                    -- replace, via dot
                    vim.cmd("norm! 0")
                    fn.setreg("a", "fin", "c")
                    runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}
    end)

    describe('-----------------------------------', function()
        it("-----------------------------------", function()
        end)
    end)

    describe('Register type is "V": ', function()

        describe('left-right-motions: ', function() -- {{{
            it("replace with \"l\" motion", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ^
            ]]
                local expected = [[
    if reg.type == "v" or (rubbing.type == "V" and linesCnt == 1) then
                            ^
            ]]
                local expectedDot = [[
    if reg.type == "v" or (rashingbbing.type == "V" and linesCnt == 1) then
            ]]

                setUpBuffer(input, "lua")
                -- replace
                -- NOTE: same results
                -- fn.setreg("a", "o\nbbin\n", "V")
                fn.setreg("a", "ubbin", "V")
                runCommandAndAssert([["agrl]], expected)
                -- replace, via dot
                fn.setreg("a", "ashing", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"h\" motion", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ^
            ]]
                local expected = [[
    if reg.type == "v" or (foobareg.type == "V" and linesCnt == 1) then
                            ^
            ]]
                local expectedDot = [[
    if reg.type == "v" or (test_Foobareg.type == "V" and linesCnt == 1) then
            ]]
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "foobar", "v")
                runCommandAndAssert([["agrh]], expected)
                -- replace, via dot
                fn.setreg("a", "test_F", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"$\" motion", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ^
            ]]
                local expected = [[
    if reg.type == "v" or (ruthless
                            ^
            ]]
                local expectedDot = [[
    if reg.type == "v" or (room
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "uthless", "V")
                runCommandAndAssert([["agr$]], expected)
                -- replace, via dot
                fn.setreg("a", "oom", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"Te\" motion", function() -- {{{
                local input = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ^
            ]]
                local expected = [[
    if reg.typescript peg.type == "V" and linesCnt == 1) then
               ^
            ]]
                local expectedDot = [[
    if reg.typer's luascript peg.type == "V" and linesCnt == 1) then
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "script p", "V")
                runCommandAndAssert([["agrTe]], expected)
                -- replace, via dot
                fn.setreg("a", "                                  r's lua      \n\t         ", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

        describe('up-down-motions: ', function() -- {{{
            it("replace with \"3j\" motion", function() -- {{{
                local input = [[
        if reindentCnt < 0 then
            reg.content = string.gsub(reg.content, "▲" .. reindents, "")
                   ^
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
                   ^
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

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "nulla sunt exuis nsunt velit enim.", "V")
                runCommandAndAssert([["agr3j]], expected)
                -- replace, via dot
                fn.setreg("a", "Lorem ipsum dolor sit amet.", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"3k\" motion", function() -- {{{
                local input = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "▲" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
                        reg.content = reindents .. reg.content
                            if lineCnt ~= 1 then
                                end
        reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                                                               ^
                                        end
            ]]
                local expected = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "▲" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
        nulla sunt exuis nsunt velit enim.
        ^
                                        end
            ]]
                local expectedDot = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "▲" .. reindents, "")
        Lorem ipsum dolor sit amet.
                                        end
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "nulla sunt exuis nsunt velit enim.", "V")
                runCommandAndAssert([["agr3k]], expected)
                -- replace, via dot
                fn.setreg("a", "Lorem ipsum dolor sit amet.", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"4k\" motion", function() -- {{{
                local input = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "▲" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
                        reg.content = reindents .. reg.content
                            if lineCnt ~= 1 then
                                end
        reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                                        end
                                         ^
            ]]
                local expected = [[
if reindentCnt < 0 then
    reg.content = string.gsub(reg.content, "▲" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
                                        endif
                                        ^
            ]]
                local expectedDot = [[
if reindentCnt < 0 then
                                        fidne
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "endif", "V")
                runCommandAndAssert([["agr4k]], expected)
                -- replace, via dot
                fn.setreg("a", "fidne", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"_\" motion", function() -- {{{
                local input = [[
            if lineCnt ~= 1 then
                    ^
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
            ^
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

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "foo", "V")
                runCommandAndAssert([["agr3_]], expected)
                -- replace, via dot
                fn.setreg("a", "bar", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

        describe('word-motions: ', function() -- {{{
            it("replace with \"2W\" motion", function() -- {{{
                local input = [[
            reg.content = string.gsub(reg.content, "▲" .. reindents, "")
                                 ^
            ]]
                local expected = [[
            reg.content = string.find(val1, val2, val3.. reindents, "")
                                 ^
            ]]
                local expectedDot = [[
            reg.content = string.global_sub(arg1, arg2,val3.. reindents, "")
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "find(val1, val2, val3\t", "V")
                runCommandAndAssert([["agr2W]], expected)
                -- replace, via dot
                fn.setreg("a", "global_sub(arg1, arg2,\n", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"4ge\" motion", function() -- {{{
                local input = [[
local reindentCnt = reindent(reg, regionMotion, motionDirection)
    if indent ~=0 then
        fn.setreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
            ^
            ]]
                local expected = [[
local reindentCnt = reindent(reg, regionMotion, motionDirection)
    if indent ~=getreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
                ^
            ]]
                local expectedDot = [[
local reindentCnt = reindent(reg, regionMotion, motionDirection+ getreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "ge", "V")
                runCommandAndAssert([["agr4ge]], expected)
                -- replace, via dot
                fn.setreg("a", " + g               \t             ", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"5b\" motion", function() -- {{{
                local input = [[
if M then
        fn.set
            reg = {
                name
                  ^
            ]]
                local expected = [[
if M then
        fn.help_me
           ^
            ]]
                local expectedDot = [[
foobar_help_me
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "help_", "V")
                runCommandAndAssert([["agr5b]], expected)
                -- replace, via dot
                fn.setreg("a", "\tfoobar_\t", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"6b\" motion", function() -- {{{
                local input = [[
    if vimMode == "n" then
        if not M.cursorPos then
            else
                if not cursorNS then
                    if motionDirection == 1 then
                                        ^
            ]]
                local expected = [[
    if vimMode == "n" then
        if not M.cursorPos then
            else
                if number ~= 1 then
                   ^
            ]]
                local expectedDot = [[
    if vimMode == "n" then
        if not M.factor +number ~= 1 then
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "number ~", "V")
                runCommandAndAssert([["agr6b]], expected)
                -- replace, via dot
                fn.setreg("a", "M.factor +\t", "V")
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
                    reg.content = string.gsub(reg.content, "▲" .. reindents, "")

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
              ^
            ]]
                local expected = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = stringCount(reg.content, "\n")

            -- Reindent the lines if counts do not match up
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))

                if reindentCnt < 0 then
                    reg.content = string.gsub(reg.content, "▲" .. reindents, "")

                    if lineCnt ~= 1 then
                        reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    end

                elseif reindentCnt > 0 then
                    reg.content = reindents .. reg.content
while true
^
            ]]
                local expectedDot = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = stringCount(reg.content, "\n")

            -- Reindent the lines if counts do not match up
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))
foobar2021
while true
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "while", "V")
                runCommandAndAssert([["agr3{]], expected)
                -- replace, via dot
                fn.setreg("a", "foobar2021", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"4}\" motion", function() -- {{{
                local input = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = stringCount(reg.content, "\n")
                                ^

            -- Reindent the lines if counts do not match up
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))

                if reindentCnt < 0 then
                    reg.content = string.gsub(reg.content, "▲" .. reindents, "")

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
                                ^

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

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "foo", "V")
                runCommandAndAssert([["agr4}]], expected)
                -- replace, via dot
                fn.setreg("a", "bar", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

        describe('text-objects: ', function() -- {{{
            it("replace with \"iw\" motion", function() -- {{{
                local input = [[
        api.nvim_win_set_cursor(0, {M.cursorPos[1], #cursorLine})
                                                          ^
            ]]
                local expected = [[
        api.nvim_win_set_cursor(0, {M.cursorPos[1], #foo})
                                                     ^
            ]]
                local expectedDot = [[
        api.nvim_win_set_cursor(0, {M.cursorPos[1], #bar})
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "foo", "V")
                runCommandAndAssert([["agriw]], expected)
                -- replace, via dot
                fn.setreg("a", "bar", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"a)\" motion, charwise", function() -- {{{
                local input = [[
            api.nvim_win_set_cursor(0, {regionReplace.startPos[1], newCol - 1})
                                                         ^
            ]]
                local expected = [[
            api.nvim_win_set_cursor(2 * (index - 1))
                                   ^
            ]]
                local expectedDot = [[
            api.nvim_win_set_cursor[index]
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "(2 * (index - 1))", "V")
                runCommandAndAssert([["agra)]], expected)
                -- replace, via dot
                fn.setreg("a", "[index]", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"a)\" motion, linewise", function() -- {{{
                local input = [[
            local repEndLine = api.nvim_buf_get_lines(curBufNr,
                regionReplace.endPos[1] - 1, regionReplace.endPos[1], false)[1]
                                   ^
            ]]
                local expected = [[
            local repEndLine = api.nvim_buf_get_lines(bufNr, start, end, true)[1]
                                                     ^
            ]]
                local expectedDot = [[
            local repEndLine = api.nvim_buf_get_lines_tbl[1]
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "(bufNr, start, end, true)", "V")
                runCommandAndAssert([["agra)]], expected)
                -- replace, via dot
                fn.setreg("a", "_tbl", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"a<\" motion, linewise", function() -- {{{
                local input = [[
<ul class="something" keyattr="attr and class has no highlight anymore">
    <li class="workaround"
        keyattr="linebreaks">text</li>
                  ^
</ul>
            ]]
                local expected = [[
<ul class="something" keyattr="attr and class has no highlight anymore">
    <List name="foo">text</li>
    ^
</ul>
            ]]
                local expectedDot = [[
<ul class="something" keyattr="attr and class has no highlight anymore">
    </li>text</li>
</ul>
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", '<List name="foo">', "V")
                runCommandAndAssert([["agra<]], expected)
                -- replace, via dot
                fn.setreg("a", "</li>", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i<\" motion, charwise", function() -- {{{
                local input = [[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
             ^
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
   ^
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

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "meta none", "V")
                runCommandAndAssert([["agri<]], expected)
                -- replace, via dot
                fn.setreg("a", "foobar", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i<\" motion, linewise", function() -- {{{
                local input = [[
<ul class="something"
             ^
    keyattr="attr and class has no highlight anymore">
</ul>
            ]]
                local expected = [[
<URL>
 ^
</ul>
            ]]
                local expectedDot = [[
</ul>
</ul>
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "URL", "V")
                runCommandAndAssert([["agri<]], expected)
                -- replace, via dot
                fn.setreg("a", "/ul", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i{\" motion, charwise", function() -- {{{
                local input = [[
    local opts = {hlGroup = "Search", timeout = 250}
                  ^
            ]]
                local expected = [[
    local opts = {timeout = 150}
                  ^
            ]]
                local expectedDot = [[
    local opts = {vimMode = 'n'}
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "timeout = 150", "V")
                runCommandAndAssert([["agri{]], expected)
                -- replace, via dot
                fn.setreg("a", "vimMode = 'n'", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i{\" motion, linewise", function() -- {{{
                local input = [[
        regionMotion = {
            startPos = api.nvim_buf_get_mark(curBufNr, "["),
            endPos   = api.nvim_buf_get_mark(curBufNr, "]")
                           ^
        }
            ]]
                local expected = [[
        regionMotion = {
            foo
            ^
        }
            ]]
                local expectedDot = [[
        regionMotion = {
            bar
        }
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "foo", "V")
                runCommandAndAssert([["agri{]], expected)
                -- replace, via dot
                fn.setreg("a", "bar", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i[\" motion, charwise", function() -- {{{
                local input = [[
api.nvim_buf_add_highlight(curBufNr, repHLNS, opts["hlGroup"], lineNr, cols[1], cols[2])
                                                     ^
            ]]
                local expected = [[
api.nvim_buf_add_highlight(curBufNr, repHLNS, opts[myHighlightGroup], lineNr, cols[1], cols[2])
                                                     ^
            ]]
                local expectedDot = [[
api.nvim_buf_add_highlight(curBufNr, repHLNS, opts['foo'], lineNr, cols[1], cols[2])
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "myHighlightGroup", "V")
                runCommandAndAssert([["agri[]], expected)
                -- replace, via dot
                fn.setreg("a", "'foo'", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i[\" motion, linewise", function() -- {{{
                local input = [==[[[
    elseif vimMode == "n" then
                foobar
        if reg.type == "v" then
                ^
            if motionType == "line" then
                local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
            ]]]==]
                local expected = [==[[[
    if reg.type == "v" then
        if motionType == "line" then
            ]]]==]
                local expectedDot = [==[[[
    M.replaceSave = function()
        end

            ]]]==]
                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", '        if reg.type == "v" then\n            if motionType == "line" then\n', "V")
                runCommandAndAssert([["agri[]], expected)
                -- replace, via dot
                fn.setreg("a", "M.replaceSave = function()\n    end\n   ", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i\"\" motion, test1", function() -- {{{
                local input = [[
            it("replace", function()
                     ^
            ]]
                local expected = [[
            it("bar", function()
                ^
            ]]
                local expectedDot = [[
            it("foobar", function()
            ]]

                setUpBuffer(input, "lua")
                assert.are.same(api.nvim_win_get_cursor(0), {1, 21})
                -- replace
                fn.setreg("a", "bar", "V")
                runCommandAndAssert([["agri"]], expected)
                -- replace, via dot
                fn.setreg("a", "foobar", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}

            it("replace with \"i\"\" motion, test2", function() -- {{{
                local input = [[
        fn["repeat#set"](t"<Plug>ReplaceExpr")
                     ^
            ]]
                local expected = [[
        fn["addSortedDataToTable"](t"<Plug>ReplaceExpr")
                     ^
            ]]
                local expectedDot = [[
        fn["foobar"](t"<Plug>ReplaceExpr")
            ]]

                setUpBuffer(input, "lua")
                -- replace
                fn.setreg("a", "addSortedDataToTable", "V")
                runCommandAndAssert([["agri"]], expected)
                -- replace, via dot
                fn.setreg("a", "foobar", "V")
                runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

        describe('mark-motions: ', function() -- {{{
            it("replace with \"`m\" motion, charwise", function() -- {{{
                local input = [[
        local fn   = vim.fn
        local cmd  = vim.cmd
                         ^
        local api  = vim.api
                ]]
                    local expected = [[
        local fn   = vim.lsp.cmd
                         ^
        local api  = vim.api
                ]]
                    local expectedDot = [[
find
        local api  = vim.api
                ]]

                    setUpBuffer(input, "lua")
                    -- replace
                    vim.cmd("norm! mm")
                    fn.setreg("a", "lsp.", "V")
                    runCommandAndAssert([[gg"agr`m]], expected)
                    -- replace, via dot
                    vim.cmd("norm! 0")
                    fn.setreg("a", "fin", "V")
                    runCommandAndAssert([[.]], expectedDot)
            end) -- }}}
        end) -- }}}

    end)

end) -- }}}


