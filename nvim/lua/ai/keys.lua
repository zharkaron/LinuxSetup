-- lua/ai/keys.lua
-- Keeps the old <leader>c* chat muscle memory, now answered by the local model.

-- Open a fresh chat seeded with the whole current buffer and an instruction, then auto-submit.
local function ai_chat_about_buffer(instruction)
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local code = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  require("codecompanion").chat({
    messages = {
      {
        role = "user",
        content = instruction .. "\n\n```" .. ft .. "\n" .. code .. "\n```",
      },
    },
    auto_submit = true,
  })
end

-- Open / toggle the chat window (use \ca for this; avoid bare \c so \ca doesn't conflict)
vim.keymap.set({ "n", "v" }, "<leader>ca", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle AI chat" })

-- Fix / explain / review the current buffer, answered in the chat window
vim.keymap.set("n", "<leader>cf", function()
  ai_chat_about_buffer("Please fix any bugs or issues in the following code and explain the changes:")
end, { desc = "AI: fix current buffer" })

vim.keymap.set("n", "<leader>ce", function()
  ai_chat_about_buffer("Please explain what the following code does:")
end, { desc = "AI: explain current buffer" })

vim.keymap.set("n", "<leader>cr", function()
  ai_chat_about_buffer("Please review the following code for bugs, style, and possible improvements:")
end, { desc = "AI: review current buffer" })
