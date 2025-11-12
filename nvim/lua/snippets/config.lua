local ls = require("luasnip")
local from_lua = require("luasnip.loaders.from_lua")

-- Automatically load all snippets from the `snippets` folder
from_lua.lazy_load({ paths = vim.fn.stdpath("config") .. "/lua/snippets" })

-- Keymaps
vim.keymap.set({"i", "s"}, "<Tab>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", true)
  end
end, {silent = true, expr = false})

vim.keymap.set({"i", "s"}, "<S-Tab>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, true, true), "n", true)
  end
end, {silent = true, expr = false})

-- Optional: auto-expand template snippet for new files
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = {"*.html", "*.sh", "*.py"},
  callback = function(event)
    local ft = vim.bo[event.buf].filetype
    local snippets = ls.get_snippets(ft)
    if snippets and #snippets > 0 then
      ls.snip_expand(snippets[1])
    end
  end,
})

