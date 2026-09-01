local host = require("nvim.ai.host")
local default_model = "qwen2.5-coder:7b"

require("codecompanion").setup({
  adapters = {
    http = {
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          env = { url = host.ollama_base(11434) },
          schema = { model = { default = default_model } },
        })
      end,
    },
  },
  interactions = {
    chat = {
      adapter = "ollama",
      slash_commands = {
        models = {
          description = "Switch the AI model for this chat",
          opts = { contains_code = false },
          callback = function(chat)
            require("nvim.ai.models").prompt_switch_model(chat)
          end,
        },
      },
      tools = {
        opts = {
          -- Let the model edit your file directly. When it proposes changes,
          -- CodeCompanion shows a diff you review in the chat before applying
          -- (g1 always-accept / g2 accept / g3 reject / g4 cancel).
          default_tools = { "insert_edit_into_file" },
        },
      },
    },
    inline = { adapter = "ollama" },
    cmd = { adapter = "ollama" },
  },
  opts = {
    log_level = "ERROR",
  },
})

-- Auto-attach the currently-focused file to every chat (not just the workspace
-- panel), so the model can always read the file the user is working on. Chat
-- is wrapped lazily; safe to call before CodeCompanion has been loaded.
local ok_ctx, ctx = pcall(require, "nvim.ai.context")
if ok_ctx and type(ctx.attach_all) == "function" then
    pcall(ctx.attach_all)
end

-- Quick model switch
vim.api.nvim_create_user_command("SetModel", function(opts)
  local model = opts.args
  if model == "" then
    vim.notify("Usage: SetModel <model_name> (e.g. qwen2.5-coder:7b)", vim.log.levels.INFO)
    return
  end

  -- Update codecompanion adapter
  local cc = require("codecompanion")
  cc.config.adapters.http.ollama = function()
    return require("codecompanion.adapters").extend("ollama", {
      env = { url = host.ollama_base(11434) },
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
