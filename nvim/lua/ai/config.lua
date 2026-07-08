local cc_url = "http://localhost:11434"
local default_model = "qwen2.5-coder:1.5b"

require("codecompanion").setup({
  adapters = {
    http = {
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          env = { url = cc_url },
          schema = { model = { default = default_model } },
        })
      end,
    },
  },
  interactions = {
    chat = { adapter = "ollama" },
    inline = { adapter = "ollama" },
    cmd = { adapter = "ollama" },
  },
  opts = {
    log_level = "ERROR",
  },
})

-- Quick model switch
vim.api.nvim_create_user_command("SetModel", function(opts)
  local model = opts.args
  if model == "" then
    vim.notify("Usage: SetModel <model_name> (e.g. qwen2.5-coder:1.5b)", vim.log.levels.INFO)
    return
  end

  -- Update codecompanion adapter
  local cc = require("codecompanion")
  cc.config.adapters.http.ollama = function()
    return require("codecompanion.adapters").extend("ollama", {
      env = { url = cc_url },
      schema = { model = { default = model } },
    })
  end

  -- Update minuet inline model
  local ok, minuet = pcall(require, "minuet")
  if ok then
    minuet.change_model(model)
  end

  vim.notify("AI model switched to: " .. model, vim.log.levels.INFO)
end, { nargs = 1, desc = "Switch AI model for chat and inline completion" })
