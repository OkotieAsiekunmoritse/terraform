#Configure AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  profile = "myprofile"
}

# Create vpc
resource "aws_vpc" "Miniproject_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true


  tags = {
    Name = "Miniproject"
   }
 }

#Create Internet gateway attachment

resource "aws_internet_gateway_attachment" "Miniproject_internet_gateway_attachment>  internet_gateway_id = aws_internet_gateway.Miniproject_igw.id
  vpc_id              = aws_vpc.Miniproject_vpc.id
}

resource "aws_internet_gateway" "Miniproject_igw" {}

#Create A Route Table
resource "aws_route_table" "Miniproject-route-table-public" {

    vpc_id = aws_vpc.Miniproject_vpc.id
    route {

        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Miniproject_igw.id
    }


    tags = {

        Name = "Miniproject-RT"
    }
}

# Associate public subnet 1 with public route table

resource "aws_route_table_association" "Miniproject-public-subnet1-association" {
  subnet_id      = aws_subnet.Miniproject-public-subnet1.id
  route_table_id = aws_route_table.Miniproject-route-table-public.id
}

# Associate public subnet 2 with public route table

resource "aws_route_table_association" "Miniproject-public-subnet2-association" {
  subnet_id      = aws_subnet.Miniproject-public-subnet2.id
  route_table_id = aws_route_table.Miniproject-route-table-public.id
}

# Associate public subnet 3 with public route table

resource "aws_route_table_association" "Miniproject-public-subnet3-association" {
  subnet_id      = aws_subnet.Miniproject-public-subnet3.id
  route_table_id = aws_route_table.Miniproject-route-table-public.id
}


# Create Public Subnet-1

resource "aws_subnet" "Miniproject-public-subnet1" {
  vpc_id                  = aws_vpc.Miniproject_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Miniproject-public-subnet1"
  }
}

# Create Public Subnet-2

resource "aws_subnet" "Miniproject-public-subnet2" {
  vpc_id                  = aws_vpc.Miniproject_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "Miniproject-public-subnet2"
  }
}

# Create Public Subnet-3

resource "aws_subnet" "Miniproject-public-subnet3" {
  vpc_id                  = aws_vpc.Miniproject_vpc.id
  cidr_block              = "10.0.3.0/24"
    map_public_ip_on_launch = true
  availability_zone       = "us-east-1c"
  tags = {
    Name = "Miniproject-public-subnet3"
  }
}


# Create Network Acl
resource "aws_network_acl" "Miniproject-network_acl" {

  vpc_id     = aws_vpc.Miniproject_vpc.id
  subnet_ids = [aws_subnet.Miniproject-public-subnet1.id, aws_subnet.Miniproject-public-subnet2.id, aws_subnet.Miniproject-public-subnet3.id]

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
   tags = {
    Name = "Miniproject-net-acl"
  }
}

# Create a security group for the load balancer

resource "aws_security_group" "Miniproject-load_balancer_sg" {
  name        = "Miniproject-load-balancer-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.Miniproject_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create Security Group to allow port 22, 80 and 443

resource "aws_security_group" "Miniproject-security-grp-rule" {
  name        = "allow_ssh_http_https"
  description = "Allow SSH, HTTP and HTTPS inbound traffic for private instances"
  vpc_id      = aws_vpc.Miniproject_vpc.id
   ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.Miniproject-load_balancer_sg.id]
  }


 ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.Miniproject-load_balancer_sg.id]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
        Name = "Miniproject-security-grp-rule"
  }
}


resource "tls_private_key" "privkey" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource  "aws_key_pair" "new-key-pair" {
  key_name = var.ssh_key
  public_key = tls_private_key.privkey.public_key_openssh
}

resource "local_file" "ssh_key" {
  content = tls_private_key.privkey.private_key_pem
  filename = "${var.ssh_key}.pem"
  file_permission = "0400"
}



# creating instance 1

resource "aws_instance" "instance1" {
  ami             = "ami-0778521d914d23bc1"
  instance_type   = "t2.micro"
  key_name        = "aws_key_pair.newkey-pair.id"
  security_groups = [aws_security_group.Miniproject-security-grp-rule.id]
  subnet_id       = aws_subnet.Miniproject-public-subnet1.id
  availability_zone = "us-east-1a"
  key_name = "project_key"
  
  
  tags = {
    Name   = "Miniproj-instance1"
    source = "terraform"
  }
}

# creating instance 2

 resource "aws_instance" "instance2" {
  ami             = "ami-0778521d914d23bc1"
  instance_type   = "t2.micro"
  key_name        = "aws_key_pair.nekey_name = "project_key"key-pair.id"
  security_groups = [aws_security_group.Miniproject-security-grp-rule.id]
  subnet_id       = aws_subnet.Miniproject-public-subnet2.id
  availability_zone = "us-east-1b"
  key_name = "project_key"
  
  tags = {
    Name   = "Miniproj-instance2"
    source = "terraform"
  }
}

# creating instance 3
resource "aws_instance" "instance3" {
  ami             = "ami-0778521d914d23bc1"
  instance_type   = "t2.micro"
  key_name        = "aws_key_pair.newkey-pair.id"
  security_groups = [aws_security_group.Miniproject-security-grp-rule.id]
  subnet_id       = aws_subnet.Miniproject-public-subnet3.id
  availability_zone = "us-east-1c"
  key_name = "project_key"
  
  tags = {
    Name   = "Miniproj-instance3"
    source = "terraform"
  }
}



# Create file to store ip addresses for the 3 instances
resource "local_file" "Ip_address" {
  filename = "/home/vagrant/Terraform_project/module/host-inventory"
  directory_permission = "0777"
  file_permission = "0777"
  content  = <<EOT
${aws_instance.instance1.public_ip}
${aws_instance.instance2.public_ip}
${aws_instance.instance3.public_ip}
  EOT
}

# Create an Application Load Balancer

resource "aws_lb" "Miniproject-load-balancer" {
  name               = "Miniproject-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Miniproject-load_balancer_sg.id]
  subnets            = [aws_subnet.Miniproject-public-subnet1.id, aws_subnet.Miniproject-public-subnet2.id, aws_subnet.Miniproject-public-subnet3.id]
  #enable_cross_zone_load_balancing = true
  enable_deletion_protection = false
  depends_on                 = [aws_instance.instance1, aws_instance.instance2, aws_instance.instance3]

 tags = {
   Name  = "Miniproject-ALB"
 }
}

# Create the target group

resource "aws_lb_target_group" "Miniproject-target-group" {
  name     = "Miniproject-target-group"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Miniproject_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 3
        unhealthy_threshold = 3
  }
}

# Create the listener

resource "aws_lb_listener" "Miniproject-listener" {
  load_balancer_arn = aws_lb.Miniproject-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Miniproject-target-group.arn
  }
}


# Create the listener rule

resource "aws_lb_listener_rule" "Miniproject-listener-rule" {
  listener_arn = aws_lb_listener.Miniproject-listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Miniproject-target-group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

# Attach the target group to the load balancer
resource "aws_lb_target_group_attachment" "Miniproject-target-group-attachment1" {
  target_group_arn = aws_lb_target_group.Miniproject-target-group.arn
  target_id        = aws_instance.instance1.id
  port             = 80

]}

resource "aws_lb_target_group_attachment" "Miniproject-target-group-attachment2" {
  target_group_arn = aws_lb_target_group.Miniproject-target-group.arn
  target_id        = aws_instance.instance2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "Miniproject-target-group-attachment3" {
  target_group_arn = aws_lb_target_group.Miniproject-target-group.arn
  target_id        = aws_instance.instance3.id
  port             = 80

  }

