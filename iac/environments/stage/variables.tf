# environments/stage/variables.tf

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

variable "addons_repo_url" {
  description = "repo url of add-ons"
  type        = string
}

variable "addons_repo_basepath" {
  description = "Repo base path of add-ons"
  type        = string
  default     = "gitops/appsets"
}

variable "addons_repo_path" {
  description = "Repo path of add-ons"
  type        = string
  default     = "stage"
}

variable "addons_repo_revision" {
  type        = string
  description = "Repo revision of add-ons"
  default     = "main"
}

variable "workload_repo_url" {
  description = "repo url of workloads"
  type        = string
}

variable "workload_repo_basepath" {
  description = "Repo base path of workloads"
  type        = string
  default     = "gitops/appsets"
}

variable "workload_repo_path" {
  description = "Repo path of workloads"
  type        = string
  default     = "stage"
}

variable "workload_repo_revision" {
  type        = string
  description = "Repo revision of workloads"
  default     = "main"
}

variable "addons" {
  description = "Kubernetes cluster addons"
  type        = any
  default = {
    enable_secrets_store_csi_driver_provider_aws = true
    enable_secrets_store_csi_driver              = true
    enable_argocd                                = true
  }
}

variable "addons_applicationset_path" {
  type        = string
  description = "Path of the application set file for addons"
  default     = "../../../gitops/appsets/stage/addons/applicationset_stage_addons.yaml"
}

variable "workload_applicationset_path" {
  type        = string
  description = "Path of the application set file for application workloads"
  default     = "../../../gitops/appsets/stage/apps/applicationset_stage_apps.yaml"
}

# Toggle to enable or disable WAF. Turn this flag on when you wish to launch a WAF resource, else turn if off.
variable "enable_waf" {
  description = "Toggle to create or delete the WAF resource"
  type        = bool
  default     = true
}

# Toggle to enable or disable ECR. Turn this flag on when you wish to launch an ECR resource, else turn if off.
variable "enable_ecr" {
  type    = bool
  default = false
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
  default     = "stage"
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
  default     = "ecr-repo-url-shortener"
}