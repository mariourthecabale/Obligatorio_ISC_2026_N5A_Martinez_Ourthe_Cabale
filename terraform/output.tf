output "alb_dns_name" {
  description = "DNS público del Application Load Balancer"
  value       = module.alb.alb_dns_name
}