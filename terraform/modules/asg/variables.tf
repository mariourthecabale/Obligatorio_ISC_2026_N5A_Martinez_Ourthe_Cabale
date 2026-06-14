## Variables para el módulo de Auto Scaling Group (ASG)
variable "name" {
  description = "Nombre base para los recursos creados por el módulo ASG"
  type = string
}

variable "private_subnet_ids" {
  description = "Lista de IDs de subnets privadas para el ASG"
  type = list(string)
}

variable "ec2_security_group_id" {
  description = "ID del Security Group para las instancias EC2 del ASG"
  type = string
}

variable "target_group_arn" {
  description = "ARN del Target Group para el ASG"
  type = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para el ASG"
  type    = string
  default = "t3.micro"
}

variable "ami" {
  description = "AMI para las instancias EC2 del ASG"
  type = string
}