-- lua/gitsigns/keys.lua
local gitsigns = require("gitsigns")

vim.keymap.set("n", "<leader>hb", gitsigns.blame_line, { desc = "Git blame line" })
vim.keymap.set("n", "<leader>hB", gitsigns.blame, { desc = "Git blame full" })
vim.keymap.set("n", "<leader>hd", gitsigns.diffthis, { desc = "Git diff this" })
vim.keymap.set("n", "<leader>hD", function()
  gitsigns.diffthis("~")
end, { desc = "Git diff this (index)" })
vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Git preview hunk" })
vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Git stage hunk" })
vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Git reset hunk" })
vim.keymap.set("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Git undo stage hunk" })
vim.keymap.set("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Git stage buffer" })
vim.keymap.set("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Git reset buffer" })
vim.keymap.set("n", "]h", function()
  if vim.wo.diff then
    return "]h"
  end
  vim.schedule(function()
    gitsigns.next_hunk()
  end)
  return "<Ignore>"
end, { expr = true, desc = "Git next hunk" })
vim.keymap.set("n", "[h", function()
  if vim.wo.diff then
    return "[h"
  end
  vim.schedule(function()
    gitsigns.prev_hunk()
  end)
  return "<Ignore>"
end, { expr = true, desc = "Git prev hunk" })
