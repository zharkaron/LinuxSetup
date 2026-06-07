# Keybindings reference

This section lists the key mappings you can press to perform actions in this configuration. Use :MyHelp in Neovim to open this README from inside the editor.

Notes:
- <leader> refers to your leader key. Check it with :echo vim.g.mapleader
- Mode abbreviations: (n) normal, (i) insert
- File paths show where the mapping is defined so you can edit it.

## Window navigation (lua/nvim/keys.lua)
- (n) <C-h>  — Move to left window
  - defined in: lua/nvim/keys.lua
- (n) <C-j>  — Move to window below
  - defined in: lua/nvim/keys.lua
- (n) <C-k>  — Move to window above
  - defined in: lua/nvim/keys.lua
- (n) <C-l>  — Move to right window
  - defined in: lua/nvim/keys.lua

## Telescope (fuzzy finder) (lua/telescope/keys.lua)
- (n) <leader>ff — Find files
  - defined in: lua/telescope/keys.lua
- (n) <leader>fg — Live grep
  - defined in: lua/telescope/keys.lua
- (n) <leader>fb — Find buffers
  - defined in: lua/telescope/keys.lua
- (n) <leader>fh — Find help tags
  - defined in: lua/telescope/keys.lua
- (n) <leader>fr — Find recent files (oldfiles)
  - defined in: lua/telescope/keys.lua
- (n) <leader>fs — Find string under cursor (grep_string)
  - defined in: lua/telescope/keys.lua

## File tree (nvim-tree) (lua/nvimtree/keys.lua)
- (n) <leader>e — Toggle file tree (NvimTreeToggle)
  - defined in: lua/nvimtree/keys.lua

## Terminal / Run file (lua/terminal/keys.lua)
- (n) <leader>tt — Open a floating terminal in the hovered node's directory, or cwd
  - defined in: lua/terminal/keys.lua
- (n) <leader>tr — Run hovered file (or current buffer file) in a floating terminal (supports .py, .sh/.bash, .lua, .js/.mjs)
  - defined in: lua/terminal/keys.lua
- (n) <leader>tb — Open a floating terminal in the current buffer's directory
  - defined in: lua/terminal/keys.lua

## Copilot (lua/copilot/keys.lua)
- (i) <C-e> — Accept Copilot suggestion (insert mode; uses copilot#Accept)
  - defined in: lua/copilot/keys.lua
- (n) <C-e> — Enable Copilot
  - defined in: lua/copilot/keys.lua
- (n) <C-d> — Disable Copilot
  - defined in: lua/copilot/keys.lua

## Copilot Chat (lua/copilotchat/keys.lua)
- (n) <leader>c   — Open Copilot Chat
  - defined in: lua/copilotchat/keys.lua
- (n) <leader>cf  — CopilotChatFix #buffer (fix code)
  - defined in: lua/copilotchat/keys.lua
- (n) <leader>ce  — CopilotChatExplain #buffer (explain code)
  - defined in: lua/copilotchat/keys.lua
- (n) <leader>cr  — CopilotChatReview #buffer (review code)
  - defined in: lua/copilotchat/keys.lua
- (n) <leader>ca  — Insert #file context commands for all open files at cursor
  - defined in: lua/copilotchat/keys.lua

## Treesitter (selection, textobjects, folds) (lua/treesitter/keys.lua)
- Incremental selection keymaps (Treesitter):
  - (n) gnn — init_selection
  - (n) grn — node_incremental
  - (n) grc — scope_incremental
  - (n) grm — node_decremental
  - defined in: lua/treesitter/keys.lua (via nvim-treesitter.configs)
- Textobject selection keymaps:
  - (n) af — select around function (function.outer)
  - (n) if — select inside function (function.inner)
  - (n) ac — select around class (class.outer)
  - (n) ic — select inside class (class.inner)
  - defined in: lua/treesitter/keys.lua
- Folds:
  - (n) za — Toggle fold under cursor
  - (n) zo — Open fold under cursor
  - (n) zc — Close fold under cursor
  - (n) zR — Open all folds
  - (n) zM — Close all folds
  - defined in: lua/treesitter/keys.lua

## Linter shortcuts (lua/lint/keys.lua)
- (n) <leader>l — Run linter for current file (lint.try_lint)
  - defined in: lua/lint/keys.lua
- (n) ]l — Jump to next lint warning (diagnostic)
  - defined in: lua/lint/keys.lua
