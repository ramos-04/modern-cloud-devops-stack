# modules/alb/outputs.tf

output "alb_dns_name" {
  value       = module.alb.lb_dns_name
  description = "The DNS name of the ALB."
}

output "alb_arn" {
  value       = module.alb.lb_arn
  description = "The ARN of the ALB."
}

output "alb_arn_suffix" {
  value       = module.alb.lb_arn_suffix
  description = "The ARN suffix of the ALB."
}

output "alb_target_group_arns" {
  value       = module.alb.target_group_arns
  description = "List of ARNs of the ALB target groups."
}

output "acm_certificate_arn" {
  value       = aws_acm_certificate.this.arn
  description = "The ARN of the self-signed ACM certificate used by the ALB."
}

output "alb_https_listener_arns" {
  value       = module.alb.https_listener_arns
  description = "The ALB HTTPS listener arns"
}