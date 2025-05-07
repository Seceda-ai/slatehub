# Load variables from .env if it exists
ifneq (,$(wildcard .env))
  include .env
  export
endif

start-db:
	surreal start --user $(SURREAL_USER) --pass $(SURREAL_PASS) file:$(DB_PATH)

init-db:
	surreal import --conn $(SURREAL_URL) --user $(SURREAL_USER) --pass $(SURREAL_PASS) $(SCHEMA_FILE)

start-frontend:
	cd $(FRONTEND_DIR) && npm run dev

dev:
	$(MAKE) start-db & sleep 2 && $(MAKE) init-db && $(MAKE) start-frontend
