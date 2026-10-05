-- lua/bufferline/style.lua
-- Bufferline highlights in the terminal palette. The powerline separators and
-- spacing live in plugins.lua; this only owns colour.

local p = require("nvim.palette")

local function hl(name, val)
  vim.api.nvim_set_hl(0, name, val)
end

hl("BufferLineFill", { bg = p.bg })
hl("BufferLineBackground", { fg = p.gray, bg = p.surface.s0 })
hl("BufferLineBuffer", { fg = p.gray, bg = p.surface.s0 })
hl("BufferLineBufferSelected", { fg = p.fg, bg = p.surface.s2, bold = true })
hl("BufferLineBufferVisible", { fg = p.gray, bg = p.bg })
hl("BufferLineBufferVisibleSelected", { fg = p.fg, bg = p.surface.s1, bold = true })
hl("BufferLineModified", { fg = p.git.change, bg = p.surface.s0 })
hl("BufferLineModifiedSelected", { fg = p.git.change, bg = p.surface.s2, bold = true })
hl("BufferLineModifiedVisible", { fg = p.git.change, bg = p.bg })
hl("BufferLineModifiedVisibleSelected", { fg = p.git.change, bg = p.surface.s1, bold = true })
hl("BufferLineTab", { fg = p.gray, bg = p.surface.s0 })
hl("BufferLineTabSelected", { fg = p.fg, bg = p.surface.s2, bold = true })
hl("BufferLineTabSeparator", { fg = p.divider, bg = p.bg })
hl("BufferLineTabSeparatorSelected", { fg = p.divider, bg = p.surface.s2 })
hl("BufferLineIndicatorSelected", { fg = p.ansi.green })
hl("BufferLineIndicatorVisible", { fg = p.prompt.frame })
hl("BufferLineSeparator", { fg = p.divider, bg = p.bg })
hl("BufferLineSeparatorSelected", { fg = p.divider, bg = p.surface.s2 })
hl("BufferLineSeparatorVisible", { fg = p.divider, bg = p.bg })
hl("BufferLineSeparatorVisibleSelected", { fg = p.divider, bg = p.surface.s1 })
hl("BufferLineDuplicate", { fg = p.gray_dim, italic = true })
hl("BufferLineDuplicateSelected", { fg = p.gray, italic = true })
hl("BufferLineDuplicateVisible", { fg = p.gray_dim, italic = true })
hl("BufferLineDuplicateVisibleSelected", { fg = p.gray, italic = true })
hl("BufferLineCloseButton", { fg = p.gray })
hl("BufferLineCloseButtonSelected", { fg = p.ansi.red })
