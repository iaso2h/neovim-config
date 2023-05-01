local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local M   = {}


--- Create a scratch window and resize it
local function newWin(func, funcArgList, bufListed, scratchBuf, layoutStyle, height2width, width2height)
    local newBufNr = api.nvim_create_buf(bufListed, scratchBuf)
    if layoutStyle == "col" then
        cmd [[wincmd v]]
        api.nvim_win_set_buf(0, newBufNr)
        cmd("vertical resize " .. (api.nvim_win_get_width(0) - math.floor(api.nvim_win_get_height(0) * 0.618 * height2width)))
    else
        cmd [[wincmd s]]
        api.nvim_win_set_buf(0, newBufNr)
        cmd("resize " .. (api.nvim_win_get_height(0) - math.floor(api.nvim_win_get_width(0) * 0.618 * width2height)))
    end
    if func then
        if next(funcArgList) then
            func(newBufNr, funcArgList)
        else
            func(newBufNr)
        end
    end
end


--- Create a new split window based on the window layout
--- @param func function Func to be executed after new window is create. This
--- function must accept the buffer number of the new buffer as the first
--- argument
--- @param funcArgList table Function argument table, can be empty
--- @param bufnamePat string Shift focus to window if any window contains the
--- buffer that match the given pattern, can be an empty string
--- @param bufListed boolean Determine whether the new create buffer listed
--- when calling api.nvim_create_buf()
--- @param scratchBuf boolean Create a "throwaway" scratch-buffer when calling
--- api.nvim_create_buf()
function M.init(func, funcArgList, bufnamePat, bufListed, scratchBuf) -- {{{
    local winIDTbl            = api.nvim_list_wins()
    local winIDNonRelativeTbl = vim.tbl_filter(function(winID) return vim.api.nvim_win_get_config(winID).relative == "" end, winIDTbl)
    local nonSplitFileTypeTbl = {"coc-explorer", "qf", "NvimTree"}

    local curWinID  = api.nvim_get_current_win()
    local winInfo   = fn.getwininfo()
    local winLayout = fn.winlayout()
    -- -- UbuntuMono
    -- local width2height   = 0.1978
    -- local height2width   = 5.0566
    -- Delugia
    local width2height   = 0.4798
    local height2width   = 2.5523

    local ui             = api.nvim_list_uis()[1]
    local screenWidth    = ui.width
    local screenHeight   = ui.height

    -- Store windows ID for position restoration
    require("buffer.var").newSplitLastBufNr = curWinID

    -- If bufnamePat is provided and vim find the buffer that match the
    -- pattern, Shift focus to that buffer in current window instead
    if bufnamePat ~= "" then -- {{{
        local matchResult
        for _, tbl in ipairs(winInfo) do
            matchResult = string.match(nvim_buf_get_name(api.nvim_win_get_buf(tbl["winid"])), bufnamePat)
            if matchResult then
                vim.api.nvim_set_current_win(tbl["winid"])
                return
            end
        end
    end -- }}}

    if #winIDNonRelativeTbl == 1 then
        if screenWidth <= screenHeight * height2width then
            return newWin(func, funcArgList, bufListed, scratchBuf, "row", height2width, width2height)
        else
            return newWin(func, funcArgList, bufListed, scratchBuf, "col", height2width - 1., width2height)
        end
    else -- {{{

        local newSplitChk = false

        -- Do not split on special window
        if vim.tbl_contains(nonSplitFileTypeTbl, vim.bo.filetype) then
            winLayout[1] = winLayout[1] == "row" and "col" or "row"
            cmd "noautocmd wincmd W"
        end

        repeat
            cmd "noautocmd wincmd W"
            if not vim.tbl_contains(nonSplitFileTypeTbl, vim.bo.filetype) and
                vim.tbl_contains(winIDNonRelativeTbl, api.nvim_get_current_win()) then

                newWin(func, funcArgList, bufListed, scratchBuf, winLayout[1], height2width, width2height)
                newSplitChk = true
            end
        until api.nvim_get_current_win() ~= curWinID

        -- In case of new win never had been created
        if not newSplitChk then
            cmd "noautocmd wincmd W"
            cmd "noautocmd wincmd W"
            return newWin(func, funcArgList, bufListed, scratchBuf, winLayout[1], height2width, width2height)
        end
    end -- }}}
end -- }}}

return M
