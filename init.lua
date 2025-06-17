-- Bootstrap lazy.nvim
local function bootstrap_lazy()
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
  if vim.loop.fs_stat(lazypath) then
    vim.opt.rtp:prepend(lazypath)
  else
    vim.api.nvim_err_writeln("Failed to set up lazy.nvim: path not found.")
    return false
  end
  return true
end

-- Copilot Config
local function copilot_config()
  vim.api.nvim_set_keymap("i", "<Tab>", 'copilot#Accept("<Tab>")', { expr = true, noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "<C-e>", ":Copilot enable<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "<C-d>", ":Copilot disable<CR>", { noremap = true, silent = true })
end

-- Copilot Chat Config
local function copilotchat_config()
  require("CopilotChat").setup({
    window = {
      width = 60,
      side = "right",
      border = "rounded",
      title = "Copilot Chat",
    },
    layout = {
      min_width = 30,
      max_width = 80,
    },
    Mappings = {
      close = {"<Esc>", "q"},
      submit_prompt = {"<C-CR>", "<CR>"},
      clear_prompt = {"<C-u>"},
    },
    auto_prompt = {
      enable = true,
    },
  })
  vim.keymap.set("n", "<leader>cf", ":CopilotChatFix #buffer<CR>", { desc = "Copilot Chat Fix" })
  vim.keymap.set("n", "<leader>ce", ":CopilotChatExplain #buffer<CR>", { desc = "Copilot Chat Explain" })
  vim.keymap.set("n", "<leader>cr", ":CopilotChatReview #buffer<CR>", { desc = "Copilot Chat Review" })
  vim.keymap.set("n", "<leader>c", ":CopilotChat<CR>", { desc = "Open Copilot Chat" })
end

-- Nvim Tree Config
local function nvim_tree_config()
  local api = require("nvim-tree.api")
  require("nvim-tree").setup({
    filters = {
      dotfiles = false,
      git_ignored = false,
    },
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
      api.config.mappings.default_on_attach(bufnr)
      local opts = function(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end
      vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "v", api.node.open.vertical, opts("Vertical Split"))
      vim.keymap.set("n", "h", api.node.open.horizontal, opts("Horizontal Split"))
    end,
  })
  vim.keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<Leader>r', ':NvimTreeRefresh<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<Leader>n', ':NvimTreeFindFile<CR>', { noremap = true, silent = true })
end

-- Treesitter Config
local function treesitter_config()
  require('nvim-treesitter.configs').setup({
    ensure_installed = { "c", "cpp", "python", "bash", "lua", "javascript", "html", "css", "json", "jsonc" },
    highlight = { enable = true },
    indent = { enable = true },
  })
end

-- Linting Config
local function linting_config()
  require("lint").linters_by_ft = {
    json = { "jq" },
    sh = { "shellcheck" },
    bash = { "shellcheck" },
    lua = { "luacheck" },
  }
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    callback = function()
      require("lint").try_lint()
    end,
  })
end

-- Help window for nvim-tree and keybindings
local function setup_help_window()
  vim.api.nvim_create_user_command("H", function()
    local buf = vim.api.nvim_create_buf(false, true)
local help_lines = get_help_lines()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "filetype", "help")
    vim.api.nvim_open_win(buf, true, { relative = "editor", width = 70, height = #help_lines, row = 5, col = 10 })
  end, {})
end

-- Main plugin setup
local function setup_plugins()
  require("lazy").setup({
    {
      "github/copilot.vim",
      config = copilot_config,
    },
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      dependencies = {
        "github/copilot.vim",
        "nvim-lua/plenary.nvim"
      },
      build = "make tiktoken",
      config = copilotchat_config,
    },
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = nvim_tree_config,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = treesitter_config,
    },
    {
      "mfussenegger/nvim-lint",
      config = linting_config,
    },
  })
end

