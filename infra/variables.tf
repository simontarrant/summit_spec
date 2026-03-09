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
