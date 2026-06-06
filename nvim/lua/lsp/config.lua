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

local function find_root(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(filename, {
    "mvnw",
    "gradlew",
    "settings.gradle",
    "settings.gradle.kts",
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    ".git",
  })

  return root or vim.fn.getcwd()
end

local missing_jdtls_warned = false

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    if vim.fn.executable("jdtls") ~= 1 then
      if not missing_jdtls_warned then
        vim.notify("Java LSP disabled: install jdtls and make sure it is on PATH.", vim.log.levels.WARN)
        missing_jdtls_warned = true
      end
      return
    end

    local root_dir = find_root(args.buf)
    local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
    local config_dir = vim.fn.stdpath("cache") .. "/jdtls/config"

    vim.lsp.start({
      name = "jdtls",
      cmd = { "jdtls", "-configuration", config_dir, "-data", workspace_dir },
      root_dir = root_dir,
      capabilities = capabilities,
      on_attach = on_attach,
    }, { bufnr = args.buf })
  end,
})
