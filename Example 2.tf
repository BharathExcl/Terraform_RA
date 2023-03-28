provider "aws" {
region = "us-east-1"
}

variable "aws_access_key" {}  # defining the provider and the required variables
variable "aws_secret_key" {}


#VPC, its subnets, and the associated route tables
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.example_vpc.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.example_vpc.id
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

#security group
resource "aws_security_group" "web_security_group" {
  name_prefix = "web_security_group"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Launch Configuration and the Auto Scaling group
resource "aws_launch_configuration" "example_launch_configuration" {
  image_id = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web_security_group.id]
}

NED



#Load balancer

resource "aws_lb" "example_lb" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
  ]

  security_groups = [
    aws_security_group.web_security_group.id,
  ]

  tags = {
    Environment = "Production"
  }

  enable_deletion_protection = true
}

resource "aws_lb_target_group" "example_target_group" {
  name_prefix      = "example-tg"
  port             = 80
  protocol         = "HTTP"
  vpc_id           = aws_vpc.example_vpc.id
  target_type      = "instance"

  health_check {
    path = "/health_check"
    port = 80
  }

  depends_on = [
    aws_lb.example_lb,
  ]
}

resource "aws_lb_listener" "example_lb_listener" {
  load_balancer_arn = aws_lb.example_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example_target_group.arn
  }
}

#Auto Scaling group and associate it with the Load Balancer:
resource "aws_autoscaling_group" "example_autoscaling_group" {
  name                 = "example-asg"
  launch_configuration = aws_launch_configuration.example_launch_configuration.id
  min_size             = 2
  max_size             = 2
  vpc_zone_identifier  = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
  ]

  target_group_arns = [
    aws_lb_target_group.example_target_group.arn,
  ]

  depends_on = [
    aws_lb_target_group.example_target_group,
  ]
}

#AWS credentials

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-1"
}