# modules/iam_for_k8s_service_account/outputs.tf

output "iam_role_arn" {
  value       = aws_iam_role.this.arn
  description = "The ARN of the IAM role created for the Kubernetes Service Account."
}

