# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "curriculum-react-banking-interface"
    Project = "curriculum-react-banking-interface"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "internal_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "curriculum-react-banking-interface"
    Project = "curriculum-react-banking-interface"
    Billing = "curriculum-react-banking-interface"
  }
}

# Route Table

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internal_gateway.id
  }

  tags = {
    Name    = "curriculum-react-banking-interface"
    Project = "curriculum-react-banking-interface"
  }
}

# Subnets 

data "aws_availability_zones" "available" {}

resource "aws_subnet" "elb_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name    = "curriculum-react-banking-interface-elb-a"
    Project = "curriculum-react-banking-interface"
  }
}

resource "aws_subnet" "elb_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name    = "curriculum-react-banking-interface-elb-b"
    Project = "curriculum-react-banking-interface"
  }
}

resource "aws_subnet" "elb_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name    = "curriculum-react-banking-interface-elb-c"
    Project = "curriculum-react-banking-interface"
  }
}

resource "aws_subnet" "ecs_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name    = "curriculum-react-banking-interface-ecs-a"
    Project = "curriculum-react-banking-interface"
  }
}

resource "aws_subnet" "ecs_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name    = "curriculum-react-banking-interface-ecs-b"
    Project = "curriculum-react-banking-interface"
  }
}

resource "aws_subnet" "ecs_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name    = "curriculum-react-banking-interface-ecs-c"
    Project = "curriculum-react-banking-interface"
  }
}

resource "aws_route_table_association" "elb_a" {
  subnet_id      = aws_subnet.elb_a.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "elb_b" {
  subnet_id      = aws_subnet.elb_b.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "elb_c" {
  subnet_id      = aws_subnet.elb_c.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "ecs_a" {
  subnet_id      = aws_subnet.ecs_a.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "ecs_b" {
  subnet_id      = aws_subnet.ecs_b.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "ecs_c" {
  subnet_id      = aws_subnet.ecs_c.id
  route_table_id = aws_route_table.route_table.id
}

# Security Groups
resource "aws_security_group" "load_balancer" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "curriculum-react-banking-interface-load-balancer"
    Project = "curriculum-react-banking-interface"
  }
}

resource "aws_security_group" "ecs_task" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "curriculum-react-banking-interface-ecs-task"
    Project = "curriculum-react-banking-interface"
  }
}

# Security Group Rules
resource "aws_security_group_rule" "ingress_load_balancer_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.load_balancer.id
  to_port           = 80
  cidr_blocks = [
  "0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_load_balancer_https" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.load_balancer.id
  to_port           = 443
  cidr_blocks = [
  "0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_ecs_task_elb" {
  from_port                = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_task.id
  to_port                  = 3000
  source_security_group_id = aws_security_group.load_balancer.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "egress_load_balancer" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  cidr_blocks = [
  "0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "egress_ecs_task" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  cidr_blocks = [
  "0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_task.id
}
