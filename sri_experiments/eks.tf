resource "aws_key_pair" "eks_key_pair" {
  key_name   = "sri-k8s-key-pair-new"
  public_key = file("~/.ssh/id_rsa.pub") # Path to your public key
}


resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"

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

resource "aws_security_group" "eks_cluster" {
  name        = "sri-eks-cluster-sg"
  description = "EKS Cluster Security Group"
  vpc_id        = "vpc-06f43a5a006ddeea0" # aws_vpc.staging_vpc.id
  # vpc_id      = aws_vpc.my_vpc.id  # Reference to your VPC ID

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
    subnet_ids = aws_subnet.eks_subnets[*].id
    security_group_ids = [aws_security_group.eks_cluster.id]
    endpoint_public_access = true
    endpoint_private_access = false
  }
  # depends_on                = [aws_iam_role_policy_attachment.eks_cluster_policy]
  enabled_cluster_log_types = ["audit", "api", "authenticator", "scheduler", "controllerManager"]
}

# EKS node group or other configurations can go here
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.1"

  cluster_name = var.cluster_name
  bootstrap_self_managed_addons = false
  # vpc_id = aws_vpc.staging_vpc.id
  vpc_id = "vpc-06f43a5a006ddeea0" # aws_vpc.staging_vpc.id
  subnet_ids   = aws_subnet.eks_subnets[*].id # Replace "subnets" with "vpc_subnets"

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      # ami_type       = "AL2023_x86_64_STANDARD"
      # instance_types = ["m5.xlarge"]
      instance_types = ["t3.medium"]

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
  subnet_ids = aws_subnet.eks_subnets[*].id
  name = "managed-node-group"
  cluster_service_cidr = var.cluster_service_cidr

  # instance_types = ["t3.medium"]

  key_name = "sri-k8s-key-pair-new"
}

