-- lua/snippets/bash.lua
local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

-- Helper to register the same snippets for both 'sh' and 'bash'
local filetypes = { "sh", "bash" }

local bash_snips = {
  -- Shebang boilerplate
  s("newfile", {
    t({"#!/usr/bin/env bash", "# Author: Zharkaron", "# Description: "}),
    i(1, "Description here"),
    i(0),
  }),

  -- if ... then ... fi
  s("if", {
    t("if "), i(1, "condition"), t("; then"),
    t({"", "  "}), i(2, "body"),
    t({"", "fi"}),
    i(0),
  }),

  -- for var in list; do ... done
  s("for", {
    t("for "), i(1, "var"), t(" in "), i(2, "list"), t("; do"),
    t({"", "  "}), i(3, "body"),
    t({"", "done"}),
    i(0),
  }),

  -- while ... do ... done
  s("while", {
    t("while "), i(1, "condition"), t("; do"),
    t({"", "  "}), i(2, "body"),
    t({"", "done"}),
    i(0),
  }),

  -- case ... in ... esac
  s("case", {
    t("case "), i(1, "word"), t(" in"),
    t({"", "  "}), i(2, "pattern"), t(")"),
    t({"", "  "}), i(3, "body"),
    t({"", "    ;;", "esac"}),
    i(0),
  }),
}

ls.add_snippets(filetypes, bash_snips)
