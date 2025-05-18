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

.PHONY: start-db stop-db init-db start-frontend dev init-full \
        seed-admin-person seed-admin-org erase-db reset-db seed-static migrate-departments \
        check-db-ready

# Start the SurrealDB container
start-db:
	@echo "→ Starting SurrealDB container…"
	@mkdir -p $(DB_DATA_DIR) $(DB_FILES_DIR)
	$(COMPOSE) up -d $(DB_SERVICE)

# Stop the SurrealDB container
stop-db:
	@echo "→ Stopping SurrealDB container…"
	$(COMPOSE) stop $(DB_SERVICE)

# Check if the database is ready to accept connections
check-db-ready:
	@echo "→ Waiting for DB to become ready…"
	@sleep 3
	@echo "→ Checking DB connection…"
	@curl -s -o /dev/null -w "%{http_code}" $(DB_URL)/health | grep 200 > /dev/null || { \
		echo "⚠️ Database not ready, waiting additional time..."; \
		sleep 5; \
	}

# Initialize the database with schema, roles, and admin user
init-db: start-db check-db-ready
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
	@echo "→ Seeding roles and departments…"
	@$(MAKE) seed-static || { \
		echo "⚠️ Role seeding encountered errors. This may be expected if roles already exist."; \
	}
	@echo "→ Creating admin user…"
	@$(MAKE) seed-admin-person || { \
		echo "⚠️ Admin user creation encountered errors. This may be expected if the user already exists."; \
	}
	@echo "✅ Database initialization completed!"

# Start the Svelte frontend development server
start-frontend:
	@echo "→ Launching Svelte frontend…"
	cd $(FRONTEND_DIR) && npm run dev

# Complete initialization including admin organization
init-full: init-db
	@echo "→ Creating admin organization…"
	@$(MAKE) seed-admin-org || { \
		echo "⚠️ Admin organization creation encountered errors. This may be expected if it already exists."; \
	}
	@echo "✅ Full initialization completed! Your system is ready for development."

# Start development environment (database + frontend)
dev: init-db start-frontend

# Create admin user via signup endpoint
seed-admin-person:
	@echo "→ Signing up admin person via record-access…"
	@curl -s -X POST $(DB_URL)/signup \
		-H "Content-Type: application/json" \
		-d '{"ns":"'"$(SURREAL_NS)"'","db":"'"$(SURREAL_DB)"'","ac":"user_access","username":"'"$(ADMIN_USERNAME)"'","password":"'"$(ADMIN_PASSWORD)"'","email":"'"$(ADMIN_EMAIL)"'"}' \
		| grep -v "error" > /dev/null || { \
			echo "⚠️ Admin user creation returned an error. User may already exist."; \
		}

# Create admin organization and link it to the admin user
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
}' \
		| grep -v "error" > /dev/null || { \
			echo "⚠️ Admin organization creation returned an error. Organization may already exist or admin user not found."; \
		}

# Erase all database data and storage files
erase-db:
	@echo "→ Stopping and erasing DB data and storage…"
	$(MAKE) stop-db
	@rm -rf $(DB_DATA_DIR)/*.db
	@rm -rf $(DB_FILES_DIR)/*
	@mkdir -p $(DB_DATA_DIR)
	@mkdir -p $(DB_FILES_DIR)
	@echo "✅ Database data erased. You can run 'make init-db' to reinitialize."

# Reset database by erasing all data and restarting development environment
reset-db: erase-db
	@echo "→ Reinitializing development environment..."
	@$(MAKE) dev

# Seed static data (roles and departments)
seed-static: start-db check-db-ready
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
	@echo "✅ Role and department data imported successfully"

# Migrate departments from roles (one-time operation for legacy data)
migrate-departments: start-db check-db-ready
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
	@echo "✅ Department migration completed"


