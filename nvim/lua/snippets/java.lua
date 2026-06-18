local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- New Java file boilerplate with filename as class name
ls.add_snippets("java", {
    s("newfile", {
        f(function()
            return "public class " .. vim.fn.expand("%:t:r")
        end, {}),
        t({" {", "", "    public static void main(String[] args) {", "        "}), i(1, ""),
        t({"", "    }", "}", ""}),
        i(0),
    }),
})
