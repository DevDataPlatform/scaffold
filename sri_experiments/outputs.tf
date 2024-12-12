output "eks_cluster_name" {
  value = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "eks_node_group_role" {
  # value = module.eks.node_groups["eks_nodes"].iam_role_arn
  value = module.eks.eks_managed_node_groups["example"].iam_role_arn
}

