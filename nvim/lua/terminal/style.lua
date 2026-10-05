-- lua/terminal/style.lua
-- Apply your style preferences for terminal buffers.
-- Colours come from g:terminal_color_0..15, set by lua/nvim/palette.lua, so
-- :terminal and toggleterm use the same 16 colours as kitty.
vim.cmd([[
  augroup TerminalStyle
    autocmd!
    autocmd TermOpen * setlocal nonumber norelativenumber
    autocmd TermOpen * setlocal signcolumn=no
    autocmd TermOpen * startinsert
  augroup END
]])

