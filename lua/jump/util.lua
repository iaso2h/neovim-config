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
---@param startLineNr? integer
---@param lastLineNr? integer
M.jumplistRegisterLines = function(startLineNr, lastLineNr) -- {{{
    startLineNr = startLineNr or 1
    if not lastLineNr then
        lastLineNr = vim.api.nvim_buf_line_count(0)
    else
        local bufferLastLine = vim.api.nvim_buf_line_count(0)
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
---@param exCommand string Vim Ex command to be executed. Either "jumps" or "changes"
---@param noStdlib boolean Whether to use the `vim.split` function in standard
--library to split the string
---@return string[]
M.getJumpsCmd = function(exCommand, noStdlib) -- {{{
    local jumpsTbl = {}
    local jumpsOutput = vim.api.nvim_exec2(exCommand, { output = true }).output
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
---@return table
M.jumpCmdParse = function(jumpCmdRaw) -- {{{
    local parseResult = { string.match(jumpCmdRaw, "^>?%s*(%d+)%s+(%d+)%s+(%d+)%s+(.*)$") }
    if not next(parseResult) then
        return parseResult
    else
        -- NOTE: the `lnum` and `col` is (1, 1) based
        return {
            count = parseResult[1],
            lnum  = tonumber(parseResult[2]),
            col   = tonumber(parseResult[3]),
            text  = parseResult[4]
        }
    end
end -- }}}
--- 1-based index of the ">" character in the ex-command `:jumps` output
---@param jumpsCmdRaw table Captured output of `:jumps`
---@return integer
M.getJumpCmdIdx = function(jumpsCmdRaw) -- {{{
    local CmdRawIdx = 0
    -- Loop backward because the index character ">" is more likely closer to
    -- the end of the `:jumps` list
    -- Ignore the header, starting at 2
    for i = #jumpsCmdRaw, 2, -1 do
        local jumpCmdRaw = jumpsCmdRaw[i]
        if string.sub(jumpCmdRaw, 1, 1) == ">" then
            CmdRawIdx = i
            break
        end
    end

    return CmdRawIdx
end -- }}}
--- Register specific line region in the current buffer and generate the `:
--jumps` output as table or redirect it to a scratch buffer
---@param returnJumpsChk? boolean Whether to return output as table or
--redirect the output into a scratch buffer
---@param startLineNr? integer
---@param lastLineNr? integer
---@param onlyOutputSpecialCharChk boolean Whether to generate output only
--when non-printable character found in the `:jumps` prompt
---@param bufferThreshold? integer How many lines to capture the `:jumps`
--output. Default is 50, which is the gerneral line number the `:jumps` will
--remember
M.jumplistRegisterLinesToTbl = function(returnJumpsChk, startLineNr, lastLineNr, onlyOutputSpecialCharChk, bufferThreshold) -- {{{
    startLineNr = startLineNr or 1
    bufferThreshold = bufferThreshold or 50
    if not lastLineNr then
        lastLineNr = vim.api.nvim_buf_line_count(0)
    else
        local bufferLastLine = vim.api.nvim_buf_line_count(0)
        lastLineNr = lastLineNr > bufferLastLine and bufferLastLine or lastLineNr
    end

    local jumpsTbl = {}
    local extendJump = function()
        local jumps = M.getJumpsCmd("jumps", false)
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
        local specialCharTick = require("util").any(function()
            return string.find(j, "^", 1, true)
        end, jumpsTbl)
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
---@param providedPrevWinId? integer Use the provided window ID to compare
--with the one after executing a ex command or function
---@param providedPrevBufNr? integer Use the provided buffer number to compare
--with the one after executing a ex command or function
M.posCenter = function(exCmd, suppressMsgChk, providedPrevWinId, providedPrevBufNr) -- {{{
    local preWinID  = providedPrevWinId and providedPrevWinId or vim.api.nvim_get_current_win()
    local prevBufNr = providedPrevBufNr and providedPrevBufNr or vim.api.nvim_get_current_buf()
    local preWinInfo = vim.fn.getwininfo(preWinID)[1]
    local ok, valOrMsg

    -- Execute the command first
    if type(exCmd) == "string" then
        ok, valOrMsg = pcall(vim.api.nvim_command, exCmd)
    elseif type(exCmd) == "function" then
        ok, valOrMsg = pcall(exCmd)
    else
        return
    end

    if not ok and not suppressMsgChk then
        if string.find(valOrMsg, "E663:", 1, true) then
            vim.api.nvim_echo({ { "At newest change", "WarningMsg" } }, false, {})
        elseif string.find(valOrMsg, "E662", 1, true) then
            vim.api.nvim_echo({ { "At oldest change", "WarningMsg" } }, false, {})
        else
            vim.notify(valOrMsg, vim.log.levels.INFO)
        end
    end

    local postBufNr = vim.api.nvim_get_current_buf()

    vim.cmd[[norm! zv]]

    -- Jump to a different buffer
    if prevBufNr ~= postBufNr then return end

    -- Make sure cursor does not sit on a fold line
    local postCursorPos = vim.api.nvim_win_get_cursor(preWinID)
    if postCursorPos[1] < preWinInfo.topline or postCursorPos[1] > preWinInfo.botline then
        vim.cmd [[norm! zz]]
    end
end -- }}}


return M
