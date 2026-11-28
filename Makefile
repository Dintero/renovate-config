TARGETS := $(shell jq '.scripts | keys | @tsv' -r package.json)
PNPM ?= pnpm -s

export COREPACK_ENABLE_DOWNLOAD_PROMPT := 0

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@echo "Usage: make <target> [VAR=value ...]"
	@echo
	@echo "Targets:"
	@grep -hE '^[a-zA-Z0-9_-]+:.*## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*## "} {printf "  %-20s %s\n", $$1, $$2}'
	@$(foreach t,$(TARGETS),printf "  %-20s %s\n" "$(t)" "Run package.json script '$(t)'";)

.pnpm-init:
	corepack enable pnpm || command -v pnpm >/dev/null
	@touch $@

node_modules: .pnpm-init pnpm-lock.yaml pnpm-workspace.yaml package.json
	$(PNPM) install
	touch node_modules

.PHONY: dependencies
dependencies: node_modules ## Install dependencies

.PHONY: $(TARGETS)
$(TARGETS): node_modules
	$(PNPM) run $@ $(ARGS)
