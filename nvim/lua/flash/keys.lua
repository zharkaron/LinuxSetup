vim.keymap.set({ "n", "x", "o" }, "s", function()
    require("flash").jump()
end, { desc = "Flash: jump to any visible character" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
    require("flash").treesitter()
end, { desc = "Flash: jump to treesitter node" })

vim.keymap.set({ "n", "x", "o" }, "r", function()
    require("flash").remote()
end, { desc = "Flash: remote jump" })
