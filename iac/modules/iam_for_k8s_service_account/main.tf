# modules/iam_for_k8s_service_account/main.tf

# Data source to get the AWS account ID
#data "aws_caller_identity" "current" {}

# IAM Role for the Kubernetes Service Account
resource "aws_iam_role" "this" {
  name = "${var.environment}-url-shortener-app-irsa-role"

  # The assume role policy allows the Kubernetes Service Account
  # to assume this IAM role.
  # The OIDC provider ARN comes from the EKS cluster module output.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
            "${replace(var.oidc_provider_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Service     = var.service_account_name
  }
}

# IAM Policy to allow access to DynamoDB
resource "aws_iam_policy" "dynamodb_access" {
  name        = "${var.environment}-${var.service_account_name}-dynamodb-policy"
  description = "IAM policy for ${var.service_account_name} to access DynamoDB table ${var.dynamodb_table_arn}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          var.dynamodb_table_arn,
          "${var.dynamodb_table_arn}/index/*" # For GSI access
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:ListTables" # Required for some SDK operations or initial checks
        ]
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory"
        ],
        Resource = [
          var.secret_manager_arn,
          var.ssm_parameter_store_arn
        ]
      }
    ]
  })

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Service     = var.service_account_name
  }
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

# Attach the AmazonEC2ContainerRegistryReadOnly policy to allow image pulls from ECR
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

