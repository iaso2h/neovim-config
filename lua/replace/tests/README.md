# Dependencies
* `/lua/util.lua`
* `/lua/yankPut.lua` to reselect last replace region
* [vim-repeat](https://github.com/tpope/vim-repeat) to make replace operator repeatable in normal mode
* [vim-visualrepeat](https://github.com/inkarkat/vim-visualrepeat) to make replace visually repeatable in both visual mode and normal mode
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)(optional) to run tests

# How to run test
* Make sure have [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) installed and is included in neovim runtime path
* Run `nvim --headless -c "PlenaryBustedDirectory <path_to_the_tests_dir/path_to_the_spec_file>` in command line.
* Run Neovim instance, and then run `:PlenaryBustedDirectory <path_to_the_tests_dir>` in command mode.
