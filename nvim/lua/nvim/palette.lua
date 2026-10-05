-- lua/nvim/palette.lua
-- Single source of truth for the Artemis x Mint palette.
-- Mirrors kitty/appearance/artemis.conf so Neovim and the terminal render from
-- the exact same hex values. Terminal ANSI names (color0..color15) are kept on
-- the left; the friendly names on the right are what the rest of the config
-- uses.
--
-- If you change kitty/appearance/artemis.conf, change it here too.

local M = {}

-- Kitty color0..color7 -- normal ANSI
M.ansi = {
  black = "#1e1f21", -- color0
  red = "#ff4f79", -- color1
  green = "#a1ff9e", -- color2
  yellow = "#f7ff6b", -- color3
  blue = "#9b5de5", -- color4
  magenta = "#88c0d0", -- color5
  cyan = "#6fffe9", -- color6
  white = "#c7c7c7", -- color7
}

-- Kitty color8..color15 -- bright ANSI
M.bright = {
  black = "#3c3f41",
  red = "#ff6f91",
  green = "#a1ff9e",
  yellow = "#fff974",
  blue = "#b28fff",
  magenta = "#88c0d0",
  cyan = "#76fff7",
  white = "#ffffff",
}

-- Kitty foreground / background / cursor / selection
M.bg = "#1e1f21"
M.fg = "#c7c7c7"
M.cursor = "#a1ff9e"
M.cursor_text = "#1e1f21"
M.sel_bg = "#4b5668"
M.sel_fg = "#ffffff"

-- Derived surfaces: bg steps for panels, cursorline and inactive buffers.
-- Only the two extra steps are invented, everything else is a palette entry.
M.surface = {
  s0 = "#222427", -- statusline, panel, pmenu
  s1 = "#282b2f", -- cursorline, telescope prompt
  s2 = "#2e3236", -- floats, active buffer line
}

-- Structure lines
M.border = "#4b5668" -- floating window borders, separators
M.divider = "#3c3f41" -- vertsplit, bufferline separators

-- Greys used by the zsh prompt (GRAY was zsh colour 240)
M.gray = "#6f7479"
M.gray_dim = "#4d5155"
M.comment = "#757a7f"

-- zsh/core/prompt.zsh mapping, so the statusline echoes the shell prompt.
M.prompt = {
  frame = "#6f7479", -- GRAY, the -- and >
  user = "#a1ff9e", -- GREEN
  host = "#9b5de5", -- BLUE
  path = "#f7ff6b", -- YELLOW
  git = "#88c0d0", -- MAGENTA
  arrow_ok = "#a1ff9e", -- ARROW_SUCCESS
  arrow_fail = "#ff4f79", -- ARROW_FAIL
}

M.diagnostic = {
  error = "#ff4f79",
  warn = "#f7ff6b",
  info = "#88c0d0",
  hint = "#a1ff9e",
  ok = "#a1ff9e",
}

M.git = {
  add = "#a1ff9e",
  change = "#f7ff6b",
  delete = "#ff4f79",
  untracked = "#88c0d0",
}

-- Push the palette into :terminal / toggleterm so in-app terminals use the same
-- 16 colours as kitty instead of Neovim's built-in defaults.
function M.apply_terminal_colors()
  local order = {
    "black",
    "red",
    "green",
    "yellow",
    "blue",
    "magenta",
    "cyan",
    "white",
    "brightblack",
    "brightred",
    "brightgreen",
    "brightyellow",
    "brightblue",
    "brightmagenta",
    "brightcyan",
    "brightwhite",
  }
  for i, name in ipairs(order) do
    local hex = (i <= 8 and M.ansi[name] or M.bright[name]) or M.fg
    vim.g["terminal_color_" .. (i - 1)] = hex
  end
end

-- Base options the palette depends on. Called by colors/artemis.lua.
--
-- Cursor colour is deliberately not set here: inside a terminal the emulator
-- draws the cursor (kitty already sets `cursor #a1ff9e`), and in GUI Neovim the
-- Cursor highlight group does the job. `guicursor` only takes named shapes, so
-- it cannot carry a hex colour.
function M.setup()
  vim.o.background = "dark"
  vim.o.termguicolors = true
  M.apply_terminal_colors()
end

return M
