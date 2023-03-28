# Define VPC
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "example-vpc"
  }
}

# Define public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "public-subnet-2"
  }
}

# Define private subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.4.0/24"
  tags = {
    Name = "private-subnet-2"
  }
}

# Define Security Group
resource "aws_security_group" "example_sg" {
  name_prefix = "example-sg"
  vpc_id = aws_vpc.example_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define Launch Configuration
resource "aws_launch_configuration" "example_lc" {
  name_prefix   = "example-lc"
  image_id      = "ami-0c94855ba95c71c99" # Specify your desired image ID here
  instance_type = "t2.micro"
  security_groups = [
    aws_security_group.example_sg.id
  ]
}

# Define Auto Scaling Group
resource "aws_autoscaling_group" "example_asg" {
  name_prefix      = "example-asg"
  launch_configuration = aws_launch_configuration.example_lc.id
  vpc_zone_identifier = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
  min_size             = 2
  max_size             = 2
  health_check_grace_period = 300
  health_check_type   = "ELB"
}
     
