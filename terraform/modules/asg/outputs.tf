output "asg_name" {
  value = aws_autoscaling_group.TF-ASG-Obligatorio.name
}

output "launch_template_id" {
  value = aws_launch_template.TF-LT-Obligatorio.id
}