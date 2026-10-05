-- colors/artemis.lua
-- Artemis x Mint colourscheme for Neovim.
--
-- Every colour comes from lua/nvim/palette.lua, which mirrors
-- kitty/appearance/artemis.conf. Neovim and kitty therefore render from the
-- same hex values and the editor blends into the terminal.
--
-- Usage: :colorscheme artemis   (applied automatically by lua/nvim/style.lua)

if vim.g.loaded_artemis then
  return
end
vim.g.loaded_artemis = true

local p = require("nvim.palette")

p.setup()

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.o.background = "dark"

vim.g.colors_name = "artemis"

local ansi, bright = p.ansi, p.bright
local surf, prompt, diag, git = p.surface, p.prompt, p.diagnostic, p.git

local function hl(name, val)
  vim.api.nvim_set_hl(0, name, val)
end
local none = "NONE"

-- nocombine so the cursor block keeps its own colours over any syntax colours.
local cursor_hl = { fg = p.cursor_text, bg = p.cursor, nocombine = true }

-- ---------------------------------------------------------------- editor UI

hl("Normal", { fg = p.fg, bg = p.bg })
hl("NormalFloat", { fg = p.fg, bg = surf.s2 })
hl("FloatBorder", { fg = p.border, bg = surf.s2 })
hl("FloatTitle", { fg = prompt.path, bg = surf.s2, bold = true })
hl("NormalNC", { fg = p.gray, bg = p.bg })
hl("WinBar", { fg = p.gray, bg = surf.s0 })
hl("WinBarNC", { fg = p.gray_dim, bg = surf.s0 })
hl("WinSeparator", { fg = p.divider, bg = none })
hl("VertSplit", { fg = p.divider, bg = none })

hl("ColorColumn", { bg = surf.s1 })
hl("Conceal", { fg = p.comment })
hl("Cursor", cursor_hl)
hl("lCursor", cursor_hl)
hl("CursorIM", cursor_hl)
hl("TermCursor", { fg = p.cursor_text, bg = p.cursor, nocombine = true })
hl("TermCursorNC", { fg = p.cursor_text, bg = p.gray })
hl("CursorColumn", { bg = surf.s1 })
hl("CursorLine", { bg = surf.s1 })
hl("CursorLineNr", { fg = prompt.frame, bg = surf.s1, bold = true })
hl("CursorLineSign", { bg = surf.s1 })
hl("CursorLineFold", { bg = surf.s1 })

hl("Directory", { fg = ansi.blue })
hl("EndOfBuffer", { fg = p.bg })

hl("LineNr", { fg = p.gray_dim })
hl("LineNrAbove", { fg = p.gray_dim })
hl("LineNrBelow", { fg = p.gray_dim })
hl("SignColumn", { fg = p.gray, bg = none })
hl("SignColumnSB", { fg = p.gray_dim, bg = surf.s1 })
hl("FoldColumn", { fg = p.gray, bg = none })
hl("Folded", { fg = p.gray, bg = surf.s0 })

hl("MatchParen", { fg = bright.white, bg = surf.s2, bold = true })

hl("ModeMsg", { fg = prompt.frame, bold = true })
hl("MsgArea", { fg = p.fg })
hl("MsgSeparator", { fg = p.border })
hl("MoreMsg", { fg = diag.info })
hl("Question", { fg = diag.info })
hl("WarningMsg", { fg = diag.warn, bold = true })
hl("ErrorMsg", { fg = diag.error, bold = true })

hl("Pmenu", { fg = p.fg, bg = surf.s0 })
hl("PmenuSel", { fg = p.sel_fg, bg = p.sel_bg, bold = true })
hl("PmenuSbar", { bg = surf.s0 })
hl("PmenuThumb", { bg = p.border })
hl("PmenuKind", { fg = prompt.frame, bg = surf.s0 })
hl("PmenuExtra", { fg = p.gray, bg = surf.s0 })
hl("PmenuMatch", { fg = prompt.path, bg = surf.s0, bold = true })
hl("PmenuMatchSel", { fg = prompt.path, bg = p.sel_bg, bold = true })
hl("WildMenu", { fg = p.cursor_text, bg = p.border, bold = true })
hl("QuickFixLine", { fg = diag.info, bg = surf.s1, bold = true })
hl("SpecialKey", { fg = bright.cyan, bg = surf.s0 })

