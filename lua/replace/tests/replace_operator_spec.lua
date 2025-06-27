-- NOTE: http://olivinelabs.com/busted/
local initLines

local outputLines
local outputCursorPos

local expectedLines
local expectedCursorPos
local expectedDotLines
local cursorIndicatorChar = "^"

describe([[Register type is "v". ]], function()

    describe([[Left-right-motions. ]], function() -- {{{
        it([[Replace with "l" motion]], function() -- {{{
            initLines = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ^
            ]]
            expectedLines = [[
    if reg.type == "v" or (robbing.type == "V" and linesCnt == 1) then
                            ^
            ]]
            expectedDotLines = [[
    if reg.type == "v" or (rushing and robbing.type == "V" and linesCnt == 1) then
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg([[a]], "obbin", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agrl]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg([[a]], "ushing and ro", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with h motion]], function() -- {{{
            initLines = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ^
            ]]
            expectedLines = [[
    if reg.type == "v" or (dogleg.type == "V" and linesCnt == 1) then
                            ^
            ]]
            expectedDotLines = [[
    if reg.type == "v" or (frandrogleg.type == "V" and linesCnt == 1) then
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg([[a]], "dogl", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agrh]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg([[a]], "frandr", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with $ motion]], function() -- {{{
            initLines = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ^
            ]]
            expectedLines = [[
    if reg.type == "v" or (ruthless
                            ^
            ]]
            expectedDotLines = [[
    if reg.type == "v" or (room
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg([[a]], "uthless", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agr$]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg([[a]], "oom", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with Te motion]], function() -- {{{
            initLines = [[
    if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                            ^
            ]]
            expectedLines = [[
    if reg.typescript peg.type == "V" and linesCnt == 1) then
               ^
            ]]
            expectedDotLines = [[
    if reg.typer's script peg.type == "V" and linesCnt == 1) then
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg([[a]], "script p", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agrTe]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg([[a]], "r's ", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
    end) -- }}}

    describe('Up-down-motions. ', function() -- {{{
        it([[Replace with 3j motion]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
    if reindentCnt < 0 then
        nulla sunt exuis nsunt velit enim.
            ^
            reg.content = reindents .. reg.content
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
            end
        end
            ]]
            expectedDotLines = [[
    if reindentCnt < 0 then
        Lorem ipsum dolor sit amet.
            end
        end
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg([[a]], "nulla sunt exuis nsunt velit enim.", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agr3j]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg([[a]], "Lorem ipsum dolor sit amet.", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with 3k motion]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
    if reindentCnt < 0 then
        reg.content = string.gsub(reg.content, "▲" .. reindents, "")
        if lineCnt ~= 1 then
            reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                elseif reindentCnt > 0 then
    nulla sunt exuis nsunt velit enim.
    ^
                                    end
            ]]
            expectedDotLines = [[
    if reindentCnt < 0 then
        reg.content = string.gsub(reg.content, "▲" .. reindents, "")
    Lorem ipsum dolor sit amet.
                                    end
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "nulla sunt exuis nsunt velit enim.", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agr3k]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "Lorem ipsum dolor sit amet.", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with 4k motion]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
    if reindentCnt < 0 then
        reg.content = string.gsub(reg.content, "▲" .. reindents, "")
        if lineCnt ~= 1 then
            reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                elseif reindentCnt > 0 then
                                    endif
                                    ^
            ]]
            expectedDotLines = [[
    if reindentCnt < 0 then
                                    fidne
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "endif", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agr4k]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "fidne", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with _ motion]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
        foo
        ^
            reg.content = reindents .. reg.content
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
            end
        end
            ]]
            expectedDotLines = [[
        bar
                reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
            end
        end
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foo", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agr3_]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "bar", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
    end) -- }}}

    describe('Word-motions. ', function() -- {{{
        it([[Replace with 2W motion]], function() -- {{{
            initLines = [[
        reg.content = string.gsub(reg.content, "▲" .. reindents, "")
                             ^
            ]]
            expectedLines = [[
        reg.content = string.find(val1, 2 .. reindents, "")
                             ^
            ]]
            expectedDotLines = [[
        reg.content = string.global_sub(arg1, 55 .. reindents, "")
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "find(val1, 2 ", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agr2W]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "global_sub(arg1, 55 ", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with 4ge motion]], function() -- {{{
            initLines = [[
    local reindentCnt = reindent(reg, regionMotion, motionDirection)
        if indent ~=0 then
            fn.setreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
                ^
            ]]
            expectedLines = [[
    local reindentCnt = reindent(reg, regionMotion, motionDirection)
        if indent ~= getreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
                    ^
            ]]
            expectedDotLines = [[
    local reindentCnt = reindent(reg, regionMotion, motionDirection + getreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", " ge", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agr4ge]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", " + ", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with 5b motion]], function() -- {{{
            initLines = [[
if M then
        fn.set
            reg = {
                name
                  ^
            ]]
            expectedLines = [[
if M then
        fn.call_me
           ^
            ]]
            expectedDotLines = [[
It said: call_me
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "call_", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agr5b]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "It said: ", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with 6b motion]], function() -- {{{
            initLines = [[
    if vimMode == "n" then
        if not M.cursorPos then
            else
                if not cursorNS then
                    if motionDirection == 1 then
                                        ^
            ]]
            expectedLines = [[
    if vimMode == "n" then
        if not M.cursorPos then
            else
                if number ~= 1 then
                   ^
            ]]
            expectedDotLines = [[
    if vimMode == "n" then
        if not factor + number ~= 1 then
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "number ~", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agr6b]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "factor + ", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
    end) -- }}}

    describe('Object-motions. ', function() -- {{{
        it([[Replace with 3{ motion]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
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
            expectedDotLines = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = stringCount(reg.content, "\n")

            -- Reindent the lines if counts do not match up
            if reindentCnt and reindentCnt ~= 0 then
                local reindents = string.rep(" ", math.abs(reindentCnt))
foobar
while true
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "while", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agr3{]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foobar", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with 4} motion]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
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
            expectedDotLines = [[
        if motionType == "line" then
            local reindentCnt = reindent(reg, regionMotion, motionDirection)
            local lineCnt     = bar

        return true
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foo", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agr4}]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "bar", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
    end) -- }}}

    describe('Text-objects. ', function() -- {{{
        it([[Replace with iw motion]], function() -- {{{
            initLines = [[
    api.nvim_win_set_cursor(0, {M.cursorPos[1], #cursorLine})
                                                      ^
            ]]
            expectedLines = [[
    api.nvim_win_set_cursor(0, {M.cursorPos[1], #foo})
                                                 ^
            ]]
            expectedDotLines = [[
    api.nvim_win_set_cursor(0, {M.cursorPos[1], #bar})
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foo", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agriw]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "bar", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with a) motion, charwise]], function() -- {{{
            initLines = [[
        api.nvim_win_set_cursor(0, {regionReplace.startPos[1], newCol - 1})
                                                     ^
            ]]
            expectedLines = [[
        api.nvim_win_set_cursor(2 * (index - 1))
                               ^
            ]]
            expectedDotLines = [[
        api.nvim_win_set_cursor[index]
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "(2 * (index - 1))", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agra)]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "[index]", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with a) motion, linewise]], function() -- {{{
            initLines = [[
        local repEndLine = api.nvim_buf_get_lines(curBufNr,
            regionReplace.endPos[1] - 1, regionReplace.endPos[1], false)[1]
                               ^
            ]]
            expectedLines = [[
        local repEndLine = api.nvim_buf_get_lines(bufNr, start, end, true)[1]
                                                 ^
            ]]
            expectedDotLines = [[
        local repEndLine = api.nvim_buf_get_lines_tbl[1]
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "(bufNr, start, end, true)", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agra)]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "_tbl", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with a< motion, linewise]], function() -- {{{
            initLines = [[
    <ul class="something" keyattr="attr and class has no highlight anymore">
        <li class="workaround"
    keyattr="linebreaks">text</li>
              ^
    </ul>
            ]]
            expectedLines = [[
    <ul class="something" keyattr="attr and class has no highlight anymore">
        <List name="foo">text</li>
        ^
    </ul>
            ]]
            expectedDotLines = [[
    <ul class="something" keyattr="attr and class has no highlight anymore">
        </li>text</li>
    </ul>
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", '<List name="foo">', "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agra<]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "</li>", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with i< motion, charwise]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
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
            expectedDotLines = [[
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
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "meta none", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agri<]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foobar", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with i< motion, linewise]], function() -- {{{
            initLines = [[
<ul class="something"
             ^
    keyattr="attr and class has no highlight anymore">
</ul>
            ]]
            expectedLines = [[
<URL>
 ^
</ul>
            ]]
            expectedDotLines = [[
</ul>
</ul>
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "URL", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agri<]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "/ul", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with i{ motion, charwise]], function() -- {{{
            initLines = [[
    local opts = {hlGroup = "Search", timeout = 250}
                  ^
            ]]
            expectedLines = [[
    local opts = {timeout = 150}
                  ^
            ]]
            expectedDotLines = [[
    local opts = {vimMode = 'n'}
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "timeout = 150", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agri{]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "vimMode = 'n'", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with i{ motion, linewise]], function() -- {{{
            initLines = [[
    regionMotion = {
        startPos = api.nvim_buf_get_mark(curBufNr, "["),
        endPos   = api.nvim_buf_get_mark(curBufNr, "]")
                       ^
    }
            ]]
            expectedLines = [[
    regionMotion = {
        foo
        ^
    }
            ]]
            expectedDotLines = [[
    regionMotion = {
        bar
    }
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foo", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agri{]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "bar", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with i[ motion, charwise]], function() -- {{{
            initLines = [[
vim.hl.range(curBufNr, repHLNS, opts["hlGroup"], {lineNr, cols[1]}, {lineNr, cols[2] + 1})
                                                     ^
            ]]
            expectedLines = [[
vim.hl.range(curBufNr, repHLNS, opts[myHighlightGroup], {lineNr, cols[1]}, {lineNr, cols[2] + 1})
                                                     ^
            ]]
            expectedDotLines = [[
vim.hl.range(curBufNr, repHLNS, opts['foo'], {lineNr, cols[1]}, {lineNr, cols[2] + 1})
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "myHighlightGroup", "c")
            outputLines, outputCursorPos     = feedkeysOutput([=["agri[]]=])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "'foo'", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with i" motion, test1]], function() -- {{{
            initLines = [[
        it("replace", function()
                ^
            ]]
            expectedLines = [[
        it("bar", function()
            ^
            ]]
            expectedDotLines = [[
        it("foobar", function()
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "bar", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agri"]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foobar", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)

        end) -- }}}

        it([[Replace with i" motion, test2]], function() -- {{{
            initLines = [[
    fn["repeat#set"](t"<Plug>ReplaceExpr")
                 ^
            ]]
            expectedLines = [[
    fn["addSortedDataToTable"](t"<Plug>ReplaceExpr")
                 ^
            ]]
            expectedDotLines = [[
    fn["foobar"](t"<Plug>ReplaceExpr")
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "addSortedDataToTable", "c")
            outputLines, outputCursorPos     = feedkeysOutput([["agri"]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foobar", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
    end) -- }}}

    describe('Mark-motions. ', function() -- {{{
        it([[Replace with `m motion, charwise]], function() -- {{{
            initLines = [[
        local fn   = vim.fn
        local cmd  = vim.cmd
                         ^
        local api  = vim.api
            ]]
            expectedLines = [[
        local fn   = vim.lsp.cmd
                         ^
        local api  = vim.api
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.cmd("norm! mi")
            vim.fn.setreg("a", "lsp.", "c")
            outputLines, outputCursorPos     = feedkeysOutput([[gg"agr`i]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
    end) -- }}}
end)

describe('Register type is "V". ', function()

    describe('Left-right-motions. ', function() -- {{{
        it([[Replace with l motion]], function() -- {{{
            initLines = [[
            if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                                    ^
            ]]
            expectedLines = [[
            if reg.type == "v" or (rubbing.type == "V" and linesCnt == 1) then
                                    ^
            ]]
            expectedDotLines = [[
            if reg.type == "v" or (rashingbbing.type == "V" and linesCnt == 1) then
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "ubbin", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agrl]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "ashing", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with h motion]], function() -- {{{
            initLines = [[
            if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                                    ^
            ]]
            expectedLines = [[
            if reg.type == "v" or (foobareg.type == "V" and linesCnt == 1) then
                                    ^
            ]]
            expectedDotLines = [[
            if reg.type == "v" or (test_Foobareg.type == "V" and linesCnt == 1) then
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foobar", "v")
            outputLines, outputCursorPos     = feedkeysOutput([["agrh]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "test_F", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
        end) -- }}}

        it([[Replace with $ motion]], function() -- {{{
            initLines = [[
            if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                                    ^
            ]]
            expectedLines = [[
            if reg.type == "v" or (ruthless
                                    ^
            ]]
            expectedDotLines = [[
            if reg.type == "v" or (room
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "uthless", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agr$]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "oom", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with Te motion]], function() -- {{{
            initLines = [[
            if reg.type == "v" or (reg.type == "V" and linesCnt == 1) then
                                    ^
            ]]
            expectedLines = [[
            if reg.typescript peg.type == "V" and linesCnt == 1) then
                       ^
            ]]
            expectedDotLines = [[
            if reg.typer's luascript peg.type == "V" and linesCnt == 1) then
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "script p", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agrTe]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "                                  r's lua      \n\t         ", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
    end) -- }}}

    describe('Up-down-motions. ', function() -- {{{
        it([[Replace with 3j motion]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
        if reindentCnt < 0 then
            nulla sunt exuis nsunt velit enim.
                ^
                reg.content = reindents .. reg.content
                if lineCnt ~= 1 then
                    reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                end
            end
            ]]
            expectedDotLines = [[
        if reindentCnt < 0 then
            Lorem ipsum dolor sit amet.
                end
            end
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "nulla sunt exuis nsunt velit enim.", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agr3j]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "Lorem ipsum dolor sit amet.", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with 3k motion]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
        if reindentCnt < 0 then
            reg.content = string.gsub(reg.content, "▲" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
        nulla sunt exuis nsunt velit enim.
        ^
                                        end
            ]]
            expectedDotLines = [[
        if reindentCnt < 0 then
            reg.content = string.gsub(reg.content, "▲" .. reindents, "")
        Lorem ipsum dolor sit amet.
                                        end
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "nulla sunt exuis nsunt velit enim.", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agr3k]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "Lorem ipsum dolor sit amet.", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with 4k motion]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
        if reindentCnt < 0 then
            reg.content = string.gsub(reg.content, "▲" .. reindents, "")
            if lineCnt ~= 1 then
                reg.content = string.gsub(reg.content, "\n" .. reindents, "\n")
                    elseif reindentCnt > 0 then
                                        endif
                                        ^
            ]]
            expectedDotLines = [[
        if reindentCnt < 0 then
                                        fidne
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "endif", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agr4k]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "fidne", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with _ motion]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
            foo
            ^
                reg.content = reindents .. reg.content
                if lineCnt ~= 1 then
                    reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                end
            end
            ]]
            expectedDotLines = [[
            bar
                    reg.content = string.gsub(reg.content, "\n", "\n" .. reindents)
                end
            end
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foo", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agr3_]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "bar", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
    end) -- }}}

    describe('Word-motions. ', function() -- {{{
        it([[Replace with 2W motion]], function() -- {{{
            initLines = [[
        reg.content = string.gsub(reg.content, "▲" .. reindents, "")
                             ^
            ]]
            expectedLines = [[
        reg.content = string.find(val1, val2, val3.. reindents, "")
                             ^
            ]]
            expectedDotLines = [[
        reg.content = string.global_sub(arg1, arg2,val3.. reindents, "")
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "find(val1, val2, val3\t", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agr2W]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "global_sub(arg1, arg2,\n", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with 4ge motion]], function() -- {{{
            initLines = [[
    local reindentCnt = reindent(reg, regionMotion, motionDirection)
        if indent ~=0 then
    fn.setreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
        ^
            ]]
            expectedLines = [[
    local reindentCnt = reindent(reg, regionMotion, motionDirection)
        if indent ~=getreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
                    ^
            ]]
            expectedDotLines = [[
    local reindentCnt = reindent(reg, regionMotion, motionDirection+ getreg(reg.name, string.rep(" ", indent) .. reg.content, reg.type)
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "ge", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agr4ge]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", " + g               \t             ", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with 5b motion]], function() -- {{{
            initLines = [[
if M then
    fn.set
        reg = {
            name
              ^
        ]]
            expectedLines = [[
if M then
    fn.help_me
       ^
        ]]
            expectedDotLines = [[
foobar_help_me
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "help_", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agr5b]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "\tfoobar_\t", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with 6b motion]], function() -- {{{
            initLines = [[
        if vimMode == "n" then
    if not M.cursorPos then
        else
            if not cursorNS then
                if motionDirection == 1 then
                                    ^
            ]]
            expectedLines = [[
        if vimMode == "n" then
    if not M.cursorPos then
        else
            if number ~= 1 then
               ^
            ]]
            expectedDotLines = [[
        if vimMode == "n" then
    if not M.factor +number ~= 1 then
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "number ~", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agr6b]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "M.factor +\t ", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
    end) -- }}}

    describe('Object-motions. ', function() -- {{{
        it([[Replace with 3{ motion]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
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
            expectedDotLines = [[
    if motionType == "line" then
        local reindentCnt = reindent(reg, regionMotion, motionDirection)
        local lineCnt     = stringCount(reg.content, "\n")

        -- Reindent the lines if counts do not match up
        if reindentCnt and reindentCnt ~= 0 then
            local reindents = string.rep(" ", math.abs(reindentCnt))
foobar2021
while true
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "while", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agr3{]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foobar2021", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with 4} motion]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
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
            expectedDotLines = [[
    if motionType == "line" then
        local reindentCnt = reindent(reg, regionMotion, motionDirection)
        local lineCnt     = bar

    return true
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foo", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agr4}]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "bar", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
    end) -- }}}

    describe('Text-objects. ', function() -- {{{
        it([[Replace with iw motion]], function() -- {{{
            initLines = [[
    api.nvim_win_set_cursor(0, {M.cursorPos[1], #cursorLine})
                                                      ^
        ]]
            expectedLines = [[
    api.nvim_win_set_cursor(0, {M.cursorPos[1], #foo})
                                                 ^
        ]]
            expectedDotLines = [[
    api.nvim_win_set_cursor(0, {M.cursorPos[1], #bar})
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foo", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agriw]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "bar", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with a) motion, charwise]], function() -- {{{
            initLines = [[
        api.nvim_win_set_cursor(0, {regionReplace.startPos[1], newCol - 1})
                                                     ^
        ]]
            expectedLines = [[
        api.nvim_win_set_cursor(2 * (index - 1))
                               ^
        ]]
            expectedDotLines = [[
        api.nvim_win_set_cursor[index]
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "(2 * (index - 1))", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agra)]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "[index]", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with a) motion, linewise]], function() -- {{{
            initLines = [[
        local repEndLine = api.nvim_buf_get_lines(curBufNr,
            regionReplace.endPos[1] - 1, regionReplace.endPos[1], false)[1]
                               ^
        ]]
            expectedLines = [[
        local repEndLine = api.nvim_buf_get_lines(bufNr, start, end, true)[1]
                                                 ^
        ]]
            expectedDotLines = [[
        local repEndLine = api.nvim_buf_get_lines_tbl[1]
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "(bufNr, start, end, true)", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agra)]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "_tbl", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with a< motion, linewise]], function() -- {{{
            initLines = [[
    <ul class="something" keyattr="attr and class has no highlight anymore">
        <li class="workaround"
    keyattr="linebreaks">text</li>
            ^
    </ul>
        ]]
            expectedLines = [[
    <ul class="something" keyattr="attr and class has no highlight anymore">
        <List name="foo">text</li>
        ^
    </ul>
        ]]
            expectedDotLines = [[
    <ul class="something" keyattr="attr and class has no highlight anymore">
        </li>text</li>
    </ul>
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", '<List name="foo">', "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agra<]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "</li>", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with i< motion, charwise]], function() -- {{{
            initLines = [[
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
            expectedLines = [[
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
            expectedDotLines = [[
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
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "meta none", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agri<]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foobar", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with i< motion, linewise]], function() -- {{{
            initLines = [[
    <ul class="something"
        ^
        keyattr="attr and class has no highlight anymore">
    </ul>
        ]]
            expectedLines = [[
    <URL>
     ^
    </ul>
        ]]
            expectedDotLines = [[
    </ul>
    </ul>
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "URL", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agri<]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "/ul", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with i{ motion, charwise]], function() -- {{{
            initLines = [[
        local opts = {hlGroup = "Search", timeout = 250}
            ^
        ]]
            expectedLines = [[
        local opts = {timeout = 150}
            ^
        ]]
            expectedDotLines = [[
        local opts = {vimMode = 'n'}
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "timeout = 150", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agri{]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "vimMode = 'n'", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with i{ motion, linewise]], function() -- {{{
            initLines = [[
    regionMotion = {
        startPos = api.nvim_buf_get_mark(curBufNr, "["),
        endPos   = api.nvim_buf_get_mark(curBufNr, "]")
                    ^
    }
        ]]
            expectedLines = [[
    regionMotion = {
        foo
        ^
    }
        ]]
            expectedDotLines = [[
    regionMotion = {
        bar
    }
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foo", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agri{]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "bar", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with i[ motion, charwise]], function() -- {{{
            initLines = [[
    vim.hl.range(curBufNr, repHLNS, opts["hlGroup"], {lineNr, cols[1]}, {lineNr, cols[2] + 1})
                                                ^
        ]]
            expectedLines = [[
    vim.hl.range(curBufNr, repHLNS, opts[myHighlightGroup], {lineNr, cols[1]}, {lineNr, cols[2] + 1})
                                                ^
        ]]
            expectedDotLines = [[
    vim.hl.range(curBufNr, repHLNS, opts['foo'], {lineNr, cols[1]}, {lineNr, cols[2] + 1})
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "myHighlightGroup", "V")
            outputLines, outputCursorPos     = feedkeysOutput([=["agri[]]=])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "'foo'", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace with i[ motion, linewise]], function() -- {{{
            initLines = [==[[[
elseif vimMode == "n" then
            foobar
    if reg.type == "v" then
            ^
        if motionType == "line" then
            local regContentNew = reindent(reg.content, regionMotion, motionDirection, vimMode)
        ]]]==]
            expectedLines = [==[[[
if reg.type == "v" then
^
    if motionType == "line" then
        ]]]==]
            expectedDotLines = [==[[[
M.replaceSave = function()
    end

        ]]]==]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", '        if reg.type == "v" then\n            if motionType == "line" then\n', "V")
            outputLines, outputCursorPos     = feedkeysOutput([=["agri[]=])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "M.replaceSave = function()\n    end\n   ", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
        end) -- }}}

        it([[Replace with i" motion, test1]], function() -- {{{
            initLines = [[
        it("replace", function()
                ^
        ]]
            expectedLines = [[
        it("bar", function()
            ^
        ]]
            expectedDotLines = [[
        it("foobar", function()
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "bar", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agri"]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foobar", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)

        end) -- }}}

        it([[Replace with i" motion, test2]], function() -- {{{
            initLines = [[
    fn["repeat#set"](t"<Plug>ReplaceExpr")
                ^
        ]]
            expectedLines = [[
    fn["addSortedDataToTable"](t"<Plug>ReplaceExpr")
                ^
        ]]
            expectedDotLines = [[
    fn["foobar"](t"<Plug>ReplaceExpr")
        ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")
            expectedDotLines = vim.split(expectedDotLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "addSortedDataToTable", "V")
            outputLines, outputCursorPos     = feedkeysOutput([["agri"]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)

            -- replace, via dot
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg("a", "foobar", "V")
            outputLines, outputCursorPos     = feedkeysOutput([[.]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedDotLines, cursorIndicatorChar)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
    end) -- }}}

    describe('Mark-motions. ', function() -- {{{
        it([[Replace with `m motion, charwise]], function() -- {{{
            initLines = [[
    local fn   = vim.fn
    local cmd  = vim.cmd
                     ^
    local api  = vim.api
            ]]
            expectedLines = [[
    local fn   = vim.lsp.cmd
                     ^
    local api  = vim.api
            ]]
            initLines        = vim.split(initLines, "\n")
            expectedLines    = vim.split(expectedLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
                vim.fn.setreg("a", "lsp.", "V")
            vim.cmd("norm! mm")
            outputLines, outputCursorPos     = feedkeysOutput([[gg"agr`m]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
    end) -- }}}
end)

describe('Replace with multibyte characters', function()

        it([[Replace 3 bytes character with 1 byte charcter]], function() -- {{{
            initLines = [[
            ct.progressBar.Hint = "等待玩家进入街霸6练习模式"
            log("Pause till palyer enter practice mode")
                                    ^
            ]]
            expectedLines = [[
            ct.progressBar.Hint = "Pause till palyer enter practice mode"
                                   ^
            log("Pause till palyer enter practice mode")
            ]]
            initLines     = vim.split(initLines, "\n")
            expectedLines = vim.split(expectedLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            outputLines, outputCursorPos     = feedkeysOutput([[yi"kgri"]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace 3 byte character with 3 byte character]], function() -- {{{
            initLines = [[
            ct.progressBar.Hint = "等待玩家关闭街霸6练习菜单"
                                   ^
            ct.progressBar.Hint = "等待玩家进入街霸6练习模式"
            ]]
            expectedLines = [[
            ct.progressBar.Hint = "等待玩家关闭街霸6练习菜单"
            ct.progressBar.Hint = "等待玩家关闭街霸6练习菜单"
                                   ^
            ]]
            initLines     = vim.split(initLines, "\n")
            expectedLines = vim.split(expectedLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            outputLines, outputCursorPos     = feedkeysOutput([[yi"jgri"]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}

        it([[Replace 4 byte character with 2 byte character]], function() -- {{{
            initLines = [[
            🤐🤑🤒
            àáâãä
            ^
            ]]
            expectedLines = [[
            àáâãä
            ^
            àáâãä
            ]]
            initLines     = vim.split(initLines, "\n")
            expectedLines = vim.split(expectedLines, "\n")

            -- Setup buffer lines
            initLinesCursor(initLines, "lua", cursorIndicatorChar)

            -- replace
            ---@diagnostic disable-next-line: param-type-mismatch
            outputLines, outputCursorPos     = feedkeysOutput([[y$kgr$]])
            expectedLines, expectedCursorPos = lineFilterCursor(expectedLines, cursorIndicatorChar)
            assert.are.same(expectedCursorPos, outputCursorPos)
            assert.are.same(expectedLines, outputLines)
        end) -- }}}
end)
