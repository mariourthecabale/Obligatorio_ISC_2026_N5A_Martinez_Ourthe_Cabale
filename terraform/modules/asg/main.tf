## Main del módulo ASG que contiene el Launch Template y el Auto Scaling Group.
resource "aws_launch_template" "TF-LT-Obligatorio" {

  name_prefix = "AWS-${var.name}-LT"

  image_id      = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = [
    var.ec2_security_group_id
  ]

  user_data = base64encode(<<-EOF
#!/bin/bash

dnf update -y
dnf install -y docker

systemctl enable docker
systemctl start docker

docker run -d \
--name nginx \
-p 80:80 \
nginx

EOF
  )

  tag_specifications {

    resource_type = "instance"

    tags = {
      Name = "AWS-${var.name}-EC2"
    }
  }
}

resource "aws_autoscaling_group" "TF-ASG-Obligatorio" {

  name = "AWS-${var.name}-ASG"

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    var.target_group_arn
  ]

  health_check_type = "ELB"

  launch_template {

    id      = aws_launch_template.TF-LT-Obligatorio.id
    version = "$Latest"
  }

  tag {

    key                 = "Name"
    value               = "AWS-${var.name}-EC2"
    propagate_at_launch = true
  }
}