# Task: Add AWS RDS + Terraform IaC + Vercel deployment support

## Objective

Update this repository to support:

1. **Infrastructure as Code**
    - Terraform provisions AWS infrastructure
    - Includes:
        - VPC
        - security group
        - RDS Postgres instance
2. **Application deployment**
    - Next.js deployed on **Vercel**
    - Backend connects to **AWS RDS**
3. **Database migrations**
    - Continue using **Goose migrations**
    - Do NOT use Prisma migrations
4. **Environment configuration**
    - `DATABASE_URL` used by both
        - local dev
        - Vercel deployment

---

# Required repository structure

Create the following directories:

```
infra/
    main.tf
    variables.tf
    outputs.tf
    terraform.tfvars.example

.env.example
vercel.json
```

Do not modify existing app code unless needed for DB config.

---

# 1. Add Terraform infrastructure

Create folder:

```
infra/
```

---

# infra/main.tf

```
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

############################
# VPC
############################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "gear-garage-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-2a", "ap-southeast-2b"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
}

############################
# SECURITY GROUP
############################

resource "aws_security_group" "db" {
  name   = "gear-garage-db-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Postgres access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"] # dev only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# SUBNET GROUP
############################

resource "aws_db_subnet_group" "db_subnets" {
  name       = "gear-garage-subnets"
  subnet_ids = module.vpc.public_subnets
}

############################
# RDS POSTGRES
############################

resource "aws_db_instance" "postgres" {

  identifier = "gear-garage-db"

  engine         = "postgres"
  engine_version = "16"

  instance_class = "db.t4g.micro"

  allocated_storage = 20

  db_name  = "gear_garage"
  username = var.db_user
  password = var.db_password

  publicly_accessible = true
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
}
```

---

# infra/variables.tf

```
variable "aws_region" {
  default = "ap-southeast-2"
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
```

---

# infra/outputs.tf

```
output "db_host" {
  value = aws_db_instance.postgres.address
}

output "db_port" {
  value = aws_db_instance.postgres.port
}

output "db_name" {
  value = aws_db_instance.postgres.db_name
}
```

---

# infra/terraform.tfvars.example

```
db_user = "postgres"
db_password = "change_me"
```

---

# 2. Environment variables

Create:

```
.env.example
```

```
DATABASE_URL=postgres://postgres:PASSWORD@HOST:5432/gear_garage
```

---

# 3. Vercel configuration

Create:

```
vercel.json
```

```
{
  "env": {
    "DATABASE_URL": "@database_url"
  }
}
```

The actual value will be configured in the Vercel dashboard.

---

# 4. README additions

Add a new section:

```
## Infrastructure

Terraform provisions AWS RDS.

Setup:

cd infra

terraform init
terraform apply
```

Terraform outputs the DB host.

Construct connection string:

```
postgres://USER:PASSWORD@HOST:5432/gear_garage
```

---

# 5. Deployment workflow

Deployment process will be:

### Provision infrastructure

```
cd infra

terraform init
terraform apply
```

---

### Get database endpoint

```
terraform output db_host
```

---

### Construct connection string

```
postgres://postgres:PASSWORD@HOST:5432/gear_garage
```

---

### Add to Vercel

```
Project Settings → Environment Variables
DATABASE_URL=<connection string>
```

---

### Deploy app

Push to GitHub → Vercel auto deploys.

---

# 6. Migration workflow

Continue using Goose:

```
make db-migrate
```

or

```
goose postgres $DATABASE_URL up
```

---

# 7. Important constraints

Codex must NOT:

- introduce Prisma migrations
- change Goose workflow
- modify DB schema files
- modify existing migrations

---

# 8. Expected outcome

After completion:

```
infra/
    main.tf
    variables.tf
    outputs.tf
```

Running:

```
terraform apply
```

creates:

```
AWS VPC
AWS Security Group
AWS RDS Postgres instance
```

Next.js on Vercel connects via `DATABASE_URL`.