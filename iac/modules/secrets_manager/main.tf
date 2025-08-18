# modules/secrets_manager/main.tf

# Create a sample secret in AWS Secrets Manager
resource "aws_secretsmanager_secret" "this" {
  name        = "poc_app_secret"
  description = "Credentials for the app"
  tags = {
    environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id

  # Hardcoded keys with empty values
  secret_string = jsonencode({
    "username" = "",
    "password" = ""
  })
}