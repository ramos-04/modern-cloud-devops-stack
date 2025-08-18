# modules/iam_for_k8s_service_account/variables.tf

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)."
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the EKS OIDC provider."
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the EKS OIDC provider."
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace where the service account will reside."
  type        = string
}

variable "service_account_name" {
  description = "The name of the Kubernetes service account."
  type        = string
}

variable "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table the service account needs access to."
  type        = string
}

variable "secret_manager_arn" {
  description = "The ARN of the secret manager object"
  type        = string
}

variable "ssm_parameter_store_arn" {
  description = "The ARN of the SSM parameter store object"
  type        = string
}