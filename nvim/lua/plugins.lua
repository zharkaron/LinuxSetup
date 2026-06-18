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

  -- AI chat (local model via codecompanion.nvim, backed by localhost / Ollama)
  {
    "olimorris/codecompanion.nvim",
    version = "^19.15.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },

  -- Inline AI completion (ghost text via the same localhost / Ollama model)
  { "milanglacier/minuet-ai.nvim" },

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

  -- Which-key (help discover keymaps)
  { "folke/which-key.nvim", opts = {} },

  -- Mason (LSP/formatter/linter installer)
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim", dependencies = "mason.nvim" },

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

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add          = { text = "│" },
        change       = { text = "│" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
      signcolumn = true,
      numhl      = false,
      linehl     = false,
      word_diff  = false,
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 500,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      sign_priority = 6,
      update_debounce = 200,
      status_formatter = nil,
      max_file_length = 40000,
      preview_config = {
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
    },
  },

  -- Neogit
  {
    "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
  },
}
