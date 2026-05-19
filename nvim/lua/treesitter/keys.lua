-- lua/treesitter/keys.lua

-- Folding keymaps
vim.keymap.set("n", "za", "za", { desc = "Toggle fold under cursor" })
vim.keymap.set("n", "zo", "zo", { desc = "Open fold under cursor" })
vim.keymap.set("n", "zc", "zc", { desc = "Close fold under cursor" })
vim.keymap.set("n", "zR", "zR", { desc = "Open all folds" })
vim.keymap.set("n", "zM", "zM", { desc = "Close all folds" })
