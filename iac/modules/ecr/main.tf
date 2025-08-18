# modules/ecr/main.tf

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}