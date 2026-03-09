# Getting started

## Prerequisites

- you must have docker installed and running
- you must have nodejs (v18+) and npm installed

## Running

- run `make help` to see all commands

## Seeded Users

Login with the seeded user:

```
[
    {
      email: "simon@example.com",
      username: "simon",
      name: "Simon",
      password: "password123",
    },
    {
      email: "test@example.com",
      username: "testuser",
      name: "Test User",
      password: "test123",
    },
  ]
```

## Infrastructure

Terraform provisions AWS RDS.
This setup is intended for the single online `prod` environment in `ap-southeast-2`.
Use local Postgres on your machine for `dev`/`local` by setting `DATABASE_URL` accordingly.

Setup:

```bash
cd infra
terraform init
terraform apply
```

Terraform outputs the DB host.

Construct connection string:

```text
postgres://USER:PASSWORD@HOST:5432/summit_spec
```

## Deployment Workflow

Provision infrastructure:

```bash
cd infra
terraform init
terraform apply
```

Get database endpoint:

```bash
terraform output db_host
```

Construct connection string:

```text
postgres://postgres:PASSWORD@HOST:5432/summit_spec
```

Add to Vercel:

```text
Project Settings -> Environment Variables
DATABASE_URL=<connection string>
```

Deploy app by pushing to GitHub so Vercel auto-deploys.

## Migration Workflow

Continue using Goose:

```bash
make db-migrate
```

or:

```bash
goose postgres $DATABASE_URL up
```
