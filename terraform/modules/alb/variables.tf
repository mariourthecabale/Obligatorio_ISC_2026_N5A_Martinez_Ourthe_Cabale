## Variable para nombre ALB
variable "name_alb" {
  type = string
}

## Variable para VPC
variable "vpc_id" {
  type = string
}

## Variable para subnet pública
variable "public_subnet_ids" {
  type = list(string)
}

## Variable para security-group de ALB
variable "alb_security_group_id" {
  type = string
}

## Variable para puerto del listener
variable "listener_port" {
  type    = number
  default = 80
}

## Variable para protocolo del listener
variable "listener_protocol" {
  type    = string
  default = "HTTP"
}

## Variable para puerto del Target Group
variable "target_group_port" {
  type    = number
  default = 80
}

## Variable para protocolo del Target Group
variable "target_group_protocol" {
  type    = string
  default = "HTTP"
}

## Variable para habilitar o deshabilitar el Health Check
variable "health_check_enabled" {
  type    = bool
  default = true
}

## Variable para protocolo del Health Check
variable "health_check_protocol" {
  type    = string
  default = "HTTP"
}

## Variable para path del Health Check
variable "health_check_path" {
  type    = string
  default = "/"
}

## Variable para intervalo del Health Check
variable "health_check_interval" {
  type    = number
  default = 30
}

## Variable para timeout del Health Check
variable "health_check_timeout" {
  type    = number
  default = 5
}

## Variable para cantidad de checks saludables requeridos
variable "health_check_healthy_threshold" {
  type    = number
  default = 2
}

## Variable para cantidad de checks no saludables requeridos
variable "health_check_unhealthy_threshold" {
  type    = number
  default = 2
}

## Variable para códigos HTTP esperados en el Health Check
variable "health_check_matcher" {
  type    = string
  default = "200"
}
