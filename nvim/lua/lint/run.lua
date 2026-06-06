-- lua/nvim/lint/run.lua
-- Wrapper around nvim-lint's try_lint that checks the linter executable is
-- present first, so a missing tool produces an actionable warning instead of
-- nvim-lint's generic error (or a Lua error).
local lint = require("lint")

local M = {}

-- command -> install hint. Package names mirror installer/packages.sh so the
-- message tells the user exactly what to install on their distro.
local install_hints = {
  javac = "a JDK (java-latest-openjdk-devel / default-jdk / jdk-openjdk)",
  pylint = "pylint (python3-pylint / pylint)",
  shellcheck = "shellcheck (ShellCheck / shellcheck)",
  luacheck = "luacheck (via luarocks)",
  jq = "jq",
  eslint = "eslint (npm install -g eslint)",
}

-- Returns the first configured linter whose command is missing, or nil.
local function first_missing_linter(ft)
  local names = lint.linters_by_ft[ft]
  if not names then
    return nil
  end
  for _, name in ipairs(names) do
    local linter = lint.linters[name]
    local cmd = type(linter) == "table" and linter.cmd or nil
    if type(cmd) == "string" and vim.fn.executable(cmd) ~= 1 then
      return cmd
    end
  end
  return nil
end

-- Run linters for the current buffer.
-- opts.silent suppresses the "no linter configured" notice (used by autocmds).
function M.lint_buffer(opts)
  opts = opts or {}
  local ft = vim.bo.filetype
  local names = lint.linters_by_ft[ft]

  if not names or #names == 0 then
    if not opts.silent then
      vim.notify("No linter configured for '" .. ft .. "' files.", vim.log.levels.INFO)
    end
    return
  end

  local missing = first_missing_linter(ft)
  if missing then
    -- Stay quiet on automatic (silent) runs so saving/leaving insert mode does
    -- not spam warnings; the manual <leader>l run still surfaces the message.
    if not opts.silent then
      vim.notify(
        string.format(
          "'%s' not found. Install %s and ensure it is on PATH.",
          missing,
          install_hints[missing] or missing
        ),
        vim.log.levels.WARN
      )
    end
    return
  end

  lint.try_lint()
  if not opts.silent then
    vim.notify("Linting done for current buffer", vim.log.levels.INFO)
  end
end

return M
