.PHONY: help install dev lint test clean venv-install

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install:  ## Install the package (auto-detects root, uv, pipx, or pip)
	@if [ "$$(id -u)" = "0" ]; then \
		echo "Running as root, installing system-wide..."; \
		pip install .; \
	elif command -v uv >/dev/null 2>&1; then \
		echo "Installing with uv..."; \
		uv tool install .; \
	elif command -v pipx >/dev/null 2>&1; then \
		echo "Installing with pipx..."; \
		pipx install .; \
	else \
		echo "Tip: Install uv or pipx for isolated installs (pacman -S uv, apt install pipx, brew install uv)"; \
		echo "Falling back to pip install --user ..."; \
		PIP_BREAK_SYSTEM_PACKAGES=1 pip install --user .; \
	fi

dev:  ## Install with dev dependencies (editable)
	PIP_BREAK_SYSTEM_PACKAGES=1 pip install -e ".[dev]"

lint:  ## Run ruff linter
	python -m ruff check calendar_cli/ tests/

test:  ## Run tests
	python -m pytest

clean:  ## Remove build artifacts
	rm -rf dist/ build/ *.egg-info calendar_cli/_version.py .pytest_cache .ruff_cache
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true

VENV := .venv
WRAPPER_DIR := $(HOME)/bin

venv-install:  ## Install into a venv and create a ~/bin/calendar-cli wrapper
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install .
	mkdir -p $(WRAPPER_DIR)
	@printf '#!/bin/sh\nexec %s/bin/calendar-cli "$$@"\n' "$$(pwd)/$(VENV)" > $(WRAPPER_DIR)/calendar-cli
	chmod +x $(WRAPPER_DIR)/calendar-cli
	@echo "Installed: $(WRAPPER_DIR)/calendar-cli -> $$(pwd)/$(VENV)/bin/calendar-cli"
