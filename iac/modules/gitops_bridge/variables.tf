# modules/gitops_bridge/variables.tf

variable "project_name" {
  description = "The overall project name."
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "addons_repo_url" {
  description = "repo url of add-ons"
  type        = string
}

variable "addons_repo_basepath" {
  description = "Repo base path of add-ons"
  type        = string
}

variable "addons_repo_path" {
  description = "Repo path of add-ons"
  type        = string
}

variable "addons_repo_revision" {
  type        = string
  description = "Repo revision of add-ons"
}

variable "workload_repo_url" {
  description = "repo url of workloads"
  type        = string
}

variable "workload_repo_basepath" {
  description = "Repo base path of workloads"
  type        = string
}

variable "workload_repo_path" {
  description = "Repo path of workloads"
  type        = string
}

variable "workload_repo_revision" {
  type        = string
  description = "Repo revision of workloads"
}

variable "addons_applicationset_path" {
  type        = string
  description = "Path of the application set file for addons"
}

variable "workload_applicationset_path" {
  type        = string
  description = "Path of the application set file for application workloads"
}

variable "kubernetes_version" {
  description = "kubernetes version in the EKS cluster"
  type        = string
}

variable "cluster_name" {
  description = "name of the eks cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "endpoint of the eks cluster"
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

/*
variable "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate authority data for the EKS cluster."
  type        = string
}

variable "cluster_auth_token" {
  description = "Authentication token for the EKS cluster (retrieved via aws_eks_cluster_auth)."
  type        = string
}
*/

variable "addons" {
  description = "Kubernetes cluster addons"
  type        = any
}

variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be deployed."
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

