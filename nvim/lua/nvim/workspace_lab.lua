-- lua/nvim/workspace_lab.lua
-- Loads the standalone 4-panel workspace layout from this config for testing,
-- without permanently integrating it. Toggle it on/off to switch back to your
-- normal nvim layout. The layout source lives at lua/nvim/workspace.lua.

local M = {}

local cache = nil

local function load()
  if cache then
    return cache
  end
  local ok, mod = pcall(require, "nvim.workspace")
  if not ok then
    vim.notify("workspace_lab: could not load nvim.workspace: " .. tostring(mod), vim.log.levels.ERROR)
    return nil
  end
  cache = mod
  return mod
end

function M.toggle()
  local mod = load()
  if not mod then
    return
  end
  local open = mod.wins and mod.wins[1] and vim.api.nvim_win_is_valid(mod.wins[1])
  if open then
    mod.close()
    vim.notify("workspace_lab: closed workspace layout")
  else
    mod.open()
    vim.notify("workspace_lab: opened workspace layout (Panel 4 = terminals)")
  end
end

function M.open()
  local mod = load()
  if mod then
    mod.open()
  end
end

function M.close()
  local mod = load()
  if mod then
    mod.close()
  end
end

function M.setup()
  vim.api.nvim_create_user_command("WorkspaceToggle", function()
    M.toggle()
  end, { desc = "Toggle the 4-panel workspace layout on/off" })
  vim.api.nvim_create_user_command("WorkspaceOpen", function()
    M.open()
  end, { desc = "Open the 4-panel workspace layout" })
  vim.api.nvim_create_user_command("WorkspaceClose", function()
    M.close()
  end, { desc = "Close the 4-panel workspace layout" })

  -- Default toggle keybinding. Change to whatever you prefer.
  vim.keymap.set("n", "<leader>ww", M.toggle, { desc = "Toggle workspace layout" })
end

return M
