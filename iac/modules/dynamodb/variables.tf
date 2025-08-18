# modules/dynamodb/variables.tf

variable "environment" {
  description = "The deployment environment (dev, stage, prod)."
  type        = string
}

variable "project" {
  description = "The project name."
  type        = string
}

variable "table_name" {
  description = "The name of the DynamoDB table."
  type        = string
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key."
  type        = string
}

variable "attributes" {
  description = "Set of nested attribute definitions for the table."
  type = list(object({
    name = string
    type = string
  }))
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput. PAY_PER_REQUEST or PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"
}

/*
variable "range_key" {
  description = "The attribute to use as the range (sort) key."
  type        = string
  default     = null # Optional
}
*/