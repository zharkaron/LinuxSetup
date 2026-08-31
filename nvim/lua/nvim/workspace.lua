local M = {}

local function create_buf(lines, name)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_name(buf, name)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    return buf
end

local function find_new_wins(old_wins)
    local new_wins = {}
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        if not old_wins[w] then
            new_wins[#new_wins + 1] = w
        end
    end
    return new_wins
end

local function win_set()
    local set = {}
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        set[w] = true
    end
    return set
end

local function toggle_task()
    local buf = vim.api.nvim_get_current_buf()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)
    if #lines == 0 then return end

    local line = lines[1]
    if #line < 4 then return end

    local checkbox = line:sub(4, 4)
    local new_line

    if checkbox == " " then
        new_line = line:sub(1, 3) .. "x" .. line:sub(5)
    elseif checkbox == "x" then
        new_line = line:sub(1, 3) .. " " .. line:sub(5)
    else
        return
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { new_line })
    vim.bo[buf].modifiable = false

    if M.task_file then
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local f = io.open(M.task_file, "w")
        if f then
            for _, l in ipairs(lines) do
                f:write(l, "\n")
            end
            f:close()
        end
    end
end

local function ensure_task_file()
    local task_file = vim.fn.getcwd() .. "/task.md"
    if vim.fn.filereadable(task_file) == 0 then
        local f = io.open(task_file, "w")
        if f then
            f:write("# Tasks\n\n")
            f:write("<!-- Format: - [ ] Task description -->\n")
            f:close()
        end
    end
    return task_file
end

