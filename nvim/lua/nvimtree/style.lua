-- lua/nvimtree/style.lua
-- Nvim-tree highlights in the terminal palette.

local p = require("nvim.palette")

local function hl(name, val)
  vim.api.nvim_set_hl(0, name, val)
end

hl("NvimTreeNormal", { fg = p.fg, bg = p.bg })
hl("NvimTreeNormalNC", { fg = p.gray, bg = p.bg })
hl("NvimTreeRootFolder", { fg = p.ansi.blue, bold = true })
hl("NvimTreeFolderName", { fg = p.ansi.blue })
hl("NvimTreeOpenedFolderName", { fg = p.ansi.blue, bold = true })
hl("NvimTreeEmptyFolderName", { fg = p.gray })
hl("NvimTreeSpecialFile", { fg = p.ansi.magenta })
hl("NvimTreeExecFile", { fg = p.ansi.green, bold = true })
hl("NvimTreeSymlink", { fg = p.ansi.cyan })
hl("NvimTreeImageFile", { fg = p.ansi.yellow })
hl("NvimTreeOpenedFile", { fg = p.fg, bold = true })
hl("NvimTreeIndentMarker", { fg = p.gray_dim })
hl("NvimTreeWindowPicker", { fg = p.ansi.red, bold = true })
hl("NvimTreeGitDirty", { fg = p.git.change })
hl("NvimTreeGitStaged", { fg = p.git.add })
hl("NvimTreeGitMerge", { fg = p.ansi.magenta })
hl("NvimTreeGitRenamed", { fg = p.ansi.magenta })
hl("NvimTreeGitNew", { fg = p.git.add })
hl("NvimTreeGitDeleted", { fg = p.git.delete })
hl("NvimTreeLiveFilterPrefix", { fg = p.ansi.magenta, bold = true })
hl("NvimTreeLiveFilterValue", { fg = p.ansi.yellow, bold = true })
hl("NvimTreeCursorLine", { bg = p.surface.s1 })
