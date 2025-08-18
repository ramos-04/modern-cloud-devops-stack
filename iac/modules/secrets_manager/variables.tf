# modules/secrets_manager/variables.tf

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)."
  type        = string
}

