output "alb_sg_id" {
  value = aws_security_group.TF-SG-ALB.id
}

output "ec2_sg_id" {
  value = aws_security_group.TF-SG-EC2.id
}

output "rds_sg_id" {
  value = aws_security_group.TF-SG-RDS.id
}

