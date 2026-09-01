-- lua/nvim-autopairs/keys.lua
-- The nvim-autopairs setup (including fast_wrap) lives in autopairs/config.lua.
-- Setup is only invoked once there; calling it again here would overwrite the
-- general config because nvim-autopairs' setup() replaces the whole config
-- table rather than merging on top of a previous setup.
local npairs = require('nvim-autopairs')

-- Fast-wrap keybinding is already registered via config.lua's setup(fast_wrap).
-- Add any custom keymaps here if needed.
-- e.g., disable auto-wrap in some filetypes or for special keys.
