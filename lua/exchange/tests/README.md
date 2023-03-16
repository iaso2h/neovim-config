# Dependencies
* `/lua/global/keymap.lua`
* `/lua/util/test.lua`
* [vim-repeat](https://github.com/tpope/vim-repeat) to make replace operator repeatable in normal mode
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)(optional) to run tests

# How to run test
* Navigate to the tests folder in terminal
* Run `nvim --clean --headless -u .\minimal_init.lua -c "PlenaryBustedFile ./exchange_operator_spec.lua"`
* NOTE that any exception occurs during loading minimal_init.lua won't display on the terminal
