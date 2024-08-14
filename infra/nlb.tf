resource "aws_security_group" "nlb" {
  name        = "nlb-security-group"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    # Application Port
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }

  egress {
    # Application Port
    from_port = 80
    to_port = 80
    cidr_blocks = aws_subnet.private_subnets[*].cidr_block
    protocol = "tcp"
  }

  tags = {
    Name = "NLB SG"
  }
}

resource "aws_lb" "nlb" {
  name               = "awesome-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.public_subnets[*].id
  security_groups = [ aws_security_group.nlb.id ]

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  tags = {
    Name = "App Server NLB"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "app-server-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    port = "traffic-port"
  }

  tags = {
    Name = "App Server TG"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}