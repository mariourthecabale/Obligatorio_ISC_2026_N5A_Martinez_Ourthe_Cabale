## Outputs para el módulo de Auto Scaling Group (ASG)
output "asg_name" {
  description = "Nombre del Auto Scaling Group creado"
  value = aws_autoscaling_group.TF-ASG-Obligatorio.name
}

## Output adicional para el ID del Launch Template, que puede ser útil para otros módulos o para referencia.
output "launch_template_id" {
  description = "ID del Launch Template creado"
  value = aws_launch_template.TF-LT-Obligatorio.id
}