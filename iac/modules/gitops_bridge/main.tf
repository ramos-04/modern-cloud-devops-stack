# modules/gitops_bridge/main.tf

# NOTE: Configure `gitops_repo` with your actual repository URL.

locals {
  name   = var.project_name
  region = var.aws_region

  cluster_version = var.kubernetes_version
  cluster_name    = var.cluster_name
  #vpc_cidr = var.vpc_cidr

  gitops_addons_url      = var.addons_repo_url
  gitops_addons_basepath = var.addons_repo_basepath
  gitops_addons_path     = var.addons_repo_path
  gitops_addons_revision = var.addons_repo_revision

  gitops_workload_url      = var.workload_repo_url
  gitops_workload_basepath = var.workload_repo_basepath
  gitops_workload_path     = var.workload_repo_path
  gitops_workload_revision = var.workload_repo_revision

  aws_addons = {
    enable_secrets_store_csi_driver_provider_aws = try(var.addons.enable_secrets_store_csi_driver_provider_aws, false)
  }

  oss_addons = {
    enable_argocd                   = try(var.addons.enable_argocd, true)
    enable_secrets_store_csi_driver = try(var.addons.enable_secrets_store_csi_driver, false)
  }

  addons = merge(
    #local.aws_addons,
    #local.oss_addons,
    { kubernetes_version = local.cluster_version },
    { aws_cluster_name = local.cluster_name }
  )

  addons_metadata = merge(
    #module.eks_blueprints_addons.gitops_metadata,
    {
      aws_cluster_name = local.cluster_name
      aws_region       = local.region
      aws_account_id   = var.aws_account_id
      aws_vpc_id       = var.vpc_id
    },
    {
      addons_repo_url      = local.gitops_addons_url
      addons_repo_basepath = local.gitops_addons_basepath
      addons_repo_path     = local.gitops_addons_path
      addons_repo_revision = local.gitops_addons_revision
    },
    {
      workload_repo_url      = local.gitops_workload_url
      workload_repo_basepath = local.gitops_workload_basepath
      workload_repo_path     = local.gitops_workload_path
      workload_repo_revision = local.gitops_workload_revision
    }
  )

  argocd_apps = {
    #addons    = file("../../../gitops/appsets/stage/addons/applicationset_stage_addons.yaml")
    #workloads = file("../../../gitops/appsets/stage/apps/applicationset_stage_apps.yaml")
    addons    = file("${var.addons_applicationset_path}")
    workloads = file("${var.workload_applicationset_path}")
  }

  tags = {
    Project = local.name
  }

}


/*
# module to install cluster add-ons in eks cluster. Please note that this module is only used to install add-ons. It does not provision an eks cluster. To provision an eks cluster, you can use 'aws-ia/eks-blueprints' module.
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = local.cluster_name
  cluster_endpoint  = var.cluster_endpoint
  cluster_version   = local.cluster_version
  oidc_provider_arn = var.oidc_provider_arn

  # Using GitOps Bridge
  create_kubernetes_resources = false

  # EKS Blueprints Addons
  enable_secrets_store_csi_driver                = local.oss_addons.enable_secrets_store_csi_driver
  enable_secrets_store_csi_driver_provider_aws   = local.aws_addons.enable_secrets_store_csi_driver_provider_aws

  tags = local.tags
}
*/


module "gitops_bridge" {
  source  = "gitops-bridge-dev/gitops-bridge/helm"
  version = "0.1.0"

  cluster = {
    metadata = local.addons_metadata
    addons   = local.addons
  }
  apps = local.argocd_apps
}

