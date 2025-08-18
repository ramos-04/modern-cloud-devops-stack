# modules/ssm_parameter_store/variables.tf

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)."
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  type        = string
}

variable "aws_region" {
  description = "The name of the AWS region"
  type        = string
}