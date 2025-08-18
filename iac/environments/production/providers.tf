# environments/production/providers.tf

# Use stable, recent versions for providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # TLS provider for self-signed certificate generation
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host = module.eks.cluster_endpoint
    #config_path = "~/.kube/config"
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = module.eks.cluster_auth_token
  }
}

provider "kubernetes" {
  host = module.eks.cluster_endpoint
  #config_path = "~/.kube/config"
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = module.eks.cluster_auth_token
}

data "aws_caller_identity" "current" {}