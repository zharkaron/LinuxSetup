-- lua/nvim/lint/config.lua
local lint = require("lint")
local run = require("lint.run")

-- Custom Java checker built on the JDK's own compiler. Needs only `javac`
-- (no extra checkstyle jar/config), so it works wherever the Java toolchain
-- from issue #108 is installed. Class files are written to a throwaway cache
-- dir so checking never litters the project tree.
local javac_lint_dir = vim.fn.stdpath("cache") .. "/javac-lint"
vim.fn.mkdir(javac_lint_dir, "p")

local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  note = vim.diagnostic.severity.INFO,
}

lint.linters.javac = {
  cmd = "javac",
  stdin = false,
  append_fname = true,
  args = { "-Xlint:all", "-d", javac_lint_dir },
  stream = "stderr",
  ignore_exitcode = true,
  parser = function(output, bufnr)
    local diagnostics = {}
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    -- javac lines look like: /abs/Path.java:12: warning: [rawtypes] message
    for line in vim.gsplit(output or "", "\n", { plain = true }) do
      local file, lnum, sev, msg = line:match("^(.-):(%d+): (%a+): (.+)$")
      if file and severity_map[sev] then
        -- Only surface diagnostics for the file being checked; javac may
        -- mention other compilation units when symbols are missing.
        if vim.fn.fnamemodify(file, ":p") == bufname then
          table.insert(diagnostics, {
            lnum = tonumber(lnum) - 1,
            col = 0,
            severity = severity_map[sev],
            source = "javac",
            message = msg,
          })
        end
      end
    end
    return diagnostics
  end,
}

-- Define linters per filetype
lint.linters_by_ft = {
  python     = { "pylint" },      -- or flake8
  sh         = { "shellcheck" },
  bash       = { "shellcheck" },
  lua        = { "luacheck" },
  json       = { "jq"},
  javascript = { "eslint" },
  typescript = { "eslint" },
  java       = { "javac" },
}

-- Auto-run lint whenever you save, open, leave insert mode, or pause typing
-- (CursorHold fires after 'updatetime' ms of inactivity in normal mode).
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave", "CursorHold" }, {
  callback = function()
    run.lint_buffer({ silent = true })
  end,
})
