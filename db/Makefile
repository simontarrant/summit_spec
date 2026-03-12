# Load environment variables from .env file if it exists
-include .env
export

.PHONY: help docker-up docker-down docker-restart docker-logs docker-reset docker-nuke \
        migrate-up migrate-down migrate-status migrate-reset \
        seed seed-canonical generate verify clean \
        setup reset reset-canonical status \
        test-docker-up test-docker-down test-migrate-up

# Default target
help:
	@echo "Summit Spec Database Makefile"
	@echo ""
	@echo "Docker commands:"
	@echo "  make docker-up       - Start PostgreSQL container"
	@echo "  make docker-down     - Stop PostgreSQL container"
	@echo "  make docker-restart  - Restart PostgreSQL container"
	@echo "  make docker-logs     - Show PostgreSQL logs"
	@echo "  make docker-reset    - Full reset: remove container, volumes, and image (destructive!)"
	@echo "  make docker-nuke     - Nuclear option: reset without confirmation (CI/CD)"
	@echo ""
	@echo "Database commands:"
	@echo "  make migrate-up      - Apply all pending migrations"
	@echo "  make migrate-down    - Rollback last migration"
	@echo "  make migrate-status  - Show migration status"
	@echo "  make migrate-reset   - Rollback all migrations (destructive!)"
	@echo "  make seed            - Seed database with sample data"
	@echo "  make verify          - Run data integrity checks"
	@echo ""
	@echo "Code generation:"
	@echo "  make generate        - Generate Go code from SQL queries"
	@echo "  make clean           - Clean generated files"
	@echo ""
	@echo "Shortcuts:"
	@echo "  make setup           - Full setup (docker-up + migrate + seed)"
	@echo "  make reset           - Full reset (docker-reset + setup)"
	@echo ""
	@echo "Debugging:"
	@echo "  make status          - Show database and Docker status"
	@echo ""
	@echo "Environment:"
	@echo "  DATABASE_URL=$(DATABASE_URL)"

# Check DATABASE_URL is set
check-env:
ifndef DATABASE_URL
	$(error DATABASE_URL is not set. Please set it in your environment or .env file)
endif

# Docker commands
docker-up:
	@echo "Starting PostgreSQL container..."
	docker compose up -d --build
	@echo "Waiting for PostgreSQL to be ready..."
	@sleep 3
	@docker compose exec -T postgres pg_isready -U $(POSTGRES_USER) -d $(POSTGRES_DB) || (sleep 2 && docker compose exec -T postgres pg_isready -U $(POSTGRES_USER) -d $(POSTGRES_DB))
	@echo "✓ PostgreSQL is ready"

docker-down:
	@echo "Stopping PostgreSQL container..."
	docker compose down
	@echo "✓ PostgreSQL stopped"

docker-restart: docker-down docker-up

docker-logs:
	@docker compose logs -f postgres

docker-reset:
	@echo "⚠️  WARNING: This will completely destroy the database and rebuild from scratch!"
	@read -p "Are you sure? (yes/no): " confirm && [ "$$confirm" = "yes" ]
	@echo "Stopping containers and removing everything..."
	docker compose down -v --remove-orphans
	@echo "Removing Docker image..."
	@docker rmi summit_spec_db-postgres 2>/dev/null || true
	@docker rmi db-postgres 2>/dev/null || true
	@echo "Removing named volume..."
	@docker volume rm summit_spec_postgres_data 2>/dev/null || true
	@echo "Pruning all unused volumes..."
	@docker volume prune -f
	@echo "✓ Database completely destroyed"

docker-nuke:
	@echo "☢️  NUCLEAR OPTION: Destroying database without confirmation..."
	@docker compose down -v --remove-orphans 2>/dev/null || true
	@docker rmi summit_spec_db-postgres 2>/dev/null || true
	@docker volume prune -f --filter label=com.docker.compose.project=summit_spec_db 2>/dev/null || true
	@echo "✓ Database nuked"

# Migration commands
migrate-up: check-env
	@echo "Applying migrations..."
	cd migrations && goose postgres "$(DATABASE_URL)" up
	@echo "✓ Migrations applied"

migrate-down: check-env
	@echo "Rolling back last migration..."
	cd migrations && goose postgres "$(DATABASE_URL)" down
	@echo "✓ Migration rolled back"

migrate-status: check-env
	@echo "Checking migration status..."
	cd migrations && goose postgres "$(DATABASE_URL)" status

migrate-reset: check-env
	@echo "⚠️  WARNING: This will rollback ALL migrations!"
	@read -p "Are you sure? (yes/no): " confirm && [ "$$confirm" = "yes" ]
	cd migrations && goose postgres "$(DATABASE_URL)" reset
	@echo "✓ All migrations rolled back"

