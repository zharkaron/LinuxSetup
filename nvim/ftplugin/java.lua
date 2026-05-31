local api = vim.api
local fn = vim.fn

local function compile_and_run()
  local bufnr = api.nvim_get_current_buf()
  local filepath = api.nvim_buf_get_name(bufnr)
  local filename = fn.fnamemodify(filepath, ":t:r")
  local filedir = fn.fnamemodify(filepath, ":h")

  local compile_cmd = string.format("javac -d %s %s", filedir, fn.fnameescape(filepath))
  local run_cmd = string.format("java -cp %s %s", filedir, filename)

  local job_opts = {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.cmd("terminal " .. run_cmd)
      else
        vim.notify("Compilation failed with exit code " .. exit_code, vim.log.levels.ERROR)
      end
    end,
  }

  vim.cmd("terminal " .. compile_cmd)

  local job_id = fn.jobstart(compile_cmd, job_opts)
  if job_id <= 0 then
    vim.notify("Failed to start compilation job", vim.log.levels.ERROR)
  end
end

api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    vim.keymap.set("n", "<F5>", compile_and_run, {
      buffer = true,
      desc = "Compile and run Java file",
    })
  end,
})
