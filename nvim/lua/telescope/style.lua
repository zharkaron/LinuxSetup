-- lua/telescope/style.lua
-- Telescope in the terminal palette instead of the old gruvbox hex values.

local p = require("nvim.palette")

local function hl(name, val)
  vim.api.nvim_set_hl(0, name, val)
end

hl("TelescopeBorder", { fg = p.border, bg = p.surface.s0 })
hl("TelescopePromptBorder", { fg = p.prompt.path, bg = p.surface.s0 })
hl("TelescopeResultsBorder", { fg = p.divider, bg = p.surface.s0 })
hl("TelescopePreviewBorder", { fg = p.border, bg = p.surface.s0 })
hl("TelescopeSelection", { fg = p.sel_fg, bg = p.sel_bg })
hl("TelescopeSelectionCaret", { fg = p.prompt.path, bg = p.sel_bg })
hl("TelescopeMultiSelection", { fg = p.ansi.green, bg = p.surface.s0 })
hl("TelescopeMultiIcon", { fg = p.ansi.green, bg = p.surface.s0 })
hl("TelescopeMatchingWord", { fg = p.ansi.yellow, bold = true })
hl("TelescopePromptPrefix", { fg = p.ansi.green, bg = p.surface.s0 })
hl("TelescopePromptCounter", { fg = p.gray, bg = p.surface.s0 })
hl("TelescopeTitle", { fg = p.prompt.git, bg = p.surface.s0, bold = true })
hl("TelescopeResultsTitle", { fg = p.prompt.git, bg = p.surface.s0, bold = true })
hl("TelescopePreviewTitle", { fg = p.prompt.git, bg = p.surface.s0, bold = true })
