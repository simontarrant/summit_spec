# Load environment variables from .env.local or .env file if it exists
-include .env.local
-include .env
export

.PHONY: help dev build start lint test test-watch clean install \
        prisma-pull prisma-generate prisma-studio \
        prisma-pull-help prisma-generate-help prisma-studio-help prisma-help

# Default target
help:
	@echo "Gear Garage Web (Next.js) Makefile"
	@echo ""
	@echo "Development commands:"
	@echo "  make dev             - Start Next.js development server"
	@echo "  make build           - Build production bundle"
	@echo "  make start           - Start production server"
	@echo "  make lint            - Run ESLint"
	@echo "  make test            - Run tests"
	@echo "  make test-watch      - Run tests in watch mode"
	@echo ""
	@echo "Prisma commands:"
	@echo "  make prisma-pull     - Pull database schema into Prisma (introspect)"
	@echo "  make prisma-generate - Generate Prisma client from schema"
	@echo "  make prisma-studio   - Open Prisma Studio database GUI"
	@echo ""
	@echo "  For detailed help:"
	@echo "    make prisma-help           (comprehensive workflow guide)"
	@echo "    make <command>-help        (e.g., make prisma-pull-help)"
	@echo ""
	@echo "Maintenance:"
	@echo "  make install         - Install dependencies"
	@echo "  make clean           - Clean build artifacts"

# Install dependencies
install:
	@echo "Installing dependencies..."
	npm install
	@echo "✓ Dependencies installed"

# Development server
dev:
	@echo "Starting Next.js development server..."
	npm run dev

# Build for production
build:
	@echo "Building for production..."
	npm run build
	@echo "✓ Build complete"

# Start production server
start:
	@echo "Starting production server..."
	npm run start

# Run linter
lint:
	@echo "Running ESLint..."
	npm run lint
	@echo "✓ Linting complete"

# Run tests
test:
	@echo "Running tests..."
	npm test

test-watch:
	npm run test:watch

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf .next
	rm -rf node_modules/.cache
	@echo "✓ Cleaned"

# Full clean (including node_modules)
clean-all: clean
	@echo "Removing node_modules..."
	rm -rf node_modules
	@echo "✓ Full clean complete"

# Setup for development
setup: install
	@echo "✓ Web app setup complete"

# Type check
type-check:
	@echo "Running TypeScript type check..."
	npx tsc --noEmit
	@echo "✓ Type check complete"

# Format code
format:
	@echo "Formatting code with Prettier..."
	@if command -v prettier >/dev/null 2>&1; then \
		npx prettier --write . ; \
	else \
		echo "Prettier not found. Install with: npm install -D prettier"; \
	fi
	@echo "✓ Code formatted"

# Prisma commands
prisma-pull:
	@echo "Pulling database schema into Prisma..."
	@if [ ! -f .env.local ] && [ ! -f .env ]; then \
		echo "Error: No .env or .env.local file found"; \
		echo "Create .env or .env.local in apps/web/ directory with DATABASE_URL"; \
		exit 1; \
	fi
	@if [ -f .env.local ]; then \
		set -a && . ./.env.local && set +a && npx prisma db pull; \
	else \
		set -a && . ./.env && set +a && npx prisma db pull; \
	fi
	@echo "✓ Prisma schema updated from database"
	@echo ""
	@echo "Next step: Run 'make prisma-generate' to regenerate the Prisma client"

prisma-generate:
	@echo "Generating Prisma client..."
	npx prisma generate
	@echo "✓ Prisma client generated"

prisma-studio:
	@echo "Opening Prisma Studio..."
	@if [ ! -f .env.local ] && [ ! -f .env ]; then \
		echo "Error: No .env or .env.local file found"; \
		echo "Create .env or .env.local in apps/web/ directory with DATABASE_URL"; \
		exit 1; \
	fi
	@if [ -f .env.local ]; then \
		set -a && . ./.env.local && set +a && npx prisma studio; \
	else \
		set -a && . ./.env && set +a && npx prisma studio; \
	fi

