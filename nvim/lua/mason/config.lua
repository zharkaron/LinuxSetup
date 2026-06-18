local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

mason.setup({
    ui = {
        border = "single",
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        },
    },
})

mason_lspconfig.setup({
    automatic_installation = false,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "MasonPackageInstalled",
    callback = function()
        vim.notify("Mason package installed!", vim.log.levels.INFO)
    end,
})
