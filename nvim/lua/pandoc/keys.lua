local fn = vim.fn
local notify = vim.notify

local function pandoc_to(format, filepath)
  local outfile = fn.fnamemodify(filepath, ":r") .. "." .. format
  local cmd = string.format("pandoc %s -o %s", fn.shellescape(filepath), fn.shellescape(outfile))
  local result = vim.fn.system(cmd)

  if vim.v.shell_error == 0 then
    notify(string.format("Exported to %s", outfile), vim.log.levels.INFO)
  else
    notify(string.format("Pandoc failed: %s", result), vim.log.levels.ERROR)
  end
end

local function get_filepath()
  local filepath = fn.expand("%:p")
  if filepath == "" then
    notify("No file open", vim.log.levels.WARN)
    return nil
  end
  return filepath
end

vim.api.nvim_create_user_command("PandocTo", function(opts)
  local filepath = get_filepath()
  if not filepath then return end
  pandoc_to(opts.args, filepath)
end, { nargs = 1, complete = function()
  return { "pdf", "docx", "html", "md", "epub", "odt", "rst", "latex", "txt" }
end, desc = "Convert current file to format via pandoc" })

vim.keymap.set("n", "<leader>pd", function()
  local filepath = get_filepath()
  if filepath then pandoc_to("docx", filepath) end
end, { desc = "Convert to DOCX" })

vim.keymap.set("n", "<leader>pp", function()
  local filepath = get_filepath()
  if filepath then pandoc_to("pdf", filepath) end
end, { desc = "Convert to PDF" })

vim.keymap.set("n", "<leader>ph", function()
  local filepath = get_filepath()
  if filepath then pandoc_to("html", filepath) end
end, { desc = "Convert to HTML" })

vim.keymap.set("n", "<leader>pm", function()
  local filepath = get_filepath()
  if filepath then pandoc_to("md", filepath) end
end, { desc = "Convert to Markdown" })
