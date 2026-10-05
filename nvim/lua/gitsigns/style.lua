-- lua/gitsigns/style.lua
-- Gitsigns sign colours, taken from the same green/yellow/red as the prompt.

local p = require("nvim.palette")

local function hl(name, val)
  vim.api.nvim_set_hl(0, name, val)
end

hl("GitSignsAdd", { fg = p.git.add })
hl("GitSignsChange", { fg = p.git.change })
hl("GitSignsDelete", { fg = p.git.delete })
hl("GitSignsUntracked", { fg = p.git.untracked })
hl("GitSignsTopdelete", { fg = p.git.delete })
hl("GitSignsChangedelete", { fg = p.git.change })
hl("GitSignsAddInline", { fg = p.git.add })
hl("GitSignsChangeInline", { fg = p.git.change })
hl("GitSignsDeleteInline", { fg = p.git.delete })
hl("GitSignsCurrentLineBlame", { fg = p.gray, italic = true })
hl("GitSignsAddNr", { fg = p.git.add })
hl("GitSignsChangeNr", { fg = p.git.change })
hl("GitSignsDeleteNr", { fg = p.git.delete })
