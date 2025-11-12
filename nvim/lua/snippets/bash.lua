local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  -- Template for new Bash file
  s("newfile", {
    t({"#!/usr/bin/env bash", "# Author: Zharkaron", "# Description: "}),
    i(1, "Description here"),
    t({"", ""}),
    i(0),
  }),

  -- if ... then ... fi
  s("if", {
    t("if [ "), i(1, "condition"), t(" ]; then"),
    t({"", "\t"}), i(2, "commands"),
    t({"", "fi"}),
    i(0),
  }),

  -- for ... in ... do ... done
  s("for", {
    t("for "), i(1, "var"), t(" in "), i(2, "list"), t("; do"),
    t({"", "\t"}), i(3, "commands"),
    t({"", "done"}),
    i(0),
  }),

  -- while ... do ... done
  s("while", {
    t("while [ "), i(1, "condition"), t(" ]; do"),
    t({"", "\t"}), i(2, "commands"),
    t({"", "done"}),
    i(0),
  }),
}
