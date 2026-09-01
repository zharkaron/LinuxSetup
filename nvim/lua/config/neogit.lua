-- lua/neogit/config.lua
local neogit = require("neogit")

neogit.setup({
  integrations = {
    telescope = true,
    diffview = false,
  },
  disable_hint = false,
  disable_context_highlighting = false,
  disable_signs = false,
  disable_commit_confirmation = false,
  graph_style = "unicode",
  kind = "tab",
  commit_editor = {
    kind = "split",
  },
  section = {
    untracked = {
      folded = false,
    },
    unstaged = {
      folded = false,
    },
    staged = {
      folded = false,
    },
    stashes = {
      folded = true,
    },
    unpulled_upstream = {
      folded = true,
    },
    unpulled_pushRemote = {
      folded = true,
    },
    recent = {
      folded = true,
    },
  },
  refresh = {
    status = { enabled = true, interval = 30 },
    reflog = { enabled = false, interval = 60 },
  },
})

-- Helper: safe push that blocks main/master
local protected_branches = { "main", "master" }

function _G.NeogitSafePush()
  local branch = vim.fn.trim(vim.fn.system("git branch --show-current 2>/dev/null"))
  if branch == "" then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end
  if vim.tbl_contains(protected_branches, branch) then
    vim.notify("Push to " .. branch .. " is blocked by safe-push", vim.log.levels.WARN)
    return
  end
  if vim.fn.input("Push branch '" .. branch .. "' to remote? (y/N): ") ~= "y" then
    vim.notify("Push cancelled", vim.log.levels.INFO)
    return
  end
  vim.cmd("Neogit push")
end

function _G.NeogitSafePushForce()
  local branch = vim.fn.trim(vim.fn.system("git branch --show-current 2>/dev/null"))
  if branch == "" then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end
  if vim.tbl_contains(protected_branches, branch) then
    vim.notify("Force push to " .. branch .. " is blocked by safe-push", vim.log.levels.WARN)
    return
  end
  if vim.fn.input("Force push branch '" .. branch .. "' to remote? (yes/N): ") ~= "yes" then
    vim.notify("Force push cancelled", vim.log.levels.INFO)
    return
  end
  vim.cmd("Neogit push --force-with-lease")
end
