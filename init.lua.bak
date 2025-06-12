-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

-- Only prepend if the path exists
if vim.loop.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
else
  vim.api.nvim_err_writeln("Failed to set up lazy.nvim: path not found.")
  return
end

require("lazy").setup({
  {
    "github/copilot.vim",
    config = function()
      -- Accept Copilot suggestion with <Tab> in insert mode
      vim.api.nvim_set_keymap("i", "<Tab>", 'copilot#Accept("<Tab>")', { expr = true, noremap = true, silent = true })
      -- Toggle Copilot on/off with Ctrl+g in insert mode
      vim.api.nvim_set_keymap("i", "<C-g>", 'copilot#Toggle()', { expr = true, noremap = true, silent = true })

      -- Enable Copilot suggestion with Ctrl+e (normal mode)
      vim.api.nvim_set_keymap("n", "<C-e>", ":Copilot enable<CR>", { noremap = true, silent = true, desc = "Enable Copilot" })
      -- Disable Copilot suggestion with Ctrl+d (normal mode)
      vim.api.nvim_set_keymap("n", "<C-d>", ":Copilot disable<CR>", { noremap = true, silent = true, desc = "Disable Copilot" })
      -- Chatbox placeholder with Ctrl+c (normal mode)
      vim.api.nvim_set_keymap("n", "<C-c>", ":echo 'Chatbox not supported with copilot.vim plugin'<CR>", { noremap = true, silent = true })
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local api = require("nvim-tree.api")
      require("nvim-tree").setup({
        git = { enable = true },
        actions = {
          use_system_clipboard = true,
          change_dir = { enable = true, global = false },
          open_file = { quit_on_open = false },
        },
        renderer = { highlight_git = true },
        view = {
          side = "left",
          width = 30,
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)

          local opts = function(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- Custom key mappings
          vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
          vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
          vim.keymap.set("n", "v", api.node.open.vertical, opts("Vertical Split"))
          vim.keymap.set("n", "h", api.node.open.horizontal, opts("Horizontal Split"))
        end,
      })
      -- Toggle file tree with <leader>e
      vim.keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

      -- Help table command :H
      vim.api.nvim_create_user_command("H", function()
        local buf = vim.api.nvim_create_buf(false, true)
        local help_lines = {
          "*NVIM-TREE-HELP*",
          "===============================================================================",
          "nvim-tree keybindings and settings",
          "",
          "Key       | Action",
          "----------|-----------------------------------------",
          "<Leader>e | Toggle nvim-tree sidebar",
          "<CR> / o  | Open file or folder",
          "Arrow Up  | Move selection up",
          "Arrow Down| Move selection down",
          "Arrow Left| Collapse folder or go up a directory",
          "Arrow Right| Open folder or file",
          "a         | Create new file/folder",
          "d         | Delete file/folder",
          "r         | Rename file/folder",
          "c         | Copy file/folder",
          "p         | Paste file/folder",
          "q         | Close sidebar",
          "",
          "Settings:",
          "- Sidebar on left side",
          "- Sidebar width 30 columns",
          "- Git status enabled (file highlights)",
          "- Clipboard enabled for copy/paste",
          "- Sidebar stays open when opening files",
          "",
          "Additional:",
          "- :X to run current file in split terminal",
          "- :C to open terminal in split",
          "- Ctrl-q to exit terminal mode",
          "- Window navigation with Ctrl+h/j/k/l",
          "",
          "Folding commands:",
          "zM         | Close all folds (fold everything)",
          "zR         | Open all folds (unfold everything)",
          "za         | Toggle fold under the cursor",
          "zc         | Close fold under cursor",
          "zo         | Open fold under cursor",
          "zj         | Jump to the start of next fold",
          "zk         | Jump to the start of previous fold",
          "===============================================================================",
        }
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_lines)
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        vim.api.nvim_buf_set_option(buf, "filetype", "help")
        vim.api.nvim_open_win(buf, true, { relative = "editor", width = 70, height = #help_lines, row = 5, col = 10 })
      end, {})
    end,
  },
  {
    -- Treesitter for better syntax highlighting and folding
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { "json" },
        highlight = { enable = true },
      })
    end,
  },
})

-- Basic Neovim settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.cmd('syntax on')

vim.opt.termguicolors = true   -- Enable true colors for better highlighting

vim.cmd('colorscheme desert')

vim.api.nvim_set_keymap('n', '<F2>', ':set paste!<CR>', { noremap = true, silent = true })

-- Window navigation with Ctrl+h/j/k/l
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

-- Git branch protection: prevent edits on main
local function check_git_branch()
  local handle = io.popen("git rev-parse --abbrev-ref HEAD 2>/dev/null")
  if not handle then return end
  local branch = handle:read("*l")
  handle:close()
  if branch == "main" then
    vim.api.nvim_echo({
      { "You are on the 'main' branch! Please switch to another branch before editing. Press Enter to quit.", "WarningMsg" }
    }, false, {})
    vim.fn.input("")
    vim.cmd("cq")
  end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
  pattern = "*",
  callback = function()
    if vim.fn.finddir(".git", ".;") ~= "" then
      check_git_branch()
    end
  end,
})

-- Run current file depending on filetype
local function run_current_file()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p") -- absolute path

  if ft == "python" then
    if not os.getenv("VIRTUAL_ENV") then
      vim.api.nvim_echo({
        { "Python script detected. Please activate a virtual environment before running.", "WarningMsg" }
      }, false, {})
      return
    end
    vim.cmd("belowright split | terminal python " .. vim.fn.shellescape(file))
    vim.cmd("resize 15")
  elseif ft == "bash" or ft == "sh" then
    vim.cmd("belowright split | terminal bash " .. vim.fn.shellescape(file))
    vim.cmd("resize 15")
  elseif ft == "zsh" then
    vim.cmd("belowright split | terminal zsh " .. vim.fn.shellescape(file))
    vim.cmd("resize 15")
  elseif ft == "lua" then
    vim.cmd("belowright split | terminal lua " .. vim.fn.shellescape(file))
    vim.cmd("resize 15")
  elseif ft == "javascript" then
    vim.cmd("belowright split | terminal node " .. vim.fn.shellescape(file))
    vim.cmd("resize 15")
  else
    vim.api.nvim_echo({ { "Unsupported filetype: " .. ft, "ErrorMsg" } }, false, {})
  end
end

-- Open a blank terminal split
local function open_custom_terminal()
  vim.cmd("belowright split | terminal")
  vim.cmd("resize 15")
end

vim.api.nvim_create_user_command("X", run_current_file, {})
vim.api.nvim_create_user_command("C", open_custom_terminal, {})

-- Terminal improvements: start insert mode, map <Esc> and <Ctrl-q> to exit terminal mode
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.cmd("startinsert")
    vim.api.nvim_buf_set_keymap(0, "t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "t", "<C-q>", "<C-\\><C-n>", { noremap = true, silent = true })
  end,
})

-- Folds via Treesitter (enable folding and configure method/expr)
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = true
