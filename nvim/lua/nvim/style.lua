-- lua/nvim/style.lua
-- Editor colours + statusline, both derived from the Kitty "Artemis x Mint"
-- theme so Neovim and the zsh prompt read as one setup.

local p = require("nvim.palette")

vim.cmd("colorscheme artemis")

-- Lualine theme that mirrors zsh/core/prompt.zsh:
-- gray powerline frame, green user/host, blue prompt arrow, yellow path,
-- magenta git branch.
local artemis_lualine = {
  normal = {
    a = { fg = p.bright.white, bg = p.surface.s2, gui = "bold" },
    b = { fg = p.bg, bg = p.prompt.git },
    c = { fg = p.fg, bg = p.surface.s0 },
    x = { fg = p.gray, bg = p.surface.s0 },
    y = { fg = p.gray_dim, bg = p.surface.s0 },
    z = { fg = p.gray_dim, bg = p.bg },
  },
  insert = {
    a = { fg = p.bg, bg = p.prompt.user, gui = "bold" },
    b = { fg = p.bg, bg = p.prompt.git },
    c = { fg = p.fg, bg = p.surface.s0 },
    x = { fg = p.gray, bg = p.surface.s0 },
    y = { fg = p.gray_dim, bg = p.surface.s0 },
  },
  visual = {
    a = { fg = p.sel_fg, bg = p.sel_bg, gui = "bold" },
    b = { fg = p.bg, bg = p.prompt.git },
    c = { fg = p.fg, bg = p.surface.s0 },
    x = { fg = p.gray, bg = p.surface.s0 },
    y = { fg = p.gray_dim, bg = p.surface.s0 },
  },
  replace = {
    a = { fg = p.bg, bg = p.prompt.path, gui = "bold" },
    b = { fg = p.bg, bg = p.prompt.git },
    c = { fg = p.fg, bg = p.surface.s0 },
    x = { fg = p.gray, bg = p.surface.s0 },
    y = { fg = p.gray_dim, bg = p.surface.s0 },
  },
  inactive = {
    a = { fg = p.gray_dim, bg = p.bg },
    b = { fg = p.gray_dim, bg = p.bg },
    c = { fg = p.gray_dim, bg = p.bg },
    x = { fg = p.gray_dim, bg = p.bg },
    y = { fg = p.gray_dim, bg = p.bg },
    z = { fg = p.gray_dim, bg = p.bg },
  },
}
-- How far through the buffer the cursor is, as a filled-bar percentage.
-- lualine's built-in "progress" component prints "Top"/"Bot" and takes no fmt.
local function file_progress()
  local cur, total = vim.fn.line("."), vim.fn.line("$")
  if total < 2 then
    return ""
  end
  -- A literal % has to be doubled or Neovim's statusline parser eats it and
  -- the whole statusline renders blank.
  return "▰ " .. tostring(math.floor(cur / total * 100)) .. "%%"
end

local sep = package.config:sub(1, 1)

-- Anything that goes into a statusline string must have % doubled.
local function stl_escape(str)
  return (str:gsub("%%", "%%%%"))
end

-- Yellow directory then default-coloured file name, mirroring the zsh prompt's
-- "YELLOW %~" split. These are two components because lualine gives each
-- component one colour.
local function path_dir()
  local dir = vim.fn.fnamemodify(vim.fn.expand("%:p:h"), ":.")
  if dir == "." then
    return ""
  end
  return stl_escape(dir) .. sep .. " "
end

local function path_name()
  local name = vim.fn.expand("%:t")
  if name == "" then
    return "[No Name]"
  end
  return name
end

require("lualine").setup({
  options = {
    -- Must be the table itself. A string here makes lualine look for
    -- lualine.themes.<name> and silently fall back to its "auto" theme.
    theme = artemis_lualine,
    -- Angled powerline separators, matching kitty's tab_powerline_style angled.
    -- Set globalstatus = true for a single bottom bar like the terminal has.
    icons_enabled = true,
    section_separators = {
      left = "",
      right = "",
      left2 = "",
      right2 = "",
    },
    component_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = {
      { path_dir, color = { fg = p.prompt.path } },
      { path_name, color = { fg = p.fg } },
    },
    lualine_x = {
      "diagnostics",
      file_progress,
      { "lsp_progress", sp = "line" },
    },
    lualine_y = { "position" },
    lualine_z = {},
  },
  -- Key must be inactive_sections; a bare `inactive` key here is silently ignored.
  inactive_sections = {
    lualine_a = { "filename", path = 0 },
    lualine_b = {},
    lualine_c = {},
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
})

-- Highlights lualine touches after load.
local function hl(name, val)
  vim.api.nvim_set_hl(0, name, val)
end
hl("StatusLine", { fg = p.fg, bg = p.surface.s0 })
hl("StatusLineNC", { fg = p.gray_dim, bg = p.bg })
