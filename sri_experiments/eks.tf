
# EKS node group or other configurations can go here
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.1"

  cluster_name = var.cluster_name
  bootstrap_self_managed_addons = false
  vpc_id = var.vpc_id
  subnet_ids = var.subnet_ids 

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      # ami_type       = "AL2023_x86_64_STANDARD"
      # instance_types = ["m5.xlarge", "t3.medium"]
      instance_types = ["t3a.micro"]

      min_size     = 2
      max_size     = 5
      desired_size = 3
    }
  }
}

module "eks_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "20.31.1"

  cluster_name = var.cluster_name 
  cluster_version = "1.27"
  subnet_ids = var.subnet_ids 
  name = "managed-node-group"
  cluster_service_cidr = var.vpc_cidr

  key_name = var.keypair_name
}

