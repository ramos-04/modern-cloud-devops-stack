# modules/ssm_parameter_store/main.tf

resource "aws_ssm_parameter" "this" {
  name        = "/sample/app_name"
  description = "a sample parameter store object for the app"
  type        = "String"
  #value       = "abc"  # Empty value to be manually updated in Console
  value = jsonencode({
    AWS_REGION          = var.aws_region
    DYNAMODB_TABLE_NAME = var.dynamodb_table_name
  })
  overwrite = true
  tags = {
    environment = var.environment
  }
}