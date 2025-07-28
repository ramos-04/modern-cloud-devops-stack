# modules/eks/main.tf

/*
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

*/


resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.environment}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ecr_read_only_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# Tag for EKS cluster discovery
resource "aws_ec2_tag" "eks_subnets_cluster" {
  for_each    = toset(var.subnet_ids)
  resource_id = each.key
  key         = "kubernetes.io/cluster/${var.environment}-eks-cluster"
  value       = "owned"
}


module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0" # Use a recent stable version

  cluster_name    = "${var.environment}-eks-cluster"
  cluster_version = var.kubernetes_version

  #cluster_role_arn = aws_iam_role.eks_cluster_role.arn
  # Ensure the security group allows EKS control plane to communicate with worker nodes
  #cluster_security_group_id = [var.cluster_security_group_id]

  vpc_id           = var.vpc_id
  subnet_ids       = var.subnet_ids
  
  control_plane_subnet_ids = var.subnet_ids
  cluster_endpoint_public_access  = true  # Explicitly enable public access for EKS control plane
  cluster_endpoint_private_access = false # Explicitly disable private access for EKS control plane
  
  # If set to `true`, the IAM user or role that creates the EKS cluster will
  # automatically be granted `system:masters` permissions within the cluster's
  # Kubernetes RBAC. This simplifies initial access.
  enable_cluster_creator_admin_permissions = true

  # Enable IAM Roles for Service Accounts (IRSA)
  # This creates the OIDC provider for the cluster, allowing Kubernetes service accounts
  # to assume IAM roles.
  enable_irsa = true


  # EKS Managed Node Group
  eks_managed_node_groups = {
    default = {
      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"
      min_size       = var.min_node_count
      max_size       = var.max_node_count
      desired_size   = var.desired_node_count
      disk_size      = var.node_disk_size
      ami_type       = "AL2_x86_64"
      # Attach the node group role
      create_iam_role = false # We create the role above
      iam_role_arn    = aws_iam_role.eks_node_group_role.arn
      subnet_ids      = var.subnet_ids # Node groups should be in the same subnets as the cluster
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}


# This resource creates a dedicated Kubernetes namespace for the ArgoCD
# application within the EKS cluster. Namespaces provide a way to
# organize cluster resources and provide scope for names.
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}


# Helm Release for ArgoCD
# This resource uses the Terraform Helm provider to deploy the ArgoCD
# application into the Kubernetes cluster using its official Helm chart.
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "5.50.0" # Use a specific, compatible version for stability
  create_namespace = true

  depends_on = [kubernetes_namespace.argocd]
}


# Null Resource to Wait for ArgoCD Server Readiness
# This null_resource is a Terraform construct used to run arbitrary commands
# (provisioners) and introduce implicit dependencies. Here, it's used to
# pause Terraform execution until the ArgoCD server deployment is ready.
resource "null_resource" "wait_for_argocd_ready" {
  depends_on = [helm_release.argocd]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for ArgoCD server deployment to be ready (max 300s)..."
      kubectl wait --for=condition=Available deployment/argocd-server --namespace argocd --timeout=300s
      echo "ArgoCD server deployment is ready."
    EOT
    interpreter = ["bash", "-c"]
  }
}

data "kubernetes_secret" "argocd_initial_password" {
  metadata {
              name      = "argocd-initial-admin-secret"
              namespace = kubernetes_namespace.argocd.metadata[0].name
           }
  depends_on = [helm_release.argocd, null_resource.wait_for_argocd_ready]
}

data "kubernetes_service" "argocd_server" {
  metadata {
              name      = "argocd-server"
              namespace = kubernetes_namespace.argocd.metadata[0].name
           }
  depends_on = [helm_release.argocd, null_resource.wait_for_argocd_ready]
}

data "aws_eks_cluster_auth" "cluster_auth_token" {
  name = module.eks_cluster.cluster_name
}
