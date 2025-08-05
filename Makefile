# SlateHub - Development Makefile
# Targets follow noun-verb pattern

.PHONY: help
help: ## Show this help message
	@echo "SlateHub Development Commands"
	@echo "Usage: make <target>"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Database targets
.PHONY: db-start db-stop db-init db-reset db-seed db-wait db-drop
db-start: ## Start SurrealDB server
	@echo "Starting SurrealDB..."
	docker-compose up -d surrealdb

db-stop: ## Stop SurrealDB server
	@echo "Stopping SurrealDB..."
	docker-compose stop surrealdb

db-drop: ## Stop SurrealDB and remove all data
	@echo "Dropping database..."
	docker-compose down -v
	rm -rf db/data
	mkdir -p db/data

db-init: ## Initialize database with schema
	@echo "Initializing database schema..."
	cd db && surreal import --conn http://localhost:8000 --user root --pass root --ns slatehub --db main schema.surql

db-reset: ## Reset database (WARNING: destroys all data)
	@echo "Resetting database..."
	$(MAKE) db-drop
	$(MAKE) db-start
	$(MAKE) db-wait

db-seed: ## Seed database with test data
	@echo "Seeding database..."
	cd db && surreal import --conn http://localhost:8000 --user root --pass root --ns slatehub --db main seed.surql

db-wait: ## Wait for SurrealDB to be healthy
	@echo "Waiting for SurrealDB..."
	@until curl -sf http://localhost:8000/health > /dev/null; do \
		echo -n "."; \
		sleep 1; \
	done
	@echo " SurrealDB is ready."

# Storage targets
.PHONY: storage-start storage-stop storage-reset
storage-start: ## Start MinIO storage server
	@echo "Starting MinIO..."
	docker-compose up -d minio

storage-stop: ## Stop MinIO storage server
	@echo "Stopping MinIO..."
	docker-compose stop minio

storage-reset: ## Reset storage (WARNING: destroys all files)
	@echo "Resetting storage..."
	docker-compose down -v
	rm -rf db/files/*
	$(MAKE) storage-start

# API targets
.PHONY: api-test api-clean
api-test: ## Run API tests
	@echo "Running API tests..."
	cd api && cargo test

api-clean: ## Clean API build artifacts
	@echo "Cleaning API build artifacts..."
	cd api && cargo clean

# Docker targets
.PHONY: docker-build docker-up docker-down docker-logs docker-clean
docker-build: ## Build all Docker images
	@echo "Building Docker images..."
	docker-compose build

docker-up: ## Start all services with Docker Compose
	@echo "Starting all services..."
	docker-compose up -d

docker-down: ## Stop all Docker services
	@echo "Stopping all services..."
	docker-compose down

docker-logs: ## Show Docker logs
	@echo "Showing Docker logs..."
	docker-compose logs -f

docker-clean: ## Clean Docker containers and volumes
	@echo "Cleaning Docker containers and volumes..."
	docker-compose down -v
	docker system prune -f

# Development targets
.PHONY: dev-setup dev-start dev-stop dev-reset dev-logs
dev-setup: ## Setup development environment
	@echo "Setting up development environment..."
	$(MAKE) web-install
	$(MAKE) docker-build
	$(MAKE) db-reset

dev-start: ## Start full development environment
	@echo "Starting development environment..."
	$(MAKE) docker-up
	$(MAKE) web-dev

dev-stop: ## Stop development environment
	@echo "Stopping development environment..."
	$(MAKE) docker-down
	pkill -f "npm run dev" || true

dev-reset: ## Reset entire development environment
	@echo "Resetting development environment..."
	$(MAKE) docker-clean
	$(MAKE) api-clean
	$(MAKE) web-clean
	$(MAKE) dev-setup

dev-logs: ## Show all development logs
	@echo "Showing development logs..."
	$(MAKE) docker-logs

# Build targets
.PHONY: build-all build-clean
build-all: ## Build everything for production
	@echo "Building all components..."
	$(MAKE) api-build
	$(MAKE) docker-build

build-clean: ## Clean all build artifacts
	@echo "Cleaning all build artifacts..."
	$(MAKE) api-clean
	$(MAKE) docker-clean

# Test targets
.PHONY: test-all test-integration
test-all: ## Run all tests
	@echo "Running all tests..."
	$(MAKE) api-test

test-integration: ## Run integration tests
	@echo "Running integration tests..."
	@echo "Integration tests not yet implemented"

# Production targets
.PHONY: prod-deploy prod-migrate
prod-deploy: ## Deploy to production
	@echo "Deploying to production..."
	@echo "Production deployment not yet configured"

prod-migrate: ## Run production migrations
	@echo "Running production migrations..."
	@echo "Production migrations not yet configured"

# Default target
.DEFAULT_GOAL := help
