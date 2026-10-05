-- lua/neogit/style.lua
-- Neogit section headers and branch label in the terminal palette.

local p = require("nvim.palette")

local function hl(name, val)
  vim.api.nvim_set_hl(0, name, val)
end

hl("NeogitSectionHeader", { fg = p.bg, bg = p.prompt.git, bold = true })
hl("NeogitBranch", { fg = p.prompt.git, bold = true })
hl("NeogitRemote", { fg = p.ansi.cyan })
hl("NeogitObjectId", { fg = p.ansi.magenta })
hl("NeogitHunkHeader", { fg = p.prompt.path, bg = p.surface.s0, bold = true })
hl("NeogitDiffContext", { bg = p.bg })
hl("NeogitDiffContextHighlight", { fg = p.gray, bg = p.bg })
hl("NeogitDiffAdd", { fg = p.git.add })
hl("NeogitDiffAddHighlight", { fg = p.git.add, bg = p.surface.s0, bold = true })
hl("NeogitDiffDelete", { fg = p.git.delete })
hl("NeogitDiffDeleteHighlight", { fg = p.git.delete, bg = p.surface.s0, bold = true })
hl("NeogitNotificationInfo", { fg = p.diagnostic.info, bg = p.surface.s0 })
hl("NeogitNotificationWarning", { fg = p.diagnostic.warn, bg = p.surface.s0 })
hl("NeogitNotificationError", { fg = p.diagnostic.error, bg = p.surface.s0 })
hl("NeogitChangeModified", { fg = p.git.change, bold = true })
hl("NeogitChangeAdded", { fg = p.git.add, bold = true })
hl("NeogitChangeDeleted", { fg = p.git.delete, bold = true })
hl("NeogitChangeRenamed", { fg = p.ansi.magenta, bold = true })
hl("NeogitChangeUpdated", { fg = p.git.change, bold = true })
hl("NeogitChangeCopied", { fg = p.ansi.cyan, bold = true })
hl("NeogitUnmergedInto", { fg = p.ansi.magenta })
hl("NeogitUnpulledFrom", { fg = p.ansi.magenta })