hl("Search", { fg = p.bg, bg = ansi.yellow })
hl("IncSearch", { fg = bright.white, bg = ansi.red, bold = true })
hl("CurSearch", { fg = p.bg, bg = bright.yellow, bold = true })
hl("Substitute", { fg = p.bg, bg = ansi.yellow })
hl("Visual", { fg = p.sel_fg, bg = p.sel_bg })
hl("VisualNOS", { fg = p.sel_fg, bg = p.sel_bg })

hl("StatusLine", { fg = p.fg, bg = surf.s0 })
hl("StatusLineNC", { fg = p.gray_dim, bg = surf.s0 })
hl("TabLine", { fg = p.gray, bg = p.bg })
hl("TabLineFill", { fg = p.gray_dim, bg = p.bg })
hl("TabLineSel", { fg = p.fg, bg = surf.s0, bold = true })

hl("NonText", { fg = p.gray_dim })
hl("Whitespace", { fg = p.gray_dim })
hl("Special", { fg = bright.red })
hl("Title", { fg = ansi.blue, bold = true })

hl("SpellBad", { sp = diag.error, undercurl = true })
hl("SpellCap", { sp = diag.warn, undercurl = true })
hl("SpellLocal", { sp = diag.info, undercurl = true })
hl("SpellRare", { sp = diag.hint, undercurl = true })

hl("debugPC", { bg = surf.s2 })
hl("debugBreakpoint", { fg = ansi.red, bg = surf.s2 })

-- ----------------------------------------------------------------- syntax

hl("Comment", { fg = p.comment, italic = true })
hl("Constant", { fg = bright.blue })
hl("String", { fg = ansi.green })
hl("Character", { fg = ansi.green })
hl("Number", { fg = bright.blue })
hl("Boolean", { fg = bright.blue })
hl("Float", { fg = bright.blue })
hl("Identifier", { fg = p.fg })
hl("Function", { fg = ansi.cyan })
hl("Statement", { fg = ansi.red })
hl("Conditional", { fg = ansi.red, bold = true })
hl("Repeat", { fg = ansi.red })
hl("Label", { fg = ansi.red })
hl("Operator", { fg = p.gray })
hl("Keyword", { fg = ansi.red })
hl("Exception", { fg = ansi.red })
hl("PreProc", { fg = ansi.magenta })
hl("Include", { fg = ansi.magenta })
hl("Define", { fg = ansi.magenta })
hl("Macro", { fg = ansi.magenta })
hl("PreCondit", { fg = ansi.magenta })
hl("Type", { fg = ansi.yellow })
hl("StorageClass", { fg = ansi.red, bold = true })
hl("Structure", { fg = ansi.yellow })
hl("Typedef", { fg = ansi.yellow })
hl("SpecialChar", { fg = p.gray })
hl("Tag", { fg = ansi.red })
hl("Delimiter", { fg = p.gray })
hl("SpecialComment", { fg = ansi.green, bold = true })
hl("Debug", { fg = ansi.magenta })
hl("Ignore", { fg = p.comment })
hl("Error", { fg = diag.error })
hl("Todo", { fg = ansi.yellow, bg = surf.s1, bold = true })

-- ------------------------------------------------------------------- diff

hl("diffAdded", { fg = git.add })
hl("diffRemoved", { fg = git.delete })
hl("diffChanged", { fg = git.change })
hl("diffAddedFile", { fg = git.add, bold = true })
hl("diffRemovedFile", { fg = git.delete, bold = true })
hl("diffOldFile", { fg = git.delete, bold = true })
hl("diffNewFile", { fg = git.add, bold = true })
hl("diffFile", { fg = ansi.magenta, bold = true })
hl("diffLine", { fg = ansi.magenta })
hl("diffIndexLine", { fg = ansi.magenta, bold = true })
hl("diffAddedLine", { bg = surf.s0 })
hl("diffRemovedLine", { bg = surf.s0 })
hl("diffChangedLine", { bg = surf.s0 })
hl("diffOldFileLine", { bg = surf.s0 })
hl("diffNewFileLine", { bg = surf.s0 })
hl("DiffAdd", { fg = ansi.green, bg = surf.s1 })
hl("DiffChange", { fg = ansi.yellow, bg = surf.s1 })
hl("DiffDelete", { fg = ansi.red, bg = surf.s1 })
hl("DiffText", { fg = bright.white, bg = surf.s2 })
hl("Added", { fg = ansi.green })
hl("Removed", { fg = ansi.red })
hl("Changed", { fg = ansi.yellow })

