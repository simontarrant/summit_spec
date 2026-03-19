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
# SECURITY GROUPS
############################

# ECS SG (public API access)
resource "aws_security_group" "ecs" {
  name   = "summit-spec-ecs-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Public API access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB SG (only ECS can access)
resource "aws_security_group" "db" {
  name   = "summit-spec-db-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description     = "Postgres from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# DB SUBNET GROUP
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

############################
# ECR
############################

resource "aws_ecr_repository" "api" {
  name         = "summit-spec-api"
  force_delete = true
}

############################
# CLOUDWATCH LOGS
############################

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/summit-spec-api"
  retention_in_days = 7
}

############################
# ECS
############################

resource "aws_ecs_cluster" "main" {
  name = "summit-spec"
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "summit-spec-ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "api" {
  family                   = "summit-spec-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "api"
    image     = "${aws_ecr_repository.api.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 8080
      protocol      = "tcp"
    }]

    environment = [
      { name = "PORT", value = "8080" },
      {
        name  = "DATABASE_URL",
        value = "postgresql://${var.db_user}:${var.db_password}@${aws_db_instance.postgres.address}:5432/summit_spec"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.api.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "api"
      }
    }
  }])
}

resource "aws_ecs_service" "api" {
  name            = "summit-spec-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
}