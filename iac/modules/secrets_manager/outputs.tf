# modules/secrets_manager/main.tf

output "secret_manager_arn_output" {
  value       = aws_secretsmanager_secret.this.arn
  description = "ARN of the Secret"
}