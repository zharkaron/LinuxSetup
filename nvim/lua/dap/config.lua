local dap = require("dap")
local dapui = require("dapui")
local virtual_text = require("nvim-dap-virtual-text")

dapui.setup()
virtual_text.setup()

dap.adapters.java = function(callback, config)
  local port = config.remote_debug_port or 5005
  local jdtls_path = config.jdtls_path or vim.fn.stdpath("data") .. "/jdtls/jdtls.jar"

  local handle = vim.loop.spawn("java", {
    args = {
      "-jar",
      jdtls_path,
      "-data",
      config.workspace_path or vim.fn.getcwd() .. "/.jdtls",
      "--jvm-arg",
      "-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,quiet=y,address=" .. port,
    },
    stdio = { nil, nil, nil },
    on_exit = function()
      callback(nil)
    end,
  }, function(code, signal)
    if code ~= 0 then
      vim.notify("Failed to start jdtls: exit code " .. code, vim.log.levels.ERROR)
    end
  end)

  local i = 0
  while i < 50 do
    vim.defer_fn(function()
      local socket = vim.loop.create_handle()
      local success = socket:connect(port, "127.0.0.1")
      if success then
        socket:close()
        callback({ type = "server", host = "localhost", port = port })
      end
    end, 100)
    i = i + 1
  end
end

dap.configurations.java = {
  {
    type = "java",
    name = "Debug (Attach to local)",
    request = "attach",
    host = "localhost",
    port = 5005,
  },
  {
    type = "java",
    name = "Debug (Attach to remote)",
    request = "attach",
    host = "127.0.0.1",
    port = 5005,
    cwd = "${workspaceFolder}",
  },
}

vim.keymap.set("n", "<F5>", function()
  if dap.session() then
    dap.continue()
  else
    dap.launch()
  end
end, { silent = true, noremap = true })
vim.keymap.set("n", "<F10>", dap.step_over, { silent = true, noremap = true })
vim.keymap.set("n", "<F11>", dap.step_into, { silent = true, noremap = true })
vim.keymap.set("n", "<S-F11>", dap.step_out, { silent = true, noremap = true })
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { silent = true, noremap = true })
vim.keymap.set("n", "<leader>B", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { silent = true, noremap = true })
vim.keymap.set("n", "<leader>rb", function()
  dap.run_to_cursor()
end, { silent = true, noremap = true })
vim.keymap.set("n", "<leader>c", dap.restart, { silent = true, noremap = true })
vim.keymap.set("n", "<leader>o", dap.terminate, { silent = true, noremap = true })
