provider "aws" {
  region = "ap-south-1"
  # region = "us-west-2"
}

# Create IAM User
resource "aws_iam_user" "eks_user" {
  name = "sri-eks-user"
  force_destroy = true
}

# Attach IAM Policies for EKS and EC2 Auto Scaling
resource "aws_iam_user_policy_attachment" "eks_policy_attachment" {
  user       = aws_iam_user.eks_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_user_policy_attachment" "worker_node_policy_attachment" {
  user       = aws_iam_user.eks_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_user_policy_attachment" "ec2_policy_attachment" {
  user       = aws_iam_user.eks_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user_policy_attachment" "autoscaling_policy_attachment" {
  user       = aws_iam_user.eks_user.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

resource "aws_iam_user_policy_attachment" "iam_policy_attachment" {
  user       = aws_iam_user.eks_user.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

# Generate Access Key for the User
resource "aws_iam_access_key" "eks_user_key" {
  user = aws_iam_user.eks_user.name
}

# Output the Access Key and Secret Key
output "eks_user_access_key" {
  value = aws_iam_access_key.eks_user_key.id
}

output "eks_user_secret_key" {
  value     = aws_iam_access_key.eks_user_key.secret
  sensitive = true
}

