# modules/eks/outputs.tf

output "cluster_id" {
  description = "The id of the EKS cluster."
  value       = module.eks_cluster.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks_cluster.cluster_name
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = module.eks_cluster.cluster_arn
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster API."
  value       = module.eks_cluster.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "OIDC provider arn of the EKS cluster"
  value       = module.eks_cluster.oidc_provider_arn
}


output "oidc_provider_url" {
  description = "OIDC provider issuer URL of the EKS cluster"
  value       = module.eks_cluster.oidc_provider
}

output "cluster_security_group_id" {
  description = "The ID of the cluster security group."
  value       = module.eks_cluster.cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate authority data for the EKS cluster."
  value       = module.eks_cluster.cluster_certificate_authority_data
}

output "cluster_auth_token" {
  description = "Authentication token for the EKS cluster (retrieved via aws_eks_cluster_auth)."
  value       = data.aws_eks_cluster_auth.cluster_auth_token.token
  sensitive   = true
}