# Fetch the available availability zones for the current region
data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
  region = var.region # Replace with your preferred region
}

## Step 1: Create a VPC

resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

## Step 2: Create Public and Private Subnets

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                              = "public-subnet-${count.index}"
    "kubernetes.io/role/elb"          = "1"
    "kubernetes.io/cluster/eks-cluster" = "shared"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count             = 2
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                               = "private-subnet-${count.index}"
    "kubernetes.io/role/internal-elb"  = "1"
    "kubernetes.io/cluster/eks-cluster" = "shared"
  }
}

## Step 3: Create an Internet Gateway (for Public Subnets)

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

## Step 4: Create Route Tables and Routes

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "public-rt"
  }
}

# Route for Public Subnets
resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

