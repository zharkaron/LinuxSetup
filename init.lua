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

-- setup bufferline
local function setup_bufferline()
  require("bufferline").setup({
    options = {
      -- Only show buffers (not terminals) in the tabline
      custom_filter = function(buf_number, buf_numbers)
        local buftype = vim.bo[buf_number].buftype
        return buftype ~= "terminal"
      end,
    }
  })
  vim.keymap.set("n", '<Tab>', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
  vim.keymap.set("n", '<S-Tab>', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })
end


-- Copilot Config
local function copilot_config()
  vim.api.nvim_set_keymap("i", "<C-e>", 'copilot#Accept("<CR>")', { expr = true, noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "<C-e>", ":Copilot enable<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "<C-d>", ":Copilot disable<CR>", { noremap = true, silent = true })
end

-- Copilot Chat Config
local function copilotchat_config()
  require("CopilotChat").setup({
    window = {
      width = 40,
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
  vim.keymap.set("n", "<leader>ca", function()
    -- Insert '#file:`filename`' for all open files into the current buffer at cursor
    local lines = {}
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_option(b, "buflisted") then
        local fname = vim.api.nvim_buf_get_name(b)
        if fname ~= "" then
          table.insert(lines, "#file:`" .. fname .. "`")
        end
      end
    end
    if #lines > 0 then
      vim.api.nvim_buf_set_lines(0, vim.fn.line('.') - 1, vim.fn.line('.') - 1, false, lines)
      vim.notify("Inserted #file context commands into current buffer.", vim.log.levels.INFO)
    else
      vim.notify("No open files to insert.", vim.log.levels.WARN)
    end
  end, { desc = "Insert #file context commands for all open files at cursor" })
end

-- Run commands
local function run_current_file()
  local ft, file
  -- Try to get file from nvim-tree if it's focused
  local ok, api = pcall(require, "nvim-tree.api")
  if ok and api.tree.is_tree_buf() then
    local node = api.tree.get_node_under_cursor()
    if node and node.absolute_path then
      file = node.absolute_path
      ft = vim.filetype.match({ filename = file }) or vim.fn.fnamemodify(file, ":e")
    end
  end
  -- Fallback to current buffer
  if not file then
    ft = vim.bo.filetype
    file = vim.fn.expand("%:p")
  end

  local dir = vim.fn.fnamemodify(file, ":h")
  local cmd = ""
  local run_as_root = vim.fn.input("Run as root? (y/n): "):lower() == "y"
  local sudo = run_as_root and "sudo " or ""

  if ft == "python" then
    cmd = "cd " .. vim.fn.shellescape(dir) .. " && " .. sudo .. "python " .. vim.fn.shellescape(file)
  elseif ft == "bash" or ft == "sh" then
    cmd = "cd " .. vim.fn.shellescape(dir) .. " && " .. sudo .. "bash " .. vim.fn.shellescape(file)
  elseif ft == "zsh" then
    cmd = "cd " .. vim.fn.shellescape(dir) .. " && " .. sudo .. "zsh " .. vim.fn.shellescape(file)
  elseif ft == "lua" then
    cmd = "cd " .. vim.fn.shellescape(dir) .. " && " .. sudo .. "lua " .. vim.fn.shellescape(file)
  elseif ft == "javascript" then
    cmd = "cd " .. vim.fn.shellescape(dir) .. " && " .. sudo .. "node " .. vim.fn.shellescape(file)
  else
    vim.api.nvim_echo({ { "Unsupported filetype: " .. ft, "ErrorMsg" } }, false, {})
    return
  end
  vim.cmd("botright 15split | terminal " .. cmd)
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
      vim.keymap.set("n", "<leader>x", function()
        api.node.open.edit()
        run_current_file()
      end, opts("Open and Run Current File"))
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

-- Help table for nvim-tree and keybindings
local function get_help_lines()
  return {
    "Nvim-Tree Help",
    "---------------------",
    "Keybindings:",
    "  <CR> or o - Open file",
    "  v - Open file in vertical split",
    "  h - Open file in horizontal split",
    "  <Leader>e - Toggle Nvim-Tree",
    "  <Leader>r - Refresh Nvim-Tree",
    "  <Leader>n - Find current file in Nvim-Tree",
    "  a - Create a new file or directory",
    "  d - Delete file or directory",
    "  r - Rename file or directory",
    "  c - Copy file or directory",
    "  p - Paste file or directory",
    "",
    "Copilot Chat Commands:",
    "  <leader>cf - Fix code with Copilot Chat",
    "  <leader>ce - Explain code with Copilot Chat",
    "  <leader>cr - Review code with Copilot Chat",
    "  <leader>c - Open Copilot Chat",
    "  <leader>ca - Insert #file context commands for all open files at cursor",
    "Folding:",
    " 'zo' - Open fold",
    " 'zc' - Close fold",
    " 'za' - Toggle fold",
    " 'zR' - Open all folds",
    " 'zM' - Close all folds",
    "",
    "Run Commands:",
    "  <leader>x - Open and run current file",
    "  <leader>r - Open terminal in home or hovered directory",
    "  <leader>w - Save all files",
    "Move around files:",
    "  <Tab> - Next buffer",
    "  <S-Tab> - Previous buffer",
    "",
  }
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
    {
      "akinsho/nvim-bufferline.lua",
      version = "*",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("bufferline").setup({})
      end,
    }
  })
end

-- Basic settings
local function setup_basic_settings()
  vim.opt.number = true
  vim.opt.expandtab = true
  vim.opt.shiftwidth = 2
  vim.opt.tabstop = 2
  vim.opt.smartindent = true
  vim.cmd('syntax on')

  vim.opt.termguicolors = true

  -- Enable tabline to always show
  vim.opt.showtabline = 2
  -- keymap for switching tabs
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

  local function prompt_and_switch_branch(git_root)
    vim.schedule(function()
      vim.ui.input({ prompt = "You are on a protected branch. Enter branch to switch to: " }, function(branch)
        if branch and #branch > 0 then
          -- Check if branch exists
          if not git_root or git_root == "" then
            vim.notify("Not a git repository.", vim.log.levels.ERROR)
            return
          end
          local branches = vim.fn.systemlist("git -C " .. git_root .. " branch --list " .. branch)
          local cmd
          branch = vim.trim(branch)
          if branches and #branches > 0 and string.match(branches[1], "%s*" .. branch .. "%s*$") then
            -- Branch exists, just checkout
            cmd = { "git", "-C", git_root, "checkout", branch }
          else
            -- Branch does not exist, create and checkout
            cmd = { "git", "-C", git_root, "checkout", "-b", branch }
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
      local file_dir = vim.fn.expand("%:p:h")
      local git_root = vim.fn.systemlist("git -C " .. file_dir .. " rev-parse --show-toplevel")[1]
      if not git_root or git_root == "" then
        return
      end
      local branch = vim.fn.systemlist("git -C " .. git_root .. " rev-parse --abbrev-ref HEAD")[1]
      if branch and is_protected_branch(branch) then
        prompt_and_switch_branch(git_root)
        vim.notify(
          "You are on a protected branch (" .. branch .. "). Please switch branches before writing.",
          vim.log.levels.WARN
        )
        return false
      end
    end,
  })
end

-- Run commands
local function run_current_file()
  local ft, file
  -- Try to get file from nvim-tree if it's focused
  local ok, api = pcall(require, "nvim-tree.api")
  if ok and api.tree.is_tree_buf() then
    local node = api.tree.get_node_under_cursor()
    if node and node.absolute_path then
      file = node.absolute_path
      ft = vim.filetype.match({ filename = file }) or vim.fn.fnamemodify(file, ":e")
    end
  end
  -- Fallback to current buffer
  if not file then
    ft = vim.bo.filetype
    file = vim.fn.expand("%:p")
  end

  local dir = vim.fn.fnamemodify(file, ":h")
  local cmd
  if ft == "python" then
    if not os.getenv("VIRTUAL_ENV") then
      vim.api.nvim_echo({
        { "Python script detected. Please activate a virtual environment before running.", "WarningMsg" }
      }, false, {})
      return
    end
    cmd = "cd " .. vim.fn.shellescape(dir) .. " && python " .. vim.fn.shellescape(file)
  elseif ft == "bash" or ft == "sh" then
    cmd = "cd " .. vim.fn.shellescape(dir) .. " && bash " .. vim.fn.shellescape(file)
  elseif ft == "zsh" then
    cmd = "cd " .. vim.fn.shellescape(dir) .. " && zsh " .. vim.fn.shellescape(file)
  elseif ft == "lua" then
    cmd = "cd " .. vim.fn.shellescape(dir) .. " && lua " .. vim.fn.shellescape(file)
  elseif ft == "javascript" then
    cmd = "cd " .. vim.fn.shellescape(dir) .. " && node " .. vim.fn.shellescape(file)
  else
    vim.api.nvim_echo({ { "Unsupported filetype: " .. ft, "ErrorMsg" } }, false, {})
    return
  end
  vim.cmd("botright | resize 10 | terminal " .. cmd)
end

-- Clipboard yank on visual mode exit
local function setup_clipboard_yank_on_visual_exit()
  vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "v:*",
    callback = function()
      -- Only yank if leaving visual mode
      if vim.fn.mode() == "n" then
        -- Yank the last visually selected text to the unnamed and system clipboard
        vim.cmd('normal! ""y')
        vim.fn.setreg("+", vim.fn.getreg("\""))
        vim.notify("Yanked visual selection to clipboard.", vim.log.levels.INFO)
      end
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

-- Open terminal in home or hovered directory
local function open_custom_terminal()
  local dir
  local ok, api = pcall(require, "nvim-tree.api")
  if ok and api.tree.is_tree_buf() then
    local node = api.tree.get_node_under_cursor()
    if node and node.absolute_path then
      dir = vim.fn.fnamemodify(node.absolute_path, ":h")
    end
  end
  if not dir then
    dir = vim.fn.expand("~")
  end
  -- Open a new terminal in the specified directory
  vim.cmd("botright split | resize 10")
  vim.cmd("lcd " .. vim.fn.fnameescape(dir))
  vim.cmd("terminal")
end

-- Custom keybindings and commands
local function setup_custom_keys()
  -- Custom terminal command and keymap
  vim.api.nvim_create_user_command("C", open_custom_terminal, {})
  vim.api.nvim_set_keymap('n', '<leader>r', ':C<CR>', { noremap = true, silent = true })

  -- Save all files command
  vim.api.nvim_set_keymap('n', '<leader>w', ':wa<CR>', { noremap = true, silent = true })

  -- Window navigation
  vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

  -- Terminal mode navigation
  vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })
  vim.api.nvim_set_keymap('t', '<C-h>', [[<C-\><C-n><C-w>h]], { noremap = true })
  vim.api.nvim_set_keymap('t', '<C-j>', [[<C-\><C-n><C-w>j]], { noremap = true })
  vim.api.nvim_set_keymap('t', '<C-k>', [[<C-\><C-n><C-w>k]], { noremap = true })
  vim.api.nvim_set_keymap('t', '<C-l>', [[<C-\><C-n><C-w>l]], { noremap = true })
  _G.run_current_file = run_current_file
  setup_bufferline()
end

-- MAIN EXECUTION
if bootstrap_lazy() then
  setup_plugins()
  setup_basic_settings()
  setup_git_branch_protection()
  setup_folds()
  setup_clipboard_yank_on_visual_exit()
  setup_custom_keys()
end