# Detailed help commands
prisma-help:
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  📚 Prisma Workflow Guide - Comprehensive Overview"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "PHILOSOPHY:"
	@echo "  This project uses a DATABASE-FIRST workflow. The source of truth is the"
	@echo "  PostgreSQL database schema (managed via SQL migrations in db/migrations/)."
	@echo "  Prisma is used as a type-safe ORM client that reflects the database schema."
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "AVAILABLE COMMANDS:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "1. make prisma-pull"
	@echo "   └─ Introspects database and updates prisma/schema.prisma"
	@echo "   └─ Run AFTER database migrations"
	@echo "   └─ Details: make prisma-pull-help"
	@echo ""
	@echo "2. make prisma-generate"
	@echo "   └─ Generates TypeScript types from schema"
	@echo "   └─ Run AFTER prisma-pull"
	@echo "   └─ Details: make prisma-generate-help"
	@echo ""
	@echo "3. make prisma-studio"
	@echo "   └─ Opens visual database browser GUI"
	@echo "   └─ Run ANYTIME to inspect/edit data"
	@echo "   └─ Details: make prisma-studio-help"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "STANDARD WORKFLOW:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "When you need to change the database schema:"
	@echo ""
	@echo "  Step 1: Create SQL migration"
	@echo "    $$ cd ../../db/migrations"
	@echo "    $$ goose create add_new_column sql"
	@echo "    $$ # Edit the new migration file"
	@echo ""
	@echo "  Step 2: Apply migration to database"
	@echo "    $$ cd ../../db"
	@echo "    $$ make migrate-up"
	@echo "    ✓ Database schema is now updated"
	@echo ""
	@echo "  Step 3: Pull schema into Prisma"
	@echo "    $$ cd ../apps/web"
	@echo "    $$ make prisma-pull"
	@echo "    ✓ prisma/schema.prisma now matches database"
	@echo ""
	@echo "  Step 4: Regenerate Prisma client"
	@echo "    $$ make prisma-generate"
	@echo "    ✓ TypeScript types now match database"
	@echo ""
	@echo "  Step 5: Restart dev server"
	@echo "    $$ npm run dev"
	@echo "    ✓ Your code now has access to new schema/types"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "QUICK SHORTCUTS (from project root):"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "  # After creating/applying migrations in db/"
	@echo "  $$ make prisma-pull && make prisma-generate"
	@echo ""
	@echo "  # Or run from root directory"
	@echo "  $$ make db-migrate          # Apply migrations"
	@echo "  $$ make prisma-pull         # Sync Prisma schema"
	@echo "  $$ make prisma-generate     # Regenerate client"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "COMMON SCENARIOS:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "Scenario: \"I added a new table in SQL migrations\""
	@echo "  → make db-migrate && make prisma-pull && make prisma-generate"
	@echo ""
	@echo "Scenario: \"I'm getting TypeScript errors about missing types\""
	@echo "  → make prisma-generate (if schema.prisma is correct)"
	@echo "  → make prisma-pull && make prisma-generate (if database changed)"
	@echo ""
	@echo "Scenario: \"I want to see what data is in the database\""
	@echo "  → make prisma-studio (opens GUI browser)"
	@echo ""
	@echo "Scenario: \"I manually edited prisma/schema.prisma\""
	@echo "  ⚠  WARNING: prisma-pull will overwrite your changes!"
	@echo "  → Only make cosmetic changes (comments, formatting)"
	@echo "  → Schema structure should come from database migrations"
	@echo ""
	@echo "Scenario: \"Setting up project on a new machine\""
	@echo "  $$ make setup                 # From root (sets up DB)"
	@echo "  $$ cd apps/web"
	@echo "  $$ make install               # Install npm dependencies"
	@echo "  $$ make prisma-generate       # Generate Prisma client"
	@echo "  $$ npm run dev                # Start dev server"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "TROUBLESHOOTING:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "Problem: \"DATABASE_URL is not set\""
	@echo "  → Create .env or .env.local in apps/web/ with DATABASE_URL"
	@echo "  → Copy from .env.example if available"
	@echo ""
	@echo "Problem: \"Prisma Client does not match schema\""
	@echo "  → Run: make prisma-generate"
	@echo ""
	@echo "Problem: \"Database connection error\""
	@echo "  → Check database is running: make db-up (from root)"
	@echo "  → Verify DATABASE_URL in .env or .env.local"
	@echo ""
	@echo "Problem: \"Types don't match database\""
	@echo "  → Run: make prisma-pull && make prisma-generate"
	@echo "  → Restart dev server: npm run dev"
	@echo ""
	@echo "Problem: \"Can't find @prisma/client\""
	@echo "  → Run: npm install (installs Prisma)"
	@echo "  → Run: make prisma-generate (generates client)"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "For command-specific details, run:"
	@echo "  • make prisma-pull-help"
	@echo "  • make prisma-generate-help"
	@echo "  • make prisma-studio-help"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""

