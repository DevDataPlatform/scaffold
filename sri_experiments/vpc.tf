data "aws_availability_zones" "available" {}

resource "aws_subnet" "eks_subnets" {
  count                  = 2
  vpc_id                 = "vpc-06f43a5a006ddeea0" # aws_vpc.staging_vpc.id
  cidr_block             = "10.0.0.0/24"
  # cidr_block           = cidrsubnet("10.0.0.0/16", 8, count.index)
  # cidr_block           = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone      = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = "vpc-06f43a5a006ddeea0" # aws_vpc.eks_vpc.id
}

resource "aws_route_table" "eks_route_table" {
  vpc_id = "vpc-06f43a5a006ddeea0" # aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }
}

resource "aws_route_table_association" "eks_route_table_association" {
  count          = length(aws_subnet.eks_subnets)
  subnet_id      = aws_subnet.eks_subnets[count.index].id
  route_table_id = aws_route_table.eks_route_table.id
}