-- Basic settings
local function setup_basic_settings()
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.expandtab = true
  vim.opt.shiftwidth = 2
  vim.opt.tabstop = 2
  vim.opt.smartindent = true
  vim.cmd('syntax on')

  vim.opt.termguicolors = true
  vim.cmd('colorscheme desert')

  vim.api.nvim_set_keymap('n', '<F2>', ':set paste!<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })
end

-- Git branch protection
local function setup_git_branch_protection()
  local protected_branches = { "main", "master", "develop" }

  local function is_protected_branch(branch)
    for _, b in ipairs(protected_branches) do
      if b == branch then
        return true
      end
    end
    return false
  end

  local function prompt_and_switch_branch()
    vim.schedule(function()
      vim.ui.input({ prompt = "You are on a protected branch. Enter branch to switch to: " }, function(branch)
        if branch and #branch > 0 then
          -- Check if branch exists
          local handle = io.popen('git branch --list ' .. branch)
          local result = handle:read("*a")
          handle:close()
          local cmd
          if result and #result > 0 then
            -- Branch exists, just checkout
            cmd = { "git", "checkout", branch }
          else
            -- Branch does not exist, create and checkout
            cmd = { "git", "checkout", "-b", branch }
          end
          vim.fn.jobstart(cmd, {
            on_exit = function(_, code)
              if code == 0 then
                vim.notify("Switched to branch '" .. branch .. "'.", vim.log.levels.INFO)
              else
                vim.notify("Failed to switch to branch '" .. branch .. "'.", vim.log.levels.ERROR)
              end
            end,
          })
        end
      end)
    end)
  end

  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
      local handle = io.popen("git rev-parse --abbrev-ref HEAD 2>/dev/null")
      local branch = handle:read("*l")
      handle:close()
      if branch and is_protected_branch(branch) then
        prompt_and_switch_branch()
        error("You are on a protected branch (" .. branch .. "). Please switch branches before writing.")
      end
    end,
  })
end

-- Run commands
local function setup_run_commands()
  local function run_current_file()
    local ft = vim.bo.filetype
    local file = vim.fn.expand("%:p")

    if ft == "python" then
      if not os.getenv("VIRTUAL_ENV") then
        vim.api.nvim_echo({
          { "Python script detected. Please activate a virtual environment before running.", "WarningMsg" }
        }, false, {})
        return
      end
      vim.cmd("belowright split | terminal python " .. vim.fn.shellescape(file))
    elseif ft == "bash" or ft == "sh" then
      vim.cmd("belowright split | terminal bash " .. vim.fn.shellescape(file))
    elseif ft == "zsh" then
      vim.cmd("belowright split | terminal zsh " .. vim.fn.shellescape(file))
    elseif ft == "lua" then
      vim.cmd("belowright split | terminal lua " .. vim.fn.shellescape(file))
    elseif ft == "javascript" then
      vim.cmd("belowright split | terminal node " .. vim.fn.shellescape(file))
    else
      vim.api.nvim_echo({ { "Unsupported filetype: " .. ft, "ErrorMsg" } }, false, {})
      return
    end
    vim.cmd("resize 15")
  end

  local function open_custom_terminal()
    vim.cmd("belowright split | terminal")
    vim.cmd("resize 15")
  end

  vim.api.nvim_create_user_command("X", run_current_file, {})
  vim.api.nvim_create_user_command("C", open_custom_terminal, {})

  vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function()
      vim.cmd("startinsert")
      vim.api.nvim_buf_set_keymap(0, "t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(0, "t", "<C-q>", "<C-\\><C-n>", { noremap = true, silent = true })
    end,
  })
end

-- Folding
local function setup_folds()
  vim.o.foldmethod = "expr"
  vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldenable = true
    function _G.custom_foldtext()
        local line = vim.fn.getline(vim.v.foldstart)
        local lines_count = vim.v.foldend - vim.v.foldstart + 1
        return line .. " (" .. lines_count .. " lines)"
    end
    vim.api.nvim_create_autocmd({"BufReadPost", "BufWinEnter"}, {
        pattern = { "*" },
        callback = function()
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.opt_local.foldtext = "v:lua.custom_foldtext()"
        end
    })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "json",
        callback = function()
            vim.opt_local.foldlevel = 3
        end
    })
  setup_help_window()
end


-- MAIN EXECUTION
if bootstrap_lazy() then
  setup_plugins()
  setup_basic_settings()
  setup_git_branch_protection()
  setup_run_commands()
  setup_folds()
end


