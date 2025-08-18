# modules/dynamodb/main.tf

module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 4.0" # Use a recent stable version

  name     = "${var.environment}-${var.table_name}"
  hash_key = var.hash_key
  #range_key = var.range_key

  attributes = var.attributes

  /*
  attributes = {
       name = "shortid"
       type = "S"
  }
*/

  billing_mode = var.billing_mode

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}