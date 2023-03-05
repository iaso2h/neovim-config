local fn  = vim.fn
local api = vim.api
local M   = {
    ns = nil,
    nsName = "myQuickfix"
}

M.main = function ()
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
    msgTbl = vim.tbl_filter(function(m)
        local regx1 = vim.regex([=[^\d\+ more line\(s\)\?; \(before\|after\) #\d\+]=])
        local regx2 = vim.regex([=[^\d\+ fewer line\(s\)\?$]=])
        local regx3 = vim.regex([=[^\d\+ change\(s\)\?; \(before\|after\) #\d\+]=])
        if not regx1:match_str(m) and not regx2:match_str(m) and not regx3:match_str(m)
            then return true end
        -- if string.match(m, [=[%d more line; before]=])
    end, msgTbl)
    if not next(msgTbl) then end

    local errorLineTbl = {}
    local checkIndent = false
    local qfTbl = {}
    for _, msg in ipairs(msgTbl) do
        if string.find(msg, [[^E%d+: ]]) then
            -- TODO: replace
            errorLineTbl[#errorLineTbl+1] = #qfTbl
        elseif string.find(msg, [[^E%d+: .*:$]]) then
            errorLineTbl[#errorLineTbl+1] = #qfTbl
            -- Checking indent in the follow iteration
            checkIndent = true
        end

        if checkIndent then
            if string.find(msg, "^\t") then
                msg = string.gsub(msg, "^\t", string.rep(" ", vim.o.tabstop))
            end
        end
        qfTbl[#qfTbl+1] = {text = msg}
    end

    fn.setqflist({}, " ", {title = "qfMessage", items = qfTbl})

    vim.cmd [[copen]]

    vim.defer_fn(function()
        require("quickfix.highlight").add(
            errorLineTbl,
            "ErrorMsg",
            api.nvim_create_namespace(M.nsName)
        )
    end, 0)
end

return M

