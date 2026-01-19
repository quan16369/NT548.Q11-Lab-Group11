# Public Route Table
resource "aws_route_table" "public_route_table" {
    vpc_id = var.vpc_id  # ID of the VPC
    
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }
  
    tags = {
        Name = "Public Route Table"
    }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_association" {
    subnet_id = var.public_subnet_id  # ID of the public subnet
    route_table_id = aws_route_table.public_route_table.id  # ID of the public route table
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
    vpc_id = var.vpc_id  # ID of the VPC
    
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.nat_gateway_id
  }

    tags = {
        Name = "Private Route Table"
    }
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_association" {
    subnet_id = var.private_subnet_id  # ID of the private subnet
    route_table_id = aws_route_table.private_route_table.id  # ID of the private route table
}