- (n) [l — Jump to previous lint warning
  - defined in: lua/lint/keys.lua

## Auto-pairs fast wrap (lua/autopairs/keys.lua)
- (n/i) <M-e> (Alt+e / Meta+e) — Trigger fast_wrap from nvim-autopairs
  - defined in: lua/autopairs/keys.lua

## Git (gitsigns) — inline blame, hunks, diff (lua/gitsigns/keys.lua)
- (n) ]h — Jump to next hunk
  - defined in: lua/gitsigns/keys.lua
- (n) [h — Jump to previous hunk
  - defined in: lua/gitsigns/keys.lua
- (n) <leader>hs — Stage hunk under cursor
  - defined in: lua/gitsigns/keys.lua
- (n) <leader>hr — Reset hunk under cursor
  - defined in: lua/gitsigns/keys.lua
- (n) <leader>hu — Undo stage hunk
  - defined in: lua/gitsigns/keys.lua
- (n) <leader>hp — Preview hunk diff
  - defined in: lua/gitsigns/keys.lua
- (n) <leader>hS — Stage entire buffer
  - defined in: lua/gitsigns/keys.lua
- (n) <leader>hR — Reset entire buffer
  - defined in: lua/gitsigns/keys.lua
- (n) <leader>hb — Git blame line (inline, eol)
  - defined in: lua/gitsigns/keys.lua
- (n) <leader>hB — Git blame full (open in new buffer)
  - defined in: lua/gitsigns/keys.lua
- (n) <leader>hd — Git diff this (vs HEAD)
  - defined in: lua/gitsigns/keys.lua
- (n) <leader>hD — Git diff this (vs index)
  - defined in: lua/gitsigns/keys.lua

## Git (Neogit) — status, commit, push, pull, branches (lua/neogit/keys.lua)
- (n) <leader>gs — Open Neogit status
  - defined in: lua/neogit/keys.lua
- (n) <leader>gc — Neogit commit (opens commit editor)
  - defined in: lua/neogit/keys.lua
- (n) <leader>gl — Neogit log
  - defined in: lua/neogit/keys.lua
- (n) <leader>gp — Git push (blocked on main/master, prompts confirmation)
  - defined in: lua/neogit/config.lua (NeogitSafePush)
- (n) <leader>gP — Git force push (blocked on main/master, requires "yes")
  - defined in: lua/neogit/config.lua (NeogitSafePushForce)
- (n) <leader>gL — Git pull
  - defined in: lua/neogit/keys.lua
- (n) <leader>gC — Git checkout (switch branch)
  - defined in: lua/neogit/keys.lua
- (n) <leader>gm — Git branch management
  - defined in: lua/neogit/keys.lua
- (n) <leader>gF — Git fetch
  - defined in: lua/neogit/keys.lua
- (n) <leader>gM — Git merge
  - defined in: lua/neogit/keys.lua
- (n) <leader>gr — Git rebase
  - defined in: lua/neogit/keys.lua
- (n) <leader>gd — Git diff
  - defined in: lua/neogit/keys.lua

---

## How to see where a mapping is defined (inside Neovim)
- :verbose map <lhs>  — shows where a mapping was last set
  - Example: :verbose nmap <leader>ff
- :map, :nmap, :imap, :vmap  — list mappings by mode
- Lua one-liner to print normal mode mappings:
  - :lua for _,m in ipairs(vim.api.nvim_get_keymap('n')) do print(m.lhs .. ' -> ' .. (m.rhs or '<lua>')) end

## Edit a mapping
1. Open the file shown above (example: :e lua/telescope/keys.lua)
2. Make your changes and save.
3. Reload the file:
   - :luafile % (runs the current Lua file), or
   - restart Neovim.