# Seed database
seed: check-env
	@echo "Seeding database..."
	@if [ -f "scripts/seed_sample_data.sql" ]; then \
		psql "$(DATABASE_URL)" -f scripts/seed_sample_data.sql; \
	else \
		echo "Warning: Seed script not found at scripts/seed_sample_data.sql"; \
	fi
	@echo "✓ Database seeded"

seed-canonical: check-env
	@echo "Seeding database with canonical data..."
	@if [ -f "scripts/seed_sleeping_pads_canonical.sql" ]; then \
		psql "$(DATABASE_URL)" -f scripts/seed_sleeping_pads_canonical.sql; \
	else \
		echo "Warning: Canonical seed script not found at scripts/seed_sleeping_pads_canonical.sql"; \
	fi
	@echo "✓ Canonical data seeded"

# Code generation
generate:
	@echo "Generating Go code from SQL queries..."
	sqlc generate
	@echo "✓ Code generated in ../gen/go/db/"

# Maintenance scripts
verify: check-env
	@echo "Running data integrity checks..."
	@if [ -f "scripts/verify_data_integrity.sql" ]; then \
		psql "$(DATABASE_URL)" -f scripts/verify_data_integrity.sql; \
	else \
		echo "Warning: Verify script not found"; \
	fi

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	rm -rf ../gen/go/db
	@echo "✓ Cleaned"

# Development shortcuts
setup: docker-up migrate-up seed
	@echo "✓ Database setup complete!"
	@echo "  Connection: $(DATABASE_URL)"

reset: docker-reset
	@echo "Waiting for volume cleanup..."
	@sleep 2
	@$(MAKE) docker-up
	@echo "Waiting for database to be ready..."
	@sleep 2
	@$(MAKE) migrate-up
	@$(MAKE) seed
	@$(MAKE) seed-canonical
	@echo "Rebuilding search index..."
	@psql "$(DATABASE_URL)" -f queries/search/rebuild_product_search_index.sql
	@echo "✓ Search index rebuilt"
	@echo "✓ Database reset and setup complete!"
	@echo "  Connection: $(DATABASE_URL)"

reset-canonical: docker-reset
	@echo "Waiting for volume cleanup..."
	@sleep 2
	@$(MAKE) docker-up
	@echo "Waiting for database to be ready..."
	@sleep 2
	@$(MAKE) migrate-up
	@$(MAKE) seed-canonical
	@echo "Rebuilding search index..."
	@psql "$(DATABASE_URL)" -f queries/search/rebuild_product_search_index.sql
	@echo "✓ Search index rebuilt"
	@echo "✓ Database reset with canonical data complete!"
	@echo "  Connection: $(DATABASE_URL)"

# Test database commands
TEST_DATABASE_URL ?= postgresql://simontarrant:password@localhost:5433/summit_spec_test?sslmode=disable

test-docker-up:
	@echo "Starting test PostgreSQL container..."
	docker compose -f docker-compose.test.yml up -d --build
	@echo "Waiting for test PostgreSQL to be ready..."
	@sleep 3
	@docker compose -f docker-compose.test.yml exec -T postgres-test pg_isready -U $(POSTGRES_USER) -d summit_spec_test || (sleep 2 && docker compose -f docker-compose.test.yml exec -T postgres-test pg_isready -U $(POSTGRES_USER) -d summit_spec_test)
	@echo "✓ Test PostgreSQL is ready"

test-docker-down:
	@echo "Stopping test PostgreSQL container..."
	docker compose -f docker-compose.test.yml down
	@echo "✓ Test PostgreSQL stopped"

test-migrate-up:
	@echo "Applying migrations to test database..."
	cd migrations && goose postgres "$(TEST_DATABASE_URL)" up
	@echo "✓ Test migrations applied"

# Debugging and status
status:
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Database Status"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "Environment:"
	@echo "  POSTGRES_USER: $(POSTGRES_USER)"
	@echo "  POSTGRES_DB: $(POSTGRES_DB)"
	@echo "  POSTGRES_PORT: $(POSTGRES_PORT)"
	@echo "  DATABASE_URL: $(DATABASE_URL)"
	@echo ""
	@echo "Docker Status:"
	@docker ps --filter name=summit_spec_db --format "  Container: {{.Names}} ({{.Status}})" 2>/dev/null || echo "  Container: Not running"
	@docker images --filter reference=summit_spec_db-postgres --format "  Image: {{.Repository}}:{{.Tag}} ({{.Size}})" 2>/dev/null || echo "  Image: Not built"
	@docker volume ls --filter name=summit_spec_postgres_data --format "  Volume: {{.Name}}" 2>/dev/null || echo "  Volume: Not created"
	@echo ""
	@if docker ps --filter name=summit_spec_db --format "{{.Names}}" | grep -q summit_spec_db; then \
		echo "Database Connection:"; \
		docker compose exec -T postgres pg_isready -U $(POSTGRES_USER) -d $(POSTGRES_DB) && echo "  ✓ Database is ready" || echo "  ✗ Database is not ready"; \
	fi
	@echo ""
