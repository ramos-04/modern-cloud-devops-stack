# modules/eks/main.tf

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

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  control_plane_subnet_ids        = var.subnet_ids
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

data "aws_eks_cluster_auth" "cluster_auth_token" {
  name = module.eks_cluster.cluster_name
}
