variable "name" {
  type        = string
  description = "Nombre base del proyecto"
}
 
variable "private_db_subnet_ids" {
  type        = list(string)
  description = "IDs de las subnets privadas para base de datos"
}
 
variable "rds_security_group_id" {
  type        = string
  description = "Security Group asociado a RDS"
}
 
variable "db_engine" {
  type        = string
  description = "Motor de base de datos"
  default     = "mysql"
}
 
variable "db_engine_version" {
  type        = string
  description = "Versión del motor MySQL"
  default     = "8.0"
}
 
variable "db_instance_class" {
  type        = string
  description = "Tipo de instancia RDS"
  default     = "db.t3.micro"
}
 
variable "allocated_storage" {
  type        = number
  description = "Storage inicial en GB"
  default     = 20
}
 
variable "max_allocated_storage" {
  type        = number
  description = "Storage máximo para autoscaling en GB"
  default     = 100
}
 
variable "storage_type" {
  type        = string
  description = "Tipo de storage"
  default     = "gp3"
}
 
variable "db_name" {
  type        = string
  description = "Nombre de la base de datos inicial"
  default     = "ecommerce"
}
 
variable "db_username" {
  type        = string
  description = "Usuario administrador de la base"
  sensitive   = true
}
 
variable "db_password" {
  type        = string
  description = "Contraseña del usuario administrador"
  sensitive   = true
}
 
variable "db_port" {
  type        = number
  description = "Puerto de la base de datos"
  default     = 3306
}
 
variable "multi_az" {
  type        = bool
  description = "Habilita RDS Multi-AZ"
  default     = false
}
 
variable "backup_retention_period" {
  type        = number
  description = "Días de retención de backups automáticos"
  default     = 7
}
 
variable "backup_window" {
  type        = string
  description = "Ventana horaria para backups automáticos"
  default     = "03:00-04:00"
}
 
variable "maintenance_window" {
  type        = string
  description = "Ventana de mantenimiento"
  default     = "sun:04:00-sun:05:00"
}
 
variable "skip_final_snapshot" {
  type        = bool
  description = "Define si se omite el snapshot final al destruir la DB"
  default     = false
}
 
variable "deletion_protection" {
  type        = bool
  description = "Protección contra borrado accidental"
  default     = false
}