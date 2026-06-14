## Creamos ALB y sus componentes asociados (Target Group y Listener)
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

## Creamos target-groups para el ALB, que serán los encargados de enrutar el tráfico a las instancias EC2
resource "aws_lb_target_group" "TF-TG-Obligatorio" {


  name     = "tg-${var.name}"
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  ## Configuración del health check para el target group
  health_check {

    enabled = var.health_check_enabled

    protocol = var.health_check_protocol

    path = var.health_check_path

    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold

    matcher = var.health_check_matcher
  }

  tags = {
    Name = "AWS-${var.name}-TG"
  }
}

## Creamos Listener para el ALB que escuchará en el puerto 80 y redirigirá el tráfico al target group creado anteriormente
resource "aws_lb_listener" "TF-Listener-HTTP" {

  load_balancer_arn = aws_lb.TF-ALB-Obligatorio.arn

  port     = var.listener_port
  protocol = var.listener_protocol

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.TF-TG-Obligatorio.arn
  }
}