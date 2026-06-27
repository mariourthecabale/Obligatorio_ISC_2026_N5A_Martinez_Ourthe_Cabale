## Variable para la región de AWS
variable "aws_region" {
  description = "Variable para la region"
  type        = string
}

## Variable para la elección de la AMI
variable "ami" {
  description = "Variable para eleccion de la ami"
  type        = string
}

## Variable para el CIDR block de la VPC
variable "vpc_cidr" {
  description = "Variable para el CIDR block"
  type        = string
}

## Variable para la subnet privada de la APP
variable "private_subnet_APP" {
  description = "Variable para la subnet privada de la APP"
  type        = string
}

## Variable para la subnet privada de la Base de Datos
variable "private_subnet_DB" {
  description = "Variable para la subnet privada de la Base de Datos"
  type        = string
}

## Variable para la subnet pública
variable "public_subnet" {
  description = "Variable para la subnet publica"
  type        = string
}

## Variable para el AZ
variable "vpc_aws_az" {
  description = "Variable para la az"
  type        = string
}

## Variable para el AZ para alta disponibilidad
variable "vpc_aws_az_2" {
  description = "Segunda AZ para alta disponibilidad"
  type        = string
}

## Variable para la subnet pública en la segunda AZ
variable "public_subnet_2" {
  description = "Subnet publica en segunda AZ"
  type        = string
}

## Variable para la subnet privada de la APP en la segunda AZ
variable "private_subnet_APP_2" {
  description = "Subnet privada APP en segunda AZ"
  type        = string
}

## Variable para la subnet privada de la Base de Datos en la segunda AZ
variable "private_subnet_DB_2" {
  description = "Subnet privada DB en segunda AZ"
  type        = string
}

## Variables para la configuración del ALB
variable "alb_name" {
  description = "Variable para el nombre del ALB"
  type        = string
}

## Variables para la configuración del Target Group
variable "target_group_port" {
  description = "Variable para el puerto del Target Group"
  type        = number
}

## Variable para el protocolo del Target Group
variable "target_group_protocol" {
  description = "Variable para el protocolo del Target Group"
  type        = string
}

## Variables para la configuración del Listener
variable "listener_port" {
  description = "Variable para el puerto del Listener"
  type        = number
}

## Variable para el protocolo del Listener
variable "listener_protocol" {
  description = "Variable para el protocolo del Listener"
  type        = string
}

## Variables para la configuración del health check del Target Group
variable "health_check_enabled" {
  description = "Variable para habilitar o deshabilitar el health check del Target Group"
  type        = bool
}

## Variable para el protocolo del health check del Target Group
variable "health_check_protocol" {
  description = "Variable para el protocolo del health check del Target Group"
  type        = string
}

## Variable para el path del health check del Target Group
variable "health_check_path" {
  description = "Variable para el path del health check del Target Group"
  type        = string
}

## Variables para la configuración del health check del Target Group
variable "health_check_interval" {
  description = "Variable para el intervalo del health check del Target Group"
  type        = number
}

## Variable para el timeout del health check del Target Group
variable "health_check_timeout" {
  description = "Variable para el timeout del health check del Target Group"
  type        = number
}

## Variable para el umbral de healthy del health check del Target Group
variable "health_check_healthy_threshold" {
  description = "Variable para el umbral de healthy del health check del Target Group"
  type        = number
}

## Variable para el umbral de unhealthy del health check del Target Group
variable "health_check_unhealthy_threshold" {
  description = "Variable para el umbral de unhealthy del health check del Target Group"
  type        = number
}

## Variable para el matcher del health check del Target Group
variable "health_check_matcher" {
  description = "Variable para el matcher del health check del Target Group"
  type        = string
}

## Variable para el nombre del proyecto, que se usará para taggear los recursos
variable "project_name" {
  description = "Nombre del proyecto para taggear los recursos"
  type        = string
  default     = "Obligatorio"
}

## Variables para el módulo de security groups
variable "app_port" {
  description = "Puerto para el tráfico de la aplicación"
  type    = number
  default = 80

  validation {
    condition     = var.app_port > 0 && var.app_port < 65536
    error_message = "app_port debe ser un número entre 1 y 65535."
  }
}

