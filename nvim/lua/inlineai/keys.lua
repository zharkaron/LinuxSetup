-- lua/inlineai/keys.lua
-- Easy enable/disable for the inline AI assistant (ghost-text completion).
-- Accepting a visible suggestion is <C-e> in insert mode (set in config.lua).

-- Primary, easy toggle (normal mode)
vim.keymap.set("n", "<leader>ai", "<cmd>Minuet virtualtext toggle<cr>", { desc = "Toggle inline AI assistant" })

-- Keep the previous inline muscle memory: <C-e> turns it on, <C-d> turns it off.
-- Note: this reuses normal-mode <C-d> (default half-page scroll), matching the
-- previous inline-AI setup. Remove these two lines to get <C-d> scrolling back.
vim.keymap.set("n", "<C-e>", "<cmd>Minuet virtualtext enable<cr>", { desc = "Enable inline AI assistant" })
vim.keymap.set("n", "<C-d>", "<cmd>Minuet virtualtext disable<cr>", { desc = "Disable inline AI assistant" })
