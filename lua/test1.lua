local M = {}

            map("n", [[<Plug>ReplaceCurLine]],
                luaRHS[[
                :lua require("replace").replaceSave();

                vim.fn["repeat#setreg"](t"<Plug>ReplaceCurLine", vim.v.register);

                if require("replace").regType == "=" then
                    vim.g.ReplaceExpr = vim.fn.getreg("=")
                end;

                vim.cmd("norm! V" .. vim.v.count1 .. "_" .. t"<lt>Esc>");

                require("replace").operator(
                    tbl_merge(
                        require("operator").vMotion(),
                        {"<Plug>ReplaceVisual", true}
                    )
                )<CR>
                ]],
                {"noremap", "silent"})

M.main = function()
    Print(
    require("replace").operator( tbl_merge( require("operator").vMotion(), {"<Plug>ReplaceVisual", true} ) )
             )
end

return M

