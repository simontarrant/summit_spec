#!/usr/bin/env bash
set -e

echo "🗑️  Deleting local Prisma migrations folder..."
rm -rf prisma/migrations

echo "🗑️  Resetting database & clearing applied migrations..."
npx prisma migrate reset --force --skip-seed

echo "📁 Creating fresh initial migration..."
npx prisma migrate dev --name init --create-only

echo "🗂️  Applying migration to fresh DB..."
npx prisma migrate dev

echo "🔧 Regenerating Prisma client..."
npx prisma generate

echo "🌱 seeding data..."
npx prisma db seed

echo "🔎 Updating search index..."
psql -d hiking_gear -f ./scripts/sql/update_search_idx.sql

echo "✨ Done! Clean DB, fresh migration, schema applied."
