# checkov:skip=CKV2_AWS_11:Flow Logs too expensive for Lab
# checkov:skip=CKV2_AWS_12:Default SG is handled separately
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name        = "VPC"
    Environment = "test"
  }

}

# Resource nay giup khoa chat Default SG cua VPC
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Default Security Group - Deny All"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name        = "IGW"
    Environment = "test"
  }
}

# checkov:skip=CKV_AWS_130:Public IP required for Lab access
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true # assign public IP to instance
  availability_zone       = var.availability_zone

  tags = {
    Name        = "Public Subnet"
    Environment = "test"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name        = "Private Subnet"
    Environment = "test"
  }
}