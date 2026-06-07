-- lua/treesitter/config.lua
require('nvim-treesitter.configs').setup({
    ensure_installed = { "bash", "lua", "python", "javascript", "typescript", "java", "html", "css" },
    highlight = { enable = true },
    indent = { enable = false },  -- disable Treesitter indentation
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
        },
    },
})
