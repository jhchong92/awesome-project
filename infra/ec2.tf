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

