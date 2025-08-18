# modules/dynamodb/outputs.tf

output "table_id" {
  description = "The ID of the DynamoDB table."
  value       = module.dynamodb_table.dynamodb_table_id
}

output "table_arn" {
  description = "The ARN of the DynamoDB table."
  value       = module.dynamodb_table.dynamodb_table_arn
}