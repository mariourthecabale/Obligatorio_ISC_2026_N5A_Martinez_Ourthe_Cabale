## Main del módulo ASG que contiene el Launch Template y el Auto Scaling Group.
## El Launch Template define la configuración de las instancias EC2, incluyendo el user data para instalar Docker y ejecutar un contenedor Nginx.
resource "aws_launch_template" "TF-LT-Obligatorio" {

  name_prefix = "AWS-${var.name}-LT"

  image_id      = var.ami
  instance_type = var.instance_type

  iam_instance_profile {
    name = "LabInstanceProfile"
  }

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
      Name = "${var.name}-EC2"
    }
  }
}

## Auto Scaling Group que utiliza el Launch Template definido anteriormente.
resource "aws_autoscaling_group" "TF-ASG-Obligatorio" {

  name = "${var.name}-ASG"

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
    value               = "${var.name}-EC2"
    propagate_at_launch = true
  }
}