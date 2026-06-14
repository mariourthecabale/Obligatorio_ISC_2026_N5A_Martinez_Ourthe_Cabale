variable "vpc_cidr" {
  type        = string
  description = "CIDR block principal de la VPC"
}

variable "name" {
  type        = string
  default     = "Obligatorio"
  description = "Nombre del proyecto para taggear los recursos"
}

variable "azs" {
  type        = list(string)
  description = "Lista de zonas de disponibilidad"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Lista de CIDR blocks para las subnets públicas"
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "Lista de CIDR blocks para las subnets privadas de la aplicación"
}

variable "private_db_subnet_cidrs" {
  type        = list(string)
  description = "Lista de CIDR blocks para las subnets privadas de la base de datos"
}