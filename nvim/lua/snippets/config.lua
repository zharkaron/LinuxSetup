local ls = require("luasnip")
require("snippets.bash")
require("snippets.html")
require("snippets.python")
require("snippets.java")

-- Keymaps for expanding/jumping snippets safely
vim.keymap.set({"i", "s"}, "<Tab>", function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    else
        -- Fallback: insert a real Tab character
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", true)
    end
end, {silent = true})

vim.keymap.set({"i", "s"}, "<S-Tab>", function()
    if ls.jumpable(-1) then
        ls.jump(-1)
    else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, true, true), "n", true)
    end
end, {silent = true})

local function find_snippet(ft, name)
    local snippets = require("luasnip").get_snippets(ft)
    if snippets then
        for _, snip in ipairs(snippets) do
            if snip.name == name then
                return snip
            end
        end
    end
    return nil
end

local function expand_newfile_snippet(ft)
    local ls = require("luasnip")
    local snip = find_snippet(ft, "newfile")
    if snip then
        vim.schedule(function()
            ls.snip_expand(snip)
        end)
    end
end

local function try_expand_on_filetype(ft, pattern)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = pattern,
        callback = function()
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            if #lines <= 1 and lines[1] == "" then
                expand_newfile_snippet(ft)
            end
        end,
    })
end

-- BufNewFile: works when opening a non-existent file directly (e.g. :e newfile.py)
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*.html",
    callback = function() expand_newfile_snippet("html") end,
})
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*.sh",
    callback = function() expand_newfile_snippet("sh") end,
})
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*.py",
    callback = function() expand_newfile_snippet("python") end,
})
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*.java",
    callback = function() expand_newfile_snippet("java") end,
})

-- FileType fallback: works when nvim-tree creates the file on disk first
-- (file exists, so BufNewFile doesn't fire, but FileType still does)
try_expand_on_filetype("html", "html")
try_expand_on_filetype("sh", "sh")
try_expand_on_filetype("python", "python")
try_expand_on_filetype("java", "java")