-- ------------------------------------------------------------ diagnostics

hl("DiagnosticError", { fg = diag.error })
hl("DiagnosticWarn", { fg = diag.warn })
hl("DiagnosticInfo", { fg = diag.info })
hl("DiagnosticHint", { fg = diag.hint })
hl("DiagnosticOk", { fg = diag.ok })
hl("DiagnosticErrorSign", { fg = diag.error })
hl("DiagnosticWarnSign", { fg = diag.warn })
hl("DiagnosticInfoSign", { fg = diag.info })
hl("DiagnosticHintSign", { fg = diag.hint })
hl("DiagnosticUnderlineError", { sp = diag.error, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = diag.warn, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = diag.info, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = diag.hint, undercurl = true })
hl("DiagnosticVirtualTextError", { fg = diag.error, bg = surf.s0 })
hl("DiagnosticVirtualTextWarn", { fg = diag.warn, bg = surf.s0 })
hl("DiagnosticVirtualTextInfo", { fg = diag.info, bg = surf.s0 })
hl("DiagnosticVirtualTextHint", { fg = diag.hint, bg = surf.s0 })
hl("DiagnosticFloatingError", { fg = diag.error })
hl("DiagnosticFloatingWarn", { fg = diag.warn })
hl("DiagnosticFloatingInfo", { fg = diag.info })
hl("DiagnosticFloatingHint", { fg = diag.hint })
hl("DiagnosticUnnecessary", { fg = p.gray_dim })

-- ------------------------------------------------------- treesitter captures

