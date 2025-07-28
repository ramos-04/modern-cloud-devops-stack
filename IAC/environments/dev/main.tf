# environments/dev/main.tf


# Procure default VPC details
module "common_vpc" {
  source = "../../modules/common_vpc"
}


# Call the EKS Cluster module
module "eks" {
  source  = "../../modules/eks"
  environment               = var.environment
  project                   = var.project_name
  vpc_id                    = module.common_vpc.vpc_id
  subnet_ids                = module.common_vpc.public_subnet_ids
  #cluster_security_group_id = module.common_vpc.default_security_group_id # Using default SG for simplicity
  instance_types            = var.eks_instance_types
  min_node_count            = var.eks_min_node_count
  max_node_count            = var.eks_max_node_count
  desired_node_count        = var.eks_desired_node_count
  node_disk_size            = var.eks_node_disk_size
  kubernetes_version        = var.kubernetes_version
}


# Call the DynamoDB Table module
module "dynamodb" {
  source        = "../../modules/dynamodb"
  environment   = var.environment
  project       = var.project_name
  table_name    = var.dynamodb_table_name
  hash_key      = var.dynamodb_hash_key
  attributes    = var.dynamodb_attributes
  billing_mode  = var.dynamodb_billing_mode
}


# Call the 'IAM for K8s Service Account' module (IRSA) 
module "iam_for_k8s_service_account" {
  source               = "../../modules/iam_for_k8s_service_account"
  environment          = var.environment
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider_url
  namespace            = var.k8s_namespace
  service_account_name = var.k8s_service_account_name
  dynamodb_table_arn   = module.dynamodb.table_arn
}


# Call the ECR module
module "ecr" {
  source           = "../../modules/ecr"
  repository_name  = var.ecr_repository_name
  environment      = var.environment
  project          = var.project_name
}


# Call the ALB module
module "alb" {
  source                    = "../../modules/alb"
  alb_name                  = var.alb_name
  project                   = var.project_name
  vpc_id                    = module.common_vpc.vpc_id
  subnet_ids                = module.common_vpc.public_subnet_ids
  environment               = var.environment
  web_acl_arn_input_to_alb  = module.waf.web_acl_arn_ouput
}

# Call the WAF module
module "waf" {
  source       = "../../modules/waf"
  web_acl_name = "${var.environment}-url-shortener-web-acl"
  environment  = var.environment
}


# Call the Cognito Core module 
module "cognito_core" {
  source          = "../../modules/cognito_core"
  user_pool_name  = "${var.environment}-url-shortener-users"
  domain_prefix   = "${var.environment}-url-shortener-auth"
  unique_suffix   = random_string.cognito_domain_suffix.result
  environment     = var.environment
}


# Create the Cognito User Pool Client directly in this environment's main.tf
# This allows us to use depends_on to explicitly manage the dependency on ALB. This helps in solving the circular dependency between ALB and Cognito
resource "aws_cognito_user_pool_client" "url_shortener_client" {
  name                                 = "${var.environment}-url-shortener-client"
  user_pool_id                         = module.cognito_core.user_pool_id
  generate_secret                      = true
  explicit_auth_flows                  = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
  prevent_user_existence_errors        = "ENABLED"

  # Callback URL now directly references the ALB DNS name
  callback_urls                        = ["https://${module.alb.alb_dns_name}/oauth2/idpresponse"]

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]

  supported_identity_providers         = ["COGNITO"]

  # Explicitly depends on the ALB module to ensure its DNS name is available when this resource is created/updated.
  depends_on                           = [module.alb]
}


# Re-configure the ALB listener with the correct Cognito details
# This resource will implicitly depend on `module.alb` and `aws_cognito_user_pool_client.url_shortener_client`
resource "aws_lb_listener_rule" "cognito_auth_rule" {
  #listener_arn = "${module.alb.alb_arn}:listener/app/${module.alb.alb_name}/${module.alb.lb_arn_suffix}/443" # Assuming HTTPS listener is on 443  
  listener_arn = module.alb.alb_https_listener_arns[0]
  priority = 100 # A priority lower than default rules

  action {
    type = "authenticate-cognito"
    authenticate_cognito {
      user_pool_arn       = module.cognito_core.user_pool_arn
      user_pool_client_id = aws_cognito_user_pool_client.url_shortener_client.id
      user_pool_domain    = module.cognito_core.user_pool_domain_url
      on_unauthenticated_request = "authenticate"
    }
  }

  action {
    type = "forward"
    target_group_arn = module.alb.alb_target_group_arns[0] # Forward to the first target group
  }

  condition {
    path_pattern {
      values = ["/*"] # Apply to all paths
    }
  }
}


# Define the random_string resource here, outside any module call
resource "random_string" "cognito_domain_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}



