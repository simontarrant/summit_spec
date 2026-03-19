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

variable "cors_origin" {
  description = "Allowed CORS origin for the Go API (e.g. Vercel domain)"
  type        = string
  default     = "http://localhost:3000"
}
