# modules/waf/variables.tf

variable "web_acl_name" {
  description = "Name of the WAF Web ACL."
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)."
  type        = string
}
