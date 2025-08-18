# modules/ssm_parameter_store/outputs.tf

output "ssm_parameter_store_arn_output" {
  value       = aws_ssm_parameter.this.arn
  description = "ARN of the SSM Parameter Store"
}