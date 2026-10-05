-- lua/noice/style.lua
-- Noice (cmdline, messages, notifications, LSP progress) in the terminal palette.

local p = require("nvim.palette")

local function hl(name, val)
  vim.api.nvim_set_hl(0, name, val)
end

hl("NoiceCmdline", { fg = p.fg, bg = p.surface.s0 })
hl("NoiceCmdlineIcon", { fg = p.ansi.green, bg = p.surface.s0 })
hl("NoiceCmdlineIconSearch", { fg = p.ansi.yellow, bg = p.surface.s0 })
hl("NoiceCmdlinePrompt", { fg = p.prompt.path, bg = p.surface.s0, bold = true })
hl("NoiceCmdlinePopup", { fg = p.fg, bg = p.surface.s1 })
hl("NoiceCmdlinePopupBorder", { fg = p.border, bg = p.surface.s1 })
hl("NoiceCmdlinePopupTitle", { fg = p.prompt.git, bg = p.surface.s1, bold = true })
hl("NoiceConfirm", { fg = p.diagnostic.warn, bg = p.surface.s0, bold = true })
hl("NoiceConfirmBorder", { fg = p.diagnostic.warn, bg = p.surface.s0 })
hl("NoiceMini", { fg = p.fg, bg = p.surface.s0 })

hl("NoiceScrollbar", { bg = p.divider })
hl("NoiceScrollbarThumb", { bg = p.border })

hl("NoiceVirtualText", { fg = p.gray, bg = p.surface.s0 })

hl("NoiceLspProgressTitle", { fg = p.prompt.git, bg = p.surface.s0, bold = true })
hl("NoiceLspProgressKind", { fg = p.ansi.cyan, bg = p.surface.s0 })
hl("NoiceLspProgressSpinner", { fg = p.ansi.green, bg = p.surface.s0 })
hl("NoiceFormatProgressDone", { fg = p.bg, bg = p.diagnostic.ok, bold = true })
hl("NoiceLspProgressClient", { fg = p.gray, bg = p.surface.s0 })

hl("NoiceCompletionItemKindDefault", { fg = p.gray })
