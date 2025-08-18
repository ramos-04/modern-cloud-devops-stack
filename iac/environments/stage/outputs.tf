# environments/stage/outputs.tf

output "eks_cluster_id_output" {
  value = module.eks.cluster_id
}

output "eks_cluster_name_output" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "dynamodb_table_id_output" {
  value = module.dynamodb.table_id
}

output "dynamodb_table_arn_output" {
  value = module.dynamodb.table_arn
}

output "ecr_repo_url_output" {
  value = var.enable_ecr ? module.ecr[0].repository_url : null
}

output "aws_region_output" {
  description = "AWS region for the deployment."
  value       = var.aws_region
}

output "alb_dns_name_output" {
  description = "The DNS name of the ALB."
  value       = module.alb.alb_dns_name
}

output "alb_arn_output" {
  description = "The ARN of the ALB."
  value       = module.alb.alb_arn
}

output "alb_target_group_arns_output" {
  description = "List of ARNs of the ALB target groups."
  value       = module.alb.alb_target_group_arns
}

output "alb_https_listener_arns_output" {
  description = "List of ARNs of the ALB HTTPS Listeners"
  value       = module.alb.alb_https_listener_arns
}

output "cognito_user_pool_domain_url_output" {
  value = module.cognito_core.user_pool_domain_url
}

output "waf_web_acl_arn_output" {
  value = length(module.waf) > 0 ? module.waf[0].web_acl_arn_ouput : null
}

output "IRSA_role_arn_output" {
  value = module.iam_for_k8s_service_account.iam_role_arn
}