# modules/cognito_core/outputs.tf

output "user_pool_arn" {
  value       = aws_cognito_user_pool.this.arn
  description = "ARN of the Cognito User Pool."
}

output "user_pool_id" {
  value       = aws_cognito_user_pool.this.id
  description = "ID of the Cognito User Pool."
}

output "user_pool_domain_url" {
  value       = aws_cognito_user_pool_domain.this.domain
  description = "Full domain URL of the Cognito User Pool."
}