prisma-pull-help:
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  📥 prisma-pull - Database Schema Introspection"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "WHAT IT DOES:"
	@echo "  Introspects your PostgreSQL database and updates prisma/schema.prisma"
	@echo "  to match the actual database structure. This is a DATABASE-FIRST workflow."
	@echo ""
	@echo "WHEN TO USE:"
	@echo "  ✓ After applying SQL migrations (make db-migrate)"
	@echo "  ✓ When database schema changes outside of Prisma"
	@echo "  ✓ Initial setup to import existing database schema"
	@echo "  ✓ To sync Prisma schema with database truth"
	@echo ""
	@echo "WORKFLOW:"
	@echo "  1. Make changes to SQL migrations in db/migrations/"
	@echo "  2. Run: make db-migrate          (apply migrations to database)"
	@echo "  3. Run: make prisma-pull         (update Prisma schema)"
	@echo "  4. Run: make prisma-generate     (regenerate Prisma client)"
	@echo "  5. Restart your dev server"
	@echo ""
	@echo "PREREQUISITES:"
	@echo "  • DATABASE_URL must be set in .env or .env.local"
	@echo "  • PostgreSQL database must be running (make db-up)"
	@echo "  • Database should have latest migrations applied"
	@echo ""
	@echo "WHAT HAPPENS:"
	@echo "  ✓ Connects to database using DATABASE_URL"
	@echo "  ✓ Reads all tables, columns, indexes, and relations"
	@echo "  ✓ Updates prisma/schema.prisma with current structure"
	@echo "  ✓ Preserves datasource/generator config blocks"
	@echo "  ⚠  May add warnings for unsupported types as comments"
	@echo ""
	@echo "IMPORTANT NOTES:"
	@echo "  • This is DATABASE → Prisma (not Prisma → database)"
	@echo "  • Manual changes to schema.prisma will be overwritten"
	@echo "  • Review changes before committing"
	@echo "  • Must run prisma-generate after to update client code"
	@echo ""
	@echo "EXAMPLE:"
	@echo "  $$ cd ../../db && make migrate-up    # Apply migrations"
	@echo "  $$ cd ../apps/web && make prisma-pull # Sync schema"
	@echo "  $$ make prisma-generate               # Update client"
	@echo ""

