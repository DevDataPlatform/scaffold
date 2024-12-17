
variable "vpc_id" {
  type        	= string
  default	= "vpc-0fa25a43ca018a9dc" 
}

# Variables for subnet IDs
variable "subnet_ids" {
  type    = list(string)
  default = [
    "subnet-05c33e8f516d7b264",  
    "subnet-0c9a0de71a29dbe63"   
  ]
}

variable "cluster_name" {
  type        	= string
  default 	= "sri-eks-cluster"
}

variable "vpc_cidr" {
  description = "The CIDR block to use for the Kubernetes service network"
  type        = string
  default     = "10.0.0.0/16"  
}

variable "cluster_role_name" {
  type        	= string
  default 	= "eks_cluster_role"
}
  
variable "keypair_name" {
  type 		= string
  default 	= "sri-eks-keypair"
}

variable "cluster_sg_name" {
  type 		= string
  default 	= "sri-eks-cluster-sg"
}
