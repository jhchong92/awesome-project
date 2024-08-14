resource "aws_iam_role" "ssm_role" {
  name = "SSMHostRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ssm_host_role_attachment" {
  name = "SSM Host Role Attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  roles = [ aws_iam_role.ssm_role.name ]
}

resource "aws_iam_instance_profile" "ssm_host_instance_profile" {
  name = "SSMHostInstanceProfile"  
  role = aws_iam_role.ssm_role.name
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# SSM Host
resource "aws_instance" "ssm-host" {
  ami = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "t2.nano"
  subnet_id = aws_subnet.public_subnets[0].id
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ssm_host_instance_profile.name

  tags = {
    Name = "Awesome SSM Host"
  }
}

# App Server
resource "aws_security_group" "ec2_sg" {
  name        = "app-server-security-group"
  description = "Allow outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    # Application Port
    from_port = 80
    to_port = 80
    cidr_blocks = [aws_vpc.main.cidr_block]
    protocol = "tcp"
  }

  ingress {
    security_groups = [ aws_security_group.nlb.id ]
    from_port = 80
    to_port = 80
    cidr_blocks = [aws_vpc.main.cidr_block]
    protocol = "tcp"
  }

  egress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = aws_subnet.private_subnets[*].cidr_block
  }

  tags = {
    Name = "AppServer SG"
  }
}

resource "aws_launch_template" "server_launch_template" {
  vpc_security_group_ids = [ aws_security_group.ec2_sg.id ]
  name_prefix = "awesome-server"
  image_id = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "t2.nano"
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [ aws_security_group.ec2_sg.id ]
  }

}

resource "aws_autoscaling_group" "app_server_asg" {
  desired_capacity = 1
  max_size = 1
  min_size = 1
  vpc_zone_identifier = aws_subnet.private_subnets[*].id

  # Add to LB Target Group
  target_group_arns = [ aws_lb_target_group.tg.arn ]

  launch_template {
    id      = aws_launch_template.server_launch_template.id
    version = aws_launch_template.server_launch_template.latest_version
  }
}