local ts = {
  ["@variable"] = p.fg,
  ["@variable.builtin"] = ansi.blue,
  ["@variable.parameter"] = p.fg,
  ["@variable.parameter.builtin"] = ansi.blue,
  ["@variable.member"] = ansi.cyan,

  ["@constant"] = bright.blue,
  ["@constant.builtin"] = bright.blue,
  ["@constant.macro"] = ansi.magenta,

  ["@module"] = ansi.magenta,
  ["@label"] = ansi.red,
  ["@property"] = ansi.green,

  ["@function"] = ansi.cyan,
  ["@function.builtin"] = bright.cyan,
  ["@function.call"] = ansi.cyan,
  ["@function.macro"] = ansi.magenta,
  ["@function.method"] = ansi.cyan,
  ["@function.method.call"] = ansi.cyan,
  ["@constructor"] = ansi.yellow,

  ["@keyword"] = ansi.red,
  ["@keyword.conditional"] = ansi.red,
  ["@keyword.debug"] = ansi.red,
  ["@keyword.definition"] = ansi.red,
  ["@keyword.directive"] = ansi.magenta,
  ["@keyword.exception"] = ansi.red,
  ["@keyword.function"] = ansi.red,
  ["@keyword.import"] = ansi.magenta,
  ["@keyword.operator"] = ansi.red,
  ["@keyword.repeat"] = ansi.red,
  ["@keyword.return"] = ansi.red,
  ["@keyword.storage"] = ansi.red,
  ["@keyword.type"] = ansi.red,

  ["@punctuation"] = p.gray,
  ["@punctuation.bracket"] = p.gray,
  ["@punctuation.delimiter"] = p.gray,
  ["@punctuation.special"] = ansi.cyan,

  ["@string"] = ansi.green,
  ["@string.documentation"] = p.comment,
  ["@string.regexp"] = bright.blue,
  ["@string.escape"] = bright.cyan,
  ["@string.special"] = bright.cyan,
  ["@string.special.path"] = ansi.magenta,
  ["@string.special.symbol"] = bright.cyan,
  ["@string.special.url"] = ansi.cyan,

  ["@character"] = ansi.green,
  ["@character.special"] = bright.cyan,

  ["@boolean"] = bright.blue,
  ["@number"] = bright.blue,
  ["@number.float"] = bright.blue,

  ["@type"] = ansi.yellow,
  ["@type.builtin"] = ansi.yellow,
  ["@type.definition"] = ansi.yellow,

  ["@attribute"] = ansi.magenta,
  ["@attribute.builtin"] = ansi.magenta,

  ["@field"] = ansi.green,
  ["@namespace"] = ansi.magenta,

  ["@comment"] = { fg = p.comment, italic = true },
  ["@comment.documentation"] = { fg = p.comment, italic = true },
  ["@comment.error"] = { fg = diag.error, bold = true },
  ["@comment.warning"] = { fg = diag.warn, bold = true },
  ["@comment.todo"] = { fg = ansi.yellow, bg = surf.s1, bold = true },
  ["@comment.note"] = { fg = ansi.magenta, italic = true },

  ["@error"] = diag.error,
  ["@warning"] = diag.warn,
  ["@hint"] = diag.hint,
  ["@info"] = diag.info,
  ["@tag"] = ansi.red,
  ["@tag.attribute"] = ansi.magenta,
  ["@tag.delimiter"] = p.gray,

  ["@text"] = p.fg,
  ["@text.literal"] = p.fg,
  ["@text.title"] = { fg = ansi.yellow, bold = true },
  ["@text.uri"] = { fg = ansi.cyan, underline = true },
  ["@text.reference"] = ansi.cyan,
  ["@text.strong"] = { fg = p.fg, bold = true },
  ["@text.emphasis"] = { fg = p.fg, italic = true },
  ["@text.strikethrough"] = { fg = p.gray, strikethrough = true },
  ["@text.math"] = ansi.cyan,
  ["@text.underline"] = { fg = p.fg, underline = true },
  ["@text.todo"] = { fg = ansi.yellow, bg = surf.s1, bold = true },
  ["@text.note"] = ansi.magenta,
  ["@text.warning"] = ansi.yellow,
  ["@text.danger"] = ansi.red,
  ["@text.diff.add"] = git.add,
  ["@text.diff.delete"] = git.delete,

  ["@markup.strong"] = { fg = p.fg, bold = true },
  ["@markup.italic"] = { fg = p.fg, italic = true },
  ["@markup.strikethrough"] = { fg = p.gray, strikethrough = true },
  ["@markup.heading.1.markdown"] = { fg = ansi.red, bold = true },
  ["@markup.heading.2.markdown"] = { fg = ansi.yellow, bold = true },
  ["@markup.heading.3.markdown"] = { fg = ansi.green, bold = true },
  ["@markup.heading.4.markdown"] = { fg = ansi.cyan, bold = true },
  ["@markup.heading.5.markdown"] = { fg = ansi.magenta, bold = true },
  ["@markup.heading.6.markdown"] = { fg = p.gray, bold = true },
  ["@markup.quote.markdown"] = { fg = p.comment, italic = true },
  ["@markup.raw.markdown"] = ansi.green,
  ["@markup.link.markdown"] = ansi.cyan,
  ["@markup.link.label.markdown"] = bright.cyan,
  ["@markup.list.markdown"] = ansi.red,
}

for capture, val in pairs(ts) do
  if type(val) == "table" then
    hl(capture, val)
  else
    hl(capture, { fg = val })
  end
end

-- -------------------------------------------------------- LSP semantic tokens

local lsp_types = {
  class = ansi.yellow,
  comment = p.comment,
  constant = bright.blue,
  constructor = ansi.cyan,
  ["enum"] = ansi.yellow,
  enumMember = bright.blue,
  event = ansi.yellow,
  ["function"] = ansi.cyan,
  interface = ansi.yellow,
  keyword = ansi.red,
  macro = ansi.magenta,
  method = ansi.cyan,
  module = ansi.magenta,
  namespace = ansi.magenta,
  number = bright.blue,
  operator = p.gray,
  parameter = p.fg,
  property = ansi.green,
  regexp = bright.blue,
  string = ansi.green,
  struct = ansi.yellow,
  type = ansi.yellow,
  typeParameter = ansi.yellow,
  variable = p.fg,
}

for kind, colour in pairs(lsp_types) do
  hl("@lsp.type." .. kind, { fg = colour })
end

