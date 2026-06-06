-- lua/plugins.lua
return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "master",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- Nvim-tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
  },

  -- Autotag
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- LuaSnip
  { "L3MON4D3/LuaSnip" },

  -- Lint
  { "mfussenegger/nvim-lint" },

  -- Copilot
  { "github/copilot.vim" },

  -- Copilot Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = { "github/copilot.vim", "nvim-lua/plenary.nvim" },
  },

  -- ToggleTerm
  {
    "akinsho/toggleterm.nvim",
    version = "*",
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Render Markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("render-markdown").setup({})
    end,
  },

  -- Colorscheme
  { "morhetz/gruvbox" },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
  },

  -- LSP Configuration
  { "neovim/nvim-lspconfig" },

  -- Completion
  { "hrsh7th/nvim-cmp", event = "InsertEnter" },
  { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },

  -- DAP
  { "nvim-neotest/nvim-nio" },
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", dependencies = "nvim-neotest/nvim-nio" },
  { "theHamsta/nvim-dap-virtual-text" },
}
