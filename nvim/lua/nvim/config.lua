-- lua/nvim/config.lua
-- General Neovim settings

-- Clipboard: use system clipboard (+) register by default
vim.opt.clipboard = "unnamedplus"

-- WSL2: bridge Neovim clipboard to Windows clipboard via clip.exe/powershell.exe
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WSL-clipboard",
    copy = {
      ["+"] = { "clip.exe" },
      ["*"] = { "clip.exe" },
    },
    paste = {
      ["+"] = { "powershell.exe", "-c", "[Console]::Out.Write($(Get-Clipboard -Raw).Replace(\"`r\", \"\"))" },
      ["*"] = { "powershell.exe", "-c", "[Console]::Out.Write($(Get-Clipboard -Raw).Replace(\"`r\", \"\"))" },
    },
    cache_enabled = true,
  }
end

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.background = "dark"
-- How long (ms) to wait after you stop typing before CursorHold fires.
-- Drives the "lint when I pause" behaviour (see lua/lint/config.lua).
vim.o.updatetime = 500
