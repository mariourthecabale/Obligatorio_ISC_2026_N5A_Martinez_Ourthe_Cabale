##SG para ALB
resource "aws_security_group" "TF-SG-ALB" {

  name        = "AWS-${var.name}-SG-ALB"
  description = "Security Group para ALB"
  vpc_id      = var.vpc_id

  ingress {

    description = "HTTP"

    from_port = 80
    to_port   = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  
  egress {
    description     = "HTTP hacia EC2"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.TF-SG-EC2.id]
  }

  tags = {
    Name = "AWS-${var.name}-SG-ALB"
  }
}

##SG para EC2
resource "aws_security_group" "TF-SG-EC2" {

  name        = "AWS-${var.name}-SG-EC2"
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
    Name = "AWS-${var.name}-SG-EC2"
  }
}

##SG para RDS
resource "aws_security_group" "TF-SG-RDS" {

  name        = "AWS-${var.name}-SG-RDS"
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
    Name = "AWS-${var.name}-SG-RDS"
  }
}