## Variable para el puerto de la base de datos
variable "db_port" {
  description = "Puerto para el tráfico de la base de datos"
  type    = number
  default = 3306

  validation {
    condition     = var.db_port > 0 && var.db_port < 65536
    error_message = "db_port debe ser un número entre 1 y 65535."
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

## Variable para los CIDR blocks permitidos al ALB
variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks permitidos al ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.alb_ingress_cidr_blocks) > 0
    error_message = "alb_ingress_cidr_blocks debe contener al menos un CIDR block."
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

## Variables para el motor de base de datos.
variable "db_engine" {
  type        = string
  description = "Motor de base de datos"
  default     = "mysql"
}

## Variable para la versión del motor de base de datos. 
variable "db_engine_version" {
  type        = string
  description = "Versión del motor MySQL"
  default     = "8.0"
}

## Variable para el tipo de instancia de la base de datos. 
variable "db_instance_class" {
  type        = string
  description = "Tipo de instancia RDS"
  default     = "db.t3.micro"
}

## Variable para el almacenamiento inicial de la base de datos. 
variable "allocated_storage" {
  type        = number
  description = "Storage inicial en GB"
  default     = 20
}

## Variable para el almacenamiento máximo de la base de datos. 
variable "max_allocated_storage" {
  type        = number
  description = "Storage máximo para autoscaling en GB"
  default     = 100
}

## Variable para el tipo de almacenamiento de la base de datos. 
variable "storage_type" {
  type        = string
  description = "Tipo de storage"
  default     = "gp3"
}

### Variable para el nombre de la base de datos inicial 
variable "db_name" {
  type        = string
  description = "Nombre de la base de datos inicial"
  default     = "ecommerce"
}

## Variable para el nombre de usuario administrador de la base de datos.
variable "db_username" {
  type        = string
  description = "Usuario administrador de la base"
  sensitive   = true
}

## Variable para la contraseña del usuario administrador de la base de datos. 
variable "db_password" {
  type        = string
  description = "Contraseña del usuario administrador"
  sensitive   = true
}

### Variable para habilitar o deshabilitar RDS Multi-AZ 
variable "multi_az" {
  type        = bool
  description = "Habilita RDS Multi-AZ"
  default     = false ## Nota: este valor se puede cambiar a true si se desea alta disponibilidad, pero esto incrementará el costo.
}

## Variable para definir número de días de retención de backups automáticos. 
variable "backup_retention_period" {
  type        = number
  description = "Días de retención de backups automáticos"
  default     = 7
}

## Variable para definir ventana horaria para backups automáticos. 
variable "backup_window" {
  type        = string
  description = "Ventana horaria para backups automáticos"
  default     = "03:00-04:00"
}

## Variable para definir ventana horaria para mantenimiento de RDS. 
variable "maintenance_window" {
  type        = string
  description = "Ventana de mantenimiento"
  default     = "sun:04:00-sun:05:00"
}

## Variable para definir si se omite el snapshot final al destruir la DB. 
variable "skip_final_snapshot" {
  type        = bool
  description = "Define si se omite el snapshot final al destruir la DB"
  default     = false
}

## Variable para definir si se habilita la protección contra borrado accidental de la DB. 
variable "deletion_protection" {
  type        = bool
  description = "Protección contra borrado accidental"
  default     = false
}

## Variable para el token de acceso a GitLab.
variable "gitlab_token" {
  sensitive = true
}

## Variable para el nombre del bucket de S3 donde se almacenarán los backups de la base de datos.
variable "bucket_name" {
  type = string
}

## Variable para comprobar la disponibilidad de la aplicación mediante curl, con reintentos y tiempo de espera configurables
variable "app_ready_check_scheme" {
  type        = string
  default     = "http"
  description = "Protocolo para comprobar la aplicación"
}

variable "app_ready_check_path" {
  type        = string
  default     = "/"
  description = "Ruta HTTP que se usa para verificar si la app ya está lista"
}

variable "app_ready_check_attempts" {
  type        = number
  default     = 60
  description = "Número máximo de intentos para comprobar la aplicación"
}

variable "app_ready_check_sleep_seconds" {
  type        = number
  default     = 10
  description = "Segundos entre cada intento de comprobación"
}

variable "app_ready_check_curl_timeout" {
  type        = number
  default     = 10
  description = "Timeout en segundos para cada petición curl"
}

## Variable para el correo electrónico donde se recibirán alertas de CloudWatch.
variable "notificacion_email" {
  description = "Email para recibir alertas de CloudWatch."
  type        = string
  default     = ""
}