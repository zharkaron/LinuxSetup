-- lua/nvim/lint/keys.lua
local run = require("lint.run")

-- Keymap to manually run linting (warns if the linter tool is missing)
vim.keymap.set("n", "<leader>l", function()
  run.lint_buffer()
end, { desc = "Run linter for current file" })

-- Optional: jump to next/previous lint warning
vim.keymap.set("n", "]l", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN }) end, { desc = "Next lint warning" })
vim.keymap.set("n", "[l", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN }) end, { desc = "Previous lint warning" })
