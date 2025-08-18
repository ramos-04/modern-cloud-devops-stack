# modules/cognito_core/main.tf

# Cognito User Pool
resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${var.domain_prefix}-${var.unique_suffix}"
  user_pool_id = aws_cognito_user_pool.this.id

}
