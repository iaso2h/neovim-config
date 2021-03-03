local function get_no_fold_line(win_info, win_fold_lnums)
    local win_non_fold_lnums = {}
    local skip_lnums = {}
    local break_for_loop = false
    if #win_fold_lnums == 2 then
        if win_fold_lnums[1] ~= win_info.topline then
            win_non_fold_lnums[1] = {win_fold_lnums[2] + 1, win_info.botline}
        elseif win_fold_lnums[1] ~= win_info.botline then
            win_non_fold_lnums[1] = {win_info.topline, win_fold_lnums[1] - 1}
        else
            win_non_fold_lnums[1] = {win_info.topline, win_fold_lnums[1] - 1}
            win_non_fold_lnums[2] = {win_fold_lnums[2] + 1, win_info.botline}
        end
    else
        for i = 1, #win_fold_lnums do
            if break_for_loop then break end
            repeat
                -- Check continuous numbers {{{
                if i ~= 1 and win_fold_lnums[i] - win_fold_lnums[i - 1] == 1 and
                    vim.tbl_contains(skip_lnums, i) then break end
                -- Check the range of continuous numbers
                local j = i
                while j ~= #win_fold_lnums and win_fold_lnums[j + 1] -
                    win_fold_lnums[j] == 1 do
                    j = j + 1;
                    skip_lnums[#skip_lnums + 1] = j
                end
                -- }}} Check continuous numbers
                -- Break the for loop if a closed fold is at the bottom of the window
                if win_fold_lnums[j] == win_info.botline then
                    break_for_loop = true;
                    break
                end

                -- Insert non-fold line number range table into win_non_fold_lnums
                if i == 1 then
                    if win_fold_lnums[1] ~= win_info.topline then
                        table.insert(win_non_fold_lnums,
                                     {win_info.topline, win_fold_lnums[i] - 1})
                    end
                    -- Fill the gap between first set of continuous numbers and the second set of continuous numbers
                    if j ~= #win_fold_lnums then
                        table.insert(win_non_fold_lnums, {
                            win_fold_lnums[j] + 1, win_fold_lnums[j + 1] - 1
                        })
                    end
                elseif i == #win_fold_lnums then
                    table.insert(win_non_fold_lnums,
                                 {win_fold_lnums[i] + 1, win_info.botline})
                elseif j == #win_fold_lnums then
                    table.insert(win_non_fold_lnums,
                                 {win_fold_lnums[j] + 1, win_info.botline})
                else
                    table.insert(win_non_fold_lnums, {
                        win_fold_lnums[j] + 1, win_fold_lnums[j + 1] - 1
                    })
                end
                break
            until true
        end
    end

    return win_non_fold_lnums
end

