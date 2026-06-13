## Creamos ALB
resource "aws_lb" "TF-ALB-Obligatorio" {

  name               = "alb-${var.name}"
  internal           = false
  load_balancer_type = "application"

  security_groups = [var.alb_security_group_id]

  subnets = var.public_subnet_ids

  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "AWS-${var.name}-ALB"
  }
}

##Creamos taret-groups
resource "aws_lb_target_group" "TF-TG-Obligatorio" {

  name     = "tg-${var.name}"
  port     = 80
  protocol = "HTTP"

  vpc_id = var.vpc_id

  health_check {

    enabled = true

    protocol = "HTTP"

    path = "/"

    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2

    matcher = "200"
  }

  tags = {
    Name = "AWS-${var.name}-TG"
  }
}


##Creamos Listener
resource "aws_lb_listener" "TF-Listener-HTTP" {

  load_balancer_arn = aws_lb.TF-ALB-Obligatorio.arn

  port     = 80
  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.TF-TG-Obligatorio.arn
  }
}