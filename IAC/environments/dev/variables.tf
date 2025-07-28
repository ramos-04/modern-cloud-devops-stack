# environments/dev/variables.tf

variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
}

variable "environment" {
  description = "The name of the environment (dev, stage, prod)."
  type        = string
}

variable "project_name" {
  description = "The overall project name."
  type        = string
  default     = "modern-cloud-devops-stack"
}

# EKS variables
variable "kubernetes_version" {
  description = "kubernetes version in the EKS cluster"
  type        = string
}

variable "eks_instance_types" {
  description = "EC2 instance types for EKS worker nodes."
  type        = list(string)
  default     = ["m5.large"]
}

variable "eks_min_node_count" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "eks_max_node_count" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "eks_desired_node_count" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "eks_node_disk_size" {
  description = "Disk size for EKS worker nodes in GB."
  type        = number
  default     = 50
}

variable "k8s_namespace" {
  description = "Kubernetes namespace for the URL shortener application."
  type        = string
  default    = "dev"
}

variable "k8s_service_account_name" {
  description = "Kubernetes service account name for the URL shortener application."
  type        = string
  default     = "sa-url-shortener"
}

# DynamoDB variables
variable "dynamodb_table_name" {
  description = "Base name for the DynamoDB table."
  type        = string
  default     = "application-data"
}

variable "dynamodb_hash_key" {
  description = "Hash key for the DynamoDB table."
  type        = string
  default     = "short_code"
}

variable "dynamodb_attributes" {
  description = "Attributes for the DynamoDB table."
  type = list(object({
    name = string
    type = string
  }))
  default = [
    { name = "short_code", type = "S" },
    # Add other attributes as needed, e.g., { name = "sort_key", type = "S" }
  ]
}

variable "dynamodb_billing_mode" {
  description = "Billing mode for DynamoDB table (PAY_PER_REQUEST or PROVISIONED)."
  type        = string
  default     = "PAY_PER_REQUEST"
}

# ALB variables
variable "alb_name" {
  description = "Name for the ALB."
  type        = string
  default     = "app-load-balancer"
}

# ECR variables
variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
}