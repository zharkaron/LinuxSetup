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

## AI Chat (lua/ai/keys.lua)
Local AI chat powered by [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim),
talking to a model served on **localhost** — no external AI account required.

Setup (one-time): run a local OpenAI-compatible server before using the chat. With
[Ollama](https://ollama.com):
```sh
ollama serve            # serves an API on http://localhost:11434
ollama pull qwen2.5-coder
```
The endpoint and model are configured in `lua/ai/config.lua`
(`env.url = "http://localhost:11434"`, `schema.model.default = "qwen2.5-coder:7b"`) —
change the model to anything you've pulled (`ollama list`).

- (n,v) <leader>c   — Toggle the AI chat window
  - defined in: lua/ai/keys.lua
- (n) <leader>cf  — Fix the current buffer (answered in chat)
  - defined in: lua/ai/keys.lua
- (n) <leader>ce  — Explain the current buffer (answered in chat)
  - defined in: lua/ai/keys.lua
- (n) <leader>cr  — Review the current buffer (answered in chat)
  - defined in: lua/ai/keys.lua
- (n,v) <leader>ca  — Open the AI action palette
  - defined in: lua/ai/keys.lua

## Inline AI assistant (lua/inlineai/keys.lua)
Ghost-text code completion in **any** file (like an inline coding assistant), powered by the same
localhost model ([minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim) →
Ollama `qwen2.5-coder:7b`, fill-in-the-middle). Uses the same `ollama serve` setup
as the chat above; endpoint/model live in `lua/inlineai/config.lua`. It auto-suggests
as you type in every filetype — toggle it off whenever you don't want it.

- (i) <C-e>  — Accept the current suggestion (insert mode)
  - defined in: lua/inlineai/config.lua (minuet virtualtext keymap)
- (i) <A-a>  — Accept one line of the suggestion
  - defined in: lua/inlineai/config.lua
- (i) <A-]> / <A-[>  — Cycle suggestions / manually request one
  - defined in: lua/inlineai/config.lua
- (i) <A-e>  — Dismiss the current suggestion
  - defined in: lua/inlineai/config.lua
- (n) <leader>ai  — Toggle the inline assistant on/off
  - defined in: lua/inlineai/keys.lua
- (n) <C-e>  — Enable the inline assistant
  - defined in: lua/inlineai/keys.lua
- (n) <C-d>  — Disable the inline assistant
  - defined in: lua/inlineai/keys.lua

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

## Which-key (plugin: `folke/which-key.nvim`)
Press `<leader>` and wait ~300ms — a popup shows every keymap that starts with `<leader>`, grouped by prefix. No extra mappings needed, it reads the `desc` from all `vim.keymap.set` calls.

- Defined in: `lua/plugins.lua`

## Mason (`williamboman/mason.nvim`)
LSP server / formatter / linter installer.

- `:Mason` — open the graphical installer
- `:LspInstall <server>` — install a language server
- Defined in: `lua/mason/config.lua`

## Conform (`stevearc/conform.nvim`) — auto-format on save
Formats the buffer automatically whenever you `:w`. Uses the formatter listed for each filetype; falls back to LSP formatting if the external tool is missing.

| Filetype | Formatter | Install via `:Mason` |
|---|---|---|
| lua | `stylua` | `stylua` |
| python | `ruff_format` | `ruff` |
| java | `google-java-format` | `google-java-format` |
| sh | `shfmt` | `shfmt` |
| html / markdown | `prettier` / `prettierd` | `prettier` |

- (n) `<leader>F` — Format buffer manually (also in visual mode)
- Defined in: `lua/plugins.lua`

Test files: `nvim /tmp/test-conform/messy.java` (and `.py`, `.sh`, `.html`)

## Flash (`folke/flash.nvim`) — enhanced motion
Type `s` then any character → labels appear on every match. Type the label to jump there.

- (n,x,o) `s` — Jump to any visible character (label jump)
- (n,x,o) `S` — Jump to a treesitter node (function, class, etc.)
- (n,x,o) `r` — Remote jump: jump there, then jump back
- Defined in: `lua/flash/keys.lua`

Test files: `nvim /tmp/test-flash/demo.py` (and `.java`, `.sh`)

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
