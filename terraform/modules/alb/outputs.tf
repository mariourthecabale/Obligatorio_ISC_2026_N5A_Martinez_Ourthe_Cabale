output "alb_arn" {
  value = aws_lb.TF-ALB-Obligatorio.arn
}

## DNS del ALB
output "alb_dns_name" {
  value = aws_lb.TF-ALB-Obligatorio.dns_name
}

##
output "target_group_arn" {
  value = aws_lb_target_group.TF-TG-Obligatorio.arn
}