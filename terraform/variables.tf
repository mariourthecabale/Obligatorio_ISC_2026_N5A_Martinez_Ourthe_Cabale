variable "aws_region" {
  type = string
  description = "Variable para la region"
}

variable "ami" {
  type = string
  description = "Variable para eleccion de la ami"
}

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