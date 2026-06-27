📦 Obligatorio ISC 2026 — N5A | Martínez · Ourthe · Cabalé
> Repositorio principal: [`mariourthecabale/Obligatorio_ISC_2026_N5A_Martinez_Ourthe_Cabale`](https://github.com/mariourthecabale/Obligatorio_ISC_2026_N5A_Martinez_Ourthe_Cabale)  
> Organización de módulos: [`ISC-2026-Martinez-Ourthe-Cabale`](https://github.com/ISC-2026-Martinez-Ourthe-Cabale)
---
# Contenidos:<br>
[Descripción general](#descripcion-general)<br>
[Diagrama de arquitectura](#diagrama-de-arquitectura)<br>
[Servicios de AWS utilizados](#servicios-de-aws-utiliados)<br>
[Datos de la infraestructura](#datos-de-infra)<br>
[Firewalling / Security Groups](#firewall-sg)<br>
[Módulos Terraform](#modulos-terraform)<br>
[Requisitos y dependencias](#requisitos)<br>
[Credenciales y accesos necesarios](#credenciales)<br>
[Estructura del repositorio](#estructura)<br>
[Instructivo de uso](#instructivo)<br>
[Variables](#variables)<br>
[Outputs](#outputs)<br>
[Consideraciones de seguridad](#consideraciones)<br>
---
## <span id="descripcion-general"></span>Descripción general

Este proyecto despliega una aplicación web de e-commerce en alta disponibilidad sobre AWS.<
La arquitectura se distribuye en dos Availability Zones, con separación de capas (pública / aplicación / base de datos), balanceo de carga automático, auto escalado de instancias EC2, base de datos MySQL administrada (RDS), y almacenamiento de backups en bucket S3.
La aplicación corre en contenedores Docker, sobre instancias EC2, la iagen es obtenida a partir de un container registry de GitLab (`registry.gitlab.com/mourthecabalediaz/app:1.0`).

## <span id="diagrama-de-arquitectura"></span>Diagrama de arquitectura
```
                          Internet
                             │
                    ┌────────▼────────┐
                    │   ALB (público) │  puerto 80 / TCP
                    │  SG-ALB: 0.0.0.0/0 → :80  │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
     AZ-1 (us-east-1a)            AZ-2 (us-east-1b)
              │                             │
   ┌──────────▼──────────┐     ┌────────────▼────────────┐
   │  Subnet Pública-1   │     │   Subnet Pública-2      │
   │  NAT Gateway + EIP  │     │   NAT Gateway + EIP     │
   └──────────┬──────────┘     └────────────┬────────────┘
              │                             │
   ┌──────────▼──────────┐     ┌────────────▼────────────┐
   │  Subnet Privada-APP-1│     │  Subnet Privada-APP-2   │
   │  EC2 (Docker)  ←ASG │     │  EC2 (Docker)  ←ASG     │
   │  SG-EC2: ALB → :80  │     │  SG-EC2: ALB → :80      │
   └──────────┬──────────┘     └────────────┬────────────┘
              │                             │
   ┌──────────▼──────────┐     ┌────────────▼────────────┐
   │  Subnet Privada-DB-1 │     │  Subnet Privada-DB-2    │
   │   RDS MySQL 8.0      │◄────┤  (Standby Multi-AZ opt) │
   │  SG-RDS: EC2 → :3306│     │                         │
   └─────────────────────┘     └─────────────────────────┘

              ┌─────────────┐
              │  S3 Bucket  │  (backups y archivos)
              └─────────────┘
```
Flujo de tráfico:
El usuario accede al DNS público del ALB por HTTP (puerto 80).
El ALB distribuye el tráfico hacia las instancias EC2 del Auto Scaling Group ubicadas en las subnets privadas de APP.
Las instancias EC2 se conectan a la base de datos RDS MySQL a través de la subnet privada de DB (puerto 3306).
Las instancias tienen salida a Internet únicamente a través del NAT Gateway (para descargar la imagen Docker desde GitLab Registry y actualizaciones del SO).


## <span id="servicios-de-aws-utiliados"></span>Servicios de AWS utilizados
* VPC:	Red virtual privada que contiene toda la infraestructura<br>
* Dos subnets públicas: (ALB/NAT)<br>
* Dos subnets privadas: APP (EC2)<br>
* Dos subnets privadas: DB (RDS)<br>
*Nota: Una subnet de cada tipo por AZ.*<br>
* IGW: Salida a Internet desde subnets públicas<br>
* NAT Gateway: Salida a Internet desde subnets privadas (una por AZ)
* Elastic IP	IPs estáticas para los NAT Gateways
* Route Tables	Tablas de ruteo separadas para subnets públicas y privadas
* Application Load Balancer (ALB)	Balanceo de carga HTTP entre instancias EC2
* Target Group	Grupo de destino del ALB con health checks
* Auto Scaling Group (ASG)	Escalado automático de instancias EC2 (mín 2, máx 4)
* Launch Template	Configuración de las instancias EC2 (AMI, tipo, user data)
* EC2	Instancias que ejecutan la aplicación en contenedores Docker
* RDS (MySQL 8.0)	Base de datos relacional administrada
* DB Subnet Group	Grupo de subnets privadas para RDS
* S3	Almacenamiento de backups y archivos
* Security Groups	Firewall a nivel de instancia para ALB, EC2 y RDS
* IAM Instance Profile	Perfil `LabInstanceProfile` para permisos de las instancias


---
## <span id="datos-de-infra"></span>Datos de la infraestructura

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alb_ingress_cidr_blocks"></a> [alb\_ingress\_cidr\_blocks](#input\_alb\_ingress\_cidr\_blocks) | CIDR blocks permitidos al ALB. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_alb_ingress_port"></a> [alb\_ingress\_port](#input\_alb\_ingress\_port) | Puerto de ingreso permitido al ALB. | `number` | `80` | no |
| <a name="input_alb_ingress_protocol"></a> [alb\_ingress\_protocol](#input\_alb\_ingress\_protocol) | Protocolo de ingreso permitido al ALB. | `string` | `"tcp"` | no |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | Variable para el nombre del ALB | `string` | n/a | yes |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Storage inicial en GB | `number` | `20` | no |
| <a name="input_ami"></a> [ami](#input\_ami) | Variable para eleccion de la ami | `string` | n/a | yes |
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | Puerto para el tráfico de la aplicación | `number` | `80` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Variable para la region | `string` | n/a | yes |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Días de retención de backups automáticos | `number` | `7` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Ventana horaria para backups automáticos | `string` | `"03:00-04:00"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | n/a | `string` | n/a | yes |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | Motor de base de datos | `string` | `"mysql"` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | Versión del motor MySQL | `string` | `"8.0"` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | Tipo de instancia RDS | `string` | `"db.t3.micro"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Nombre de la base de datos inicial | `string` | `"ecommerce"` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Contraseña del usuario administrador | `string` | n/a | yes |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | Puerto para el tráfico de la base de datos | `number` | `3306` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Usuario administrador de la base | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Protección contra borrado accidental | `bool` | `false` | no |
| <a name="input_gitlab_token"></a> [gitlab\_token](#input\_gitlab\_token) | n/a | `any` | n/a | yes |
| <a name="input_health_check_enabled"></a> [health\_check\_enabled](#input\_health\_check\_enabled) | Variable para habilitar o deshabilitar el health check del Target Group | `bool` | n/a | yes |
| <a name="input_health_check_healthy_threshold"></a> [health\_check\_healthy\_threshold](#input\_health\_check\_healthy\_threshold) | Variable para el umbral de healthy del health check del Target Group | `number` | n/a | yes |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Variable para el intervalo del health check del Target Group | `number` | n/a | yes |
| <a name="input_health_check_matcher"></a> [health\_check\_matcher](#input\_health\_check\_matcher) | Variable para el matcher del health check del Target Group | `string` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Variable para el path del health check del Target Group | `string` | n/a | yes |
| <a name="input_health_check_protocol"></a> [health\_check\_protocol](#input\_health\_check\_protocol) | Variable para el protocolo del health check del Target Group | `string` | n/a | yes |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Variable para el timeout del health check del Target Group | `number` | n/a | yes |
| <a name="input_health_check_unhealthy_threshold"></a> [health\_check\_unhealthy\_threshold](#input\_health\_check\_unhealthy\_threshold) | Variable para el umbral de unhealthy del health check del Target Group | `number` | n/a | yes |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | Variable para el puerto del Listener | `number` | n/a | yes |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | Variable para el protocolo del Listener | `string` | n/a | yes |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Ventana de mantenimiento | `string` | `"sun:04:00-sun:05:00"` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Storage máximo para autoscaling en GB | `number` | `100` | no |
| <a name="input_multi_az"></a> [multi\_az](#input\_multi\_az) | Habilita RDS Multi-AZ | `bool` | `false` | no |
| <a name="input_private_subnet_APP"></a> [private\_subnet\_APP](#input\_private\_subnet\_APP) | Variable para la subnet privada de la APP | `string` | n/a | yes |
| <a name="input_private_subnet_APP_2"></a> [private\_subnet\_APP\_2](#input\_private\_subnet\_APP\_2) | Subnet privada APP en segunda AZ | `string` | n/a | yes |
| <a name="input_private_subnet_DB"></a> [private\_subnet\_DB](#input\_private\_subnet\_DB) | Variable para la subnet privada de la Base de Datos | `string` | n/a | yes |
| <a name="input_private_subnet_DB_2"></a> [private\_subnet\_DB\_2](#input\_private\_subnet\_DB\_2) | Subnet privada DB en segunda AZ | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nombre del proyecto para taggear los recursos | `string` | `"Obligatorio"` | no |
| <a name="input_public_subnet"></a> [public\_subnet](#input\_public\_subnet) | Variable para la subnet publica | `string` | n/a | yes |
| <a name="input_public_subnet_2"></a> [public\_subnet\_2](#input\_public\_subnet\_2) | Subnet publica en segunda AZ | `string` | n/a | yes |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Define si se omite el snapshot final al destruir la DB | `bool` | `false` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Tipo de storage | `string` | `"gp3"` | no |
| <a name="input_target_group_port"></a> [target\_group\_port](#input\_target\_group\_port) | Variable para el puerto del Target Group | `number` | n/a | yes |
| <a name="input_target_group_protocol"></a> [target\_group\_protocol](#input\_target\_group\_protocol) | Variable para el protocolo del Target Group | `string` | n/a | yes |
| <a name="input_vpc_aws_az"></a> [vpc\_aws\_az](#input\_vpc\_aws\_az) | Variable para la az | `string` | n/a | yes |
| <a name="input_vpc_aws_az_2"></a> [vpc\_aws\_az\_2](#input\_vpc\_aws\_az\_2) | Segunda AZ para alta disponibilidad | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Variable para el CIDR block | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS público del Application Load Balancer |
---
## <span id="firewall-sg"></span>Firewalling / Security Groups
Se implementan tres Security Groups con accesos estrictos:
### SG-ALB (Application Load Balancer)
|Dirección|Puerto|Protocolo|Origen|
|---------|------|---------|------|
|Ingress|80(configurable)|TCP (configurable)|`0.0.0.0/0` (Internet)|
|Egress|Todo|Todos|`0.0.0.0/0`|
### SG-EC2(Instancias del ASG)
|Dirección|Puerto|Protocolo|Origen|
|---------|------|---------|------|
|Ingress|80(configurable vía `app_port`)|TCP|Solo desde SG-ALB|E
|Egress|Todo|Todos|`0.0.0.0/0`|

> Las instancias EC2 **no son accesibles directamente desde Internet**. El único ingreso permitido proviene del ALB.
### SG-RDS (Base de datos MySQL)
|Dirección|Puerto|Protocolo|Origen|
|---------|------|-------- |------|
|Ingress|3306 (configurable vía `db_port`)|TCP|Solo desde SG-EC2|
|Egress|Todo|Todos|`0.0.0.0/0`|
> La base de datos **no es accesible ni desde Internet ni desde el ALB**, únicamente desde las instancias de aplicación.
Resumen del modelo de seguridad:
```
Internet → [SG-ALB] → ALB → [SG-EC2] → EC2 → [SG-RDS] → RDS
```
---


## <span id="descripcion-general"></span>Módulos Terraform
Este repositorio actúa como orquestador que consume módulos alojados en la organización `ISC-2026-Martinez-Ourthe-Cabale`.
|Nombre del módulo|	Repositorio| fuente	|Descripción|
|-----------------|------------|--------|-----------|
|`alb`|	`ISC-2026-Martinez-Ourthe-Cabale/module-alb`|git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-alb.git	|ALB, Target Group, Listener|
|`database`|`ISC-2026-Martinez-Ourthe-Cabale/module-database`|git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-database.git|RDS MySQL + DB Subnet Group|
|`db_storage`|`ISC-2026-Martinez-Ourthe-Cabale/storage-backup|git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/storage-backup|S3 bucket para backups|
|`ec2-tmp`|	`ISC-2026-Martinez-Ourthe-Cabale/modules-ec2-tmp`|git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/modules-ec2-tmp.git	|EC2 temporales (uso durante desarrollo)|
|`ec2_asg`|	`ISC-2026-Martinez-Ourthe-Cabale/module-asg`|git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-asg.git|Launch Template + Auto Scaling Group|
|`networking`|`ISC-2026-Martinez-Ourthe-Cabale/module-networking`|git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-networking.git|git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-networking.git|VPC, subnets, IGW, NAT GW, route tables|
|security_groups`|	`ISC-2026-Martinez-Ourthe-Cabale/module-security-groups`|git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-security-groups.git	|SG para ALB, EC2 y RDS|
|`scripts`|	`ISC-2026-Martinez-Ourthe-Cabale/scripts`|git::ssh://git@github.com/ISC-2026-Martinez-Ourthe-Cabale/module-security-groups.git|Scripts de ejecución manual|

> Los módulos se referencian vía SSH (`git::ssh://git@github.com/...`). Requieren acceso SSH configurado con permisos a la organización.
---
## <span id="requisitos"></span>Requisitos y dependencias
|Herramienta|Versión mínima recomendada|Instalación|
|-----------|--------------------------|-----------|
|Terraform|	`>= 1.3.0`|	terraform.io/downloads|
|AWS CLI|	`>= 2.0`|	aws.amazon.com/cli|
|Git	|`>= 2.30`	|git-scm.com|
|SSH	Cualquier versión moderna	Incluido en Linux/macOS; en Windows usar OpenSSH o PuTTY


## <span id="credenciales"></span>Credenciales y accesos necesarios

|Requisito|	Detalle|
|---------|--------|
|Cuenta AWS|Con permisos suficientes para crear VPC, EC2, RDS, S3, ALB, IAM, etc.|
|AWS credentials|Configuradas vía `aws configure`, variables de entorno, o perfil de instancia|
|Clave SSH en GitHub|	Para que Terraform pueda clonar los módulos vía `git::ssh://`|
|GitLab Token|	Token de despliegue para pull de la imagen Docker (`registry.gitlab.com/mourthecabalediaz/app:1.0`)|
|IAM Instance Profile|	`LabInstanceProfile` debe existir en la cuenta AWS antes del despliegue|
|Permisos AWS necesarios (mínimos)|El usuario o rol que ejecute Terraform debe tener permisos para gestionar: `ec2:*`, `rds:*`, `elasticloadbalancing:*`, `autoscaling:*`, `s3:*`, `iam:PassRole` (para el Instance Profile).|
---
## <span id="estructura"></span>Estructura del repositorio
Obligatorio_ISC_2026_N5A_Martinez_Ourthe_Cabale/
├── terraform/
│   ├── main.tf           # Orquestación de todos los módulos
│   ├── variables.tf      # Declaración de variables de entrada
│   ├── outputs.tf        # Outputs (ALB DNS)
│   ├── terraform.tfvars  # Valores concretos (NO commitear si tiene secretos)
│   └── providers.tf      # Configuración del provider AWS (si existe)
├── .gitignore
├── LICENSE
└── README.md
```
> **Nota:** El directorio `terraform/` contiene el código HCL principal. Todos los comandos deben ejecutarse desde dentro de ese directorio.
---
## <span id="instructivo"></span>Instructivo de uso
1. Clonar el repositorio
```bash
git clone git@github.com:mariourthecabale/Obligatorio_ISC_2026_N5A_Martinez_Ourthe_Cabale.git
cd Obligatorio_ISC_2026_N5A_Martinez_Ourthe_Cabale/terraform
```
2. Configurar credenciales AWS
```bash
aws configure
# Ingresar: AWS Access Key ID, Secret Access Key, región (ej: us-east-1) y formato (json)
```
O bien, si se trabaja en un entorno con roles de instancia/Lab, las credenciales ya están disponibles.
3. Configurar la clave SSH para GitHub
Asegurarse de que la clave SSH esté registrada en GitHub y agregada al agente SSH:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa   # o la clave correspondiente
ssh -T git@github.com   # verificar acceso
```
4. Crear el archivo de variables
Crear un archivo `terraform.tfvars` en el directorio `terraform/` con todos los valores requeridos:
```hcl
# Región y zonas de disponibilidad
aws_region   = "us-east-1"
vpc_aws_az   = "us-east-1a"
vpc_aws_az_2 = "us-east-1b"

# Red
vpc_cidr             = "10.0.0.0/16"
public_subnet        = "10.0.1.0/24"
public_subnet_2      = "10.0.2.0/24"
private_subnet_APP   = "10.0.10.0/24"
private_subnet_APP_2 = "10.0.11.0/24"
private_subnet_DB    = "10.0.20.0/24"
private_subnet_DB_2  = "10.0.21.0/24"

# Cómputo
ami         = "ami-XXXXXXXXXXXXXXXXX"   # Amazon Linux 2023 en us-east-1

# Base de datos
db_username = "admin"
db_password = "SuperSecreta123!"       # ¡Usar un valor seguro!
db_name     = "ecommerce"

# ALB
alb_name              = "obligatorio-alb"
listener_port         = 80
listener_protocol     = "HTTP"
target_group_port     = 80
target_group_protocol = "HTTP"

health_check_enabled             = true
health_check_path                = "/"
health_check_protocol            = "HTTP"
health_check_matcher             = "200"
health_check_interval            = 30
health_check_timeout             = 5
health_check_healthy_threshold   = 2
health_check_unhealthy_threshold = 3

# S3
bucket_name = "obligatorio-backup-XXXX"   # debe ser globalmente único

# GitLab
gitlab_token = "gldt-XXXXXXXXXXXX"         # Deploy token de GitLab
```
> ⚠️ **No commitear `terraform.tfvars` si contiene contraseñas o tokens.** Agregar al `.gitignore`.
5. Inicializar Terraform
Este paso descarga los módulos desde GitHub vía SSH:
```bash
terraform init
```
Si hay errores de clonación de módulos, verificar que la clave SSH tenga acceso a la organización `ISC-2026-Martinez-Ourthe-Cabale`.
6. Revisar el plan de ejecución
```bash
terraform plan
```
Revisar la salida para confirmar los recursos que se crearán antes de aplicar.
7. Aplicar la infraestructura
```bash
terraform apply
```
Escribir `yes` cuando se solicite confirmación. El proceso tarda aproximadamente 10–15 minutos (la creación de RDS y el NAT Gateway son los recursos más lentos).
8. Obtener el DNS del ALB
Al finalizar, Terraform mostrará el DNS público del ALB:
```
Outputs:
alb_dns_name = "obligatorio-alb-XXXXXXXXXX.us-east-1.elb.amazonaws.com"
```
Acceder a esa URL desde el navegador para verificar que la aplicación responde.
9. Destruir la infraestructura
Cuando ya no se necesite el entorno:
```bash
terraform destroy
```
> ⚠️ Esto eliminará **todos** los recursos creados, incluyendo la base de datos. Si `skip_final_snapshot = false`, se creará un snapshot de RDS antes de borrar.
---
## <span id="variables"></span>Variables

| Variable | Tipo | Requerida | Default | Descripción |
|-----------|------|:---------:|---------|-------------|
| `aws_region` | `string` | ✅ | — | Región AWS donde desplegar |
| `vpc_cidr` | `string` | ✅ | — | CIDR block de la VPC |
| `vpc_aws_az` | `string` | ✅ | — | Primera Availability Zone |
| `vpc_aws_az_2` | `string` | ✅ | — | Segunda Availability Zone |
| `public_subnet` | `string` | ✅ | — | CIDR subnet pública AZ1 |
| `public_subnet_2` | `string` | ✅ | — | CIDR subnet pública AZ2 |
| `private_subnet_APP` | `string` | ✅ | — | CIDR subnet privada APP AZ1 |
| `private_subnet_APP_2` | `string` | ✅ | — | CIDR subnet privada APP AZ2 |
| `private_subnet_DB` | `string` | ✅ | — | CIDR subnet privada DB AZ1 |
| `private_subnet_DB_2` | `string` | ✅ | — | CIDR subnet privada DB AZ2 |
| `ami` | `string` | ✅ | — | ID de la AMI para las instancias EC2 |
| `project_name` | `string` | ❌ | `"Obligatorio"` | Nombre del proyecto para tags |
| `alb_name` | `string` | ✅ | — | Nombre del ALB |
| `alb_ingress_cidr_blocks` | `list(string)` | ❌ | `["0.0.0.0/0"]` | CIDRs permitidos al ALB |
| `alb_ingress_port` | `number` | ❌ | `80` | Puerto de ingreso al ALB |
| `alb_ingress_protocol` | `string` | ❌ | `"tcp"` | Protocolo de ingreso al ALB |
| `listener_port` | `number` | ✅ | — | Puerto del Listener del ALB |
| `listener_protocol` | `string` | ✅ | — | Protocolo del Listener |
| `target_group_port` | `number` | ✅ | — | Puerto del Target Group |
| `target_group_protocol` | `string` | ✅ | — | Protocolo del Target Group |
| `health_check_enabled` | `bool` | ✅ | — | Habilitar health check |
| `health_check_path` | `string` | ✅ | — | Path del health check |
| `health_check_protocol` | `string` | ✅ | — | Protocolo del health check |
| `health_check_matcher` | `string` | ✅ | — | Código HTTP esperado |
| `health_check_interval` | `number` | ✅ | — | Intervalo entre checks (seg) |
| `health_check_timeout` | `number` | ✅ | — | Timeout del check (seg) |
| `health_check_healthy_threshold` | `number` | ✅ | — | Chequeos OK para marcar healthy |
| `health_check_unhealthy_threshold` | `number` | ✅ | — | Chequeos fallidos para unhealthy |
| `app_port` | `number` | ❌ | `80` | Puerto de la aplicación en EC2 |
| `db_engine` | `string` | ❌ | `"mysql"` | Motor de base de datos |
| `db_engine_version` | `string` | ❌ | `"8.0"` | Versión del motor |
| `db_instance_class` | `string` | ❌ | `"db.t3.micro"` | Tipo de instancia RDS |
| `db_name` | `string` | ❌ | `"ecommerce"` | Nombre de la base de datos |
| `db_username` | `string` | ✅ | — | Usuario admin de la DB |
| `db_password` | `string` | ✅ | — | Contraseña admin de la DB |
| `db_port` | `number` | ❌ | `3306` | Puerto de la DB |
| `allocated_storage` | `number` | ❌ | `20` | Storage inicial en GB |
| `max_allocated_storage` | `number` | ❌ | `100` | Storage máximo en GB |
| `storage_type` | `string` | ❌ | `"gp3"` | Tipo de almacenamiento |
| `backup_retention_period` | `number` | ❌ | `7` | Días de retención de backups |
| `backup_window` | `string` | ❌ | `"03:00-04:00"` | Ventana de backup |
| `maintenance_window` | `string` | ❌ | `"sun:04:00-sun:05:00"` | Ventana de mantenimiento |
| `multi_az` | `bool` | ❌ | `false` | Habilitar RDS Multi-AZ |
| `skip_final_snapshot` | `bool` | ❌ | `false` | Omitir snapshot al destruir |
| `deletion_protection` | `bool` | ❌ | `false` | Proteger DB contra borrado |
| `bucket_name` | `string` | ✅ | — | Nombre del bucket S3 |
| `gitlab_token` | `any` | ✅ | — | Token de despliegue de GitLab |
---

## <span id="outputs"></span> Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS público del Application Load Balancer |


## <span id="condiciones"></span>Consideraciones de seguridad

#### Secretos: Las variables `db_password` y `gitlab_token` son sensibles. No commitearlas en texto plano.
#### State file: El estado de Terraform (`terraform.tfstate`) contiene valores sensibles. Configurar un backend remoto (ej: S3 + DynamoDB) para entornos compartidos.
#### RDS no público: La base de datos no tiene acceso público. El único acceso es desde las instancias EC2 del ASG.
#### NAT Gateway por AZ: Cada AZ tiene su propio NAT Gateway, garantizando que la salida a Internet de las instancias privadas no dependa de una única AZ.
#### Cifrado RDS: El almacenamiento de la base de datos está cifrado en reposo (`storage_encrypted = true`).

---
Proyecto Obligatorio — ISC 2026 — N5A | Martínez, Ourthe-Cabalé