hl("@lsp.typemod.variable.readonly", { fg = p.comment })
hl("@lsp.typemod.variable.defaultLibrary", { fg = bright.cyan })
hl("@lsp.typemod.variable.static", { fg = bright.blue })
hl("@lsp.typemod.variable.deprecated", { fg = p.gray, strikethrough = true })
hl("@lsp.typemod.property.readonly", { fg = p.comment })
hl("@lsp.typemod.property.defaultLibrary", { fg = bright.cyan })
hl("@lsp.typemod.property.static", { fg = bright.blue })
hl("@lsp.typemod.property.deprecated", { fg = p.gray, strikethrough = true })
hl("@lsp.typemod.function.defaultLibrary", { fg = bright.cyan })
hl("@lsp.typemod.function.declaration", { fg = ansi.cyan, bold = true })
hl("@lsp.typemod.function.deprecated", { fg = p.gray, strikethrough = true })
hl("@lsp.typemod.method.defaultLibrary", { fg = bright.cyan })
hl("@lsp.typemod.method.declaration", { fg = ansi.cyan, bold = true })
hl("@lsp.typemod.method.deprecated", { fg = p.gray, strikethrough = true })
hl("@lsp.typemod.class.defaultLibrary", { fg = bright.yellow })
hl("@lsp.typemod.class.abstract", { fg = ansi.yellow, italic = true })
hl("@lsp.typemod.class.deprecated", { fg = p.gray, strikethrough = true })
hl("@lsp.typemod.interface.defaultLibrary", { fg = bright.yellow })
hl("@lsp.typemod.struct.defaultLibrary", { fg = bright.yellow })
hl("@lsp.typemod.enum.defaultLibrary", { fg = bright.yellow })
hl("@lsp.typemod.enumMember.defaultLibrary", { fg = bright.blue })
hl("@lsp.typemod.type.defaultLibrary", { fg = bright.yellow })
hl("@lsp.typemod.keyword.deprecated", { fg = p.gray, strikethrough = true })
hl("@lsp.typemod.macro.defaultLibrary", { fg = ansi.magenta })
hl("@lsp.typemod.comment.documentation", { fg = p.comment, italic = true })
hl("@lsp.typemod.string.injected", { fg = ansi.cyan })
hl("@lsp.typemod.operator.injected", { fg = ansi.cyan })
hl("@lsp.mod.deprecated", { fg = p.gray, strikethrough = true })
hl("@lsp.mod.readonly", { fg = p.comment })
hl("@lsp.typemod", {})

-- --------------------------------------------------------- render-markdown

hl("RenderMarkdownH1Bg", { fg = ansi.red, bg = surf.s0 })
hl("RenderMarkdownH2Bg", { fg = ansi.yellow, bg = surf.s0 })
hl("RenderMarkdownH3Bg", { fg = ansi.green, bg = surf.s0 })
hl("RenderMarkdownH4Bg", { fg = ansi.cyan, bg = surf.s0 })
hl("RenderMarkdownH5Bg", { fg = ansi.magenta, bg = surf.s0 })
hl("RenderMarkdownH6Bg", { fg = p.gray, bg = surf.s0 })
hl("RenderMarkdownCode", { fg = ansi.green, bg = surf.s0 })
hl("RenderMarkdownInfo", { fg = ansi.cyan, bg = surf.s0, italic = true })
hl("RenderMarkdownSuccess", { fg = ansi.green, bg = surf.s0, italic = true })
hl("RenderMarkdownHint", { fg = diag.hint, bg = surf.s0, italic = true })
hl("RenderMarkdownWarn", { fg = diag.warn, bg = surf.s0, italic = true })
hl("RenderMarkdownError", { fg = diag.error, bg = surf.s0, italic = true })

-- ------------------------------------------------------------------- health

hl("healthError", { fg = diag.error })
hl("healthSuccess", { fg = diag.ok })
hl("healthWarning", { fg = diag.warn })
hl("helpCommand", { fg = ansi.cyan })
hl("helpExample", { fg = ansi.green })
hl("helpHeader", { fg = ansi.yellow, bold = true })
hl("helpHyperTextJump", { fg = ansi.cyan, underline = true })
hl("helpSectionDelim", { fg = prompt.frame })
