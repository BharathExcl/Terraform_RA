resource "aws_launch_configuration" "example" {     #change example with desired insrance name
  image_id = "ami id"                               #replace ami id with intended AMI id
  instance_type = "t2.micro"
  # Add any other configuration options as needed
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.id
  vpc_zone_identifier = ["${aws_subnet.private.*.id}"]
  desired_capacity = 2
  min_size = 2
  max_size = 2
  # Add any other configuration options as needed
}

#Security group 
resource "aws_security_group" "example" {
  name_prefix = "example_sg_"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}