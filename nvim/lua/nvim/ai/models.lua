local M = {}

local cc_url = require("nvim.ai.host").ollama_base(11434)

local function list_models()
    local ok, res = pcall(vim.system, { "curl", "-sS", cc_url .. "/api/tags" }, { text = true })
    if not ok or res.code ~= 0 then
        return nil
    end
    local ok_json, data = pcall(vim.json.decode, res.stdout)
    if not ok_json or not data or not data.models then
        return nil
    end
    local names = {}
    for _, m in ipairs(data.models) do
        if m.name then
            names[#names + 1] = m.name
        end
    end
    table.sort(names)
    return names
end

---Prompt the user to switch the model used by the given chat.
---@param chat table A CodeCompanion chat (Chat:buffers() style object).
function M.prompt_switch_model(chat)
    local models = list_models()
    if not models or #models == 0 then
        vim.notify("models: no models found on Ollama (" .. cc_url .. ")", vim.log.levels.ERROR)
        return
    end

    local current = chat.adapter
        and chat.adapter.schema
        and chat.adapter.schema.model
        and chat.adapter.schema.model.default

    vim.ui.select(models, {
        prompt = "Select AI model" .. (current and (" (current: " .. current .. ")") or ""),
        format_item = function(item)
            return item == current and (item .. " (current)") or item
        end,
    }, function(choice)
        if not choice then
            return
        end
        local ok, err = pcall(function()
            if type(chat.change_model) == "function" then
                chat:change_model({ model = choice })
            else
                error("CodeCompanion chat:change_model is unavailable")
            end
        end)
        if ok then
            vim.notify("AI model changed to: " .. choice, vim.log.levels.INFO)
        else
            vim.notify("models: failed to switch: " .. tostring(err), vim.log.levels.ERROR)
        end
    end)
end

return M
