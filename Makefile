SHELL := /usr/bin/env bash

SH_SCRIPTS := install.sh installer/packages.sh $(wildcard zsh/bin/*)
LUA_FILES := $(shell find nvim -name '*.lua' -type f)

EXPECTED_FILES := \
	install.sh \
	installer/packages.sh \
	kitty/kitty.conf \
	kitty/appearance/fonts.conf \
	kitty/appearance/tab.conf \
	kitty/appearance/artemis.conf \
	nvim/init.lua \
	nvim/lua/plugins.lua \
	nvim/lazy-lock.json \
	zsh/zshrc \
	zsh/config.zsh \
	zsh/plugins.txt \
	zsh/core/aliases.zsh \
	zsh/core/prompt.zsh \
	zsh/core/plugins.zsh \
	zsh/core/command-not-found.zsh \
	zsh/themes/colors.zsh \
	qutebrowser/config.py \
	qutebrowser/dark.css \
	neomutt/muttrc \
	neomutt/mailcap \
	neomutt/README.md \
	git-hooks/pre-push \
	README.md \
	docs/installer.md

.PHONY: all check lint-sh lint-lua check-config

all: check

check: lint-sh lint-lua check-config

lint-sh:
	@echo ":: Running ShellCheck on shell scripts ..."
	@shellcheck --shell=bash $(SH_SCRIPTS)
	@echo "   All shell scripts pass."

lint-lua:
	@echo ":: Running luacheck on Lua files ..."
	@if command -v luacheck &>/dev/null; then \
		luacheck $(LUA_FILES); \
	else \
		echo "   luacheck not found, skipping Lua lint."; \
	fi

check-config:
	@echo ":: Validating expected config files ..."
	@failed=0; \
	for f in $(EXPECTED_FILES); do \
		if [ ! -f "$$f" ]; then \
			echo "   MISSING: $$f"; \
			failed=1; \
		fi; \
	done; \
	if [ "$$failed" -eq 0 ]; then \
		echo "   All expected config files present."; \
	else \
		exit 1; \
	fi
