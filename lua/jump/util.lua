local M = {}


--- Reverse a list-like table
---@param t table
---@return table
M.tblReverse = function(t) -- {{{
    local tblReversed = {}
    local len = #t
    for k, v in ipairs(t) do
        tblReversed[len + 1 - k] = v
    end
    return tblReversed
end -- }}}
--- Register specific line region in current buffer
---@param startLineNr? number
---@param lastLineNr? number
M.jumplistRegisterLines = function(startLineNr, lastLineNr) -- {{{
    startLineNr = startLineNr or 1
    if not lastLineNr then
        lastLineNr = vim.fn.line("$")
    else
        local bufferLastLine = vim.fn.line("$")
        lastLineNr = lastLineNr > bufferLastLine and bufferLastLine or lastLineNr
    end
    vim.cmd([[norm! ]] .. startLineNr .. [[G0]])
    vim.cmd [[clearjumps]]

    for i = 1, lastLineNr, 1 do
        if i ~= lastLineNr then
            -- NOTE: m``` failed to register in jumplist when cursor is at the
            -- last line of the buffer
            vim.cmd [[norm! m```j]]
        end
    end
end -- }}}
--- Split the string output of `:jumps` into table by line break
---@param noStdlib boolean Whether to use the `vim.split` function in standard
--library to split the string
---@return string[]
M.getJumpsCmd = function(noStdlib) -- {{{
    local jumpsTbl = {}
    local jumpsOutput = vim.api.nvim_exec2("jumps", { output = true }).output
    if not noStdlib then
        return vim.split(jumpsOutput, "\n", { plain = true, trimempty = false })
    else
        local lastIdx = { 0 }
        local idxTbl = {}
        repeat
            lastIdx = { string.find(jumpsOutput, "\n", lastIdx[1] + 1, true) }
            if next(lastIdx) then
                idxTbl[#idxTbl + 1] = vim.deepcopy(lastIdx)
            end
        until not next(lastIdx)

        if not next(idxTbl) then
            return {}
        end

        -- {        idx1,     idx2,     idx3,     idx4      }
        --      ↑          ↑         ↑         ↑         ↑
        -- {<headStr1>,<subStr2>,<subStr3>,<subStr4>,<tailStr5>}
        for i, idx in ipairs(idxTbl) do
            if i < #idxTbl then
                local nextIdx = idxTbl[i + 1]
                if idx[2] + 1 ~= nextIdx[1] then
                    -- Skip adjacent to next idx
                    local midStr = string.sub(jumpsOutput, idx[2] + 1, nextIdx[1] - 1)
                    jumpsTbl[#jumpsTbl + 1] = midStr
                end
            end
            if i == 1 then
                if idx[1] ~= 1 then
                    -- Skip adjacent to the beginning
                    local headStr = string.sub(jumpsOutput, 1, idx[1] - 1)
                    jumpsTbl[#jumpsTbl + 1] = headStr
                end
            end
            if i == #idxTbl then
                if idx[2] ~= string.len(jumpsOutput) then
                    -- Skip adjacent to the end
                    local tailStr = string.sub(jumpsOutput, idx[2] + 1, -1)
                    jumpsTbl[#jumpsTbl + 1] = tailStr
                end
            end
        end
    end

    return jumpsTbl
end -- }}}
--- Parse data in a single line in the `:jumps`
---@param jumpCmdRaw string
M.jumpCmdParse = function(jumpCmdRaw) -- {{{
    local parseResult = { string.match(jumpCmdRaw, "^>?%s*(%d+)%s+(%d+)%s+(%d+)%s+(.*)$") }
    if not next(parseResult) then
        return parseResult
    else
        return {
            count = parseResult[1],
            lnum  = tonumber(parseResult[2]),
            col   = tonumber(parseResult[3]),
            text  = parseResult[4]
        }
    end
end -- }}}
--- Register specific line region in the current buffer and generate the `:
--jumps` output as table or redirect it to a scratch buffer
---@param returnJumpsChk? boolean Whether to return output as table or
--redirect the output into a scratch buffer
---@param startLineNr? number
---@param lastLineNr? number
---@param onlyOutputSpecialCharChk boolean Whether to generate output only
--when non-printable character found in the `:jumps` prompt
---@param bufferThreshold? number How many lines to capture the `:jumps`
--output. Default is 50, which is the gerneral line number the `:jumps` will
--remember
M.jumplistRegisterLinesToTbl = function(returnJumpsChk, startLineNr, lastLineNr, onlyOutputSpecialCharChk, bufferThreshold) -- {{{
    startLineNr = startLineNr or 1
    bufferThreshold = bufferThreshold or 50
    if not lastLineNr then
        lastLineNr = vim.fn.line("$")
    else
        local bufferLastLine = vim.fn.line("$")
        lastLineNr = lastLineNr > bufferLastLine and bufferLastLine or lastLineNr
    end

    local jumpsTbl = {}
    local extendJump = function()
        local jumps = M.getJumpsCmd()
        vim.cmd [[noa clearjumps]]
        for _, jump in ipairs(jumps) do
            if jump ~= " jump line  col file/text" and string.sub(jump, 1, 1) ~= ">" then
                jumpsTbl[#jumpsTbl+1] = jump
            end
        end
    end

    -- Start registering
    vim.cmd([[norm! ]] .. startLineNr .. [[G0]])
    vim.cmd [[clearjumps]]
    for i = 1, lastLineNr, 1 do
        -- Register in every lines
        if i ~= lastLineNr then
            -- NOTE: m``` failed to register in jumplist when cursor is at the
            -- last line of the buffer
            vim.cmd [[norm! m```j]]
        else
            if lastLineNr % bufferThreshold ~= 0 then
                extendJump()
            end
        end

        if i % bufferThreshold == 0 then
            extendJump()
        end
    end

    -- Check special character
    if onlyOutputSpecialCharChk then
        local specialCharTick = false
        for _, j in ipairs(jumpsTbl) do
            if string.find(j, "^", 1, true) then
                specialCharTick = true
                break
            end
        end
        if not specialCharTick then
            vim.notify("No special characters found")
            return
        end
    end

    if returnJumpsChk then
        return jumpsTbl
    end

    -- Output the result into a new scratch buffer
    require("buffer.util").redirScratch(jumpsTbl, nil)
end -- }}}
--- Execute ex command then center the screen if necessary
---@param exCmd string|function Ex command or executable function
---@param suppressMsgChk? boolean Whether to suppress the error message when
--execute the `exCmd` string or call the `exCmd` function
---@param remapChk? boolean Whether to use remap key when execute a ex command
M.posCenter = function(exCmd, suppressMsgChk, remapChk) -- {{{
    local winID      = vim.api.nvim_get_current_win()
    local prevBufNr  = vim.api.nvim_get_current_buf()
    local preWinInfo = vim.fn.getwininfo(winID)[1]
    local ok, valOrMsg

    -- Execute the command first
    if type(exCmd) == "string" then
        local remapStr = remapChk and "normal " or "normal! "
        ok, valOrMsg = pcall(vim.api.nvim_command, remapStr .. vim.v.count1 .. t(exCmd))
    elseif type(exCmd) == "function" then
        ok, valOrMsg = pcall(exCmd)
    else
        return
    end

    if not ok and not suppressMsgChk then
        vim.notify(valOrMsg, vim.log.levels.INFO)
    end

    local postBufNr = vim.api.nvim_get_current_buf()

    -- Jump to a different buffer
    if prevBufNr ~= postBufNr then return end

    -- Make sure cursor does not sit on a fold line
    vim.cmd[[norm! zv]]

    local postCursorPos = vim.api.nvim_win_get_cursor(winID)
    if postCursorPos[1] < preWinInfo.topline or postCursorPos[1] > preWinInfo.botline then
        vim.cmd [[norm! zz]]
    end
end -- }}}


return M
