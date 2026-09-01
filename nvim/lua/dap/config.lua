local dap = require("dap")
local dapui = require("dapui")
local virtual_text = require("nvim-dap-virtual-text")

dapui.setup()
virtual_text.setup()

dap.adapters.java = function(callback, config)
  local port = config.remote_debug_port or 5005
  local jdtls_path = config.jdtls_path or vim.fn.stdpath("data") .. "/jdtls/jdtls.jar"

  local handle = vim.uv.spawn("java", {
    args = {
      "-jar",
      jdtls_path,
      "-data",
      config.workspace_path or vim.fn.getcwd() .. "/.jdtls",
      "--jvm-arg",
      "-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,quiet=y,address=" .. port,
    },
    stdio = { nil, nil, nil },
  }, function(code, signal)
    if code ~= 0 then
      vim.notify("Failed to start jdtls: exit code " .. code, vim.log.levels.ERROR)
    end
  end)

  -- Poll the debug port until jdtls listens, then hand the server to DAP.
  -- Only call callback() once, and stop polling once the server is found.
  local attempts = 0
  local max_attempts = 50
  local done = false

  local function finish(cb_arg)
    if done then
      return
    end
    done = true
    callback(cb_arg)
  end

  local function try_connect()
    if done or attempts >= max_attempts then
      if not done then
        vim.notify("Timed out waiting for jdtls debugger on port " .. port, vim.log.levels.ERROR)
      end
      return
    end
    attempts = attempts + 1

    local socket = vim.uv.new_tcp()
    socket:connect("127.0.0.1", port, function(err)
      if not err then
        socket:close()
        finish({ type = "server", host = "localhost", port = port })
      else
        socket:close()
        if not done then
          vim.defer_fn(try_connect, 500)
        end
      end
    end)
  end

  try_connect()
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
