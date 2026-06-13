## ARN del ALB
output "alb_arn" {
  value       = aws_lb.TF-ALB-Obligatorio.arn
  description = "ARN del Application Load Balancer"
}

## DNS del ALB
output "alb_dns_name" {
  value       = aws_lb.TF-ALB-Obligatorio.dns_name
  description = "Nombre DNS del Application Load Balancer"
}

## ARN del Target Group asociado al ALB
output "target_group_arn" {
  value       = aws_lb_target_group.TF-TG-Obligatorio.arn
  description = "ARN del Target Group asociado al ALB"
}

## ARN del Listener del ALB
output "listener_arn" {
  description = "ARN del listener HTTP del ALB"
  value       = aws_lb_listener.TF-Listener-HTTP.arn
}