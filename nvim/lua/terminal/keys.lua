local api = require("nvim-tree.api")
local Terminal = require("toggleterm.terminal").Terminal
local fn = vim.fn
local notify = vim.notify

-- Persistent bottom terminal toggled with F12
local bottom_term = Terminal:new({
  direction = "horizontal",
  close_on_exit = true,
  hidden = true,
})
vim.keymap.set({ "n", "t" }, "<F12>", function()
  bottom_term:toggle()
end, { desc = "Toggle persistent terminal" })

-- Exit terminal mode with Esc (back to terminal-normal mode)
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

local function open_floating_terminal_in_dir(path)
  local term = Terminal:new({
    dir = path,
    direction = "float",
    close_on_exit = false,
    hidden = true,
  })
  term:toggle()
end

local function run_command_in_terminal(cmd, path)
  -- create a terminal that runs cmd in dir=path
  local term = Terminal:new({
    cmd = cmd,
    dir = path,
    direction = "float",
    close_on_exit = false,
    hidden = true,
  })
  term:toggle()
end

local function get_node_or_buffer_file()
  -- Try tree node under cursor first
  local ok, node = pcall(api.tree.get_node_under_cursor)
  if ok and node and node.absolute_path and node.type == "file" then
    return node.absolute_path
  end
  -- Fallback: current buffer file
  local buffile = fn.expand("%:p")
  if buffile ~= "" and fn.filereadable(buffile) == 1 then
    return buffile
  end
  return nil
end

-- Hints shown when a Java toolchain command is missing. Package names cover
-- the distros handled by installer/packages.sh (dnf / apt / pacman).
local java_install_hints = {
  java = "a JDK (java-latest-openjdk-devel / default-jdk / jdk-openjdk)",
  javac = "a JDK (java-latest-openjdk-devel / default-jdk / jdk-openjdk)",
  mvn = "maven",
  gradle = "gradle",
}

local function have_tool(cmd)
  if fn.executable(cmd) == 1 then
    return true
  end
  notify(
    string.format("'%s' not found. Install %s and ensure it is on PATH.", cmd, java_install_hints[cmd] or cmd),
    vim.log.levels.WARN
  )
  return false
end

-- Build a project-aware run command for a Java file.
-- Returns (cmd, dir) to run, or nil when a required tool is missing.
local function java_run_command(file)
  -- Maven: prefer the wrapper, fall back to a system mvn.
  local maven_root = vim.fs.root(file, { "mvnw", "pom.xml" })
  if maven_root then
    if fn.filereadable(maven_root .. "/mvnw") == 1 then
      return "./mvnw compile exec:java", maven_root
    end
    if not have_tool("mvn") then
      return nil
    end
    return "mvn compile exec:java", maven_root
  end

  -- Gradle: prefer the wrapper, fall back to a system gradle.
  local gradle_root = vim.fs.root(file, {
    "gradlew",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
  })
  if gradle_root then
    if fn.filereadable(gradle_root .. "/gradlew") == 1 then
      return "./gradlew run", gradle_root
    end
    if not have_tool("gradle") then
      return nil
    end
    return "gradle run", gradle_root
  end

  -- Single-file fallback: compile next to the source, then run it.
  if not have_tool("javac") or not have_tool("java") then
    return nil
  end
  local dir = fn.fnamemodify(file, ":h")
  local class = fn.fnamemodify(file, ":t:r")
  local cmd = string.format(
    "javac -d %s %s && java -cp %s %s",
    fn.shellescape(dir),
    fn.shellescape(file),
    fn.shellescape(dir),
    class
  )
  return cmd, dir
end

-- Open terminal in hovered directory or file (or cwd)
vim.keymap.set("n", "<leader>tt", function()
  local ok, node = pcall(api.tree.get_node_under_cursor)
  local path
  if ok and node then
    if node.type == "file" then
      path = fn.fnamemodify(node.absolute_path, ":h")
    elseif node.type == "directory" then
      path = node.absolute_path
    end
  end
  if not path or path == "" then
    path = fn.getcwd()
  end
  open_floating_terminal_in_dir(path)
end, { desc = "Open terminal in node directory (or cwd)" })

-- Run hovered file (fallback to current buffer) in terminal
vim.keymap.set("n", "<leader>tr", function()
  local file = get_node_or_buffer_file()
  if not file then
    notify("No file selected or open to run.", vim.log.levels.WARN)
    return
  end

  -- Save the buffer first so compilers/interpreters see the latest changes.
  if fn.expand("%:p") == file and vim.bo.modified then
    vim.cmd("write")
  end

  local ext = fn.fnamemodify(file, ":e")
  local shfile = fn.shellescape(file)
  local cmd
  local run_dir = fn.fnamemodify(file, ":h")

  if ext == "py" then
    -- -u for unbuffered output
    cmd = "python3 -u " .. shfile
  elseif ext == "sh" or ext == "bash" then
    cmd = "bash " .. shfile
  elseif ext == "lua" then
    cmd = "lua " .. shfile
  elseif ext == "js" or ext == "mjs" then
    cmd = "node " .. shfile
  elseif ext == "java" then
    cmd, run_dir = java_run_command(file)
    if not cmd then
      return
    end
  else
    notify("No run command configured for *." .. ext .. " files.", vim.log.levels.WARN)
    return
  end

  run_command_in_terminal(cmd, run_dir)
end, { desc = "Run hovered/open file in floating terminal" })

-- Open terminal in current buffer’s directory
vim.keymap.set("n", "<leader>tb", function()
  local file = fn.expand("%:p")
  if file == "" then
    notify("No file open", vim.log.levels.WARN)
    return
  end
  local dir = fn.fnamemodify(file, ":h")
  open_floating_terminal_in_dir(dir)
end, { desc = "Open terminal in buffer directory" })
