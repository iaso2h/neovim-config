# Dependencies
* `/lua/global/`
* `/lua/util/test.lua`
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) to run tests
    * NOTE: Please use the commit version before "9ce85b0". The "9ce85b0" commit replace the old `plenary.busted.run` with the new `plenary.test_harness` implementation in Neovim Ex Command, which will break all the tests(It just occupied the test buffer as plenary's floating output window)

# How to run test
* Navigate to the tests folder in terminal
* Run `nvim --clean --headless -u ./minimal_init.lua -c "PlenaryBustedFile ./jumplist_spec.lua"`
* NOTE that any exception occurs during loading minimal_init.lua won't display on the terminal, you have to run `nvim -u ./minimal_init.lua` to twiddle it around a round a little bit and make sure no major exception occurs
