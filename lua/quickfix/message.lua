local fn  = vim.fn
local api = vim.api
local M   = {
    filterChk = false
}

--- Pip neovim message into quickfix
M.main = function()
    local msg = api.nvim_cmd({cmd = "messages"}, {output = true})
    local function split(str, sep)
        local result = {}
        local regex = ("([^%s]+)"):format(sep)
        for each in str:gmatch(regex) do
            table.insert(result, each)
        end
        return result
    end

    local msgTbl = split(msg, "\n")
    if M.filterChk then
        msgTbl = vim.tbl_filter(function(m)
            local regx1 = vim.regex([=[^\d\+ more line\(s\)\?;]=])
            local regx2 = vim.regex([=[^\d\+ lines\? less;]=])
            local regx3 = vim.regex([=[^\d\+ fewer line\(s\)\?$]=])
            local regx4 = vim.regex([=[^\d\+ change\(s\)\?; \(before\|after\) #\d\+]=])
            if not regx1:match_str(m) and
                not regx2:match_str(m) and
                not regx3:match_str(m) and
            not regx4:match_str(m) then
                return true end
            -- if string.match(m, [=[%d more line; before]=])
        end, msgTbl)
    end
    if not next(msgTbl) then end

    local errorLineTbl = {}
    local checkIndent = false
    local qfTbl = {}
    for _, m in ipairs(msgTbl) do
        if checkIndent then
            -- local myStr = "\tno file 'C:\\Users\\Hashub\\AppData\\Local\\Temp\\nvim\\packer_hererocks\\2.1.0-beta3\\share\\lua\\5.1\\e.lua'"
            -- Print(string.find(myStr, "^\t"))
            if string.find(m, "^\t") then
                local indentMsg = string.gsub(m, "^\t", string.rep(" ", vim.o.tabstop))
                -- Close check in next iteration
                if m == indentMsg then
                    checkIndent = false
                else
                    m = indentMsg
                end
            else
                checkIndent = false
            end
        end
        qfTbl[#qfTbl+1] = {text = m}

        -- Checking vim error code
        if string.find(m, [=[^E%d+: .*[^:]$]=]) or
        string.find(m, [[^Error executing vim.schedule lua callback]]) then
            errorLineTbl[#errorLineTbl+1] = #qfTbl
        else
            if string.find(m, [[^E%d+: .*:$]]) or
                string.find(m, [[^stack traceback:]]) or
                string.find(m, [[^Error executing l?L?ua]])
                then
                -- Checking indent in the follow iteration
                errorLineTbl[#errorLineTbl+1] = #qfTbl
                checkIndent = true
            end
        end
    end

    if #qfTbl == 0 then
        return vim.notify("No messages", vim.log.levels.INFO)
    end

    require("quickfix.highlight").clear()
    fn.setqflist({}, "r", {title = "qfMessage", items = qfTbl})

    vim.cmd [[copen]]
    vim.cmd [[clast]]

    vim.defer_fn(function()
        require("quickfix.highlight").add(
            errorLineTbl,
            "ErrorMsg",
            require("quickfix").ns
        )
    end, 0)
end

return M