local function load_task_buffer()
    if not vim.api.nvim_buf_is_valid(M.task_buf) then return end
    local lines = {}
    local f = io.open(M.task_file, "r")
    if f then
        for line in f:lines() do
            lines[#lines + 1] = line
        end
        f:close()
    end
    local was_modifiable = vim.bo[M.task_buf].modifiable
    vim.bo[M.task_buf].modifiable = true
    vim.api.nvim_buf_set_lines(M.task_buf, 0, -1, false, lines)
    vim.bo[M.task_buf].modifiable = was_modifiable
end

local function refresh_panel1()
    if M.wins and M.wins[1] and vim.api.nvim_win_is_valid(M.wins[1]) then
        local cur_win = vim.api.nvim_get_current_win()
        if cur_win == M.wins[1] then
            local ok, err = pcall(load_task_buffer)
            if not ok then
                vim.notify("workspace: failed to refresh task.md: " .. tostring(err))
            end
        end
    end
end

local function save_panel_sizes()
    M.saved_sizes = {}
    for i, w in ipairs(M.wins) do
        if vim.api.nvim_win_is_valid(w) then
            M.saved_sizes[i] = {
                width = vim.api.nvim_win_get_width(w),
                height = vim.api.nvim_win_get_height(w),
            }
        end
    end
end

local function restore_panel_sizes()
    if not M.saved_sizes then return end
    for i, w in ipairs(M.wins) do
        if vim.api.nvim_win_is_valid(w) and M.saved_sizes[i] then
            pcall(vim.api.nvim_win_set_width, w, M.saved_sizes[i].width)
            pcall(vim.api.nvim_win_set_height, w, M.saved_sizes[i].height)
        end
    end
    M.saved_sizes = nil
end

local function is_nvimtree_buf(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    return name:match("NvimTree") ~= nil
end

M.locked = {}

local function enforce_lock()
    local win = vim.api.nvim_get_current_win()
    local entry = M.locked[win]
    if not entry then return end
    local buf = vim.api.nvim_win_get_buf(win)
    if buf == entry.buf then return end
    if entry.allow_tree and is_nvimtree_buf(buf) then return end
    if entry.allow_term and vim.bo[buf].buftype == "terminal" then return end
    vim.api.nvim_win_set_buf(win, entry.buf)
end

local function register_lock(win, buf, allow_tree, allow_term)
    M.locked[win] = { buf = buf, allow_tree = allow_tree, allow_term = allow_term }
end

local function get_editor_winid()
    local p3 = M.wins and M.wins[3]
    if p3 and vim.api.nvim_win_is_valid(p3) then
        return p3
    end
    for _, w in ipairs(M.wins or {}) do
        if vim.api.nvim_win_is_valid(w) then
            local buf = vim.api.nvim_win_get_buf(w)
            if not is_nvimtree_buf(buf) then
                return w
            end
        end
    end
    return vim.api.nvim_get_current_win()
end

local function set_open_target()
    local config = require("nvim-tree.config")
    if M.saved_picker == nil then
        M.saved_picker = {
            enable = config.g.actions.open_file.window_picker.enable,
            picker = config.g.actions.open_file.window_picker.picker,
            resize_window = config.g.actions.open_file.resize_window,
        }
    end
    config.g.actions.open_file.window_picker.enable = true
    config.g.actions.open_file.window_picker.picker = function()
        return get_editor_winid()
    end
    config.g.actions.open_file.resize_window = false
    require("nvim-tree.lib").target_winid = get_editor_winid()
end

local function restore_open_target()
    if M.saved_picker then
        local config = require("nvim-tree.config")
        config.g.actions.open_file.window_picker.enable = M.saved_picker.enable
        config.g.actions.open_file.window_picker.picker = M.saved_picker.picker
        config.g.actions.open_file.resize_window = M.saved_picker.resize_window
        M.saved_picker = nil
    end
end

local function toggle_nvimtree()
    if not M.wins or not M.wins[1] then return end
    local p1_win = M.wins[1]

    local tree_winnr = nil
    for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(w) then
            local buf = vim.api.nvim_win_get_buf(w)
            if is_nvimtree_buf(buf) then
                tree_winnr = w
                break
            end
        end
    end

    if tree_winnr then
        restore_open_target()
        local view = require("nvim-tree.view")
        view.abandon_current_window()
        vim.api.nvim_win_set_buf(tree_winnr, M.task_buf)
        vim.bo[M.task_buf].modifiable = false
        M.wins[1] = tree_winnr
        restore_panel_sizes()
        if vim.api.nvim_win_is_valid(tree_winnr) then
            vim.api.nvim_set_current_win(tree_winnr)
        end
    else
        save_panel_sizes()
        local cur_win = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(p1_win)
        require("nvim-tree.lib").open({ winid = p1_win })
        set_open_target()
        restore_panel_sizes()
        if vim.api.nvim_win_is_valid(cur_win) then
            vim.api.nvim_set_current_win(cur_win)
        end
    end
end

local term = {
    tabs = {}, -- each entry: { buf = bufnr, label = string }
    active = nil,
}
M.term = term

local function get_p4_win()
    local win = M.wins and M.wins[4]
    if win and vim.api.nvim_win_is_valid(win) then
        return win
    end
    return nil
end

local function get_sidebar_win()
    local win = M.term_sidebar_win
    if win and vim.api.nvim_win_is_valid(win) then
        return win
    end
    return nil
end

local function update_sidebar()
    local win = get_sidebar_win()
    if not win then
        return
    end
    local sbuf = M.term_sidebar_buf
    if not vim.api.nvim_buf_is_valid(sbuf) then
        return
    end

    local labels = {}
    for idx, tab in ipairs(term.tabs) do
        local mark = (idx == term.active) and "*" or " "
        labels[#labels + 1] = string.format("%s%d:%s", mark, idx, tab.short_label or tab.label or "")
    end
    labels[#labels + 1] = " +new"

    local line = table.concat(labels, "  ")
    local max = vim.api.nvim_win_get_width(win)
    if #line > max then
        line = line:sub(1, max - 1)
    end

    vim.bo[sbuf].modifiable = true
    vim.api.nvim_buf_set_lines(sbuf, 0, -1, false, { line })
    vim.bo[sbuf].modifiable = false
end

local function p4_show(buf)
    local win = get_p4_win()
    if not win then return end
    if not vim.api.nvim_buf_is_valid(buf) then return end
    vim.api.nvim_win_set_buf(win, buf)
    vim.bo[buf].modifiable = false
    vim.api.nvim_set_current_win(win)
    update_sidebar()
end

local function tab_label(dir, cmd)
    local plain_cmd = (cmd or ""):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    if plain_cmd == "" or plain_cmd == vim.o.shell then
        return "shell " .. (dir or vim.fn.getcwd())
    end
    return plain_cmd
end

local function tab_is_shell(cmd)
    local plain_cmd = (cmd or ""):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    return plain_cmd == "" or plain_cmd == vim.o.shell
end

local function tab_short_label(dir, cmd)
    local plain_cmd = (cmd or ""):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    if plain_cmd == "" or plain_cmd == vim.o.shell then
        return "shell"
    end
    local trimmed = plain_cmd
    local ispy = trimmed:find("[%w_%-%.]+%.py") ~= nil
    if ispy then
        local file = trimmed:match("([%w_%-%.]+%.py)")
        if file then
            return file
        end
    end
    if #trimmed > 14 then
        return trimmed:sub(1, 14) .. ".."
    end
    return trimmed
end

local function term_new_tab(dir, cmd)
    local win = get_p4_win()
    if not win then
        vim.notify("workspace: Panel 4 not available")
        return
    end
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_set_current_win(win)
    vim.fn.termopen(cmd or vim.o.shell, { cwd = dir or vim.fn.getcwd() })
    vim.bo[buf].swapfile = false
    vim.bo[buf].bufhidden = "hide"
    term.tabs[#term.tabs + 1] = {
        buf = buf,
        label = tab_label(dir, cmd),
        short_label = tab_short_label(dir, cmd),
        is_shell = tab_is_shell(cmd),
    }
    term.active = #term.tabs
    update_sidebar()
end

local function open_terminal_in_dir(dir)
    term_new_tab(dir, vim.o.shell)
end

local function open_fresh_terminal()
    open_terminal_in_dir(vim.fn.getcwd())
end

local function term_remove_tab(bufnr)
    local idx = nil
    for i, tab in ipairs(term.tabs) do
        if tab.buf == bufnr then
            idx = i
            break
        end
    end
    if not idx then
        return
    end
    table.remove(term.tabs, idx)
    if term.active == idx then
        term.active = nil
    elseif term.active and term.active > idx then
        term.active = term.active - 1
    end
    update_sidebar()
end

local function term_toggle()
    local win = get_p4_win()
    if not win then return end
    local current_buf = vim.api.nvim_win_get_buf(win)
    local showing_term = vim.bo[current_buf].buftype == "terminal"

    if #term.tabs == 0 then
        open_fresh_terminal()
        return
    end

    if not term.active or not term.tabs[term.active] or not vim.api.nvim_buf_is_valid(term.tabs[term.active].buf) then
        for idx, tab in ipairs(term.tabs) do
            if vim.api.nvim_buf_is_valid(tab.buf) then
                term.active = idx
                p4_show(tab.buf)
                return
            end
        end
        open_fresh_terminal()
        return
    end

    if showing_term then
        vim.api.nvim_set_current_win(win)
    else
        p4_show(term.tabs[term.active].buf)
    end
end

local function term_reindex()
    local valid = {}
    for _, tab in ipairs(term.tabs) do
        if vim.api.nvim_buf_is_valid(tab.buf) then
            valid[#valid + 1] = tab
        end
    end
    local active_tab = term.active and term.tabs[term.active] or nil
    term.tabs = valid
    term.active = nil
    for idx, tab in ipairs(term.tabs) do
        if tab == active_tab then
            term.active = idx
            break
        end
    end
    update_sidebar()
end

local function term_next()
    term_reindex()
    if #term.tabs == 0 then return end
    local n = term.active or 0
    n = n % #term.tabs + 1
    term.active = n
    p4_show(term.tabs[n].buf)
end

local function term_prev()
    term_reindex()
    if #term.tabs == 0 then return end
    local n = (term.active or 2) - 1
    if n < 1 then n = #term.tabs end
    term.active = n
    p4_show(term.tabs[n].buf)
end

local function term_goto(n)
    term_reindex()
    if not term.tabs[n] or not vim.api.nvim_buf_is_valid(term.tabs[n].buf) then
        vim.notify("workspace: terminal tab " .. n .. " not open")
        return
    end
    term.active = n
    p4_show(term.tabs[n].buf)
end

local function get_tree_node_path()
    local ok_api, api = pcall(require, "nvim-tree.api")
    if ok_api and api and api.tree then
        local ok, node = pcall(api.tree.get_node_under_cursor)
        if ok and node and node.absolute_path and node.type == "file" then
            return node.absolute_path
        end
    end
    local buffile = vim.fn.expand("%:p")
    if buffile ~= "" and vim.fn.filereadable(buffile) == 1 then
        return buffile
    end
    return nil
end

local function notify(msg)
    vim.notify("workspace: " .. msg)
end

local function have_tool(cmd)
    if vim.fn.executable(cmd) == 1 then
        return true
    end
    notify("'" .. cmd .. "' not found on PATH")
    return false
end

local function java_run_command(file)
    local maven_root = vim.fs.root(file, { "mvnw", "pom.xml" })
    if maven_root then
        if vim.fn.filereadable(maven_root .. "/mvnw") == 1 then
            return "./mvnw compile exec:java", maven_root
        end
        if not have_tool("mvn") then return nil end
        return "mvn compile exec:java", maven_root
    end

    local gradle_root = vim.fs.root(file, {
        "gradlew",
        "build.gradle",
        "build.gradle.kts",
        "settings.gradle",
        "settings.gradle.kts",
    })
    if gradle_root then
        if vim.fn.filereadable(gradle_root .. "/gradlew") == 1 then
            return "./gradlew run", gradle_root
        end
        if not have_tool("gradle") then return nil end
        return "gradle run", gradle_root
    end

    if not have_tool("javac") or not have_tool("java") then return nil end
    local dir = vim.fn.fnamemodify(file, ":h")
    local class = vim.fn.fnamemodify(file, ":t:r")
    local cmd = string.format(
        "javac -d %s %s && java -cp %s %s",
        vim.fn.shellescape(dir),
        vim.fn.shellescape(file),
        vim.fn.shellescape(dir),
        class
    )
    return cmd, dir
end

local function run_current_file()
    local file = get_tree_node_path()
    if not file then
        notify("No file selected or open to run.")
        return
    end
    if vim.fn.expand("%:p") == file and vim.bo.modified then
        vim.cmd("write")
    end
    local ext = vim.fn.fnamemodify(file, ":e")
    local shfile = vim.fn.shellescape(file)
    local cmd, run_dir
    if ext == "py" then
        cmd = "python3 -u " .. shfile
        run_dir = vim.fn.fnamemodify(file, ":h")
    elseif ext == "sh" or ext == "bash" then
        cmd = "bash " .. shfile
        run_dir = vim.fn.fnamemodify(file, ":h")
    elseif ext == "lua" then
        cmd = "lua " .. shfile
        run_dir = vim.fn.fnamemodify(file, ":h")
    elseif ext == "js" or ext == "mjs" then
        cmd = "node " .. shfile
        run_dir = vim.fn.fnamemodify(file, ":h")
    elseif ext == "java" then
        cmd, run_dir = java_run_command(file)
        if not cmd then return end
    else
        notify("No run command configured for *." .. ext .. " files.")
        return
    end
    term_new_tab(run_dir, cmd)
end

local function open_terminal_in_empty_dir()
    local path
    local ok_api, api = pcall(require, "nvim-tree.api")
    if ok_api and api and api.tree then
        local ok, node = pcall(api.tree.get_node_under_cursor)
        if ok and node then
            if node.type == "file" then
                path = vim.fn.fnamemodify(node.absolute_path, ":h")
            elseif node.type == "directory" then
                path = node.absolute_path
            end
        end
    end
    if not path or path == "" then
        path = vim.fn.getcwd()
    end
    open_terminal_in_dir(path)
end

local function open_terminal_in_buffer_dir()
    local file = vim.fn.expand("%:p")
    if file == "" then
        notify("No file open")
        return
    end
    local dir = vim.fn.fnamemodify(file, ":h")
    open_terminal_in_dir(dir)
end

M.keymaps = {}

local function set_keymap(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.desc = opts.desc or ""
    vim.keymap.set(mode, lhs, rhs, opts)
    local scope = opts.buffer and "buffer" or "global"
    M.keymaps[#M.keymaps + 1] = {
        mode = mode,
        lhs = lhs,
        scope = scope,
        buf = opts.buffer or nil,
    }
end

local function setup_panel4_terminal_keys()
    set_keymap({ "n", "t" }, "<F12>", term_toggle, { desc = "Toggle terminal in Panel 4" })
    set_keymap("n", "<leader>tt", open_terminal_in_empty_dir, { desc = "Open terminal in Panel 4 (node dir or cwd)" })
    set_keymap("n", "<leader>tr", run_current_file, { desc = "Run file in Panel 4 terminal" })
    set_keymap("n", "<leader>tb", open_terminal_in_buffer_dir, { desc = "Open terminal in buffer directory" })
    set_keymap("n", "<leader>t]", term_next, { desc = "Next terminal tab" })
    set_keymap("n", "<leader>t[", term_prev, { desc = "Previous terminal tab" })
    for i = 1, 9 do
        set_keymap("n", "<leader>t" .. i, function()
            term_goto(i)
        end, { desc = "Go to terminal tab " .. i })
    end
    set_keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
end

local function clear_workspace_keymaps()
    for _, km in ipairs(M.keymaps) do
        if km.scope == "global" then
            pcall(vim.keymap.del, km.mode, km.lhs)
        elseif km.buf and vim.api.nvim_buf_is_valid(km.buf) then
            pcall(vim.keymap.del, km.mode, km.lhs, { buffer = km.buf })
        end
    end
    M.keymaps = {}
end

local function clear_workspace_autocmds()
    if M.autocmd_group then
        pcall(vim.api.nvim_del_augroup_by_id, M.autocmd_group)
    end
    M.autocmd_group = nil
end

function M.open()
    if M.wins and M.wins[1] and vim.api.nvim_win_is_valid(M.wins[1]) then
        return
    end

    M.autocmd_group = vim.api.nvim_create_augroup("WorkspaceLayout", { clear = true })
    M.created_bufs = {}

    local function track_buf(buf)
        M.created_bufs[#M.created_bufs + 1] = buf
    end

    local total_width = vim.o.columns
    local total_height = vim.o.lines - vim.o.cmdheight

    local left_width = math.floor(total_width * 0.23)
    local top_height = math.floor(total_height * 0.60)
    local right_width = total_width - left_width
    local p2_width = math.floor(right_width * 2 / 3)

    local left_win = vim.api.nvim_get_current_win()

    local before = win_set()
    vim.cmd(left_width .. "vsplit")
    local new_wins = find_new_wins(before)
    local actual_left_win = new_wins[1]
    local right_win = left_win

    M.task_file = ensure_task_file()
    local lines = {}
    local f = io.open(M.task_file, "r")
    if f then
        for line in f:lines() do
            lines[#lines + 1] = line
        end
        f:close()
    end
    local left_buf = vim.api.nvim_create_buf(false, true)
    track_buf(left_buf)
    vim.api.nvim_buf_set_lines(left_buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_name(left_buf, "[task.md - Panel 1 view]")
    vim.api.nvim_win_set_buf(actual_left_win, left_buf)
    vim.bo[left_buf].modifiable = false
    vim.bo[left_buf].bufhidden = "hide"
    vim.bo[left_buf].swapfile = false
    vim.bo[left_buf].filetype = "markdown"
    vim.wo[actual_left_win].conceallevel = 2
    vim.wo[actual_left_win].concealcursor = "nc"
    vim.wo[actual_left_win].foldmethod = "manual"
    vim.wo[actual_left_win].foldenable = false
    set_keymap("n", "<Space>", toggle_task, { buffer = left_buf, silent = true })

    M.task_buf = left_buf
    M.p1_win = actual_left_win

    local right_buf = create_buf(
        { "", "  (placeholder)", "" },
        "[right]"
    )
    track_buf(right_buf)
    vim.api.nvim_win_set_buf(right_win, right_buf)
    vim.api.nvim_set_current_win(right_win)

    before = win_set()
    vim.cmd(top_height .. "split")
    new_wins = find_new_wins(before)
    local top_right_win = new_wins[1]
    local bottom_right_win = right_win

    local bottom_buf = create_buf(
        { "", "  Panel 4", "  (placeholder)", "" },
        "[panel-4]"
    )
    track_buf(bottom_buf)
    vim.bo[bottom_buf].bufhidden = "hide"
    vim.api.nvim_win_set_buf(bottom_right_win, bottom_buf)

    local p2_buf = create_buf(
        { "", "  Panel 2", "  (placeholder)", "" },
        "[panel-2]"
    )
    track_buf(p2_buf)
    vim.api.nvim_set_current_win(top_right_win)

    before = win_set()
    vim.cmd(p2_width .. "vsplit")
    new_wins = find_new_wins(before)
    local p3_win = new_wins[1]
    local p2_win = top_right_win

    vim.api.nvim_win_set_buf(p2_win, p2_buf)

    local p3_buf = create_buf(
        { "", "  Panel 3", "  (placeholder)", "" },
        "[panel-3]"
    )
    track_buf(p3_buf)
    vim.api.nvim_win_set_buf(p3_win, p3_buf)

    M.wins = {
        [1] = actual_left_win,
        [2] = p2_win,
        [3] = p3_win,
        [4] = bottom_right_win,
    }

    local tabbar_height = 1
    vim.api.nvim_set_current_win(bottom_right_win)
    before = win_set()
    vim.cmd("belowright 2split")
    new_wins = find_new_wins(before)
    local sidebar_win = new_wins[1]
    vim.api.nvim_win_set_height(sidebar_win, tabbar_height)
    vim.api.nvim_set_current_win(bottom_right_win)

    local sidebar_buf = vim.api.nvim_create_buf(false, true)
    track_buf(sidebar_buf)
    vim.api.nvim_buf_set_name(sidebar_buf, "[terminals]")
    vim.bo[sidebar_buf].modifiable = false
    vim.bo[sidebar_buf].bufhidden = "hide"
    vim.bo[sidebar_buf].swapfile = false
    vim.api.nvim_win_set_buf(sidebar_win, sidebar_buf)
    vim.wo[sidebar_win].winfixheight = true

    M.term_sidebar_win = sidebar_win
    M.term_sidebar_buf = sidebar_buf
    M.p4_height = vim.api.nvim_win_get_height(bottom_right_win)

    register_lock(actual_left_win, left_buf, true, false)
    register_lock(p2_win, p2_buf, false, false)
    register_lock(bottom_right_win, bottom_buf, false, true)
    register_lock(sidebar_win, sidebar_buf, false, false)

    set_keymap("n", "<leader>e", toggle_nvimtree, { silent = true })

    setup_panel4_terminal_keys()

    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        group = M.autocmd_group,
        callback = function()
            vim.schedule(enforce_lock)
        end,
    })

    vim.api.nvim_create_autocmd("WinEnter", {
        group = M.autocmd_group,
        callback = function()
            vim.schedule(refresh_panel1)
        end,
    })

    local function panel4_valid()
        local p4 = M.wins and M.wins[4]
        return p4 and p4 ~= 0 and vim.api.nvim_win_is_valid(p4)
    end

    -- Panel 4's main terminal window can be torn down externally (e.g. when a
    -- plugin reacts to a finished terminal during interaction). Repair it so the
    -- layout does not get permanently broken / the sidebar left orphaned.
    local function repair_panel4()
        if panel4_valid() then
            return
        end
        local sidebar_win = M.term_sidebar_win
        if not sidebar_win or not vim.api.nvim_win_is_valid(sidebar_win) then
            return
        end
        local ok, win = pcall(function()
            vim.api.nvim_set_current_win(sidebar_win)
            -- Split upward from the right-column-width sidebar so the new
            -- window lands back in P4's original slot: right column, directly
            -- above the 1-line sidebar and below the top-right panels.
            vim.cmd("aboveleft split")
            return vim.api.nvim_get_current_win()
        end)
        if not ok or not win or not vim.api.nvim_win_is_valid(win) then
            return
        end
        M.wins[4] = win
        vim.api.nvim_win_set_buf(win, bottom_buf)
        register_lock(win, bottom_buf, false, true)
        if M.p4_height and M.p4_height > 0 then
            pcall(vim.api.nvim_win_set_height, win, M.p4_height)
        end
        local tab = term.active and term.tabs[term.active]
        if not tab or not vim.api.nvim_buf_is_valid(tab.buf) then
            for _, t in ipairs(term.tabs) do
                if vim.api.nvim_buf_is_valid(t.buf) then
                    tab = t
                    break
                end
            end
        end
        if tab and vim.api.nvim_buf_is_valid(tab.buf) then
            p4_show(tab.buf)
        else
            update_sidebar()
        end
    end

    vim.api.nvim_create_autocmd("WinClosed", {
        group = M.autocmd_group,
        callback = function()
            vim.schedule(repair_panel4)
        end,
    })

    vim.api.nvim_create_autocmd("TermClose", {
        group = M.autocmd_group,
        callback = function(args)
            vim.schedule(function()
                local buf = args.buf
                local closed_idx = nil
                for i, tab in ipairs(term.tabs) do
                    if tab.buf == buf then
                        closed_idx = i
                        break
                    end
                end
                if not closed_idx then
                    return
                end
                local closed = term.tabs[closed_idx]

                -- Run tabs keep their output visible so it can be read.
                if not closed.is_shell then
                    return
                end

                -- Shell closed: drop it from the list. Never auto-create a new
                -- terminal here (an out-of-place one just scrambles the tabs),
                -- and never leave the panel empty if other tabs remain.
                term_remove_tab(buf)
                if #term.tabs == 0 then
                    -- Panel would be empty: seed a fresh shell at the natural slot.
                    open_fresh_terminal()
                    term.active = #term.tabs
                    p4_show(term.tabs[#term.tabs].buf)
                    return
                end
                if not get_p4_win() then
                    return
                end
                -- Focus the most recently-active tab that is still valid.
                local focus = term.tabs[term.active]
                if not focus or not vim.api.nvim_buf_is_valid(focus.buf) then
                    focus = nil
                    for _, tab in ipairs(term.tabs) do
                        if vim.api.nvim_buf_is_valid(tab.buf) then
                            focus = tab
                            break
                        end
                    end
                end
                if focus then
                    for i, tab in ipairs(term.tabs) do
                        if tab == focus then
                            term.active = i
                            p4_show(tab.buf)
                        end
                    end
                end
            end)
        end,
    })

    update_sidebar()
    open_fresh_terminal()

    vim.api.nvim_set_current_win(actual_left_win)
end

function M.close()
    if not M.wins then
        return
    end
    local had_terminal = #term.tabs > 0
    local wins = M.wins
    M.wins = nil

    local sidebar_win = M.term_sidebar_win
    local term_bufs = {}
    for _, tab in ipairs(term.tabs) do
        term_bufs[#term_bufs + 1] = tab.buf
    end
    term.tabs = {}
    term.active = nil
    M.term_sidebar_buf = nil
    M.term_sidebar_win = nil
    M.locked = {}

    local all_wins = vim.tbl_filter(function(w)
        return vim.api.nvim_win_is_valid(w)
    end, wins)
    if sidebar_win and vim.api.nvim_win_is_valid(sidebar_win) then
        all_wins[#all_wins + 1] = sidebar_win
    end

    for _, w in ipairs(all_wins) do
        if vim.api.nvim_win_is_valid(w) and #vim.api.nvim_list_wins() > 1 then
            pcall(vim.api.nvim_win_close, w, true)
        end
    end

    for _, buf in ipairs(term_bufs) do
        if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end

    for _, buf in ipairs(M.created_bufs or {}) do
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
            pcall(vim.api.nvim_buf_set_option, buf, "bufhidden", "wipe")
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end
    M.created_bufs = {}

    clear_workspace_keymaps()
    clear_workspace_autocmds()
    M.saved_picker = nil
    M.saved_sizes = nil

    if had_terminal then
        vim.notify("workspace: closed. Terminal tabs were not persisted.")
    end
end

function M.toggle()
    if M.wins and M.wins[1] and vim.api.nvim_win_is_valid(M.wins[1]) then
        M.close()
    else
        M.open()
    end
end

return M
