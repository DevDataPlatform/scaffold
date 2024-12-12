variable "region" {
  default = "ap-south-1"
}

variable "cluster_name" {
  default = "sri-eks-cluster"
}

variable "cluster_service_cidr" {
  description = "The CIDR block to use for the Kubernetes service network"
  type        = string
  default     = "10.0.0.0/16"  # Set a default value or specify in `eks.tf`
}


