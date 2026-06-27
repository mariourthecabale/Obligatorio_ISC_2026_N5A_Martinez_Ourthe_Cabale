## Output para mostrar el DNS público del Application Load Balancer
output "alb_dns_name" {
  description = "DNS público del Application Load Balancer"
  value       = module.alb.alb_dns_name

  depends_on  = [null_resource.Esperando_por_APP]
}
