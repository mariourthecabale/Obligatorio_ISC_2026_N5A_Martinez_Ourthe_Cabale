## Variables para los SG de ALB, EC2 y RDS
variable "project_name" {
  description = "Nombre del proyecto para identificar los recursos"
  type = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se crearán los security groups"
  type = string

  validation {
    condition     = length(trimspace(var.vpc_id)) > 0
    error_message = "vpc_id es obligatorio y no puede estar vacío."
  }
}

variable "app_port" {
  description = "Puerto para el tráfico de la aplicación"
  type    = number
  default = 80

  validation {
    condition     = var.app_port > 0 && var.app_port < 65536
    error_message = "app_port debe ser un número entre 1 y 65535."
  }
}

variable "db_port" {
  description = "Puerto para el tráfico de la base de datos"
  type    = number
  default = 3306

  validation {
    condition     = var.db_port > 0 && var.db_port < 65536
    error_message = "db_port debe ser un número entre 1 y 65535."
  }
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks permitidos al Application Load Balancer."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.alb_ingress_cidr_blocks) > 0
    error_message = "alb_ingress_cidr_blocks debe contener al menos un CIDR block."
  }
}

## Variable para el puerto de ingreso permitido al ALB
variable "alb_ingress_port" {
  description = "Puerto de ingreso permitido al ALB."
  type        = number
  default     = 80
  
  validation {
    condition     = var.alb_ingress_port > 0 && var.alb_ingress_port < 65536
    error_message = "alb_ingress_port debe ser un número entre 1 y 65535."
  }
}

## Variable para el protocolo de ingreso permitido al ALB
variable "alb_ingress_protocol" {
  description = "Protocolo de ingreso permitido al ALB."
  type        = string
  default     = "tcp"

  validation {
    condition     = contains(["tcp", "udp", "icmp"], var.alb_ingress_protocol)
    error_message = "alb_ingress_protocol debe ser 'tcp', 'udp' o 'icmp'."
  }
}