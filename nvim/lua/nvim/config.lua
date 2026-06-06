-- lua/nvim/config.lua
-- General Neovim settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.background = "dark"
-- How long (ms) to wait after you stop typing before CursorHold fires.
-- Drives the "lint when I pause" behaviour (see lua/lint/config.lua).
vim.o.updatetime = 500
