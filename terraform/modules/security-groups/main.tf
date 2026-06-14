## Security Group para ALB
resource "aws_security_group" "TF-SG-ALB" {

  name        = "AWS-${var.project_name}-SG-ALB"
  description = "Security Group para ALB"
  vpc_id      = var.vpc_id

  ingress {

    description = "HTTP/HTTPS desde Internet"
    from_port   = var.alb_ingress_port
    to_port     = var.alb_ingress_port
    protocol    = var.alb_ingress_protocol
    cidr_blocks = var.alb_ingress_cidr_blocks
  }

  egress {

  from_port   = 0
  to_port     = 0
  protocol    = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}

  tags = {
    Name = "AWS-${var.project_name}-SG-ALB"
  }
}

## Security Group para EC2
resource "aws_security_group" "TF-SG-EC2" {

  name        = "AWS-${var.project_name}-SG-EC2"
  description = "Security Group para EC2"
  vpc_id      = var.vpc_id

  ingress {

    description = "Trafico desde ALB"

    from_port = var.app_port
    to_port   = var.app_port

    protocol = "tcp"

    security_groups = [
      aws_security_group.TF-SG-ALB.id
    ]
  }

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AWS-${var.project_name}-SG-EC2"
  }
}

## Security Group para RDS
resource "aws_security_group" "TF-SG-RDS" {

  name        = "AWS-${var.project_name}-SG-RDS"
  description = "Security Group para RDS"
  vpc_id      = var.vpc_id

  ingress {

    description = "MySQL desde EC2"

    from_port = var.db_port
    to_port   = var.db_port

    protocol = "tcp"

    security_groups = [
      aws_security_group.TF-SG-EC2.id
    ]
  }

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AWS-${var.project_name}-SG-RDS"
  }
}
