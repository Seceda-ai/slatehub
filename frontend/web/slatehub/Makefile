# Frontend development tasks
.PHONY: install dev build preview check clean

# Load environment variables if present
ifneq (,$(wildcard .env))
	include .env
	export
endif

# Default NPM command (can be overridden with pnpm if needed)
NPM_CMD := npm

install:
	@echo "→ Installing dependencies…"
	$(NPM_CMD) install

dev:
	@echo "→ Starting development server…"
	$(NPM_CMD) run dev

build:
	@echo "→ Building for production…"
	$(NPM_CMD) run build

preview:
	@echo "→ Running production preview…"
	$(NPM_CMD) run preview

check:
	@echo "→ Running type checking…"
	$(NPM_CMD) run check

clean:
	@echo "→ Cleaning build artifacts…"
	rm -rf build .svelte-kit node_modules/.vite

# Create development env from example
init-env:
	@if [ ! -f .env ]; then \
		echo "→ Creating .env from template…"; \
		cp .env-example .env; \
		echo "VITE_SURREAL_URL=http://localhost:8000/rpc" >> .env; \
		echo "VITE_SURREAL_NS=$${SURREAL_NS:-seceda}" >> .env; \
		echo "VITE_SURREAL_DB=$${SURREAL_DB:-core}" >> .env; \
	else \
		echo "→ .env already exists"; \
	fi

# Full development setup
setup: init-env install dev

# Clean and rebuild dev environment
rebuild: clean init-env install dev