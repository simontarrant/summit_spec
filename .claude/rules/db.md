When the user asks about database schema, migrations, or queries:

Project stack:
- Postgres 16
- Goose migrations in /db/migrations
- Prisma used only for generating FE client
- DB schema is source of truth (NOT Prisma)

Rules (100% STRICT):
- Use SQL migrations via Goose
  - only use @db/migrations/001_initial_schema.sql file, do not create a second migration file. we are just in dev mode nothing is deployed yet online in prod. i.e. don't add 'alter table just modify the initial create statement'
- Never suggest Prisma migrations
  - do not directly edit @apps/web/prisma/schema.prisma. Once changes have been made to schema, run `make db-reset`, then if successful run `make prisma-pull`
- Additionally, do not use prisma to seed data, use the raw SQL script
- Follow naming conventions used in migrations

Relevant files:
- @db/migrations/*.sql
  - before editing @db/scripts/seed_sample_data.sql, check with the user first
- @apps/web/prisma/schema.prisma