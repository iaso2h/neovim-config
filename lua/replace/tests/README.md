# Dependencies
* `/lua/util/keymap.lua`
* `/lua/yankPut.lua` to reselect last replace region
* [vim-repeat](https://github.com/tpope/vim-repeat) to make replace operator repeatable in normal mode
* [vim-visualrepeat](https://github.com/inkarkat/vim-visualrepeat) to make replace visually repeatable in both visual mode and normal mode
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)(optional) to run testsw

# How to run test
* Naviagte to the tests folder in terminal
* Run `nvim --clean --headless -u .\minimal_init.lua -c "PlenaryBustedFile ./replace_operator_spec.lua"`
