-- lua/treesitter/compat.lua
-- Compatibility shim: Neovim 0.12 + nvim-treesitter `master` branch.
--
-- Neovim 0.12 removed the legacy single-node match format for treesitter query
-- predicates/directives: a capture id now always maps to a *list* of nodes
-- (TSNode[]). The `master` branch of nvim-treesitter still passes `match[id]`
-- straight into vim.treesitter.get_node_text(), which then calls `node:range()`
-- on a table and errors:
--   attempt to call method 'range' (a nil value)
-- This breaks markdown code-block injection parsing, e.g. render-markdown.nvim
-- and the codecompanion chat buffer (both full of fenced code blocks).
--
-- We wrap get_node_text so a node *list* is unwrapped to a single node. Real
-- TSNodes are userdata, so ordinary calls pass through untouched.
local ts = vim.treesitter
local orig_get_node_text = ts.get_node_text

---@diagnostic disable-next-line: duplicate-set-field
ts.get_node_text = function(node, source, opts)
  if type(node) == "table" and node.range == nil and node[1] ~= nil then
    node = node[#node]
  end
  return orig_get_node_text(node, source, opts)
end
