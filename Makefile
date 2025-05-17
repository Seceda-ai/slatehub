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
ROLES_SCHEMA_FILE := backend/db/seed_roles.surql
MIGRATE_DEPARTMENTS_FILE := backend/db/migrate_departments.surql
FRONTEND_DIR  := $(FRONTEND_DIR)
DB_DATA_DIR   := backend/db/data
DB_FILES_DIR  := backend/db/files

.PHONY: start-db stop-db init-db start-frontend dev \
        seed-admin-person seed-admin-org erase-db reset-db seed-static migrate-departments

start-db:
	@echo "→ Starting SurrealDB container…"
	@mkdir -p $(DB_DATA_DIR) $(DB_FILES_DIR)
	$(COMPOSE) up -d $(DB_SERVICE)

stop-db:
	@echo "→ Stopping SurrealDB container…"
	$(COMPOSE) stop $(DB_SERVICE)

init-db: start-db
	@echo "→ Waiting for DB to become ready…"
	@sleep 3
	@echo "→ Importing schema…"
	@surreal import \
		--conn $(DB_URL) \
		--user $(SURREAL_USER) --pass $(SURREAL_PASS) \
		--namespace $(SURREAL_NS) --database $(SURREAL_DB) \
		$(SCHEMA_FILE) 2>&1 || { \
			echo "⚠️ Schema import encountered errors:"; \
			surreal import \
				--conn $(DB_URL) \
				--user $(SURREAL_USER) --pass $(SURREAL_PASS) \
				--namespace $(SURREAL_NS) --database $(SURREAL_DB) \
				$(SCHEMA_FILE) 2>&1; \
			echo "This may be OK if you've run this before and the schema already exists."; \
		}

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
"statements":[{"sql":"BEGIN TRANSACTION; LET $$person = (SELECT id FROM person WHERE username = \"'"$(ADMIN_USERNAME)"'\" )[0].id; IF $$person == NONE THEN THROW \"Admin user not found\"; END; LET $$org = CREATE organization CONTENT { name: \"'"$(ADMIN_ORG_NAME)"'\", slug: \"'"$(ADMIN_ORG_NAME)"'\", created_at: time::now() }; CREATE member_of_org CONTENT { in: $$person, out: $$org.id, role: \"owner\", joined_at: time::now() }; COMMIT TRANSACTION;"}]\
}'

erase-db:
	@echo "→ Stopping and erasing DB data and storage…"
	$(MAKE) stop-db
	@rm -rf $(DB_DATA_DIR)/*.db
	@rm -rf $(DB_FILES_DIR)/*
	@mkdir -p $(DB_DATA_DIR)
	@mkdir -p $(DB_FILES_DIR)

reset-db: erase-db
	@$(MAKE) dev

seed-static: start-db
	@echo "→ Importing production roles schema…"
	@surreal import \
		--conn $(DB_URL) \
		--user $(SURREAL_USER) --pass $(SURREAL_PASS) \
		--namespace $(SURREAL_NS) --database $(SURREAL_DB) \
		$(ROLES_SCHEMA_FILE) 2>&1 || { \
			echo "⚠️ Roles schema import encountered errors:"; \
			surreal import \
				--conn $(DB_URL) \
				--user $(SURREAL_USER) --pass $(SURREAL_PASS) \
				--namespace $(SURREAL_NS) --database $(SURREAL_DB) \
				$(ROLES_SCHEMA_FILE) 2>&1; \
			echo "This may be OK if you've run this before and the roles already exist."; \
		}

migrate-departments: start-db
	@echo "→ Migrating departments from roles…"
	@surreal import \
		--conn $(DB_URL) \
		--user $(SURREAL_USER) --pass $(SURREAL_PASS) \
		--namespace $(SURREAL_NS) --database $(SURREAL_DB) \
		$(MIGRATE_DEPARTMENTS_FILE) 2>&1 || { \
			echo "⚠️ Department migration encountered errors:"; \
			surreal import \
				--conn $(DB_URL) \
				--user $(SURREAL_USER) --pass $(SURREAL_PASS) \
				--namespace $(SURREAL_NS) --database $(SURREAL_DB) \
				$(MIGRATE_DEPARTMENTS_FILE) 2>&1; \
			echo "Check migration results for details."; \
		}
