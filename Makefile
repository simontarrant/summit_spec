.PHONY: help setup dev clean install \
        db-up db-down db-reset db-migrate db-seed \
        web-dev web-build web-start web-clean \
        prisma-pull prisma-generate prisma-studio \
        dev-all stop-all \
        status check clean-all \
        test-db-up test-db-down test-db-migrate test test-watch

# Colors for output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# =============================================================================
# Help Menu
# =============================================================================

help:
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  🏔️  Gear Garage - Monorepo Makefile"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo ""
	@echo "$(GREEN)Quick Start Commands:$(RESET)"
	@echo "  make setup              - Full project setup (database + dependencies)"
	@echo "  make dev-all            - Run database + web in parallel"
	@echo "  make dev                - Alias for dev-all"
	@echo "  make stop-all           - Stop all running services"
	@echo ""
	@echo "$(GREEN)Database Commands:$(RESET)"
	@echo "  make db-up              - Start PostgreSQL container"
	@echo "  make db-down            - Stop PostgreSQL container"
	@echo "  make db-reset           - Reset database (destructive!)"
	@echo "  make db-migrate         - Run database migrations"
	@echo "  make db-seed            - Seed database with sample data"
	@echo ""
	@echo "$(GREEN)Web Commands (Next.js):$(RESET)"
	@echo "  make web-dev            - Run Next.js dev server"
	@echo "  make web-build          - Build Next.js for production"
	@echo "  make web-start          - Start Next.js production server"
	@echo ""
	@echo "$(GREEN)Prisma Commands:$(RESET)"
	@echo "  make prisma-pull        - Pull database schema into Prisma (introspect)"
	@echo "  make prisma-generate    - Generate Prisma client from schema"
	@echo "  make prisma-studio      - Open Prisma Studio database GUI"
	@echo ""
	@echo "$(GREEN)Testing:$(RESET)"
	@echo "  make test-db-up         - Start test PostgreSQL container (port 5433)"
	@echo "  make test-db-down       - Stop test PostgreSQL container"
	@echo "  make test-db-migrate    - Run migrations against test database"
	@echo "  make test               - Run test suite"
	@echo "  make test-watch         - Run tests in watch mode"
	@echo ""
	@echo "$(GREEN)Maintenance:$(RESET)"
	@echo "  make install            - Install all dependencies"
	@echo "  make clean              - Clean all build artifacts"
	@echo "  make clean-all          - Deep clean including dependencies"
	@echo "  make check              - Check system tools + services"
	@echo "  make status             - Show project status"
	@echo ""
	@echo "$(YELLOW)Individual Makefiles:$(RESET)"
	@echo "  db/Makefile             - Database operations"
	@echo "  apps/web/Makefile       - Next.js operations"
	@echo ""

# =============================================================================
# Setup
# =============================================================================

setup: install db-up db-migrate db-seed
	@echo "$(GREEN)✓ Full project setup complete!$(RESET)"
	@echo ""
	@echo "$(CYAN)Next steps:$(RESET)"
	@echo "  1. Run: make dev-all"
	@echo "  2. Open: http://localhost:3000 (web)"

install:
	@echo "$(CYAN)Installing dependencies...$(RESET)"
	@echo "$(YELLOW)→ Installing web dependencies$(RESET)"
	@cd apps/web && $(MAKE) install
	@echo "$(GREEN)✓ All dependencies installed$(RESET)"

# =============================================================================
# Database Commands
# =============================================================================

db-up:
	@echo "$(CYAN)Starting database...$(RESET)"
	@cd db && $(MAKE) docker-up

db-down:
	@echo "$(CYAN)Stopping database...$(RESET)"
	@cd db && $(MAKE) docker-down

db-reset:
	@echo "$(RED)Resetting database...$(RESET)"
	@cd db && $(MAKE) reset

db-migrate:
	@echo "$(CYAN)Running migrations...$(RESET)"
	@cd db && $(MAKE) migrate-up

db-seed:
	@echo "$(CYAN)Seeding database...$(RESET)"
	@cd db && $(MAKE) seed

db-logs:
	@cd db && $(MAKE) docker-logs

# =============================================================================
# Web Commands
# =============================================================================

web-dev:
	@echo "$(CYAN)Starting Next.js dev server...$(RESET)"
	@cd apps/web && $(MAKE) dev

web-build:
	@echo "$(CYAN)Building Next.js app...$(RESET)"
	@cd apps/web && $(MAKE) build

web-start:
	@echo "$(CYAN)Starting Next.js production server...$(RESET)"
	@cd apps/web && $(MAKE) start

