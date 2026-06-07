-- Use Treesitter for folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldlevel = 1       -- close folds by default (levels > 1 will be folded)
vim.o.foldenable = true
