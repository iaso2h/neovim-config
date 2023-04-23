local M = {}


M.tblReverse = function(t)
    local tblReversed = {}
    local len = #t
    for k, v in ipairs(t) do
        tblReversed[len + 1 - k] = v
    end
    return tblReversed
end


M.getJumpsTbl = function()
    local jumps = vim.api.nvim_exec2("jumps", { output = true }).output
    local jumpsTbl = vim.split(jumps, "\n", { trimempty = false })
    -- jumpsTbl[1] = nil
    return jumpsTbl
end

M.getJumpCmdIdx = function(jumpsCmdRaw)
    local CmdRawIdx = 0
    -- jumpsCmdRaw[1] = nil -- Remove header
    for i = #jumpsCmdRaw, 2, -1 do
        local jumpCmdRaw = jumpsCmdRaw[i]
        if string.sub(jumpCmdRaw, 1, 1) == ">" then
            CmdRawIdx = i
            break
        end
    end
    return CmdRawIdx
end

M.jumplistRegisterLines = function(startLineNr, lastLineNr)
    startLineNr = startLineNr or 1
    vim.cmd([[norm! ]] .. startLineNr .. [[G0]])
    vim.cmd [[clearjumps]]
    lastLineNr = lastLineNr or vim.fn.line("$")

    for i = 1, lastLineNr, 1 do
        if i ~= lastLineNr then
            -- NOTE: m``` failed to register in jumplist when cursor is at the
            -- last line of the buffer
            vim.cmd [[norm! m```j]]
        end
    end
end


M.jumplistParse = function(jumpCmdRaw, verbose)
    if verbose then
        local parseResult = { string.match(jumpCmdRaw, "^>?%s*(%d+)%s+(%d+)%s+(%d+)%s+(.*)$") }
        if not next(parseResult) then
            return parseResult
        else
            return {
                count = tonumber(parseResult[1]),
                lnum  = tonumber(parseResult[2]),
                col   = tonumber(parseResult[3]),
                text  = parseResult[4]
            }
        end
    else
        return {count = string.match(jumpCmdRaw, "^>?%s*(%d+)%s.*$")}
    end
end


M.jumplistRegisterLinesToTbl = function(returnJumpsChk, startLineNr, lastLineNr, onlyOutputSpecialCharChk, bufferThreshold)
    startLineNr = startLineNr or 1
    lastLineNr = lastLineNr or vim.fn.line("$")
    bufferThreshold = bufferThreshold or 50

    local currentBuf = vim.api.nvim_get_current_buf()
    local jumpsTbl = {}
    local extendJump = function()
        local jumps = M.getJumpsTbl()
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
            if lastLineNr % 50 ~= 0 then
                extendJump()
            end
        end

        if i % 50 == 0 then
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
    local scratchBuf
    if vim.bo.modifiable and not vim.bo.buflisted and vim.bo.bufhidden ~= "" then
        scratchBuf = currentBuf
    else
        -- TODO: how to decide perform a vertical split or a horizontal split
        vim.cmd [[vsplit]]
        scratchBuf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(scratchBuf, "bufhidden", "wipe")
        vim.api.nvim_set_current_buf(scratchBuf)
    end
    vim.api.nvim_buf_set_lines(scratchBuf, 0, -1, false, jumpsTbl)
end


return M
