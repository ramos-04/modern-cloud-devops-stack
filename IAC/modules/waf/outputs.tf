# modules/waf/outputs.tf

output "web_acl_arn_ouput" {
  value       = aws_wafv2_web_acl.this.arn
  description = "The ARN of the WAF Web ACL."
}

output "web_acl_id" {
  value       = aws_wafv2_web_acl.this.id
  description = "The ID of the WAF Web ACL."
}
