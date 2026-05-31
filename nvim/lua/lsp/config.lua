local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if has_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities()
end

local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts)
end

-- Use a simple LSP config that avoids the deprecated module
local root_dir = vim.loop.cwd()
local buf = vim.api.nvim_create_buf(false, true)

local config = {
  name = "jdtls",
  cmd = {
    "python3",
    vim.fn.stdpath("data") .. "/jdtls/bin/jdtls.py",
    "-data",
    vim.fn.getcwd() .. "/.jdtls",
  },
  filetypes = { "java" },
  root_dir = root_dir,
  settings = {},
  capabilities = capabilities,
  on_attach = on_attach,
}

-- Start the LSP client using the new API
vim.lsp.start(config)
