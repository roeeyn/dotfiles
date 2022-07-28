-- Nvim UFO (Folding)

vim.o.foldcolumn = "1"
vim.o.foldlevel = 99 -- feel free to decrease the value
vim.o.foldlevelstart = -1
vim.o.foldenable = true

require("ufo").setup()
