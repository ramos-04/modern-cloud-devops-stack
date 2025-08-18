# modules/cognito_core/variables.tf

variable "user_pool_name" {
  description = "Name of the Cognito User Pool."
  type        = string
}

variable "domain_prefix" {
  description = "Base domain prefix for the Cognito User Pool (e.g., your-app-dev)."
  type        = string
}

variable "unique_suffix" {
  description = "A unique suffix to ensure the Cognito domain is globally unique."
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)."
  type        = string
}
