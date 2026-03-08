# Claude Code Task: Backend Test Suite Setup (Simple Version)

## Objective

Set up a **simple backend testing framework** for the Next.js application.

The application architecture:

- **Next.js Route Handlers** act as the backend
- **Prisma Client** connects to Postgres
- **Goose migrations** manage the schema
- Tests should run against a **separate Postgres test database**

Testing requirements:

1. Unit tests for pure backend logic
2. Integration tests for route handlers
3. Integration tests using a **real Postgres test database**
4. Tests should call route handlers **directly**, not through HTTP
5. Database must be **reset between tests**

Avoid unnecessary complexity.

Do NOT use:

- Supertest
- Testcontainers
- Mock DB libraries

---

# Testing Stack

Use the following tools:

| Tool | Purpose |
| --- | --- |
| Vitest | test runner |
| Prisma client | DB access |
| Docker Compose | test Postgres instance |

---

# Directory Structure

Create the following structure at the repo root:

```
tests/
  setup/
    db.ts
  routes/
    products.test.ts
  unit/
    example.test.ts

vitest.config.ts
.env.test
docker-compose.test.yml
```

---

# Step 1 — Install Dependencies

Install Vitest:

```
pnpm add -D vitest
```

---

# Step 2 — Vitest Configuration

Create:

```
vitest.config.ts
```

Implementation:

```
import {defineConfig }from"vitest/config"

exportdefaultdefineConfig({
  test: {
    environment:"node",
    globals:true,
    include: ["tests/**/*.test.ts"]
  }
})
```

---

# Step 3 — Test Database

Create environment file:

```
.env.test
```

Example:

```
DATABASE_URL=postgresql://postgres:postgres@localhost:5433/geargarage_test
```

Note: use a **different port than development DB**.

---

# Step 4 — Docker Test Database

Create:

```
docker-compose.test.yml
```

Implementation:

```
version:"3.8"

services:
  postgres-test:
    image: postgres:16
    container_name: geargarage-postgres-test
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: geargarage_test
    ports:
      -"5433:5432"
```

---

# Step 5 — Database Setup Helper

Create:

```
tests/setup/db.ts
```

Purpose:

- provide Prisma client
- reset database between tests

Implementation:

```
import {PrismaClient }from"@prisma/client"

exportconstprisma=newPrismaClient()

exportasyncfunctionresetDB() {

consttables=awaitprisma.$queryRaw<
    { tablename:string }[]
  >`SELECT tablename FROM pg_tables WHERE schemaname='public'`

for (const { tablename }oftables) {

if (tablename!=="_prisma_migrations") {

awaitprisma.$executeRawUnsafe(
`TRUNCATE TABLE "${tablename}" CASCADE`
      )

    }

  }

}
```

---

# Step 6 — Unit Test Example

Create:

```
tests/unit/example.test.ts
```

Example:

```
import {describe,it,expect }from"vitest"

functionadd(a:number,b:number) {
returna+b
}

describe("math", () => {

it("adds numbers", () => {

expect(add(2,3)).toBe(5)

  })

})
```

Unit tests should cover:

- validation logic
- helper functions
- business logic utilities

They should **not access the database**.

---

# Step 7 — Route Integration Tests

Route tests should:

- seed the database
- call route handler directly
- assert response

Create:

```
tests/routes/products.test.ts
```

Example:

```
import {describe,it,expect,beforeEach }from"vitest"
import {GET }from"@/app/api/products/route"
import {prisma,resetDB }from"../setup/db"

describe("GET /api/products", () => {

beforeEach(async () => {

awaitresetDB()

  })

it("returns inserted products",async () => {

awaitprisma.product.create({
      data: {
        name:"Durston Kakwa 55"
      }
    })

constreq=newRequest("http://localhost/api/products")

constres=awaitGET(req)

constbody=awaitres.json()

expect(res.status).toBe(200)
expect(body.length).toBe(1)

  })

})
```

---

# Step 8 — Package.json Scripts

Add test commands:

```
{
  "scripts": {
    "test":"vitest run",
    "test:watch":"vitest"
  }
}
```

---

# Step 9 — Running Tests

Start the test database:

```
docker compose -f docker-compose.test.yml up -d
```

Run migrations:

```
make db-migrate
```

Run tests:

```
pnpm test
```

---

# Testing Workflow

Typical test flow:

```
Start test DB
↓
Run migrations
↓
Seed test data
↓
Call route handler
↓
Assert response
↓
Reset DB
```

---

# Expected Result

Running:

```
pnpm test
```

should execute:

- unit tests
- route tests
- DB integration tests

All tests should run against the **test database container** and must not affect the development database.