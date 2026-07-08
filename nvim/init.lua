-- init.lua
-- init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  -- clone lazy.nvim if it doesn't exist
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

-- prepend lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- now load your plugins
require("lazy").setup("plugins") -- adjust path if your plugins.lua is elsewhere

-- Load core Neovim configuration
require("nvim.config")
require("nvim.style")
require("nvim.keys")

-- Load plugin-specific modular configs

-- treesitter
require("treesitter.compat") -- Neovim 0.12 / master-branch predicate shim (load before any parse)
require("treesitter.config")
require("treesitter.style")
require("treesitter.keys")


-- nvimtree
require("nvimtree.config")
require("nvimtree.style")
require("nvimtree.keys")

-- autopairs
require("autopairs.config")
require("autopairs.style")
require("autopairs.keys")

-- Snippets
require("snippets.config")

-- Flash (enhanced motions)
require("flash.keys")

-- lint
require("lint.config")
require("lint.style")
require("lint.keys")

-- AI chat (local model via codecompanion.nvim)
require("ai.config")
require("ai.style")
require("ai.keys")

-- Inline AI assistant (local model ghost-text completion via minuet-ai)
require("inlineai.config")
require("inlineai.style")
require("inlineai.keys")

-- terminal
require("terminal.config")
require("terminal.style")
require("terminal.keys")

-- pandoc (file format conversion)
require("pandoc.keys")

-- Mason (LSP/formatter/linter installer)
require("mason.config")

-- LSP
-- Using a command to defer loading until plugins are ready
vim.api.nvim_create_user_command("LoadLSP", function()
  require("lsp.config")
  require("lsp.keys")
  require("lsp.cmp")
end, {})
vim.cmd("LoadLSP")

-- Gitsigns
require("gitsigns.keys")
require("gitsigns.style")

-- Neogit
require("config.neogit")
require("neogit.keys")
require("neogit.style")

-- DAP
require("dap.config")

-- telescope
require("telescope.setup")

-- harpoon
require("harpoon.setup")
require("harpoon.maps")

-- Help list
require("help.config")

vim.api.nvim_create_user_command("MyHelp", function()
  require("help.config").show()
end, {})
