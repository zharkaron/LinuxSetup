-- lua/nvim/config.lua
-- General Neovim settings

-- Clipboard: use system clipboard (+) register by default
vim.opt.clipboard = "unnamedplus"

-- WSL2: bridge Neovim clipboard to Windows clipboard via powershell.exe
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WSL-clipboard",
    copy = {
      ["+"] = { "powershell.exe", "-NoProfile", "-Command", "$input | Set-Clipboard" },
      ["*"] = { "powershell.exe", "-NoProfile", "-Command", "$input | Set-Clipboard" },
    },
    paste = {
      ["+"] = { "powershell.exe", "-NoProfile", "-Command", "[Console]::Out.Write($(Get-Clipboard -Raw).Replace(\"`r\", \"\"))" },
      ["*"] = { "powershell.exe", "-NoProfile", "-Command", "[Console]::Out.Write($(Get-Clipboard -Raw).Replace(\"`r\", \"\"))" },
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
