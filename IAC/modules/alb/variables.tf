# modules/alb/variables.tf

variable "alb_name" {
  description = "Name of the Application Load Balancer."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the ALB."
  type        = list(string)
}

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)."
  type        = string
}

variable "project" {
  description = "The project name."
  type        = string
}

variable "web_acl_arn_input_to_alb" {
  description = "The web acl arn."
  type        = string
}
