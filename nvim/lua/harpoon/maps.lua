local harpoon = require("harpoon")
local map = vim.keymap.set

map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: mark file" })
map("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: toggle menu" })
map("n", "<C-1>", function() harpoon:list():select(1) end, { desc = "Harpoon: jump to mark 1" })
map("n", "<C-2>", function() harpoon:list():select(2) end, { desc = "Harpoon: jump to mark 2" })
map("n", "<C-3>", function() harpoon:list():select(3) end, { desc = "Harpoon: jump to mark 3" })
map("n", "<C-4>", function() harpoon:list():select(4) end, { desc = "Harpoon: jump to mark 4" })