prisma-generate-help:
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  🔧 prisma-generate - Regenerate Prisma Client"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "WHAT IT DOES:"
	@echo "  Reads prisma/schema.prisma and generates TypeScript types and query"
	@echo "  builder code in node_modules/@prisma/client. This is the code you"
	@echo "  import and use in your application."
	@echo ""
	@echo "WHEN TO USE:"
	@echo "  ✓ After running prisma-pull (schema changed from database)"
	@echo "  ✓ After manually editing prisma/schema.prisma"
	@echo "  ✓ After npm install (to ensure client is up to date)"
	@echo "  ✓ When you see TypeScript errors about missing Prisma types"
	@echo "  ✓ Initial project setup"
	@echo ""
	@echo "WORKFLOW:"
	@echo "  Standard database-first workflow:"
	@echo "    1. Update database via migrations (make db-migrate)"
	@echo "    2. Pull schema into Prisma (make prisma-pull)"
	@echo "    3. Generate client (make prisma-generate)  ← YOU ARE HERE"
	@echo "    4. Restart dev server to use new types"
	@echo ""
	@echo "  Schema-only changes workflow:"
	@echo "    1. Edit prisma/schema.prisma manually (comments, indexes, etc.)"
	@echo "    2. Generate client (make prisma-generate)  ← YOU ARE HERE"
	@echo ""
	@echo "WHAT HAPPENS:"
	@echo "  ✓ Parses prisma/schema.prisma"
	@echo "  ✓ Generates TypeScript types for all models"
	@echo "  ✓ Creates type-safe query builder (PrismaClient)"
	@echo "  ✓ Outputs to node_modules/@prisma/client/"
	@echo "  ✓ Makes types available via: import { PrismaClient } from '@prisma/client'"
	@echo ""
	@echo "SPEED:"
	@echo "  • Fast (usually < 5 seconds)"
	@echo "  • No database connection required"
	@echo "  • Safe to run anytime"
	@echo ""
	@echo "IMPORTANT NOTES:"
	@echo "  • Run this AFTER prisma-pull, not before"
	@echo "  • Generated code is gitignored (in node_modules)"
	@echo "  • Must run after npm install on new machines"
	@echo "  • Dev server hot-reload may not pick up changes (restart recommended)"
	@echo ""
	@echo "EXAMPLE:"
	@echo "  $$ make prisma-generate"
	@echo "  $$ npm run dev  # Restart to use new types"
	@echo ""

prisma-studio-help:
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  🎨 prisma-studio - Visual Database Browser"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "WHAT IT DOES:"
	@echo "  Opens Prisma Studio, a visual database browser GUI in your web browser."
	@echo "  Allows you to view, edit, filter, and manage database records through"
	@echo "  an intuitive interface without writing SQL."
	@echo ""
	@echo "WHEN TO USE:"
	@echo "  ✓ Browse and inspect database records"
	@echo "  ✓ Manually edit data during development"
	@echo "  ✓ Debug data issues (see actual values)"
	@echo "  ✓ Test relationships between models"
	@echo "  ✓ Quick data entry without writing seed scripts"
	@echo "  ✓ Verify migrations applied correctly"
	@echo ""
	@echo "FEATURES:"
	@echo "  • Visual table browser with filtering and sorting"
	@echo "  • Edit records inline (click any cell)"
	@echo "  • Navigate relationships (click foreign keys)"
	@echo "  • Create and delete records via GUI"
	@echo "  • Search and filter with visual query builder"
	@echo "  • View record counts and table stats"
	@echo ""
	@echo "PREREQUISITES:"
	@echo "  • DATABASE_URL must be set in .env or .env.local"
	@echo "  • PostgreSQL database must be running (make db-up)"
	@echo "  • prisma/schema.prisma must exist"
	@echo ""
	@echo "ACCESSING:"
	@echo "  • Opens automatically in your default browser"
	@echo "  • Default URL: http://localhost:5555"
	@echo "  • Leave terminal running while using Studio"
	@echo "  • Press Ctrl+C to stop Studio"
	@echo ""
	@echo "IMPORTANT NOTES:"
	@echo "  ⚠  Changes are immediate (no transaction safety)"
	@echo "  ⚠  Use only in development (not production)"
	@echo "  ✓ Safe to use alongside running dev server"
	@echo "  ✓ Changes reflect immediately in your app"
	@echo "  ✓ No code generation required (reads schema directly)"
	@echo ""
	@echo "WORKFLOW EXAMPLE:"
	@echo "  Debug workflow:"
	@echo "    1. Notice bug in your app"
	@echo "    2. Run: make prisma-studio"
	@echo "    3. Inspect data to find issue"
	@echo "    4. Fix data or identify code problem"
	@echo ""
	@echo "  Data entry workflow:"
	@echo "    1. Run: make prisma-studio"
	@echo "    2. Navigate to table (e.g., 'brand')"
	@echo "    3. Click 'Add record' button"
	@echo "    4. Fill in fields and save"
	@echo "    5. Data immediately available in app"
	@echo ""
	@echo "TIPS:"
	@echo "  • Use Cmd+K (Mac) / Ctrl+K (Windows) for quick navigation"
	@echo "  • Click column headers to sort"
	@echo "  • Use filter bar for complex queries"
	@echo "  • Click foreign key values to jump to related records"
	@echo ""
