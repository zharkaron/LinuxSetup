-- lua/inlineai/config.lua
-- Inline code completion (ghost text) in every file, powered by the
-- same localhost model used for chat (Ollama qwen2.5-coder, fill-in-the-middle).
-- Toggle it any time via the keymaps in keys.lua or `:Minuet virtualtext toggle`.
require("minuet").setup({
  provider = "openai_fim_compatible",
  n_completions = 1,    -- one suggestion at a time (lighter on a local model)
  context_window = 512, -- start small; raise if your machine can handle it
  request_timeout = 5,  -- seconds; a local model's first token can be slow
  throttle = 1500,      -- ms between requests
  debounce = 600,       -- ms of idle typing before a request is sent
  provider_options = {
    openai_fim_compatible = {
      api_key = "TERM", -- Ollama ignores auth; any present env var name satisfies it
      name = "Ollama",
      end_point = "http://localhost:11434/v1/completions",
      model = "qwen2.5-coder:7b",
      optional = {
        max_tokens = 56,
        top_p = 0.9,
      },
    },
  },
  virtualtext = {
    -- Suggest as you type in every filetype.
    -- Set to {} for manual-only, then invoke with the `next` keymap below.
    auto_trigger_ft = { "*" },
    keymap = {
      accept = "<C-e>",      -- accept whole suggestion (kept from the old inline keybind)
      accept_line = "<A-a>", -- accept one line
      prev = "<A-[>",
      next = "<A-]>",        -- cycle, or manually request a suggestion
      dismiss = "<A-e>",
    },
  },
})
