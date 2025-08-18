# modules/ecr/variables.tf

variable "environment" {
  description = "The deployment environment (dev, stage, prod)."
  type        = string
}

variable "project" {
  description = "The project name."
  type        = string
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}


