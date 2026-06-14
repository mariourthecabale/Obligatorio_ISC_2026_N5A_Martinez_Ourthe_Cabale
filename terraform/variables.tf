## Variable para la región de AWS
variable "aws_region" {
  type = string
  description = "Variable para la region"
}

## Variable para el CIDR block de la VPC
variable "ami" {
  type = string
  description = "Variable para eleccion de la ami"
}

## Variables para el módulo de networking
variable "vpc_cidr" {
  type = string
  description = "Variable para el CIDR block"
}

variable "private_subnet_APP" {
  type = string
  description = "Variable para la subnet privada de la APP"
}

variable "private_subnet_DB" {
  type = string
  description = "Variable para la subnet privada de la Base de Datos"
}

variable "public_subnet" {
  type = string
  description = "Variable para la subnet publica"
}

variable "vpc_aws_az" {
  type = string
  description = "Variable para la az"
}

variable "vpc_aws_az_2" {
  type        = string
  description = "Segunda AZ para alta disponibilidad"
}

variable "public_subnet_2" {
  type        = string
  description = "Subnet publica en segunda AZ"
}

variable "private_subnet_APP_2" {
  type        = string
  description = "Subnet privada APP en segunda AZ"
}

variable "private_subnet_DB_2" {
  type        = string
  description = "Subnet privada DB en segunda AZ"
}

variable "name" {
  type = string
  description = "Obligatorio"
}

## Variables para el módulo de security groups
variable "app_port" {
  type    = number
  default = 80
}

variable "db_port" {
  type    = number
  default = 3306
}