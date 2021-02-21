-- File: enhanceFold.lua
-- Author: iaso2h
-- Description: Enhnace origin fold feature, mainly focus on markder fold method
-- Version: 0.0.1
-- TODO: Better [z and [Z algorithm
-- Last Modified: 2021-02-09 then
local fn = vim.fn
local cmd = vim.cmd
local api = vim.api
local util = require "util"
local vim = vim
local M = {}
-- Initiation {{{
enhanceFoldInit = 1
enhanceFoldStartHLID = 9138
enhanceFoldEndHLID = 9139
enhanceFoldPriority = enhanceFoldPriority or 30
-- }}} Initiation

----
-- Function: EnhanceFold
--
-- @param modeType: n/v/V standards for normal mode, visual characterwise mode,
-- visual linewise mode
-- @param ...:      When in normal mode, character need provided to be appended at the end of line, but other mode doesn't
-- Returns: 0
----
-- %s#endfunction#end
-- %s#endif#end
-- %s#endwhile#end
-- %s#endfor#end
-- %s#" {{{#-- {{{
-- %s#" }}}#-- }}}
-- %s# \. # \.\.
-- %s#!=#\~=
-- %s#||#or
-- %s#&&#and
-- %s##
-- %s#^\s*"#--
-- %s#==\##==
-- %s#==?##==
-- %s#len(#\#
-- %s#!\(\w\)#not \1
-- %s#\(^\s*\)\(normal!.*\)#\1cmd [[\2]]
-- %s# \\#
function M.enhanceFoldAdd(modeType, ...) -- {{{
    local argTable = table.pack(...)
    local saveCursor = api.nvim_win_get_cursor(0)
    local curLine = api.nvim_get_current_line()
    if modeType == "n" then
        if api.nvim_get_option("filetype") == "vim" then
            local delimiterPosList = util.MatchAll(curLine, '"')
            if #delimiterPosList % 2 ~= 0 then
                cmd("normal! A " .. argTable[1])
            else
                cmd("normal! A" " .. argTable[1])
            end
        else
            cmd("normal! A " .. api.nvim_get_var("filetype") .. " " .. argTable[1])
        end
    elseif vim.stricmp(modeType, "v") == 0 then
        local selectStart = api.nvim_buf_get_mark("<")
        local selectEnd = api.nvim_buf_get_mark(">")
        if selectEnd[1] == selectStart[1] then
            do
                return 0
            end
        else
            if api.nvim_get_option("filetype") == "vim" then
                local delimiterPosList = util.MatchAll(curLine, '"')
                if #delimiterPosList % 2 ~= 0 then
                    api.nvim_win_set_cursor(selectStart[1], 0)
                    cmd [[normal! g_a {{{]]
                    api.nvim_win_set_cursor(selectEnd[1], 0)
                    cmd [[normal! g_a }}}]]
                else
                    api.nvim_win_set_cursor(selectStart[1], 0)
                    cmd [[normal! g_a " {{{]]
                    api.nvim_win_set_cursor(selectEnd[1], 0)
                    cmd [[normal! g_a " }}}]]
                end
            else
                api.nvim_win_set_cursor(selectStart[1], 0)
                cmd ("normal! g_a " .. vim.g.FiletypeCommentDelimiter[vim.o.filetype] .. " {{{")
                api.nvim_win_set_cursor(selectEnd[1], 0)
                cmd ("normal! g_a " .. vim.g.FiletypeCommentDelimiter[vim.o.filetype] .. " }}}")
            end
        end

        -- TODO: Refresh fold sign column ?
        api.nvim_win_set_cursor(0, saveCursor)
    end
end -- }}}

----
-- Function: EnhanceFoldJump: Jump to previous/next fold location inclusively
--
-- @param direction:   Possible value "previous", "next"
-- @param showWarning: boolean. Whether to show warnning message
-- when not inside fold scope
-- @param returnVar:   boolean. Whether to return verbose list when execute successfully
-- returns: return [true, l:foldPos, l:matchPos] when returnVar is set to true, otherwise return [true] when succeeded, return [false] when failed
----
function M.enhanceFoldJump(direction, showWarning, returnVar) -- {{{
    local command
    if direction == "previous" then
        command = "[z"
    elseif direction == "next" then
        command = "]z"
    end
    local saveView = fn.winsaveview()
    local cursorPos = api.nvim_win_get_cursor(0)
    local lastFoldPos = cursorPos
    -- Get fold position
    local foldPos
    local matchPos
    cmd ("keepjumps normal! " .. command)
    while 1 do -- {{{
        foldPos = api.nvim_win_get_cursor(0)
        local foldPosLine = api.nvim_get_current_line()
        -- Parsing pattern
        if direction == "previous" then
            matchPos = fn.matchstrpos(foldPosLine, vim.g.enhanceFoldStartPat[vim.o.filetype])
        elseif direction == "next" then
            matchPos = fn.matchstrpos(foldPosLine, vim.g.enhanceFoldEndPat[vim.o.filetype])
        end

        local lineComment
        local lineCommentIdent
        -- TODO: ?
        if matchPos[1] ~= "" then
            lineComment = matchPos[2] == 0
            lineCommentIdent = (matchPos[1][1] == " " or matchPos[1][1] == '\t') and true or false
            break
        end
        -- Check inside foldermarker scope
        if foldPos == lastFoldPos then
            if showWarning then
                api.nvim_echo({"Not inside fold scope", "WarningMsg"}, true, {})
                fn.winrestview(saveView)
                do
                    return {false}
                end
            end
        else
            lastFoldPos = foldPos
            cmd("keepjumps normal! " .. command)
        end
    end -- }}}
-- Make jump location when returnVar is 0
    if returnVar then
        cmd [[normal! mz`z]]
    end

    return returnVar == 1 and {true, foldPos, matchPos} or {true}
end -- }}}


--"
-- Function: EnhanceFoldHL Enhence Fold Highlight Light, highlight
-- previous/next fold when cursor within the fold scope
--
-- @param warningMsg: string value to show when fold scope not found, provided
-- empty string wont't show message when fold scope not found
-- @param time:       milisecond to start the EnhanceFoldRemoveHLMatch() and
-- the appending function
-- @param funcName:   function name in a string value, this function will be
-- invoke with the EnhanceFoldRemoveHLMatch() function when reaching time if
-- provide
-- Returns: 0
--"
function EnhanceFoldHL(warningMsg, time, funcName) -- {{{
    local saveView = fn.winsaveview()
-- Fold marker info
    local validStartFoldPos = M.enhanceFoldJump("previous", false, true)
-- Check valid fold position
    if not validStartFoldPos[1] then
        if warningMsg ~= "" then
        api.nvim_echo({warningMsg, "WarningMsg"}, true, {})
        do return 0 end
        end
    end
    local foldStartPos = validStartFoldPos[2]
    local foldStartMatchPos = validStartFoldPos[3]
    local validEndFoldPos = M.enhanceFoldJump("next", false, true)
    local foldEndPos= validEndFoldPos[2]
    local foldEndMatchPos = validEndFoldPos[3]
    local winID = api.nvim_get_current_win()
    -- Create Highlight {{{
    local foldStartDict = {
        matchID       = enhanceFoldStartHLID,
        foldPos       = foldStartPos,
        matchPos      = foldStartMatchPos,
    }
    local foldEndDict = {
        matchID       = enhanceFoldEndHLID,
        foldPos       = foldEndPos,
        matchPos      = foldEndMatchPos,
    }
    local foldHLNS
    for idx, val in ipairs({foldStartDict, foldEndDict}) do
        foldHLNS = api.nvim_buf_add_highlight(0, 0, "Search", val["foldPos"][1] - 1, val["matchPos"][2], val["matchPos"][3])
    end
    -- }}} Create Highlight

    -- Restore view
    fn.winrestview(saveView)
    -- Auto clear Highlight when time > 0
    if time > 0 then fn.timer_start(time, "EnhanceFoldRemoveHLMatch") end
    -- Execute appending function
    if funcName ~= "" then
        call timer_start(time, funcName)
        return 0
    end
end -- }}}

function M.enhanceFoldRemoveHLMatch(...) -- {{{
    while exists("g:enhanceFoldHLMatch[s:winID]") and g:enhanceFoldHLMatch[s:winID] ~= []
        if CompareNeovimVersion("0.5.0", "<=") then
            call matchdelete(remove(g:enhanceFoldHLMatch[s:winID], 0), s:winID)
        else
            call matchdelete(remove(g:enhanceFoldHLMatch[s:winID], 0))
        end
    end
end -- }}}

function M.nhanceDelete(...) abort -- {{{
-- Fold marker info {{{
    let l:foldStartPos = s:foldStartDict["foldPos"]
    let l:foldEndPos = s:foldEndDict["foldPos"]
    let l:saveView = winsaveview()
-- Create restore point
    cmd [[normal! mz`z]]
    -- }}} Fold marker info

    if s:lineComment == 1 then
-- Delete fold start
        execute printf("%ds#%s##g", l:foldStartPos[1], g:enhanceFoldStartPat[&filetype])
        let l:saveUnnamedReg = @@ | d
        let l:foldEndPos[1] -= 1
        let l:saveView["lnum"] -= 1
-- Delete fold end
        execute printf("%ds#%s##g", l:foldEndPos[1], g:enhanceFoldEndPat[&filetype])
-- Delete empty line
        if s:lineComment == 1 | d | end then
    else
        execute printf("%ds#%s##g", l:foldStartPos[1], g:enhanceFoldStartPat[&filetype])
        execute printf("%ds#%s##g", l:foldEndPos[1], g:enhanceFoldEndPat[&filetype])
    end
-- Resotre
    call winrestview(l:saveView)
    if exists("l:saveUnnamedReg") | let @@ = l:saveUnnamedReg | end then
end -- }}}

function M.nhanceChange(...) abort -- {{{
--TODO : " Mode - Commandline " Commandline & Insert {{{ Insert {{{
-- Fold marker info {{{
    let l:foldStartPos = s:foldStartDict["foldPos"]
    let l:foldEndPos = s:foldEndDict["foldPos"]
    let l:saveView = winsaveview()
    -- }}} Fold marker info

    echohl Moremsg
    let l:newFoldMakrerName = input("New fold marder name: ")
    if empty(l:newFoldMakrerName) then
        echohl WarningMsg | echo " " | echo "Cancel" | echohl None
        call winrestview(l:saveView)
        return 0
    else
        if s:lineComment == 1 then
            let l:newFoldStart = printf("%s %s {{{", g:FiletypeCommentDelimiter[&filetype], l:newFoldMakrerName)
            let l:newFoldEnd = printf("%s }}} %s", g:FiletypeCommentDelimiter[&filetype], l:newFoldMakrerName)
        else
            let l:newFoldStart = printf(" %s %s {{{", g:FiletypeCommentDelimiter[&filetype], l:newFoldMakrerName)
            let l:newFoldEnd = printf(" %s }}} %s", g:FiletypeCommentDelimiter[&filetype], l:newFoldMakrerName)
        end
    end
    echohl None
-- Clear highlight
    call EnhanceFoldRemoveHLMatch()
-- Change fold markder name
    execute printf("%ds#%s#%s#g", l:foldStartPos[1], g:enhanceFoldStartPat[&filetype], l:newFoldStart)
    execute printf("%ds#%s#%s#g", l:foldEndPos[1], g:enhanceFoldEndPat[&filetype], l:newFoldEnd)
-- Reindent new comment line
    if s:lineCommentIdent then
        call cursor(l:foldStartPos[1], l:foldStartPos[2])
        cmd [[normal! ==]]
        call cursor(l:foldEndPos[1], l:foldEndPos[2])
        cmd [[normal! ==]]
    end
-- Resotre
    if exists("l:saveUnnamedReg") | let @@ = l:saveUnnamedReg | end then
    call winrestview(l:saveView)
end -- }}}

return M

