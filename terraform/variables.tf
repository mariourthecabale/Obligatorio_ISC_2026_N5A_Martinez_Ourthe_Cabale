## Variables para la configuración de AWS y la infraestructura
## Variable para la región de AWS
variable "aws_region" {
  type = string
  description = "Variable para la region"
}

## Variable para la elección de la AMI
variable "ami" {
  type = string
  description = "Variable para eleccion de la ami"
}

## Variables para la configuración de la VPC, subnets y AZs
variable "vpc_cidr" {
  type = string
  description = "Variable para el CIDR block"
}

## Variable para la subnet privada de la APP
variable "private_subnet_APP" {
  type = string
  description = "Variable para la subnet privada de la APP"
}

## Variable para la subnet privada de la Base de Datos
variable "private_subnet_DB" {
  type = string
  description = "Variable para la subnet privada de la Base de Datos"
}

## Variable para la subnet pública
variable "public_subnet" {
  type = string
  description = "Variable para la subnet publica"
}

## Variable para el AZ
variable "vpc_aws_az" {
  type = string
  description = "Variable para la az"
}

## Variable para el AZ para alta disponibilidad
variable "vpc_aws_az_2" {
  type        = string
  description = "Segunda AZ para alta disponibilidad"
}

## Variable para la subnet pública en la segunda AZ
variable "public_subnet_2" {
  type        = string
  description = "Subnet publica en segunda AZ"
}

## Variable para la subnet privada de la APP en la segunda AZ
variable "private_subnet_APP_2" {
  type        = string
  description = "Subnet privada APP en segunda AZ"
}

## Variable para la subnet privada de la Base de Datos en la segunda AZ
variable "private_subnet_DB_2" {
  type        = string
  description = "Subnet privada DB en segunda AZ"
}

## Variables para la configuración del ALB
variable "alb_name" {
  type = string
  description = "Variable para el nombre del ALB"
}

## Variables para la configuración del Target Group
variable "target_group_port" {
  type = number
  description = "Variable para el puerto del Target Group"
}

## Variable para el protocolo del Target Group
variable "target_group_protocol" {
  type = string
  description = "Variable para el protocolo del Target Group"
}

## Variables para la configuración del Listener
variable "listener_port" {
  type = number
  description = "Variable para el puerto del Listener"
}

## Variable para el protocolo del Listener
variable "listener_protocol" {
  type = string
  description = "Variable para el protocolo del Listener"
}

## Variables para la configuración del health check del Target Group
variable "health_check_enabled" {
  type = bool
  description = "Variable para habilitar o deshabilitar el health check del Target Group"
}

## Variable para el protocolo del health check del Target Group
variable "health_check_protocol" {
  type = string
  description = "Variable para el protocolo del health check del Target Group"
}

## Variable para el path del health check del Target Group
variable "health_check_path" {
  type = string
  description = "Variable para el path del health check del Target Group"
}

## Variables para la configuración del health check del Target Group
variable "health_check_interval" {
  type = number
  description = "Variable para el intervalo del health check del Target Group"
}

## Variable para el timeout del health check del Target Group
variable "health_check_timeout" {
  type = number
  description = "Variable para el timeout del health check del Target Group"
}

## Variable para el umbral de healthy del health check del Target Group
variable "health_check_healthy_threshold" {
  type = number
  description = "Variable para el umbral de healthy del health check del Target Group"
}

## Variable para el umbral de unhealthy del health check del Target Group
variable "health_check_unhealthy_threshold" {
  type = number
  description = "Variable para el umbral de unhealthy del health check del Target Group"
}

## Variable para el matcher del health check del Target Group
variable "health_check_matcher" {
  type = string
  description = "Variable para el matcher del health check del Target Group"
}

## Variable para el nombre del proyecto, que se usará para taggear los recursos
variable "name" {
  type    = string
  default = "Obligatorio"
  description = "Nombre del proyecto para taggear los recursos"
}

variable "app_port" {
  type    = number
  default = 80
}

variable "db_port" {
  type    = number
  default = 3306
}

