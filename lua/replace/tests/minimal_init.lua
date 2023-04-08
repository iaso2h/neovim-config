local configPath = vim.fn.stdpath("config")
vim.opt.runtimepath:append(configPath)

-- Add plenary.nvim, vim-repeat, vim-visualrepeat in your runtime path. In my
-- case, I manage them via packer.nvim
local packagePathHead = vim.fn.stdpath("data") .. "/lazy/"
vim.opt.runtimepath:append(packagePathHead .. "plenary.nvim")
vim.opt.runtimepath:append(packagePathHead .. "vim-repeat")
vim.opt.runtimepath:append(packagePathHead .. "vim-visualrepeat")

require("replace").suppressMessage = true
require("global.keymap")
require("util.test")

-- Mapping
map("n", [[<Plug>ReplaceOperatorInplace]], function ()
    return vim.fn.luaeval [[require("replace").expr(true)]]
end, {"silent", "expr"}, "Replace operator and restore the cursor position")

map("n", [[<Plug>ReplaceOperator]], function ()
    return vim.fn.luaeval [[require("replace").expr(false)]]
end, {"silent", "expr"}, "Replace operator")

map("n", [[<Plug>ReplaceExpr]],
    [[<CMD>let g:ReplaceExpr=getreg("=")<Bar>exec "norm!" . v:count1 . "."<CR>]],
    {"silent"}, "Replace expression"
)

map("n", [[<Plug>ReplaceCurLine]], function ()
    require("replace").replaceSave()

    vim.fn["repeat#setreg"](t"<Plug>ReplaceCurLine", vim.v.register)

    if require("replace").regType == "=" then
        vim.g.ReplaceExpr = vim.fn.getreg("=")
    end

    require("replace").operator{"line", "V", "<Plug>ReplaceCurLine", true}
end, {"noremap", "silent"}, "Replace current line")

map("x", [[<Plug>ReplaceVisual]],
    luaRHS[[
    :lua require("replace").replaceSave();

    vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register);

    if require("replace").regType == "=" then
        vim.g.ReplaceExpr = vim.fn.getreg("=")
    end;

    local vMotion = require("operator").vMotion(false);
    table.insert(vMotion, "<Plug>ReplaceVisual");
    require("replace").operator(vMotion)<CR>
    ]],
    {"noremap", "silent"}, "Replace selected")

map("n", [[<Plug>ReplaceVisual]], function ()
    require("replace").replaceSave()

    vim.fn["repeat#setreg"](t"<Plug>ReplaceVisual", vim.v.register)

    if require("replace").regType == "=" then
        vim.g.ReplaceExpr = vim.fn.getreg("=")
    end

    vim.cmd("noa norm! " .. vim.fn["visualrepeat#reapply#VisualMode"](0))

    local vMotion = require("operator").vMotion(false)
    table.insert(vMotion, "<Plug>ReplaceVisual")
    require("replace").operator(vMotion)
end, {"noremap", "silent"}, "Visual-repeat for replaced selected")

map("n", [[gr]],  [[<Plug>ReplaceOperatorInplace]], "Replace operator and restore the cursor position")
map("n", [[gru]], [[<Plug>ReplaceOperator]],        "Replace operator")
map("n", [[grr]], [[<Plug>ReplaceCurLine]],         "Replace current line")
map("x", [[R]],   [[<Plug>ReplaceVisual]],          "Replace selected")
