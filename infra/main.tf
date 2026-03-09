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

  name = "summit-spec-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["ap-southeast-2a", "ap-southeast-2b"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
}

############################
# SECURITY GROUP
############################

resource "aws_security_group" "db" {
  name   = "summit-spec-db-sg"
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
  name       = "summit-spec-subnets"
  subnet_ids = module.vpc.public_subnets
}

############################
# RDS POSTGRES
############################

resource "aws_db_instance" "postgres" {
  identifier = "summit-spec-db"

  engine         = "postgres"
  engine_version = "16"

  instance_class = "db.t4g.micro"

  allocated_storage = 20

  db_name  = "summit_spec"
  username = var.db_user
  password = var.db_password

  publicly_accessible = true
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
}
