# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

This is a Next.js 16 application for managing hiking gear catalogs and gear lists. Users can browse hiking products (currently focused on sleeping pads), create custom gear lists, and track weights and specifications.

**Tech Stack:**
- Next.js 16 (App Router)
- React 19
- TypeScript (strict mode)
- Prisma ORM with PostgreSQL
- Tailwind CSS v4
- Custom UI component system with geometric design language

## Development Commands

### Essential Commands
```bash
# Start development server (http://localhost:3000)
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run linter
npm run lint
```

### Database Commands
```bash
# Start PostgreSQL (via Docker)
docker compose up -d

# Generate Prisma client after schema changes
npx prisma generate

# Create and apply migrations
npx prisma migrate dev --name <migration_name>

# Apply migrations in production
npx prisma migrate deploy

# Seed the database with sample data
npx tsx prisma/seed.ts

# Open Prisma Studio (database GUI)
npx prisma studio

# Rebuild search index (run after data changes)
psql $DATABASE_URL -f scripts/sql/update_search_idx.sql
```

## Architecture

### Database Schema (Prisma)

The schema follows a hierarchical product model:

**Core entities:**
- `User` → owns gear lists and can create custom products
- `Brand` → represents gear manufacturers
- `Product` → logical product (e.g., "NeoAir XLite NXT")
- `ProductVariant` → specific SKU with weight and dimensions (e.g., "Regular", "Long")
- `ProductVariantSleepingPadDetail` → category-specific attributes (R-value, dimensions)
- `GearList` → user's collection of gear
- `GearListItem` → links variants to lists with quantity/weight overrides

**Search optimization:**
- `ProductVariantSearchIndex` → denormalized table with PostgreSQL full-text search (`tsvector`)
- Uses `pg_trgm` and `unaccent` extensions for fuzzy matching
- Rebuild via `scripts/sql/update_search_idx.sql`

### Frontend Structure

```
src/
├── app/              # Next.js App Router pages
│   ├── layout.tsx    # Root layout with fonts and metadata
│   ├── page.tsx      # Example page (theme showcase)
│   └── globals.css   # Theme system and Tailwind config
├── components/
│   └── ui/           # Reusable UI primitives (see UI System below)
└── lib/
    ├── prisma.ts     # Shared Prisma client singleton
    └── cn.ts         # Utility for conditional classNames
```

**Path alias:** `@/*` maps to `src/*` (configured in tsconfig.json)

### UI System

This project uses a **custom geometric design language** with angled corners and chamfered edges (see `docs/ui_components.md` and `docs/fe_patterns.md`).

**Component primitives (src/components/ui/):**
- `<Page>` → Page wrapper (`.ui-page` class)
- `<Card>` → Content container (`.ui-card` class)
- `<SectionLabel>` → Small uppercase label (`.ui-label` class)
- `<PrimaryButton>` / `<AccentButton>` → CTAs (`.ui-button-primary/accent`)
- `<TextInput>` → Form input (`.ui-input`)
- `<AppShell>` → Top bar + tabs wrapper

**Design tokens (globals.css):**
- Colors: `--primary` (forest green), `--accent` (warm ochre), `--charcoal`, `--slate`
- Typography: Sora (headings), Inter (body), JetBrains Mono (technical values)
- Shape: `corner-angle` (asymmetric radii), `chamfer` (top-right cut)
- Spacing: Based on 4px grid (1rem = 16px)

**Pattern rules:**
1. Every page must be wrapped in `<Page>`
2. Group content inside `<Card>` components
3. Each card should start with `<SectionLabel>` + heading
4. Use only the provided button/input components (no custom variants)
5. Use `mono` class for technical values (weights, dimensions, R-values)

See `docs/fe_patterns.md` for copy-paste examples.

## Key Conventions

### TypeScript
- Strict mode enabled
- Use ES2017 target (for better compatibility)
- Prefer explicit types over inference for public APIs
- Use Prisma-generated types from `@prisma/client`

### Database
- All migrations must be tracked in `prisma/migrations/`
- Use `snake_case` for database columns, but Prisma maps to `camelCase` in code
- Search index is **manually managed** (not auto-synced via triggers)
- Always run `update_search_idx.sql` after bulk data changes

### Components
- Server components by default (mark `"use client"` only when necessary)
- Keep components in `src/components/ui/` for shared primitives
- Co-locate page-specific components in `src/app/[route]/` if not reusable

### Styling
- Use Tailwind utility classes for layout/spacing
- Use theme classes (`.ui-*`) for styled components
- Avoid inline styles or CSS modules
- Use `cn()` helper from `@/lib/cn` for conditional classes

## Authentication

The app uses **NextAuth.js v5** (Auth.js) for authentication:

**Authentication flow:**
1. Users can sign up or log in at `/login`
2. Credentials provider authenticates against the `User` table (username or email + password)
3. Passwords are hashed with bcrypt (12 rounds)
4. JWT sessions are used (no database sessions)
5. Middleware protects all routes except `/login` and `/api/signup`
6. Authenticated users see the main UI with topbar and tabs

**Key files:**
- `src/lib/auth.ts` → NextAuth configuration and auth handlers
- `src/app/api/auth/[...nextauth]/route.ts` → NextAuth API route
- `src/app/api/signup/route.ts` → User registration endpoint
- `src/app/login/page.tsx` → Login/signup page with tabbed interface
- `src/middleware.ts` → Route protection and redirects
- `src/components/ui/auth-shell.tsx` → Authenticated layout wrapper
- `src/components/providers/session-provider.tsx` → Session provider wrapper

**Implementation notes:**
- Login accepts both username and email as identifier
- 300ms delay added to login to prevent timing attacks
- Signup validates email format and password length (min 8 chars)
- After successful signup, user is automatically logged in
- Sign out redirects to `/login`

## Environment Variables

Required in `.env`:
```
DATABASE_URL="postgresql://user:password@localhost:5432/hiking_gear?schema=public"
AUTH_SECRET="<generated-secret>"  # Generate with: openssl rand -base64 32
AUTH_URL="http://localhost:3000"
```

## Docker Setup

The project includes a PostgreSQL 16 container:
```bash
docker compose up -d  # Start database
docker compose down   # Stop database
```

**Default credentials:**
- User: `simon`
- Password: `password`
- Database: `localdb`
- Port: 5432

## Product Categories

Currently supports:
- `SLEEPING_PAD` → Insulated/uninsulated camping pads

Future planned categories (see schema enum):
- PACK, QUILT, BAG, PILLOW, etc.

Each category can have its own detail table (e.g., `ProductVariantSleepingPadDetail`).

## Search Implementation

Full-text search is powered by PostgreSQL `tsvector`:
1. Products are indexed in `ProductVariantSearchIndex`
2. The `search_tsv` column contains a weighted vector of brand + product + variant names
3. Queries use `to_tsquery()` with `unaccent()` for accent-insensitive matching
4. Rebuild index by running `scripts/sql/update_search_idx.sql`

**Note:** The search index is **not automatically updated** on row changes. This is intentional for performance. Update it manually when needed.

## Testing Strategy

No test suite currently exists. When adding tests:
- Use Jest + React Testing Library for component tests
- Use Prisma in-memory SQLite or test containers for DB tests
- Test search functionality against real PostgreSQL (requires extensions)
