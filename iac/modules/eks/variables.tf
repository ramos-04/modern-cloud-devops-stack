# modules/eks/variables.tf

variable "environment" {
  description = "The deployment environment (dev, stage, prod)."
  type        = string
}

variable "project" {
  description = "The project name."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC for the EKS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster."
  type        = list(string)
}

variable "instance_types" {
  description = "List of EC2 instance types for the EKS worker nodes."
  type        = list(string)
  default     = ["m5.large"]
}

variable "min_node_count" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "desired_node_count" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "node_disk_size" {
  description = "Disk size for EKS worker nodes in GB."
  type        = number
  default     = 50
}

/*
variable "cluster_security_group_id" {
  description = "The ID of the security group for the EKS cluster."
  type        = string
}
*/