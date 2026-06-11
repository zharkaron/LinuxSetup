-- lua/ai/config.lua
-- Local AI chat via codecompanion.nvim, backed by a model served on localhost.
-- No external AI account is required. Start a backend first, e.g. with Ollama:
--   ollama serve          # serves an OpenAI-compatible API on http://localhost:11434
--   ollama pull qwen2.5-coder
require("codecompanion").setup({
  adapters = {
    http = {
      -- Point the built-in "ollama" adapter at the local server.
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          env = {
            url = "http://localhost:11434",
          },
          schema = {
            model = {
              -- Change this to whatever you've pulled locally (`ollama list`).
              default = "qwen2.5-coder:7b",
            },
          },
        })
      end,
    },
  },
  -- Use the local model for every interaction type.
  interactions = {
    chat = { adapter = "ollama" },
    inline = { adapter = "ollama" },
    cmd = { adapter = "ollama" },
  },
  opts = {
    log_level = "ERROR",
  },
})
