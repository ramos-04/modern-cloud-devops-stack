# modules/common_vpc/outputs.tf

output "vpc_id" {
  description = "The ID of the default VPC."
  value       = data.aws_vpc.default.id
}

output "public_subnet_ids" {
  description = "A list of public subnet IDs in the default VPC."
  value       = [for s in data.aws_subnets.default.ids : s]
}

output "default_security_group_id" {
  description = "The ID of the default security group in the default VPC."
  value       = data.aws_security_group.default.id
}