web-clean:
	@cd apps/web && $(MAKE) clean

# =============================================================================
# Prisma Commands
# =============================================================================

prisma-pull:
	@echo "$(CYAN)Pulling database schema into Prisma...$(RESET)"
	@cd apps/web && $(MAKE) prisma-pull

prisma-generate:
	@echo "$(CYAN)Generating Prisma client...$(RESET)"
	@cd apps/web && $(MAKE) prisma-generate

prisma-studio:
	@echo "$(CYAN)Opening Prisma Studio...$(RESET)"
	@cd apps/web && $(MAKE) prisma-studio

# =============================================================================
# Development Workflow
# =============================================================================

dev-all:
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "$(GREEN)  🚀 Starting all services...$(RESET)"
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@$(MAKE) --no-print-directory db-up
	@echo ""
	@echo "$(YELLOW)Starting Next.js...$(RESET)"
	@cd apps/web && $(MAKE) dev

dev: dev-all

stop-all:
	@echo "$(RED)Stopping all services...$(RESET)"
	@-pkill -f "next dev" 2>/dev/null || true
	@cd db && $(MAKE) docker-down
	@echo "$(GREEN)✓ All services stopped$(RESET)"

# =============================================================================
# Maintenance
# =============================================================================

clean:
	@echo "$(CYAN)Cleaning all build artifacts...$(RESET)"
	@cd apps/web && $(MAKE) clean
	@echo "$(GREEN)✓ Cleaned$(RESET)"

clean-all: clean
	@echo "$(RED)Deep cleaning (including dependencies)...$(RESET)"
	@cd apps/web && $(MAKE) clean-all
	@echo "$(GREEN)✓ Deep clean complete$(RESET)"

check:
	@echo "$(CYAN)Checking installation status...$(RESET)"
	@echo ""
	@echo "$(YELLOW)System tools:$(RESET)"
	@command -v docker >/dev/null 2>&1 && echo "  $(GREEN)✓$(RESET) docker" || echo "  $(RED)✗$(RESET) docker (required)"
	@docker compose version >/dev/null 2>&1 && echo "  $(GREEN)✓$(RESET) docker compose" || echo "  $(RED)✗$(RESET) docker compose (required)"
	@command -v node >/dev/null 2>&1 && echo "  $(GREEN)✓$(RESET) node" || echo "  $(RED)✗$(RESET) node (required)"
	@command -v npm >/dev/null 2>&1 && echo "  $(GREEN)✓$(RESET) npm" || echo "  $(RED)✗$(RESET) npm (required)"
	@echo ""
	@echo "$(YELLOW)Database:$(RESET)"
	@docker ps --filter name=gear_garage_db --format "  $(GREEN)✓$(RESET) PostgreSQL ({{.Status}})" 2>/dev/null || echo "  $(YELLOW)○$(RESET) PostgreSQL (not running, use: make db-up)"
	@echo ""

status:
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "$(GREEN)  📊 Project Status$(RESET)"
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@$(MAKE) --no-print-directory check
	@echo ""
	@echo "$(YELLOW)Services:$(RESET)"
	@pgrep -f "next dev" >/dev/null && echo "  $(GREEN)✓$(RESET) Next.js dev server running" || echo "  $(YELLOW)○$(RESET) Next.js not running"

# =============================================================================
# Testing
# =============================================================================

test-db-up:
	@echo "$(CYAN)Starting test database...$(RESET)"
	@cd db && $(MAKE) test-docker-up

test-db-down:
	@echo "$(CYAN)Stopping test database...$(RESET)"
	@cd db && $(MAKE) test-docker-down

test-db-migrate:
	@echo "$(CYAN)Running test database migrations...$(RESET)"
	@cd db && $(MAKE) test-migrate-up

test:
	@if ! docker ps --filter name=gear_garage_test_db --format '{{.Names}}' | grep -q gear_garage_test_db; then \
		echo "$(YELLOW)Test database not running, starting it...$(RESET)"; \
		$(MAKE) --no-print-directory test-db-up; \
		$(MAKE) --no-print-directory test-db-migrate; \
	fi
	@echo "$(CYAN)Running tests...$(RESET)"
	@cd apps/web && npm test

test-watch:
	@if ! docker ps --filter name=gear_garage_test_db --format '{{.Names}}' | grep -q gear_garage_test_db; then \
		echo "$(YELLOW)Test database not running, starting it...$(RESET)"; \
		$(MAKE) --no-print-directory test-db-up; \
		$(MAKE) --no-print-directory test-db-migrate; \
	fi
	@cd apps/web && npm run test:watch
