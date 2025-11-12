-- lua/snippets/bash.lua
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node


-- Boilerplate snippet for new Bash files
ls.add_snippets("sh", {
    s("newfile", {  -- trigger word, can be anything
        t({"#!/bin/bash", -- the first line
        "# Author: Zharkaron",
        "# Description: "}),
        i(1, "Description here"),
        t({""}),
        i(0)
    }),
})

-- Bash snippets
ls.add_snippets("sh", {
  s("ifblock", {
    t("if "), i(1, "condition"), t("; then"),
    t({"", "  "}), i(2, "body"),
    t({"", "fi"}),
    i(0)
  }),
  s("forblock", {
    t("for "), i(1, "var"), t(" in "), i(2, "list"), t("; do"),
    t({"", "  "}), i(3, "body"),
    t({"", "done"}),
    i(0)
  }),
  s("whileblock", {
    t("while "), i(1, "condition"), t("; do"),
    t({"", "  "}), i(2, "body"),
    t({"", "done"}),
    i(0)
  }),
  s("caseblock", {
    t("case "), i(1, "word"), t(" in"),
    t({"", "  "}), i(2, "pattern"), t(") "),
    i(3, "body"), t({"", "    ;;"}),
    t({"", "esac"}),
    i(0)
  }),
})
