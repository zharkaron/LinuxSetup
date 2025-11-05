-- init.lua
vim.opt.rtp:prepend("~/.local/share/nvim/lazy/lazy.nvim")

-- Load plugins
require("plugins")

-- Load core Neovim configuration
require("nvim.config")
require("nvim.style")
require("nvim.keys")

-- Load plugin-specific modular configs

-- treesitter
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

-- lint
require("lint.config")
require("lint.style")
require("lint.keys")

-- Copilot
require("copilot.config")
require("copilot.style")
require("copilot.keys")

-- CopilotChat
require("copilotchat.config")
require("copilotchat.style")
require("copilotchat.keys")

-- terminal
require("terminal.config")
require("terminal.style")
require("terminal.keys")

-- telescope
require("telescope.setup")
