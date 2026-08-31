local Terminal = require("toggleterm.terminal").Terminal
local fn = vim.fn
local notify = vim.notify

-- Exit terminal mode with Esc (back to terminal-normal mode)
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

local function open_floating_terminal_in_dir(path)
  local term = Terminal:new({
    dir = path,
    direction = "float",
    close_on_exit = false,
    hidden = true,
  })
  term:toggle()
end

-- Open terminal in current buffer’s directory
vim.keymap.set("n", "<leader>tb", function()
  local file = fn.expand("%:p")
  if file == "" then
    notify("No file open", vim.log.levels.WARN)
    return
  end
  local dir = fn.fnamemodify(file, ":h")
  open_floating_terminal_in_dir(dir)
end, { desc = "Open terminal in buffer directory" })
