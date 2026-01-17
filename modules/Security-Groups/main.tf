resource "aws_default_security_group" "default_security_group" {
  vpc_id = var.vpc_id
  tags = {
    Name = "Default Security Group VPC"
  }
}

# checkov:skip=CKV2_AWS_5:Attached via module structure checkov misses
resource "aws_security_group" "public" {
  vpc_id      = var.vpc_id
  description = "Allow SSH access from a specific IP"
  name        = "Public Security Group"
  tags = {
    Name = "Public Security Group"
  }
}

# checkov:skip=CKV2_AWS_5:Attached via module structure checkov misses
resource "aws_security_group" "private" {
  vpc_id      = var.vpc_id
  description = "Allow connections from Private EC2 instance"
  name        = "Private Security Group EC2"
  tags = {
    Name = "Private Security Group EC2"
  }
}

# --- Rules For Public SG ---
# checkov:skip=CKV_AWS_24:Allow SSH for Lab
resource "aws_security_group_rule" "public_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_ip]
  security_group_id = aws_security_group.public.id
  description       = "Allow SSH from a specific IP"
}

# checkov:skip=CKV_AWS_382:Allow all egress for Lab updates
resource "aws_security_group_rule" "public_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
  description       = "Allow all outbound traffic"
}

# --- Rules For Private SG ---
resource "aws_security_group_rule" "private_ingress_ssh_from_public" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public.id
  security_group_id        = aws_security_group.private.id
  description              = "Allow SSH from Public Security Group"
}

resource "aws_security_group_rule" "private_ingress_all_tcp_from_public" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public.id
  security_group_id        = aws_security_group.private.id
  description              = "Allow all TCP ports from Public Security Group"
}

# checkov:skip=CKV_AWS_382:Allow all egress for Lab updates
resource "aws_security_group_rule" "private_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private.id
  description       = "Allow all outbound traffic"
}