## Variables para el módulo de base de datos RDS.
## Variable para el nombre de la base de datos.
variable "db_name" {
  type        = string
  description = "Nombre de la base de datos"
  default     = "ecommerce"
}

## Variable para el usuario administrador de RDS.
variable "db_username" {
  type        = string
  description = "Usuario administrador de RDS"
  sensitive   = true
}

## Variable para la contraseña del usuario administrador de RDS.
variable "db_password" {
  type        = string
  description = "Password administrador de RDS"
  sensitive   = true
}