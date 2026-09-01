local M = {}

-- Auto-inject the currently-focused file into the workspace AI chat on each
-- submit, so the model can see the file the user is working on without having
-- to type #buffer. The chat is embedded in the workspace, so "current file"
-- means the last real editable buffer that had focus (e.g. the file open in
-- Panel 3, or a file edited before \ww was pressed), never the chat panel
-- itself.

-- Tracked by workspace.lua via WinEnter/BufEnter: the most recent real file
-- buffer that received focus.
M.current_file = nil

local function get_format_buffer_for_llm()
    local ok, helpers = pcall(require, "codecompanion.interactions.chat.helpers")
    if ok and helpers and type(helpers.format_buffer_for_llm) == "function" then
        return helpers.format_buffer_for_llm
    end
    return nil
end

---Resolve the file buffer the user is currently working on.
---@param workspace table The workspace module (to read editor_buf/p3_buf).
local function current_editor_buf(workspace)
    -- A real file buffer holding focus right now wins.
    local cur = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(cur) then
        local bt = vim.bo[cur].buftype
        local name = vim.api.nvim_buf_get_name(cur)
        if bt == "" and name ~= "" and name:sub(1, 1) == "/" then
            return cur
        end
    end

    -- Otherwise fall back to the most recently focused file buffer.
    if M.current_file and vim.api.nvim_buf_is_valid(M.current_file) then
        return M.current_file
    end

    -- Last resort: the workspace's kept editor buffer.
    local editor = workspace and (workspace.editor_buf or workspace.p3_buf)
    if editor and vim.api.nvim_buf_is_valid(editor)
        and vim.bo[editor].buftype == "" then
        return editor
    end

    return nil
end

---Inject the current file's contents into the chat right before submission.
---@param chat table A CodeCompanion chat.
---@param workspace table The workspace module.
local function inject_current_file(chat, workspace)
    local bufnr = current_editor_buf(workspace)
    if not bufnr then
        return
    end
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == "" then
        return
    end

    local format_buffer = get_format_buffer_for_llm()
    if not format_buffer then
        return
    end

    local ok, content, id = pcall(format_buffer, bufnr, path, {
        message = "User's current file (auto-attached)",
    })
    if not ok or not content or not id then
        return
    end

    -- Re-attach only when the attached file's content actually differs from the
    -- last time. This keeps regenerations from duplicating identical context
    -- while still pushing fresh content after the user edits the file.
    local prev = chat._auto_context_prev
    if prev and prev.id == id and prev.content == content then
        return
    end

    chat:add_context({
        role = "user",
        content = content,
    }, "codecompanion.interactions.shared.editor_context.buffer", id, {
        bufnr = bufnr,
        path = path,
        tag = "buffer",
    })

    chat._auto_context_prev = { id = id, content = content }
end

---Register auto-context injection on a chat. Idempotent: each chat gets the
---callback attached at most once (tracked via a field on the chat object).
---@param chat table A CodeCompanion chat.
---@param workspace table The workspace module.
function M.attach(chat, workspace)
    if not chat or not workspace then
        return
    end
    if chat._auto_context_attached then
        return
    end
    chat._auto_context_attached = true

    if type(chat.add_callback) ~= "function" then
        return
    end
    chat:add_callback("on_before_submit", function(c)
        inject_current_file(c, workspace)
    end)
end

return M
