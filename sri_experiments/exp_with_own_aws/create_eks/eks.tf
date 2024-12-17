  
resource "aws_iam_role" "eks_cluster_role" {
  name = var.cluster_role_name
  # name = data.aws_iam_role.cluster_role.name

  # count = data.aws_iam_role.cluster_role.id != "" ? 0 : 1
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole" 
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_security_group" "eks_cluster_sg" {

  name        = "sri-eks-cluster-sg" # data.aws_security_group.cluster_sg.name
  
  description = "EKS Cluster Security Group"
  vpc_id        = var.vpc_id

  # Allow communication between the EKS control plane and worker nodes
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow access from anywhere (can be restricted further)
  }

  # Allow communication between worker nodes
  ingress {
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Modify with your VPC CIDR range
  }

  # Allow outbound traffic (you can modify as per your requirements)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic to anywhere
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    # subnet_ids = aws_subnet.eks_subnets[*].id
    subnet_ids = var.subnet_ids
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
    endpoint_public_access = true
    endpoint_private_access = false
  }
  # depends_on			= [aws_iam_role_policy_attachment.eks_cluster_policy]
  # enabled_cluster_log_types 	= ["audit", "api", "authenticator", "scheduler", "controllerManager"]
}

# EKS node group or other configurations can go here
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.1"

  cluster_name = var.cluster_name
  bootstrap_self_managed_addons = false
  vpc_id = var.vpc_id
  # subnet_ids   = aws_subnet.eks_subnets[*].id 
  subnet_ids = var.subnet_ids

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      # ami_type       = "AL2023_x86_64_STANDARD"
      # instance_types = ["m5.xlarge"]
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

  cluster_name = module.eks.cluster_id
  cluster_version = "1.27"
  # subnet_ids = aws_subnet.eks_subnets[*].id
  subnet_ids = var.subnet_ids
  name = "managed-node-group"
  cluster_service_cidr = var.vpc_cidr

  key_name = "sri-eks-keypair"
}

