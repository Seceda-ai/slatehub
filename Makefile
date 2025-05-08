# ──────────────────────────────────────────────────────────────────────────────
# Load .env vars if present
# ──────────────────────────────────────────────────────────────────────────────
ifneq (,$(wildcard .env))
	include .env
	export
endif

# ──────────────────────────────────────────────────────────────────────────────
# Variables
# ──────────────────────────────────────────────────────────────────────────────
COMPOSE       := docker-compose
DB_SERVICE    := db
DB_URL        := http://127.0.0.1:8000
SCHEMA_FILE   := backend/db/schema.surql
FRONTEND_DIR  := $(FRONTEND_DIR)

.PHONY: start-db stop-db init-db start-frontend dev \
        seed-admin-person seed-admin-org erase-db reset-db

start-db:
	@echo "→ Starting SurrealDB container…"
	$(COMPOSE) up -d $(DB_SERVICE)

stop-db:
	@echo "→ Stopping SurrealDB container…"
	$(COMPOSE) stop $(DB_SERVICE)

init-db: start-db
	@echo "→ Waiting for DB to become ready…"
	@sleep 3
	@echo "→ Importing schema…"
	surreal import \
		--conn $(DB_URL) \
		--user $(SURREAL_USER) --pass $(SURREAL_PASS) \
		--namespace $(SURREAL_NS) --database $(SURREAL_DB) \
		$(SCHEMA_FILE)

start-frontend:
	@echo "→ Launching Svelte frontend…"
	cd $(FRONTEND_DIR) && npm run dev

dev: init-db start-frontend

seed-admin-person:
	@echo "→ Signing up admin person via record-access…"
	@curl -s -X POST $(DB_URL)/signup \
		-H "Content-Type: application/json" \
		-d '{"ns":"'"$(SURREAL_NS)"'","db":"'"$(SURREAL_DB)"'","ac":"user_access","username":"'"$(ADMIN_USERNAME)"'","password":"'"$(ADMIN_PASSWORD)"'","email":"'"$(ADMIN_EMAIL)"'"}'

seed-admin-org:
	@echo "→ Creating admin organization & membership…"
	@curl -s -X POST $(DB_URL)/sql \
		-H "Content-Type: application/json" \
		-H "Accept: application/json" \
		-u $(SURREAL_USER):$(SURREAL_PASS) \
		-d '{\
"ns":"'"$(SURREAL_NS)"'",\
"db":"'"$(SURREAL_DB)"'",\
"statements":[{"sql":"LET $$u = (SELECT id FROM person WHERE username = \"'"$(ADMIN_USERNAME)"'\" )[0].id; CREATE organization CONTENT { name: \"'"$(ADMIN_ORG_NAME)"'\", slug: \"'"$(ADMIN_ORG_NAME)"'\", created_at: time::now() }; LET $$o = (SELECT id FROM organization WHERE slug = \"'"$(ADMIN_ORG_NAME)"'\" )[0].id; CREATE member_of_org CONTENT { in: $$u, out: $$o, role: \"owner\", joined_at: time::now() };"}]\
}'

erase-db:
	@echo "→ Stopping and erasing DB data…"
	$(MAKE) stop-db
	@rm -rf backend/db/data

reset-db: erase-db
	@$(MAKE) dev
