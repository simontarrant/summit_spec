output "db_host" {
  value = aws_db_instance.postgres.address
}

output "db_port" {
  value = aws_db_instance.postgres.port
}

output "db_name" {
  value = aws_db_instance.postgres.db_name
}

output "database_url" {
  value       = "postgresql://${var.db_user}:${var.db_password}@${aws_db_instance.postgres.address}:5432/summit_spec"
  description = "Connection string for Postgres"
  sensitive   = true
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.api.repository_url
  description = "ECR repository URL for API Docker images"
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.api.name
}