# environments/dev/outputs.tf

output "eks_cluster_name_output" {
  value = module.eks.cluster_id
}

output "dynamodb_table_id_output" {
  value = module.dynamodb.table_id
}

output "dynamodb_table_arn_output" {
  value = module.dynamodb.table_arn
}

output "ecr_repo_url_output" {
  value = module.ecr.repository_url
}

output "aws_region_output" {
  description = "AWS region for the deployment."
  value       = var.aws_region
}

output "dynamodb_table_name_output" {
  description = "Name of the DynamoDB table"
  value       = var.dynamodb_table_name
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
  value = module.waf.web_acl_arn_ouput
}

