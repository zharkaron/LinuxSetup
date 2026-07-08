local harpoon = require("harpoon")
local map = vim.keymap.set

map("n", "<leader>m", function() harpoon:list():add() end, { desc = "Harpoon: mark file" })
map("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: toggle menu" })
map("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon: jump to mark 1" })
map("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon: jump to mark 2" })
map("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon: jump to mark 3" })
map("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon: jump to mark 4" })
