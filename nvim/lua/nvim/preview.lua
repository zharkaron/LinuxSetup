-- lua/nvim/preview.lua
-- :ThemePreview
--
-- Opens a scratch buffer showing what the Artemis x Mint palette actually
-- renders as: the 16 terminal colours, the editor surfaces, the real highlight
-- groups read back out of Neovim, the zsh prompt mapping, and a
-- Treesitter-highlighted sample so you can compare the syntax colours against
-- your terminal.

local p = require("nvim.palette")

local M = {}

local ns = vim.api.nvim_create_namespace("artemis_preview")

-- Width of one swatch cell, and the block glyphs used to paint it.
-- Eight cells across is 96 columns at W = 12, which fits an 80-100 column
-- window without wrapping.
local W = 12
local BLOCKS = "████████"

-- Each row is { text = "...", hl = { { from, to, hl_group }, ... } }
local marks = {}

local function put(text)
  local row = #marks
  marks[row + 1] = { text = text or "", hl = {} }
  return row
end

local function paint(row, from, to, group)
  if not group then
    return
  end
  local hl = marks[row + 1].hl
  hl[#hl + 1] = { from, to, group }
end

local function pad(text, width)
  return ("%-" .. width .. "s"):format(text)
end

local function hex(n)
  return type(n) == "number" and string.format("#%06x", n) or nil
end

-- Read a highlight group back out of Neovim, so the groups section reflects
-- what colors/artemis.lua actually set rather than what the palette intended.
local function probe(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok or not hl then
    return nil
  end
  return hex(hl.fg) or hex(hl.bg)
end

-- ---------------------------------------------------------------------------
-- Support highlight groups for the preview buffer itself.
-- ---------------------------------------------------------------------------

local cache = {}

local function colour_group(colour, prefix)
  if not colour then
    return nil
  end
  local name = prefix .. colour:gsub("#", "")
  if not cache[name] then
    cache[name] = true
    if prefix == "PreviewSw" then
      vim.api.nvim_set_hl(0, name, { fg = colour, bg = colour })
    else
      vim.api.nvim_set_hl(0, name, { fg = colour })
    end
  end
  return name
end

local function fg(colour)
  return colour_group(colour, "PreviewFg")
end

local function swatch(colour)
  return colour_group(colour, "PreviewSw")
end

vim.api.nvim_set_hl(0, "PreviewTitle", { fg = p.prompt.git, bold = true })
vim.api.nvim_set_hl(0, "PreviewHeading", { fg = p.bright.blue, bold = true })
vim.api.nvim_set_hl(0, "PreviewDim", { fg = p.gray })

-- ---------------------------------------------------------------------------
-- Row builders.
-- ---------------------------------------------------------------------------

local function blank()
  put("")
end

local function heading(text)
  blank()
  local row = put("  " .. text)
  paint(row, 2, 2 + #text, "PreviewHeading")
  blank()
end

-- One row of colour swatches: key, painted block, hex. Breaks into as many
-- rows as needed to stay within `per_row` cells.
local function swatch_row(items, per_row)
  per_row = per_row or 8
  for first = 1, #items, per_row do
    local chunk = {}
    for i = first, math.min(first + per_row - 1, #items) do
      chunk[#chunk + 1] = items[i]
    end
    local key_row = put("")
    local block_row = put("")
    local hex_row = put("")
    local keys, blocks, hexes = {}, {}, {}
    for i, it in ipairs(chunk) do
      local x = (i - 1) * W
      keys[i] = pad(it.key, W)
      blocks[i] = BLOCKS .. "  "
      hexes[i] = pad(it.hex or "", W)
      paint(block_row, 2 + x, 2 + x + #BLOCKS, swatch(it.hex))
      paint(hex_row, 2 + x, 2 + x + #(it.hex or ""), "PreviewDim")
    end
    marks[key_row + 1].text = "  " .. table.concat(keys)
    marks[block_row + 1].text = "  " .. table.concat(blocks)
    marks[hex_row + 1].text = "  " .. table.concat(hexes)
  end
end

-- "key   value", where the value keeps its colour.
local function kv(key, value, colour)
  local row = put("  " .. pad(key, 22) .. value)
  paint(row, 24, 24 + #value, colour)
end

-- A line built from coloured fragments.
local function fragments(parts)
  local row = put("")
  local buffer = {}
  for _, part in ipairs(parts) do
    local startc = #table.concat(buffer)
    buffer[#buffer + 1] = part[1]
    paint(row, 2 + startc, 2 + startc + #part[1] - 1, part[2])
  end
  marks[row + 1].text = "  " .. table.concat(buffer)
end

-- ---------------------------------------------------------------------------
-- Content.
-- ---------------------------------------------------------------------------

local ANSI_NAMES = { "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white" }

local SURFACES = {
  { "background", p.bg },
  { "foreground", p.fg },
  { "cursor", p.cursor },
  { "selection", p.sel_bg },
  { "surface s0", p.surface.s0 },
  { "surface s1", p.surface.s1 },
  { "surface s2", p.surface.s2 },
  { "border", p.border },
  { "divider", p.divider },
  { "comment", p.comment },
  { "gray", p.gray },
  { "gray dim", p.gray_dim },
}

local GROUPS = {
  "Keyword",
  "String",
  "Number",
  "Float",
  "Boolean",
  "Constant",
  "Identifier",
  "Function",
  "Statement",
  "Conditional",
  "Repeat",
  "Label",
  "Operator",
  "Comment",
  "PreProc",
  "Type",
  "Special",
  "Underlined",
  "CursorLine",
  "CursorLineNr",
  "Visual",
  "Search",
  "IncSearch",
  "StatusLine",
  "StatusLineNC",
  "VertSplit",
  "WinSeparator",
  "Pmenu",
  "PmenuSel",
  "FloatBorder",
  "NormalFloat",
  "LineNr",
  "SignColumn",
  "NonText",
  "DiffAdd",
  "DiffChange",
  "DiffDelete",
  "DiagnosticError",
  "DiagnosticWarn",
  "DiagnosticInfo",
  "DiagnosticHint",
  "GitSignsAdd",
  "GitSignsChange",
  "GitSignsDelete",
}

local SAMPLE = {
  "-- Comments are #757a7f and italic.",
  'local M = { version = "0.1.0" }',
  "",
  "--- Greet someone a number of times.",
  "---@param name string  @param times integer",
  "function M.greet(name, times)",
  '  local greeting = "hello, " .. name',
  "  for i = 1, times do",
  "    if #greeting > 40 then",
  '      return nil, "too long"',
  "    end",
  '    print(string.format("%s %d", greeting, i))',
  "  end",
  "  return greeting",
  "end",
  "",
  "local Point = {}",
  "Point.__index = Point",
  "",
  "function Point.new(x, y)",
  "  return setmetatable({ x = x, y = y }, Point)",
  "end",
  "",
  "function Point:len2()",
  "  return self.x ^ 2 + self.y ^ 2",
  "end",
  "",
  "return M",
}

function M.show()
  local buf = vim.api.nvim_create_buf(false, true)

  blank()
  local title = put("  ▊ ARTEMIS x MINT")
  paint(title, 2, 3 + #"ARTEMIS x MINT", "PreviewTitle")
  kv("same palette as", "kitty/appearance/artemis.conf", fg(p.gray))
  kv("change colours in", "nvim/lua/nvim/palette.lua", fg(p.gray))
  blank()

  heading("TERMINAL PALETTE  ·  kitty color0-7")
  swatch_row((function()
    local out = {}
    for i, name in ipairs(ANSI_NAMES) do
      out[i] = { key = name, hex = p.ansi[name] }
    end
    return out
  end)())

  heading("BRIGHT  ·  kitty color8-15")
  swatch_row((function()
    local out = {}
    for i, name in ipairs(ANSI_NAMES) do
      out[i] = { key = "b:" .. name, hex = p.bright[name] }
    end
    return out
  end)())

  heading("EDITOR SURFACES")
  swatch_row((function()
    local out = {}
    for i, s in ipairs(SURFACES) do
      out[i] = { key = s[1], hex = s[2] }
    end
    return out
  end)(), 6)

  heading("HIGHLIGHT GROUPS  ·  read back from Neovim")
  for i = 1, #GROUPS, 2 do
    local row = put("  ")
    for slot = 0, 1 do
      local name = GROUPS[i + slot]
      if name then
        local colour = probe(name)
        local x = slot * 34
        while #marks[row + 1].text - 2 < x do
          marks[row + 1].text = marks[row + 1].text .. " "
        end
        local base = #marks[row + 1].text - 2
        marks[row + 1].text = marks[row + 1].text .. pad(name, 26) .. (colour or "(none)")
        paint(row, 2 + base + 26, 2 + base + 26 + #(colour or ""), fg(colour))
      end
    end
  end
  blank()

  heading("ZSH PROMPT MAPPING  ·  the statusline copies this")
  fragments({
    { "zharkaron@linuxsetup", fg(p.prompt.user) },
    { ":", fg(p.fg) },
    { "~/LinuxSetup/nvim", fg(p.prompt.path) },
    { " (main)", fg(p.prompt.git) },
    { " > ", fg(p.prompt.frame) },
  })
  fragments({
    { "NORMAL", fg(p.bright.white) },
    { "  (main) ", fg(p.prompt.git) },
    { "zsh/core/", fg(p.prompt.path) },
    { "prompt.zsh", fg(p.fg) },
  })
  blank()

  heading("SYNTAX  ·  real Treesitter")
  for _, code in ipairs(SAMPLE) do
    put("  " .. code)
  end
  blank()

  heading("DIAGNOSTICS  ·  GIT  ·  DIFF")
  fragments({ { "error  ", fg(p.diagnostic.error) }, { "unused variable 'x'", fg(p.fg) } })
  fragments({ { "warn   ", fg(p.diagnostic.warn) }, { "line longer than 120 columns", fg(p.fg) } })
  fragments({ { "info   ", fg(p.diagnostic.info) }, { "resolved to /usr/local/lib", fg(p.fg) } })
  fragments({ { "hint   ", fg(p.diagnostic.hint) }, { "did you mean greet()?", fg(p.fg) } })
  blank()
  fragments({ { "+ added", fg(p.git.add) }, { "        git.add", "PreviewDim" } })
  fragments({ { "- removed", fg(p.git.delete) }, { "      git.delete", "PreviewDim" } })
  fragments({ { "~ changed", fg(p.git.change) }, { "      git.change", "PreviewDim" } })
  fragments({ { "? untracked", fg(p.git.untracked) }, { "    git.untracked", "PreviewDim" } })
  blank()
  kv("close this window with", "q", fg(p.cursor))
  blank()

  -- Render the assembled rows.
  local lines = {}
  for i, m in ipairs(marks) do
    lines[i] = m.text
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  for i, m in ipairs(marks) do
    for _, h in ipairs(m.hl) do
      vim.api.nvim_buf_add_highlight(buf, ns, h[3], i - 1, h[1], h[2])
    end
  end

  -- Treesitter runs on the finished buffer, so this is the real syntax output.
  vim.bo[buf].filetype = "lua"

  -- The buffer deliberately mixes prose with Lua, so any LSP attached to it
  -- would report the headings as syntax errors. Silence diagnostics here.
  vim.diagnostic.set(vim.api.nvim_create_namespace("theme_preview"), {}, { bufnr = buf })

  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.bo[buf].modifiable = false
  vim.bo[buf].swapfile = false
  vim.bo[buf].buftype = "nofile"
  vim.wo[win].spell = false
  vim.wo[win].cursorline = false
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].wrap = false
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>bdelete!<CR>", { nowait = true, silent = true })
  vim.cmd("normal! gg")
  marks = {}
end

vim.api.nvim_create_user_command("ThemePreview", M.show, {
  desc = "Show the Artemis x Mint palette, highlight groups and syntax preview",
})

return M
