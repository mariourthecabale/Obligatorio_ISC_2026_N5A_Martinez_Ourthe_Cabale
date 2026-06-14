## Outputs para los SG de ALB, EC2 y RDS
output "alb_sg_id" {
  description = "ID del Security Group asociado al Application Load Balancer, permite tráfico HTTP desde Internet hacia el ALB."
  value = aws_security_group.TF-SG-ALB.id
}

## Output para el SG de EC2
output "ec2_sg_id" {
  description = "ID del Security Group asociado a las instancias EC2, permite tráfico desde el ALB hacia las instancias."
  value = aws_security_group.TF-SG-EC2.id
}

## Output para el SG de RDS
output "rds_sg_id" {
  description = "ID del Security Group asociado a la base de datos RDS, permite tráfico desde las instancias EC2 hacia la base de datos."
  value = aws_security_group.TF-SG-RDS.id
}