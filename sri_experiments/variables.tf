variable "region" {
  default = "ap-south-1"
}

variable "cluster_name" {
  type        	= string
  default 	= "sri"
}

variable "vpc_id" {
  type        	= string
  # default	= "vpc-06f43a5a006ddeea0" 
  default	= "vpc-0fa25a43ca018a9dc"  # own
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
  # default 	= "sri-k8s-key-pair"
  default 	= "sri-eks-keypair"  # own
}

variable "cluster_sg_name" {
  type 		= string
  default 	= "sri-eks-cluster-sg"
}

variable "subnet_ids" {
  type    = list(string)
  default = [
    "subnet-05c33e8f516d7b264",  # own 
    "subnet-0c9a0de71a29dbe63"   # own   
  #  "subnet-0893eae15fe20d36f",  
  #  "subnet-07578870c36500e08"
  ]
}
