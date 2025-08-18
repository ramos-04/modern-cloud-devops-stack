# modules/waf/main.tf

resource "aws_wafv2_web_acl" "this" {
  name        = var.web_acl_name
  description = "WAF Web ACL for ${var.environment} URL Shortener"
  scope       = "REGIONAL" # Use REGIONAL for ALB, CLOUDFRONT for CloudFront distributions
  default_action {
    allow {} # Default action is to allow requests that don't match any rules
  }

  # Add the top-level visibility_config for the Web ACL itself
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.web_acl_name}-metrics" # Unique metric name for the Web ACL
    sampled_requests_enabled   = true
  }

  # Common AWS Managed Rule Groups
  # These are pre-configured rules managed by AWS to protect against common threats.

  # AWSManagedRulesCommonRuleSet: Provides protection against a broad range of common vulnerabilities
  # such as SQL injection, cross-site scripting (XSS), and HTTP floods.

  /*
  rule {
    name     = "AWS-Managed-CommonRuleSet"
    priority = 10 # Lower priority means it's evaluated earlier
    override_action {
      none {} # Use the default action of the rule group (usually BLOCK)
    }
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  */


  # Example Custom Rule: Block specific IP address (for testing)
  # This rule will block requests coming from a specific IP address.
  # In a real scenario, you'd manage IP sets dynamically or use more sophisticated rules.
  rule {
    name     = "BlockSpecificIP"
    priority = 50
    action {
      block {} # Action to block the request
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blocked_ips.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockSpecificIP"
      sampled_requests_enabled   = true
    }
  }

  # Example Custom Rule: Rate-based rule to mitigate DDoS or brute-force attacks
  # This rule counts requests from a single IP address over a 5-minute period.
  # If the rate exceeds the limit, subsequent requests are blocked.

  /*
  rule {
    name     = "RateLimit"
    priority = 60
    action {
      block {} # Action to block requests exceeding the rate limit
    }
    statement {
      rate_based_statement {
        limit = 200 # Max 200 requests from an IP in 5 minutes
        aggregate_key_type = "IP" # Aggregate based on source IP address
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }
  */

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# IP Set for blocking specific IPs (MOVED OUTSIDE aws_wafv2_web_acl resource)
resource "aws_wafv2_ip_set" "blocked_ips" {
  name               = "${var.environment}-blocked-ips"
  description        = "IP set for blocking specific IPs for ${var.environment} environment"
  ip_address_version = "IPV4"
  scope              = "REGIONAL"
  # Add your IP addresses here. For testing, you can put your public IP.
  # Be careful not to block yourself!
  addresses = ["192.0.2.1/32"] # Example: Replace with an IP you want to test blocking
}
